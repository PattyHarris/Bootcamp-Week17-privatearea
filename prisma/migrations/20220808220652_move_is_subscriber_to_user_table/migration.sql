/*
  Warnings:

  - You are about to drop the column `isSubscriber` on the `Session` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Session" DROP COLUMN "isSubscriber";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "isSubscriber" BOOLEAN NOT NULL DEFAULT false;
