import "dotenv/config";
import bcrypt from "bcryptjs";
import express, { NextFunction, Request, Response } from "express";
import cors from "cors";
import jwt from "jsonwebtoken";
import { PrismaClient, Prisma, Rol } from "@prisma/client";

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

// Edits a user's nombreCompleto/email/rol. Password changes are a separate
// concern, not handled here.
app.patch("/users/:id", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { email, nombreCompleto, rol } = req.body || {};

  if (!email && !nombreCompleto && !rol) {
    return res.status(400).json({ message: "Nothing to update" });
  }
  if (rol && rol !== "ADMINISTRADOR" && rol !== "CAJERA") {
    return res.status(400).json({ message: "rol must be ADMINISTRADOR or CAJERA" });
  }

  try {
    const usuario = await prisma.user.update({
      where: { id },
      data: {
        ...(email ? { email } : {}),
        ...(nombreCompleto ? { nombreCompleto } : {}),
        ...(rol ? { rol } : {}),
      },
      select: { id: true, email: true, nombreCompleto: true, rol: true, activo: true },
    });
    return res.json(usuario);
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      return res.status(409).json({ message: "Ese email ya está en uso" });
    }
    return res.status(404).json({ message: "User not found" });
  }
});

// Two cases in one endpoint:
// - A user changing their OWN password: must provide passwordActual, which
//   is verified against the stored hash.
// - An Administrador resetting ANY user's password (e.g. a locked-out
//   Cajera): no passwordActual needed, admin override.
app.patch("/users/:id/password", authenticateToken, async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { passwordActual, passwordNueva } = req.body || {};

  if (!passwordNueva || String(passwordNueva).length < 4) {
    return res.status(400).json({ message: "passwordNueva debe tener al menos 4 caracteres" });
  }

  const esUnoMismo = req.user!.id === id;
  const esAdmin = req.user!.rol === "ADMINISTRADOR";
  if (!esUnoMismo && !esAdmin) {
    return res.status(403).json({ message: "No autorizado para cambiar esta contraseña" });
  }

  try {
    const usuario = await prisma.user.findUniqueOrThrow({ where: { id } });

    if (esUnoMismo) {
      if (!passwordActual) {
        return res.status(400).json({ message: "passwordActual is required" });
      }
      const coincide = await bcrypt.compare(passwordActual, usuario.password);
      if (!coincide) {
        return res.status(401).json({ message: "La contraseña actual no coincide" });
      }
    }

    const hashedPassword = await bcrypt.hash(passwordNueva, 10);
    await prisma.user.update({ where: { id }, data: { password: hashedPassword } });
    return res.status(204).send();
  } catch (error) {
    return res.status(404).json({ message: "Usuario no encontrado" });
  }
});

app.get("/users", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const usuarios = await prisma.user.findMany({
    select: { id: true, email: true, nombreCompleto: true, rol: true, activo: true },
    orderBy: { id: "asc" },
  });
  res.json(usuarios);
});

// Activates/deactivates a user. We never hard-delete accounts so their
// sales/audit history (once that exists) always stays attributable.
app.patch("/users/:id/activo", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { activo } = req.body || {};

  if (typeof activo !== "boolean") {
    return res.status(400).json({ message: "activo must be a boolean" });
  }

  try {
    const usuario = await prisma.user.update({
      where: { id },
      data: { activo },
      select: { id: true, email: true, nombreCompleto: true, rol: true, activo: true },
    });
    return res.json(usuario);
  } catch (error) {
    return res.status(404).json({ message: "User not found" });
  }
});

// ==========================================
//  PRODUCTOS
// ==========================================
// Any authenticated user (Administrador or Cajera) can list products - the
// Cajera needs this to sell. Mutations are admin-only, matching the
// Flutter app's menu (Productos is an admin-only screen).

app.get("/productos", authenticateToken, async (req: Request, res: Response) => {
  const productos = await prisma.producto.findMany({
    orderBy: { nombreProducto: "asc" },
  });
  res.json(productos);
});

