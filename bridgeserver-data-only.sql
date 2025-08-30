-- Data import for PostgreSQL (converted from SQLite)
-- Generated on 2025-08-28 17:37:56
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- Temporarily disable foreign key checks for data import
SET session_replication_role = replica;

INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'3f68b718f56d96df3eebb3b7ef25b3d5a81fa40b097eccf9f9a457fe460f9fa5','2025-04-17 14:12:06');
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'c134185762599fee149f514b656ff8a3fe3e34f4dc3d9ac8a15796828a651e65','2025-04-18 17:37:58');
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'10994a841ba3a2ef998bea3e2e0ed3119d450d30f0fa1577ccf24683f68fb358','2025-04-21 17:46:31');
INSERT INTO "__drizzle_migrations" VALUES(TRUE,'','2025-06-18 12:37:32');
INSERT INTO "devices" VALUES('cam-E6B4','auto:cam-E6B4','0.0.0.0','unknown','','online','camera','2025-08-28 15:37:10','2025-07-27 13:14:55','2025-08-28 15:37:10',NULL,NULL,NULL,'Camera cam-E6B4','Auto-registered camera from controller raspberr-mb8b9trx-e45f','{"autoRegistered":true,"registeredAt":"2025-07-27T16:14:55.927Z","parentController":"raspberr-mb8b9trx-e45f"}');
INSERT INTO "devices" VALUES('cam-0A24','auto:cam-0A24','0.0.0.0','unknown','','online','camera','2025-08-28 14:58:40','2025-07-28 14:31:07','2025-08-28 14:58:40',NULL,NULL,NULL,'Camera cam-0A24','Auto-registered camera from controller raspberr-mb8b9trx-e45f','{"autoRegistered":true,"registeredAt":"2025-07-28T17:31:07.467Z","parentController":"raspberr-mb8b9trx-e45f"}');
INSERT INTO "controllers" VALUES('raspberr-mb8b9trx-e45f','DelicasaPi-Kitchen-001','Kitchen Area',NULL,NULL,'192.168.1.124','https://pi-api.delicasa.workers.dev','vending_machine','cloudflare_tunnel','online','["door_control","image_capture","ping"]','linux/arm64','{"deploymentTime":"2025-08-28T18:55:55+01:00"}',''2025-08-27 16:25:27'.ze45gmo25.6165e7f8','2025-08-28 15:37:13','2025-07-27 13:14:25','2025-08-28 15:37:13','e4:5f:01:15:cd:36',NULL,NULL,NULL);

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;
