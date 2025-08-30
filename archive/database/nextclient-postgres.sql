-- Converted from SQLite to PostgreSQL
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;


CREATE TABLE IF NOT EXISTS "__drizzle_migrations" (
			id SERIAL PRIMARY KEY,
			hash TEXT NOT NULL,
			created_at NUMERIC
		);
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'8c071da48029ad628d380d6a8fef3ce8cb46389b9f150c318b5197b857e163eb',1750254655598);
CREATE TABLE "payment_methods" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"user_id" TEXT NOT NULL,
	"stripe_payment_method_id" TEXT NOT NULL,
	"type" TEXT NOT NULL,
	"brand" TEXT,
	"last_four" TEXT,
	"expiry_month" INTEGER,
	"expiry_year" INTEGER,
	"is_default" INTEGER DEFAULT FALSE NOT NULL,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE "payments" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"user_id" TEXT NOT NULL,
	"session_id" TEXT,
	"payment_method_id" TEXT,
	"stripe_payment_intent_id" TEXT,
	"amount" REAL NOT NULL,
	"currency" TEXT DEFAULT 'USD' NOT NULL,
	"status" TEXT DEFAULT 'pending' NOT NULL,
	"description" TEXT,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("payment_method_id") REFERENCES ""payment_methods""(""id"") ON UPDATE no action ON DELETE no action
);
CREATE TABLE "users" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"email" TEXT NOT NULL,
	"role" TEXT DEFAULT 'USER' NOT NULL,
	"external_id" TEXT,
	"phone_number" TEXT,
	"is_active" INTEGER DEFAULT 1 NOT NULL,
	"last_login_at" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE d1_migrations(
		id         SERIAL PRIMARY KEY,
		name       TEXT UNIQUE,
		applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE "controllers" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"location" TEXT NOT NULL,
	"status" TEXT DEFAULT 'offline' NOT NULL,
	"ip_address" TEXT,
	"mac_address" TEXT,
	"firmware_version" TEXT,
	"capabilities" TEXT,
	"max_devices" INTEGER DEFAULT 10 NOT NULL,
	"current_devices" INTEGER DEFAULT 0 NOT NULL,
	"last_seen" INTEGER,
	"last_heartbeat" INTEGER,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE "cameras" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"controller_id" TEXT NOT NULL,
	"device_id" TEXT,
	"name" TEXT NOT NULL,
	"type" TEXT DEFAULT 'esp32-cam' NOT NULL,
	"status" TEXT DEFAULT 'offline' NOT NULL,
	"resolution" TEXT DEFAULT '640x480',
	"frame_rate" INTEGER DEFAULT 10,
	"stream_url" TEXT,
	"recording_enabled" INTEGER DEFAULT 0,
	"motion_detection" INTEGER DEFAULT 1,
	"last_image" TEXT,
	"last_capture" INTEGER,
	"total_captures" INTEGER DEFAULT 0,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE "captured_images" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"camera_id" TEXT NOT NULL,
	"controller_id" TEXT NOT NULL,
	"device_id" TEXT,
	"filename" TEXT NOT NULL,
	"url" TEXT,
	"local_path" TEXT,
	"size" INTEGER,
	"width" INTEGER,
	"height" INTEGER,
	"format" TEXT DEFAULT 'jpeg',
	"capture_type" TEXT DEFAULT 'manual',
	"metadata" TEXT,
	"is_processed" INTEGER DEFAULT 0,
	"processed_at" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
DELETE FROM sqlite_sequence;
CREATE INDEX "payment_methods_user_idx" ON "payment_methods" ("user_id");
CREATE INDEX "payment_methods_stripe_idx" ON "payment_methods" ("stripe_payment_method_id");
CREATE INDEX "payments_user_idx" ON "payments" ("user_id");
CREATE INDEX "payments_status_idx" ON "payments" ("status");
CREATE INDEX "payments_stripe_id_idx" ON "payments" ("stripe_payment_intent_id");
CREATE INDEX "users_external_id_idx" ON "users" ("external_id");
CREATE INDEX "users_role_idx" ON "users" ("role");
CREATE INDEX "users_email_idx" ON "users" ("email");
CREATE UNIQUE INDEX "users_email_unique" ON "users" ("email");
CREATE INDEX "controllers_status_idx" ON "controllers" ("status");
CREATE INDEX "controllers_location_idx" ON "controllers" ("location");
CREATE INDEX "controllers_last_seen_idx" ON "controllers" ("last_seen");
CREATE INDEX "controllers_mac_address_idx" ON "controllers" ("mac_address");
CREATE INDEX "cameras_controller_idx" ON "cameras" ("controller_id");
CREATE INDEX "cameras_device_idx" ON "cameras" ("device_id");
CREATE INDEX "cameras_status_idx" ON "cameras" ("status");
CREATE INDEX "cameras_last_capture_idx" ON "cameras" ("last_capture");
CREATE INDEX "captured_images_camera_idx" ON "captured_images" ("camera_id");
CREATE INDEX "captured_images_controller_idx" ON "captured_images" ("controller_id");
CREATE INDEX "captured_images_device_idx" ON "captured_images" ("device_id");
CREATE INDEX "captured_images_capture_type_idx" ON "captured_images" ("capture_type");
CREATE INDEX "captured_images_created_at_idx" ON "captured_images" ("created_at");
