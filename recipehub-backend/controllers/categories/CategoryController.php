<?php
/**
 * File: controllers/categories/CategoryController.php
 * Fungsi: Handle CRUD operations untuk category
 */

class CategoryController {
    
    private $category;
    private $recipe;
    
    /**
     * Constructor
     */
    public function __construct() {
        $this->category = new Category();
        $this->recipe = new Recipe();
    }
    
    /**
     * Method: getCategories()
     * Fungsi: Get semua kategori milik satu user
     * Request: GET /categories?user_id=1
     * Response: array of categories
     */
    public function getCategories() {
        // 1. EXTRACT USER_ID
        $userId = isset($_GET['user_id']) ? $_GET['user_id'] : null;
        
        // 2. VALIDASI
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        $userId = (int)$userId;
        
        // 3. QUERY
        $categories = $this->category->getByUserId($userId);
        
        // 4. RESPONSE
        Response::success($categories, "Kategori loaded");
    }
    
    /**
     * Method: addCategory()
     * Fungsi: Create kategori baru
     * Request: POST /categories
     * Body: { user_id, name }
     * Response: { id } (category_id yang baru dibuat)
     */
    public function addCategory() {
        // 1. EXTRACT DATA
        $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : null;
        $name = isset($_POST['name']) ? trim($_POST['name']) : null;
        
        // 2. VALIDASI
        
        // Cek user_id kosong
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        // Cek name kosong
        if (empty($name)) {
            Response::badRequest("Nama kategori harus diisi");
        }
        
        // Cek nama terlalu panjang
        if (strlen($name) > 100) {
            Response::badRequest("Nama kategori maksimal 100 karakter");
        }
        
        // Cek duplicate name untuk user ini
        $existingCategory = $this->category->getByUserIdAndName($userId, $name);
        if ($existingCategory) {
            Response::error("Kategori dengan nama ini sudah ada", 409);
        }
        
        // 3. CREATE
        $data = [
            'user_id' => $userId,
            'name' => $name
        ];
        
        $categoryId = $this->category->create($data);
        
        if (!$categoryId) {
            Response::error("Gagal membuat kategori");
        }
        
        // 4. RESPONSE
        $responseData = ['id' => $categoryId];
        Response::success($responseData, "Kategori berhasil ditambahkan");
    }
    
    /**
     * Method: editCategory()
     * Fungsi: Update kategori
     * Request: PUT /categories/{id}
     * Body: { user_id, name }
     * Response: success message
     */
    public function editCategory($id) {
        // 1. EXTRACT DATA
        $id = (int)$id;
        
        // Untuk PUT request, data biasanya di-parse dari body
        parse_str(file_get_contents("php://input"), $_PUT);
        
        $userId = isset($_PUT['user_id']) ? (int)$_PUT['user_id'] : null;
        $name = isset($_PUT['name']) ? trim($_PUT['name']) : null;
        
        // 2. VALIDASI
        
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        if (empty($name)) {
            Response::badRequest("Nama kategori harus diisi");
        }
        
        if (strlen($name) > 100) {
            Response::badRequest("Nama kategori maksimal 100 karakter");
        }
        
        // Cek kategori ada & milik user ini
        $category = $this->category->getById($id);
        if (!$category) {
            Response::notFound("Kategori tidak ditemukan");
        }
        
        if ($category['user_id'] != $userId) {
            Response::unauthorized("Kategori ini bukan milik Anda");
        }
        
        // Cek duplicate name (tapi boleh sama dengan nama lama)
        if ($category['name'] !== $name) {
            $existingCategory = $this->category->getByUserIdAndName($userId, $name);
            if ($existingCategory) {
                Response::error("Kategori dengan nama ini sudah ada", 409);
            }
        }
        
        // 3. UPDATE
        $data = ['name' => $name];
        $result = $this->category->update($id, $data);
        
        if (!$result) {
            Response::error("Gagal update kategori");
        }
        
        // 4. RESPONSE
        Response::success(null, "Kategori berhasil diperbarui");
    }
    
    /**
     * Method: deleteCategory()
     * Fungsi: Delete kategori
     * Request: DELETE /categories/{id}
     * Body: { user_id }
     * Response: success message
     */
    public function deleteCategory($id) {
        // 1. EXTRACT DATA
        $id = (int)$id;
        
        // Untuk DELETE request, parse data dari body
        parse_str(file_get_contents("php://input"), $_DELETE);
        
        $userId = isset($_DELETE['user_id']) ? (int)$_DELETE['user_id'] : null;
        
        // 2. VALIDASI
        
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        // Cek kategori ada & milik user ini
        $category = $this->category->getById($id);
        if (!$category) {
            Response::notFound("Kategori tidak ditemukan");
        }
        
        if ($category['user_id'] != $userId) {
            Response::unauthorized("Kategori ini bukan milik Anda");
        }
        
        // Cek kategori masih punya resep
        // Jika ada resep, tidak boleh delete (database punya ON DELETE RESTRICT)
        $recipeCount = $this->recipe->countByCategory($id);
        if ($recipeCount > 0) {
            Response::error("Kategori masih memiliki " . $recipeCount . " resep. Hapus resep terlebih dahulu", 400);
        }
        
        // 3. DELETE
        $result = $this->category->delete($id);
        
        if (!$result) {
            Response::error("Gagal delete kategori");
        }
        
        // 4. RESPONSE
        Response::success(null, "Kategori berhasil dihapus");
    }
}
?>