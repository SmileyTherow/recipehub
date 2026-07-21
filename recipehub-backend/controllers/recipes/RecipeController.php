<?php
class RecipeController {
    
    private $recipe;
    private $category;
    
    public function __construct() {
        $this->recipe = new Recipe();
        $this->category = new Category();
    }
    public function getRecipes() {
        $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
        
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        $recipes = $this->recipe->getByUserId($userId);
        Response::success($recipes, "Resep loaded");
    }
    
    public function getRecipeDetail($recipeId) {
        $recipeId = (int)$recipeId;
        $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
        
        if (empty($recipeId) || empty($userId)) {
            Response::badRequest("Recipe ID dan User ID harus dikirim");
        }
        
        $recipe = $this->recipe->getById($recipeId);
        
        if (!$recipe) {
            Response::notFound("Resep tidak ditemukan");
        }
        
        if ($recipe['user_id'] != $userId) {
            Response::unauthorized("Resep ini bukan milik Anda");
        }
        
        Response::success($recipe, "Resep detail loaded");
    }
    
    public function addRecipe() {
        $userId = isset($_POST['user_id']) ? (int)$_POST['user_id'] : null;
        $categoryId = isset($_POST['category_id']) ? (int)$_POST['category_id'] : null;
        $name = isset($_POST['name']) ? trim($_POST['name']) : null;
        $ingredients = isset($_POST['ingredients']) ? trim($_POST['ingredients']) : null;
        $steps = isset($_POST['steps']) ? trim($_POST['steps']) : null;
        $cookingTime = isset($_POST['cooking_time']) ? (int)$_POST['cooking_time'] : null;
        $servings = isset($_POST['servings']) ? (int)$_POST['servings'] : null;
        // NEW: read optional description
        $description = isset($_POST['description']) ? trim($_POST['description']) : null;
        
        // Validasi semua field required
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        if (empty($categoryId)) {
            Response::badRequest("Category ID harus dikirim");
        }
        
        if (empty($name)) {
            Response::badRequest("Nama resep harus diisi");
        }
        
        if (empty($ingredients)) {
            Response::badRequest("Ingredients harus diisi");
        }
        
        if (empty($steps)) {
            Response::badRequest("Steps harus diisi");
        }
        
        if (empty($cookingTime) || $cookingTime <= 0) {
            Response::badRequest("Cooking time harus berupa angka positif");
        }
        
        if (empty($servings) || $servings <= 0) {
            Response::badRequest("Servings harus berupa angka positif");
        }
        
        // Validasi panjang string
        if (strlen($name) > 255) {
            Response::badRequest("Nama resep maksimal 255 karakter");
        }
        
        if (strlen($ingredients) > 5000) {
            Response::badRequest("Ingredients maksimal 5000 karakter");
        }
        
        if (strlen($steps) > 5000) {
            Response::badRequest("Steps maksimal 5000 karakter");
        }
        
        // Validasi category ownership
        $category = $this->category->getById($categoryId);
        if (!$category) {
            Response::notFound("Kategori tidak ditemukan");
        }
        
        if ($category['user_id'] != $userId) {
            Response::unauthorized("Kategori ini bukan milik Anda");
        }
        
        // Handle file upload (image optional)
        $image = null;
        
        if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {
            $image = FileUpload::uploadImage($_FILES['image']);
            
            if (!$image) {
                Response::error("Upload gambar gagal. Pastikan file adalah image (jpg/png/gif) dan ukuran < 5MB", 400);
            }
        }
        
        // Create recipe
        $data = [
            'user_id' => $userId,
            'category_id' => $categoryId,
            'name' => $name,
            'ingredients' => $ingredients,
            'steps' => $steps,
            'cooking_time' => $cookingTime,
            'servings' => $servings,
            'image' => $image,
            'description' => $description, // NEW: include description
        ];
        
        $recipeId = $this->recipe->create($data);
        
        if (!$recipeId) {
            Response::error("Gagal membuat resep, silakan coba lagi");
        }
        
        $responseData = ['id' => $recipeId];
        Response::success($responseData, "Resep berhasil ditambahkan");
    }
    
