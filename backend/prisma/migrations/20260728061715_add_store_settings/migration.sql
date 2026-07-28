-- CreateTable
CREATE TABLE "StoreSettings" (
    "id" TEXT NOT NULL,
    "standardDeliveryLabel" TEXT NOT NULL DEFAULT 'Standard Delivery',
    "standardDeliveryDays" TEXT NOT NULL DEFAULT '3-5 days',
    "standardDeliveryPrice" INTEGER NOT NULL DEFAULT 150,
    "expressDeliveryLabel" TEXT NOT NULL DEFAULT 'Express Delivery',
    "expressDeliveryDays" TEXT NOT NULL DEFAULT '1-2 days',
    "expressDeliveryPrice" INTEGER NOT NULL DEFAULT 300,
    "taxRatePercent" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StoreSettings_pkey" PRIMARY KEY ("id")
);
