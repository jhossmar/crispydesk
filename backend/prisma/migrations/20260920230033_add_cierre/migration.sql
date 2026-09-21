-- CreateTable
CREATE TABLE "Cierre" (
    "id" SERIAL NOT NULL,
    "fechaInicio" TIMESTAMP(3) NOT NULL,
    "fechaCierre" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cantidadVentas" INTEGER NOT NULL,
    "totalEfectivo" DOUBLE PRECISION NOT NULL,
    "totalQr" DOUBLE PRECISION NOT NULL,
    "totalGeneral" DOUBLE PRECISION NOT NULL,
    "cerradoPorId" INTEGER NOT NULL,
    "cerradoPorNombre" TEXT NOT NULL,

    CONSTRAINT "Cierre_pkey" PRIMARY KEY ("id")
);
