<?php

/**
 * File: models/User.php
 * Fungsi: Model untuk query user dari database
 */

class User
{

    // Property untuk database connection
    private $db;

    /**
     * Constructor
     * Fungsi: Membuat instance Database
     */
    public function __construct()
    {
        $this->db = new Database();
    }

    /**
     * Method: findByEmail()
     * Fungsi: Cari user berdasarkan email menggunakan prepared statement
     * Parameter: $email (string)
     * Return: array (user data) atau null jika tidak ditemukan
     */
    public function findByEmail($email)
    {
        // Prepared statement dengan placeholder (?)
        $stmt = $this->db->prepare("SELECT id, name, email, password FROM users WHERE email = ?");

        // Bind parameter: "s" = string type
        $stmt->bind_param("s", $email);

        // Execute query
        $stmt->execute();

        // Get result
        $result = $stmt->get_result();

        // Fetch sebagai associative array
        $user = $result->fetch_assoc();

        // Close statement untuk free resources
        $stmt->close();

        // Return user data atau null
        return $user;
    }

    /**
     * Method: findById()
     * Fungsi: Cari user berdasarkan ID
     * Parameter: $id (integer)
     * Return: array (user data) atau null
     */
    public function findById($id)
    {
        $stmt = $this->db->prepare("SELECT id, name, email FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);  // "i" = integer type
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        $stmt->close();

        return $user;
    }

    /**
     * Method: create()
     * Fungsi: Buat user baru dengan password yang di-hash
     * Parameter: $data (array)
     *   - $data['name'] (string)
     *   - $data['email'] (string)
     *   - $data['password'] (string) - akan di-hash secara otomatis
     * Return: integer (user ID) atau false jika gagal
     */
    public function create($data)
    {
        // Hash password menggunakan BCRYPT algorithm
        // PASSWORD_BCRYPT = algoritma yang aman & direkomendasikan
        $hashedPassword = password_hash($data['password'], PASSWORD_BCRYPT);

        // Prepared statement untuk INSERT
        $stmt = $this->db->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");

        // Bind 3 parameter: name (s), email (s), password (s)
        $stmt->bind_param("sss", $data['name'], $data['email'], $hashedPassword);

        // Execute INSERT
        if ($stmt->execute()) {
            // Ambil ID user yang baru dibuat
            $userId = $this->db->lastInsertId();
            $stmt->close();
            return $userId;
        }

        // Return false jika INSERT gagal
        $stmt->close();
        return false;
    }

    /**
     * Method: emailExists()
     * Fungsi: Cek apakah email sudah terdaftar di database
     * Parameter: $email (string)
     * Return: boolean (true jika sudah ada, false jika belum)
     */
    public function emailExists($email)
    {
        // Gunakan method findByEmail untuk cek
        $user = $this->findByEmail($email);

        // Jika $user tidak null, berarti email sudah ada
        return $user !== null;
    }
}