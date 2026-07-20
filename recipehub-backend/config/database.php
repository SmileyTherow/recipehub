<?php
/**
 * File: config/database.php
 * Fungsi: Konfigurasi koneksi database MySQL
 */

class Database {
    // Informasi koneksi database
    private $host = "localhost";
    private $username = "root";
    private $password = "";
    private $database = "recipehub";
    
    // Object koneksi
    private $conn;
    
    /**
     * Constructor
     * Fungsi: Membuat koneksi ke database saat object dibuat
     */
    public function __construct() {
        // Buat koneksi menggunakan MySQLi
        $this->conn = new mysqli(
            $this->host,
            $this->username,
            $this->password,
            $this->database
        );
        
        // Cek apakah koneksi gagal
        if ($this->conn->connect_error) {
            die("Koneksi Database Gagal: " . $this->conn->connect_error);
        }
        
        // Set charset ke UTF-8 (agar bisa simpan karakter Indonesia)
        $this->conn->set_charset("utf8");
    }
    
    /**
     * Method: query()
     * Fungsi: Execute query SELECT
     * Parameter: $sql (string SQL query)
     * Return: mysqli_result object
     */
    public function query($sql) {
        // Execute query
        $result = $this->conn->query($sql);
        
        // Jika query gagal, die dengan pesan error
        if (!$result) {
            die("Query Gagal: " . $this->conn->error);
        }
        
        return $result;
    }
    
    /**
     * Method: execute()
     * Fungsi: Execute query INSERT, UPDATE, DELETE
     * Parameter: $sql (string SQL query)
     * Return: true jika berhasil, false jika gagal
     */
    public function execute($sql) {
        // Execute query
        if ($this->conn->query($sql) === TRUE) {
            return true;
        } else {
            die("Execute Gagal: " . $this->conn->error);
        }
    }
    
    /**
     * Method: prepare()
     * Fungsi: Membuat prepared statement (lebih aman)
     * Parameter: $sql (string SQL query dengan placeholder ?)
     * Return: mysqli_stmt object
     */
    public function prepare($sql) {
        return $this->conn->prepare($sql);
    }
    
    /**
     * Method: lastInsertId()
     * Fungsi: Mendapatkan ID terakhir yang di-insert
     * Return: integer (ID terakhir)
     */
    public function lastInsertId() {
        return $this->conn->insert_id;
    }
    
    /**
     * Method: close()
     * Fungsi: Menutup koneksi database
     */
    public function close() {
        $this->conn->close();
    }
}
?>