    public function editRecipe($recipeId) {
        $recipeId = (int)$recipeId;

        // Determine input source:
        // - If request method is PUT, parse raw input to $input
        // - If request method is POST with override _method=PUT (common for multipart), use $_POST as $input
        // - Otherwise, try to parse raw input
        $input = [];

        $requestMethod = isset($_SERVER['REQUEST_METHOD']) ? $_SERVER['REQUEST_METHOD'] : 'GET';
        $isOverridePut = false;

        if ($requestMethod === 'POST') {
            // Detect override in either query or post body
            if ((isset($_GET['_method']) && strtoupper($_GET['_method']) === 'PUT') ||
                (isset($_POST['_method']) && strtoupper($_POST['_method']) === 'PUT')) {
                $isOverridePut = true;
            }
        }

        if ($requestMethod === 'PUT' && !$isOverridePut) {
            parse_str(file_get_contents("php://input"), $input);
        } elseif ($requestMethod === 'POST' && $isOverridePut) {
            // For multipart/form-data uploads, PHP populates $_POST and $_FILES only on POST.
            // Use $_POST as the input source so uploaded files in $_FILES are available.
            $input = $_POST;
        } else {
            // Fallback
            parse_str(file_get_contents("php://input"), $input);
        }

        // Normalize: remove _method if present
        if (isset($input['_method'])) {
            unset($input['_method']);
        }

        // Extract fields safely from $input
        $userId = isset($input['user_id']) ? (int)$input['user_id'] : null;
        $categoryId = isset($input['category_id']) ? (int)$input['category_id'] : null;
        $name = isset($input['name']) ? trim($input['name']) : null;
        $ingredients = isset($input['ingredients']) ? trim($input['ingredients']) : null;
        $steps = isset($input['steps']) ? trim($input['steps']) : null;
        $cookingTime = isset($input['cooking_time']) ? (int)$input['cooking_time'] : null;
        $servings = isset($input['servings']) ? (int)$input['servings'] : null;
        // NEW: read optional description
        $description = isset($input['description']) ? trim($input['description']) : null;
        
        // Validasi recipe_id & user_id
        if (empty($recipeId)) {
            Response::badRequest("Recipe ID harus dikirim");
        }
        
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        // Query recipe
        $recipe = $this->recipe->getById($recipeId);
        
        if (!$recipe) {
            Response::notFound("Resep tidak ditemukan");
        }
        
        if ($recipe['user_id'] != $userId) {
            Response::unauthorized("Resep ini bukan milik Anda");
        }
        
        // Build update data (partial update)
        $updateData = [];
        
        if (!empty($categoryId)) {
            $category = $this->category->getById($categoryId);
            if (!$category) {
                Response::notFound("Kategori tidak ditemukan");
            }
            if ($category['user_id'] != $userId) {
                Response::unauthorized("Kategori ini bukan milik Anda");
            }
            $updateData['category_id'] = $categoryId;
        }
        
        if (!empty($name)) {
            if (strlen($name) > 255) {
                Response::badRequest("Nama resep maksimal 255 karakter");
            }
            $updateData['name'] = $name;
        }
        
        if (!empty($ingredients)) {
            if (strlen($ingredients) > 5000) {
                Response::badRequest("Ingredients maksimal 5000 karakter");
            }
            $updateData['ingredients'] = $ingredients;
        }
        
        if (!empty($steps)) {
            if (strlen($steps) > 5000) {
                Response::badRequest("Steps maksimal 5000 karakter");
            }
            $updateData['steps'] = $steps;
        }
        
        if (!empty($cookingTime)) {
            if ($cookingTime <= 0) {
                Response::badRequest("Cooking time harus berupa angka positif");
            }
            $updateData['cooking_time'] = $cookingTime;
        }
        
        if (!empty($servings)) {
            if ($servings <= 0) {
                Response::badRequest("Servings harus berupa angka positif");
            }
            $updateData['servings'] = $servings;
        }

        // NEW: include description if provided (non-empty)
        if (!empty($description)) {
            $updateData['description'] = $description;
        }
        
        // Handle image upload (replace old image if new one provided)
        // Important: if the request was a POST override, uploaded files will be in $_FILES.
        if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {
            $newImage = FileUpload::uploadImage($_FILES['image']);
            
            if (!$newImage) {
                Response::error("Upload gambar gagal. Pastikan file adalah image (jpg/png/gif) dan ukuran < 5MB", 400);
            }
            
            // Delete old image
            if (!empty($recipe['image'])) {
                FileUpload::deleteFile($recipe['image']);
            }
            
            $updateData['image'] = $newImage;
        }
        
        // Check if there's data to update
        if (empty($updateData)) {
            Response::badRequest("Tidak ada data yang diupdate");
        }
        
        // Update recipe
        $result = $this->recipe->update($recipeId, $updateData);
        
        if (!$result) {
            Response::error("Gagal update resep");
        }
        
        Response::success(null, "Resep berhasil diperbarui");
    }
    
    public function deleteRecipe($recipeId) {
        $recipeId = (int)$recipeId;
        
        parse_str(file_get_contents("php://input"), $_DELETE);
        
        $userId = isset($_DELETE['user_id']) ? (int)$_DELETE['user_id'] : null;
        
        // Validasi
        if (empty($recipeId)) {
            Response::badRequest("Recipe ID harus dikirim");
        }
        
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        // Query recipe
        $recipe = $this->recipe->getById($recipeId);
        
        if (!$recipe) {
            Response::notFound("Resep tidak ditemukan");
        }
        
        if ($recipe['user_id'] != $userId) {
            Response::unauthorized("Resep ini bukan milik Anda");
        }
        
        // Delete image file
        if (!empty($recipe['image'])) {
            FileUpload::deleteFile($recipe['image']);
        }
        
        // Delete recipe
        $result = $this->recipe->delete($recipeId);
        
        if (!$result) {
            Response::error("Gagal delete resep");
        }
        
        Response::success(null, "Resep berhasil dihapus");
    }
}
?>