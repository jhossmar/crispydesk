import "dotenv/config";
import bcrypt from "bcryptjs";
import express, { NextFunction, Request, Response } from "express";
import cors from "cors";
import jwt from "jsonwebtoken";
import { PrismaClient, Rol } from "@prisma/client";

const app = express();
const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET was not defined");
}

app.use(cors());
app.use(express.json());

interface AuthPayload {
  id: number;
  email: string;
  rol: Rol;
  nombreCompleto: string;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: AuthPayload;
    }
  }
}

// ==========================================
//  AUTHENTICATION MIDDLEWARE
// ==========================================
const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "No token provided" });
  }

  // Expects format: "Bearer token_string"
  const token = authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Malformed token" });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as AuthPayload;
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ message: "Invalid or expired token" });
  }
};

// Only lets an authenticated Administrador through. Must run after authenticateToken.
const requireAdmin = (req: Request, res: Response, next: NextFunction) => {
  if (req.user?.rol !== "ADMINISTRADOR") {
    return res.status(403).json({ message: "Requiere rol Administrador" });
  }
  next();
};

// ==========================================
//  PUBLIC ROUTES (No token required)
// ==========================================
app.get("/", (req: Request, res: Response) => {
  res.send("CrispyDesk backend is working!");
});

app.get("/health", (req: Request, res: Response) => {
  res.status(200).json({ status: "ok" });
});

app.post("/login", async (req: Request, res: Response) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  try {
    const user = await prisma.user.findUnique({ where: { email } });

    if (user && user.activo) {
      const isMatch = await bcrypt.compare(password, user.password);
      if (isMatch) {
        const payload: AuthPayload = {
          id: user.id,
          email: user.email,
          rol: user.rol,
          nombreCompleto: user.nombreCompleto,
        };
        const token = jwt.sign(payload, JWT_SECRET, { expiresIn: "12h" });
        return res.json({ message: "Login successful", token, user: payload });
      }
    }

    return res.status(401).json({ message: "Invalid credentials" });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error occurred";
    return res.status(500).json({ message: "Internal server error during login", error: errorMessage });
  }
});

// ==========================================
//  PROTECTED ROUTES (Requires token)
// ==========================================
app.get("/profile", authenticateToken, (req: Request, res: Response) => {
  res.json({ user: req.user });
});

// ==========================================
//  ADMIN-ONLY ROUTES
// ==========================================
// Users are provisioned by an Administrador from inside the app,
// not through public self-registration.
app.post("/register", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const { email, password, nombreCompleto, rol } = req.body || {};

  if (!email || !password || !nombreCompleto) {
    return res.status(400).json({ message: "email, password and nombreCompleto are required" });
  }
  if (rol && rol !== "ADMINISTRADOR" && rol !== "CAJERA") {
    return res.status(400).json({ message: "rol must be ADMINISTRADOR or CAJERA" });
  }

  try {
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        nombreCompleto,
        rol: rol ?? "CAJERA",
      },
    });

    return res.status(201).json({
      message: "User registered successfully",
      user: {
        id: newUser.id,
        email: newUser.email,
        nombreCompleto: newUser.nombreCompleto,
        rol: newUser.rol,
      },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error occurred";
    return res.status(500).json({ message: "Internal server error during registration", error: errorMessage });
  }
});

app.listen(PORT, () => {
  console.log(`CrispyDesk backend running on http://localhost:${PORT}`);
});

export default app;
