<?php
/**
 * File: models/Category.php
 * Fungsi: Model untuk query category dari database
 */

class Category {
    
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    /**
     * Method: getByUserId()
     * Fungsi: Ambil semua kategori milik satu user
     * Parameter: $userId (integer)
     * Return: array of categories
     */
    public function getByUserId($userId) {
        $stmt = $this->db->prepare("
            SELECT id, name 
            FROM categories 
            WHERE user_id = ? 
            ORDER BY name ASC
        ");
        
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $categories = [];
        while ($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
        
        $stmt->close();
        return $categories;
    }
    
    /**
     * Method: getById()
     * Fungsi: Ambil detail kategori berdasarkan ID
     * Parameter: $id (integer)
     * Return: array (category data) atau null
     */
    public function getById($id) {
        $stmt = $this->db->prepare("
            SELECT * FROM categories WHERE id = ?
        ");
        
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $category = $result->fetch_assoc();
        $stmt->close();
        
        return $category;
    }
    
    /**
     * Method: create()
     * Fungsi: Buat kategori baru
     * Parameter: $data (array dengan keys: user_id, name)
     * Return: integer (category_id) atau false
     */
    public function create($data) {
        $stmt = $this->db->prepare("
            INSERT INTO categories (user_id, name) 
            VALUES (?, ?)
        ");
        
        $stmt->bind_param("is", $data['user_id'], $data['name']);
        
        if ($stmt->execute()) {
            $categoryId = $this->db->lastInsertId();
            $stmt->close();
            return $categoryId;
        }
        
        $stmt->close();
        return false;
    }
    
    /**
     * Method: update()
     * Fungsi: Update kategori yang sudah ada
     * Parameter: $id (category_id), $data (array dengan field yang akan diupdate)
     * Return: boolean
     */
    public function update($id, $data) {
        $stmt = $this->db->prepare("UPDATE categories SET name = ? WHERE id = ?");
        $stmt->bind_param("si", $data['name'], $id);
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }
    
    /**
     * Method: delete()
     * Fungsi: Hapus kategori
     * Parameter: $id (category_id)
     * Return: boolean
     */
    public function delete($id) {
        $stmt = $this->db->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }
    
    /**
     * Method: countByUserId()
     * Fungsi: Hitung total kategori milik satu user
     * Parameter: $userId (integer)
     * Return: integer (jumlah kategori)
     */
    public function countByUserId($userId) {
        $stmt = $this->db->prepare("SELECT COUNT(*) as total FROM categories WHERE user_id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        
        return (int)$row['total'];
    }

    /**
     * Method: getByUserIdAndName()
     * Fungsi: Cek apakah kategori dengan nama ini sudah ada untuk user ini
     * Parameter: $userId, $name
     * Return: array (category data) atau null
     */
    public function getByUserIdAndName($userId, $name) {
        $stmt = $this->db->prepare("
            SELECT id, name FROM categories 
            WHERE user_id = ? AND name = ?
        ");
        
        $stmt->bind_param("is", $userId, $name);
        $stmt->execute();
        $result = $stmt->get_result();
        $category = $result->fetch_assoc();
        $stmt->close();
        
        return $category;
    }
}
?>