app.post("/productos", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const { nombreProducto, categoria, precioProducto, stockProducto } = req.body || {};

  if (!nombreProducto || !categoria || precioProducto == null) {
    return res
      .status(400)
      .json({ message: "nombreProducto, categoria and precioProducto are required" });
  }

  try {
    const producto = await prisma.producto.create({
      data: {
        nombreProducto,
        categoria,
        precioProducto,
        stockProducto: stockProducto ?? 0,
      },
    });
    return res.status(201).json(producto);
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      return res.status(409).json({ message: "Ya existe un producto con ese nombre" });
    }
    return res.status(500).json({ message: "No se pudo crear el producto" });
  }
});

// Edits only the master data (nombre/categoria/precio). Stock is handled
// exclusively by /productos/:id/stock so editing details never touches
// inventory by accident.
app.patch("/productos/:id", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { nombreProducto, categoria, precioProducto } = req.body || {};

  if (!nombreProducto && !categoria && precioProducto == null) {
    return res.status(400).json({ message: "Nothing to update" });
  }

  try {
    const producto = await prisma.producto.update({
      where: { id },
      data: {
        ...(nombreProducto ? { nombreProducto } : {}),
        ...(categoria ? { categoria } : {}),
        ...(precioProducto != null ? { precioProducto } : {}),
      },
    });
    return res.json(producto);
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      return res.status(409).json({ message: "Ya existe un producto con ese nombre" });
    }
    return res.status(404).json({ message: "Producto no encontrado" });
  }
});

// Adjusts stock by a signed delta (positive = entrada, negative = salida),
// matching ajustarStock() from the original sqflite helper.
app.patch(
  "/productos/:id/stock",
  authenticateToken,
  requireAdmin,
  async (req: Request, res: Response) => {
    const id = Number(req.params.id);
    const { delta } = req.body || {};

    if (typeof delta !== "number" || !Number.isFinite(delta)) {
      return res.status(400).json({ message: "delta must be a number" });
    }

    try {
      const actual = await prisma.producto.findUniqueOrThrow({ where: { id } });
      if (actual.stockProducto + delta < 0) {
        return res.status(400).json({ message: "Stock insuficiente" });
      }

      const producto = await prisma.producto.update({
        where: { id },
        data: { stockProducto: { increment: delta } },
      });
      return res.json(producto);
    } catch (error) {
      return res.status(404).json({ message: "Producto no encontrado" });
    }
  },
);

app.delete("/productos/:id", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const id = Number(req.params.id);

  try {
    await prisma.producto.delete({ where: { id } });
    return res.status(204).send();
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
      return res.status(404).json({ message: "Producto no encontrado" });
    }
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2003") {
      return res
        .status(409)
        .json({ message: "No se puede eliminar: este producto tiene ventas registradas" });
    }
    return res.status(500).json({ message: "No se pudo eliminar el producto" });
  }
});

// ==========================================
//  VENTAS
// ==========================================
// Any authenticated user (Cajera or Administrador) can sell and view sales.

