-- CreateTable
CREATE TABLE "Producto" (
    "id" SERIAL NOT NULL,
    "nombreProducto" TEXT NOT NULL,
    "categoria" TEXT NOT NULL,
    "precioProducto" DOUBLE PRECISION NOT NULL,
    "stockProducto" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Producto_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Producto_nombreProducto_key" ON "Producto"("nombreProducto");
