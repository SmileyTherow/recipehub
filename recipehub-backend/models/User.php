<?php
class User
{

    // Property untuk database connection
    private $db;

    public function __construct()
    {
        $this->db = new Database();
    }

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

    public function emailExists($email)
    {
        // Gunakan method findByEmail untuk cek
        $user = $this->findByEmail($email);

        // Jika $user tidak null, berarti email sudah ada
        return $user !== null;
    }
}