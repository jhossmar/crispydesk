-- CreateTable
CREATE TABLE "Gasto" (
    "id" SERIAL NOT NULL,
    "fecha" TIMESTAMP(3) NOT NULL,
    "categoria" TEXT NOT NULL,
    "monto" DOUBLE PRECISION NOT NULL,
    "descripcion" TEXT,
    "registradoPorId" INTEGER NOT NULL,
    "registradoPorNombre" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Gasto_pkey" PRIMARY KEY ("id")
);
