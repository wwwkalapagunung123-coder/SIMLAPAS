PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nip TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        blok TEXT
      );
INSERT INTO users VALUES(1,'hitam','1234','4321','Kepala Lapas','-');
CREATE TABLE narapidana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_reg TEXT UNIQUE NOT NULL,
        nama TEXT NOT NULL,
        blok TEXT NOT NULL,
        sel TEXT NOT NULL,
        tanggal_masuk TEXT NOT NULL,
        estimasi_bebas TEXT NOT NULL,
        status TEXT NOT NULL
      );
CREATE TABLE insiden (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_reg TEXT NOT NULL,
        nama_napi TEXT NOT NULL,
        nip_petugas TEXT NOT NULL,
        keterangan TEXT NOT NULL,
        tanggal TEXT NOT NULL
      );
CREATE TABLE blok (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_blok TEXT UNIQUE NOT NULL,
        kapasitas_sel INTEGER NOT NULL,
        maks_penghuni INTEGER NOT NULL,
        tingkat_keamanan TEXT NOT NULL
      );
PRAGMA writable_schema=ON;
CREATE TABLE IF NOT EXISTS sqlite_sequence(name,seq);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('users',1);
PRAGMA writable_schema=OFF;
COMMIT;