// Creates a sale atomically: validates stock for every item first, then
// decrements stock and inserts the venta + detalles in one transaction, so
// a failure partway through never leaves stock/records inconsistent.
// Prices are read from the current Producto record server-side (not trusted
// from the client) so a stale/tampered price can't be submitted.
app.post("/ventas", authenticateToken, async (req: Request, res: Response) => {
  const { items, formaPago, montoEfectivo, montoQr } = req.body || {};

  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: "items must be a non-empty array" });
  }
  for (const item of items) {
    if (!item?.productoId || !item?.cantidad || item.cantidad <= 0) {
      return res
        .status(400)
        .json({ message: "Each item needs a productoId and a positive cantidad" });
    }
  }
  if (formaPago !== "EFECTIVO" && formaPago !== "QR" && formaPago !== "MIXTO") {
    return res.status(400).json({ message: "formaPago must be EFECTIVO, QR or MIXTO" });
  }
  const efectivo = Number(montoEfectivo) || 0;
  const qr = Number(montoQr) || 0;
  if (efectivo < 0 || qr < 0) {
    return res.status(400).json({ message: "montoEfectivo/montoQr must not be negative" });
  }

  try {
    const venta = await prisma.$transaction(async (tx) => {
      let total = 0;
      const detallesData: {
        productoId: number;
        nombreProducto: string;
        cantidad: number;
        precioUnitario: number;
        subtotal: number;
        nota?: string;
      }[] = [];

      for (const item of items) {
        const producto = await tx.producto.findUniqueOrThrow({
          where: { id: item.productoId },
        });
        if (producto.stockProducto < item.cantidad) {
          throw new Error(`STOCK_INSUFICIENTE:${producto.nombreProducto}`);
        }

        const subtotal = producto.precioProducto * item.cantidad;
        total += subtotal;
        detallesData.push({
          productoId: producto.id,
          nombreProducto: producto.nombreProducto,
          cantidad: item.cantidad,
          precioUnitario: producto.precioProducto,
          subtotal,
          nota: typeof item.nota === "string" && item.nota.trim() ? item.nota.trim() : undefined,
        });

        await tx.producto.update({
          where: { id: producto.id },
          data: { stockProducto: { decrement: item.cantidad } },
        });
      }

      if (efectivo + qr < total) {
        throw new Error("PAGO_INSUFICIENTE");
      }

      return tx.venta.create({
        data: {
          totalVenta: total,
          formaPago,
          montoEfectivo: efectivo,
          montoQr: qr,
          detalles: { create: detallesData },
        },
        include: { detalles: true },
      });
    });

    return res.status(201).json(venta);
  } catch (error) {
    if (error instanceof Error && error.message.startsWith("STOCK_INSUFICIENTE:")) {
      const nombre = error.message.split(":")[1];
      return res.status(400).json({ message: `Stock insuficiente de ${nombre}` });
    }
    if (error instanceof Error && error.message === "PAGO_INSUFICIENTE") {
      return res.status(400).json({ message: "El monto pagado no cubre el total de la venta" });
    }
    return res.status(500).json({ message: "No se pudo registrar la venta" });
  }
});

app.get("/ventas", authenticateToken, async (req: Request, res: Response) => {
  const ventas = await prisma.venta.findMany({ orderBy: { id: "desc" } });
  res.json(ventas);
});

app.get("/ventas/:id/detalles", authenticateToken, async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const detalles = await prisma.detalleVenta.findMany({ where: { ventaId: id } });
  res.json(detalles);
});

// Deletes a sale and restores the stock it had consumed, in one transaction.
app.delete("/ventas/:id", authenticateToken, async (req: Request, res: Response) => {
  const id = Number(req.params.id);

  try {
    await prisma.$transaction(async (tx) => {
      const detalles = await tx.detalleVenta.findMany({ where: { ventaId: id } });
      for (const detalle of detalles) {
        await tx.producto.update({
          where: { id: detalle.productoId },
          data: { stockProducto: { increment: detalle.cantidad } },
        });
      }
      await tx.venta.delete({ where: { id } });
    });
    return res.status(204).send();
  } catch (error) {
    return res.status(404).json({ message: "Venta no encontrada" });
  }
});

// ==========================================
//  ESTADÍSTICAS Y REPORTES
// ==========================================

function inicioDeDia(fecha: Date): Date {
  return new Date(fecha.getFullYear(), fecha.getMonth(), fecha.getDate(), 0, 0, 0, 0);
}

function finDeDia(fecha: Date): Date {
  return new Date(fecha.getFullYear(), fecha.getMonth(), fecha.getDate(), 23, 59, 59, 999);
}

function claveDia(fecha: Date): string {
  const anio = fecha.getFullYear();
  const mes = String(fecha.getMonth() + 1).padStart(2, "0");
  const dia = String(fecha.getDate()).padStart(2, "0");
  return `${anio}-${mes}-${dia}`;
}

// "YYYY-MM-DD" query params represent a local calendar date, not a UTC
// instant. Parsing them with `new Date(string)` would interpret them as UTC
// midnight, which can land on the previous local day west of UTC (bit us in
// testing: server runs in America/La_Paz, UTC-4).
function parsearFechaLocal(fechaYYYYMMDD: string): Date {
  const [anio, mes, dia] = fechaYYYYMMDD.split("-").map(Number);
  return new Date(anio, mes - 1, dia);
}

// Same local-date reasoning as parsearFechaLocal, for "YYYY-MM" month params.
function inicioDeMes(mesYYYYMM: string): Date {
  const [anio, mes] = mesYYYYMM.split("-").map(Number);
  return new Date(anio, mes - 1, 1, 0, 0, 0, 0);
}

function finDeMes(mesYYYYMM: string): Date {
  const [anio, mes] = mesYYYYMM.split("-").map(Number);
  return new Date(anio, mes, 0, 23, 59, 59, 999); // day 0 of next month = last day of this one
}

