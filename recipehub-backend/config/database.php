<?php
class Database {
    // Informasi koneksi database
    private $host = "localhost";
    private $username = "root";
    private $password = "";
    private $database = "recipehub";
    
    // Object koneksi
    private $conn;
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
    public function query($sql) {
        // Execute query
        $result = $this->conn->query($sql);
        
        // Jika query gagal, die dengan pesan error
        if (!$result) {
            die("Query Gagal: " . $this->conn->error);
        }
        
        return $result;
    }
    public function execute($sql) {
        // Execute query
        if ($this->conn->query($sql) === TRUE) {
            return true;
        } else {
            die("Execute Gagal: " . $this->conn->error);
        }
    }
    public function prepare($sql) {
        return $this->conn->prepare($sql);
    }
    public function lastInsertId() {
        return $this->conn->insert_id;
    }
    
    public function close() {
        $this->conn->close();
    }
}
?>