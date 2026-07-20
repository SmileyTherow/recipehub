<?php
/**
 * File: controllers/dashboard/DashboardController.php
 * Fungsi: Handle dashboard request
 */

class DashboardController {
    
    private $recipe;
    private $category;
    
    /**
     * Constructor
     * Fungsi: Inisialisasi Recipe & Category model
     */
    public function __construct() {
        $this->recipe = new Recipe();
        $this->category = new Category();
    }
    
    /**
     * Method: getDashboard()
     * Fungsi: Get dashboard data (ringkasan untuk user)
     * Request: GET /dashboard
     * Parameter: user_id (dari POST atau GET)
     * Response: total_recipes, total_categories, latest_recipes
     */
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