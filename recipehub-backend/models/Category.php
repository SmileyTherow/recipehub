<?php
class Category {
    
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }

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

    public function update($id, $data) {
        $stmt = $this->db->prepare("UPDATE categories SET name = ? WHERE id = ?");
        $stmt->bind_param("si", $data['name'], $id);
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }

    public function delete($id) {
        $stmt = $this->db->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param("i", $id);
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }

    public function countByUserId($userId) {
        $stmt = $this->db->prepare("SELECT COUNT(*) as total FROM categories WHERE user_id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        
        return (int)$row['total'];
    }

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