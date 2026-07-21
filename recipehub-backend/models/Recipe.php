<?php
class Recipe {
    
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }

    public function getByUserId($userId) {
        $stmt = $this->db->prepare("
            SELECT id, name, category_id, cooking_time, servings, image, description 
            FROM recipes 
            WHERE user_id = ? 
            ORDER BY created_at DESC
        ");
        
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $recipes = [];
        while ($row = $result->fetch_assoc()) {
            $recipes[] = $row;
        }
        
        $stmt->close();
        return $recipes;
    }

    public function getById($id) {
        $stmt = $this->db->prepare("
            SELECT * FROM recipes WHERE id = ?
        ");
        
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $recipe = $result->fetch_assoc();
        $stmt->close();
        
        return $recipe;
    }
    
    public function getLatest($userId, $limit = 5) {
        $stmt = $this->db->prepare("
            SELECT id, name, category_id, cooking_time, servings, image, description 
            FROM recipes 
            WHERE user_id = ? 
            ORDER BY created_at DESC 
            LIMIT ?
        ");
        
        $stmt->bind_param("ii", $userId, $limit);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $recipes = [];
        while ($row = $result->fetch_assoc()) {
            $recipes[] = $row;
        }
        
        $stmt->close();
        return $recipes;
    }
    
    public function create($data) {
        $stmt = $this->db->prepare("
            INSERT INTO recipes 
            (user_id, category_id, name, ingredients, steps, cooking_time, servings, image, description) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        // types: i (user_id), i (category_id), s (name), s (ingredients), s (steps),
        // i (cooking_time), i (servings), s (image), s (description)
        $stmt->bind_param(
            "iisssiiss",
            $data['user_id'],
            $data['category_id'],
            $data['name'],
            $data['ingredients'],
            $data['steps'],
            $data['cooking_time'],
            $data['servings'],
            $data['image'],
            $data['description']
        );
        
        if ($stmt->execute()) {
            $recipeId = $this->db->lastInsertId();
            $stmt->close();
            return $recipeId;
        }
        
        $stmt->close();
        return false;
    }
    
    public function update($id, $data) {
        // Build dynamic query berdasarkan field yang ada di $data
        $fields = [];
        $values = [];
        $types = "";
        
        if (isset($data['name'])) {
            $fields[] = "name = ?";
            $values[] = $data['name'];
            $types .= "s";
        }
        if (isset($data['category_id'])) {
            $fields[] = "category_id = ?";
            $values[] = $data['category_id'];
            $types .= "i";
        }
        if (isset($data['ingredients'])) {
            $fields[] = "ingredients = ?";
            $values[] = $data['ingredients'];
            $types .= "s";
        }
        if (isset($data['steps'])) {
            $fields[] = "steps = ?";
            $values[] = $data['steps'];
            $types .= "s";
        }
        if (isset($data['cooking_time'])) {
            $fields[] = "cooking_time = ?";
            $values[] = $data['cooking_time'];
            $types .= "i";
        }
        if (isset($data['servings'])) {
            $fields[] = "servings = ?";
            $values[] = $data['servings'];
            $types .= "i";
        }
        if (isset($data['image'])) {
            $fields[] = "image = ?";
            $values[] = $data['image'];
            $types .= "s";
        }
        if (isset($data['description'])) {
            $fields[] = "description = ?";
            $values[] = $data['description'];
            $types .= "s";
        }
        
        if (empty($fields)) {
            return false;
        }
        
        $values[] = $id;
        $types .= "i";
        
        $sql = "UPDATE recipes SET " . implode(", ", $fields) . " WHERE id = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param($types, ...$values);
        
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }
    
    public function delete($id) {
        $stmt = $this->db->prepare("DELETE FROM recipes WHERE id = ?");
        $stmt->bind_param("i", $id);
        $result = $stmt->execute();
        $stmt->close();
        
        return $result;
    }
    
    public function countByUserId($userId) {
        $stmt = $this->db->prepare("SELECT COUNT(*) as total FROM recipes WHERE user_id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        
        return (int)$row['total'];
    }

    public function countByCategory($categoryId) {
        $stmt = $this->db->prepare("SELECT COUNT(*) as total FROM recipes WHERE category_id = ?");
        $stmt->bind_param("i", $categoryId);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        
        return (int)$row['total'];
    }
}
?>