app.get("/estadisticas", authenticateToken, async (req: Request, res: Response) => {
  const hoy = new Date();

  const [resumenHoy, resumenHistorico, rankingGrupos] = await Promise.all([
    prisma.venta.aggregate({
      where: { fechaVenta: { gte: inicioDeDia(hoy), lte: finDeDia(hoy) } },
      _sum: { totalVenta: true },
      _count: true,
    }),
    prisma.venta.aggregate({ _sum: { totalVenta: true } }),
    prisma.detalleVenta.groupBy({
      by: ["nombreProducto"],
      _sum: { cantidad: true, subtotal: true },
      orderBy: { _sum: { cantidad: "desc" } },
    }),
  ]);

  res.json({
    totalHoy: resumenHoy._sum.totalVenta ?? 0,
    cantidadHoy: resumenHoy._count,
    totalHistorico: resumenHistorico._sum.totalVenta ?? 0,
    ranking: rankingGrupos.map((g) => ({
      nombreProducto: g.nombreProducto,
      totalUnidades: g._sum.cantidad ?? 0,
      totalIngreso: g._sum.subtotal ?? 0,
    })),
  });
});

// Combines what used to be four separate queries (resumen, desglose diario,
// ranking, listado) into one call for a date range.
app.get("/reportes", authenticateToken, async (req: Request, res: Response) => {
  const desdeParam = req.query.desde as string | undefined;
  const hastaParam = req.query.hasta as string | undefined;

  if (!desdeParam || !hastaParam) {
    return res
      .status(400)
      .json({ message: "desde and hasta query params are required (YYYY-MM-DD)" });
  }

  const desde = inicioDeDia(parsearFechaLocal(desdeParam));
  const hasta = finDeDia(parsearFechaLocal(hastaParam));

  const [ventas, rankingGrupos] = await Promise.all([
    prisma.venta.findMany({
      where: { fechaVenta: { gte: desde, lte: hasta } },
      orderBy: { id: "desc" },
    }),
    prisma.detalleVenta.groupBy({
      where: { venta: { fechaVenta: { gte: desde, lte: hasta } } },
      by: ["nombreProducto"],
      _sum: { cantidad: true, subtotal: true },
      orderBy: { _sum: { cantidad: "desc" } },
    }),
  ]);

  const cantidad = ventas.length;
  const total = ventas.reduce((sum, v) => sum + v.totalVenta, 0);

  const porDia = new Map<string, { cantidad: number; total: number }>();
  for (const venta of ventas) {
    const clave = claveDia(venta.fechaVenta);
    const actual = porDia.get(clave) ?? { cantidad: 0, total: 0 };
    actual.cantidad += 1;
    actual.total += venta.totalVenta;
    porDia.set(clave, actual);
  }
  const diario = Array.from(porDia.entries())
    .map(([dia, valores]) => ({ dia, ...valores }))
    .sort((a, b) => (a.dia < b.dia ? 1 : -1));

  res.json({
    resumen: { cantidad, total },
    diario,
    ranking: rankingGrupos.map((g) => ({
      nombreProducto: g.nombreProducto,
      totalUnidades: g._sum.cantidad ?? 0,
      totalIngreso: g._sum.subtotal ?? 0,
    })),
    ventas,
  });
});

// ==========================================
//  CIERRE DE CAJA
// ==========================================

// Cash actually retained per sale is total minus whatever portion was paid
// by QR (capped at the sale total, in case of an overpayment typo) - NOT
// the raw amount the customer handed over, which can exceed the total when
// they pay with a bigger bill and get change back.
function totalesPago(ventas: { totalVenta: number; formaPago: string; montoQr: number }[]) {
  let totalEfectivo = 0;
  let totalQr = 0;
  for (const venta of ventas) {
    const qr = venta.formaPago !== "EFECTIVO" ? Math.min(venta.montoQr, venta.totalVenta) : 0;
    totalQr += qr;
    totalEfectivo += venta.totalVenta - qr;
  }
  return { totalEfectivo, totalQr, totalGeneral: totalEfectivo + totalQr };
}

