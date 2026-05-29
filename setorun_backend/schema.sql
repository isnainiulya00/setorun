-- Skema referensi PostgreSQL SETORUN (Sudah Direvisi)

CREATE TYPE user_gender AS ENUM ('male', 'fem');
CREATE TYPE mutabaah_note AS ENUM ('ziyadah', 'murajaah');

-- 1. Tabel Guru dibuat pertama
CREATE TABLE guru (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_2 VARCHAR(255) NOT NULL
);

-- 2. Tabel Halaqoh (UNIQUE dihapus agar Guru bisa punya banyak halaqah)
CREATE TABLE halaqoh (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    jadwal VARCHAR(200) DEFAULT '',
    guru_id INT NOT NULL, 
    FOREIGN KEY (guru_id) REFERENCES guru(id) ON DELETE CASCADE
);

-- 3. Tabel Murid dipindah ke sini (Sebelum Chat Room), ditambahkan status_join
CREATE TABLE murid (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender user_gender NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_2 VARCHAR(255) NOT NULL,
    halaqoh_id INT,
    status_join VARCHAR(20), -- Menampung 'pending' atau 'approved'
    FOREIGN KEY (halaqoh_id) REFERENCES halaqoh(id) ON DELETE SET NULL
);

-- 4. Tabel Chat Room (Sekarang aman karena tabel murid & halaqoh sudah ada)
CREATE TABLE chat_room (
    id SERIAL PRIMARY KEY,
    murid_id INT UNIQUE NOT NULL,
    halaqoh_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (murid_id) REFERENCES murid(id) ON DELETE CASCADE,
    FOREIGN KEY (halaqoh_id) REFERENCES halaqoh(id) ON DELETE CASCADE
);

-- 5. Tabel Chat Message
CREATE TABLE chat_message (
    id SERIAL PRIMARY KEY,
    room_id INT NOT NULL,
    sender_type VARCHAR(10) NOT NULL,
    sender_id INT NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES chat_room(id) ON DELETE CASCADE
);

-- 6. Tabel Mutabaah
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