-- Skema referensi PostgreSQL SETORUN (selaras dengan model Django)

CREATE TYPE user_gender AS ENUM ('male', 'fem');
CREATE TYPE mutabaah_note AS ENUM ('ziyadah', 'murajaah');

CREATE TABLE guru (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_2 VARCHAR(255) NOT NULL
);

CREATE TABLE halaqoh (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    guru_id INT UNIQUE NOT NULL,
    FOREIGN KEY (guru_id) REFERENCES guru(id) ON DELETE CASCADE
);

CREATE TABLE murid (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_2 VARCHAR(255) NOT NULL,
    halaqoh_id INT,
    FOREIGN KEY (halaqoh_id) REFERENCES halaqoh(id) ON DELETE SET NULL
);

CREATE TABLE mutabaah (
    id SERIAL PRIMARY KEY,
    murid_id INT NOT NULL,
    tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nama_surah VARCHAR(100) NOT NULL,
    ayat VARCHAR(50) NOT NULL,
    note mutabaah_note NOT NULL,
    keterangan VARCHAR(255),
    FOREIGN KEY (murid_id) REFERENCES murid(id) ON DELETE CASCADE
);