async function calcularPeriodoActual() {
  const ultimoCierre = await prisma.cierre.findFirst({ orderBy: { fechaCierre: "desc" } });
  const fechaInicio = ultimoCierre?.fechaCierre ?? new Date(0);

  const ventas = await prisma.venta.findMany({
    where: { fechaVenta: { gt: fechaInicio } },
    select: { totalVenta: true, formaPago: true, montoQr: true },
  });

  const { totalEfectivo, totalQr, totalGeneral } = totalesPago(ventas);
  return {
    fechaInicio,
    cantidadVentas: ventas.length,
    totalEfectivo,
    totalQr,
    totalGeneral,
  };
}

app.get("/cierre/actual", authenticateToken, async (req: Request, res: Response) => {
  res.json(await calcularPeriodoActual());
});

app.post("/cierre", authenticateToken, async (req: Request, res: Response) => {
  const actual = await calcularPeriodoActual();
  if (actual.cantidadVentas === 0) {
    return res
      .status(400)
      .json({ message: "No hay ventas registradas en este período para cerrar" });
  }

  const cierre = await prisma.cierre.create({
    data: {
      fechaInicio: actual.fechaInicio,
      cantidadVentas: actual.cantidadVentas,
      totalEfectivo: actual.totalEfectivo,
      totalQr: actual.totalQr,
      totalGeneral: actual.totalGeneral,
      cerradoPorId: req.user!.id,
      cerradoPorNombre: req.user!.nombreCompleto,
    },
  });
  res.status(201).json(cierre);
});

app.get("/cierre/historial", authenticateToken, async (req: Request, res: Response) => {
  const historial = await prisma.cierre.findMany({ orderBy: { fechaCierre: "desc" } });
  res.json(historial);
});

// ==========================================
//  GASTOS
// ==========================================
// Admin-only, matching the Flutter app's menu (same as Productos/Usuarios).

app.post("/gastos", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const { fecha, categoria, monto, descripcion } = req.body || {};

  if (!fecha || !categoria || monto == null || Number(monto) <= 0) {
    return res
      .status(400)
      .json({ message: "fecha, categoria y monto (mayor a 0) son requeridos" });
  }

  const gasto = await prisma.gasto.create({
    data: {
      fecha: parsearFechaLocal(fecha),
      categoria,
      monto: Number(monto),
      descripcion: descripcion || null,
      registradoPorId: req.user!.id,
      registradoPorNombre: req.user!.nombreCompleto,
    },
  });
  return res.status(201).json(gasto);
});

// Combines the month's expense list with its summary (total gastos, total
// ventas, ganancia real, breakdown by category) in one call.
app.get("/gastos", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const mesParam = req.query.mes as string | undefined;
  if (!mesParam) {
    return res.status(400).json({ message: "mes query param is required (YYYY-MM)" });
  }

  const desde = inicioDeMes(mesParam);
  const hasta = finDeMes(mesParam);

  const [gastos, ventasMes] = await Promise.all([
    prisma.gasto.findMany({
      where: { fecha: { gte: desde, lte: hasta } },
      orderBy: { fecha: "desc" },
    }),
    prisma.venta.findMany({
      where: { fechaVenta: { gte: desde, lte: hasta } },
      select: { totalVenta: true },
    }),
  ]);

  const totalGastos = gastos.reduce((sum, g) => sum + g.monto, 0);
  const totalVentasMes = ventasMes.reduce((sum, v) => sum + v.totalVenta, 0);

  const porCategoria = new Map<string, number>();
  for (const g of gastos) {
    porCategoria.set(g.categoria, (porCategoria.get(g.categoria) ?? 0) + g.monto);
  }

  res.json({
    gastos,
    resumen: {
      totalGastos,
      totalVentasMes,
      gananciaReal: totalVentasMes - totalGastos,
      porCategoria: Array.from(porCategoria.entries()).map(([categoria, monto]) => ({
        categoria,
        monto,
      })),
    },
  });
});

app.delete("/gastos/:id", authenticateToken, requireAdmin, async (req: Request, res: Response) => {
  const id = Number(req.params.id);

  try {
    await prisma.gasto.delete({ where: { id } });
    return res.status(204).send();
  } catch (error) {
    return res.status(404).json({ message: "Gasto no encontrado" });
  }
});

app.listen(PORT, () => {
  console.log(`CrispyDesk backend running on http://localhost:${PORT}`);
});

export default app;
