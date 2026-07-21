<?php
class DashboardController {
    private $recipe;
    private $category;
    public function __construct() {
        $this->recipe = new Recipe();
        $this->category = new Category();
    }
    public function getDashboard() {
        // 1. EXTRACT USER_ID
        // User_id bisa dikirim dari POST atau GET
        $userId = isset($_POST['user_id']) ? $_POST['user_id'] : 
                  (isset($_GET['user_id']) ? $_GET['user_id'] : null);
        
        // 2. VALIDASI USER_ID
        if (empty($userId)) {
            Response::badRequest("User ID harus dikirim");
        }
        
        // Convert ke integer
        $userId = (int)$userId;
        
        // 3. QUERY DATA
        // Hitung total resep
        $totalRecipes = $this->recipe->countByUserId($userId);
        
        // Hitung total kategori
        $totalCategories = $this->category->countByUserId($userId);
        
        // Ambil 5 resep terbaru
        $latestRecipes = $this->recipe->getLatest($userId, 5);
        
        // 4. PREPARE RESPONSE DATA
        $dashboardData = [
            'total_recipes' => $totalRecipes,
            'total_categories' => $totalCategories,
            'latest_recipes' => $latestRecipes
        ];
        
        // 5. RETURN SUCCESS RESPONSE
        Response::success($dashboardData, "Dashboard data loaded");
    }
}
?>