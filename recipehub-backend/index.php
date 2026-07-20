<?php

/**
 * File: index.php
 * Fungsi: Router/Entry point untuk semua request API dari Flutter
 */

// Jangan tampilkan error ke client (mencegah HTML error merusak JSON)
ini_set('display_errors', '0');
ini_set('display_startup_errors', '0');
error_reporting(E_ALL);
ini_set('log_errors', '1');
ini_set('error_log', __DIR__ . '/error_log.txt');

// ============================================================
// CORS HEADERS
// ============================================================
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ============================================================
// INCLUDE CONFIG, HELPERS, MODELS, CONTROLLERS
// ============================================================
require_once 'config/database.php';
require_once 'helpers/Response.php';
require_once 'helpers/FileUpload.php';

require_once 'models/User.php';
require_once 'models/Recipe.php';
require_once 'models/Category.php';

require_once 'controllers/auth/AuthController.php';
require_once 'controllers/dashboard/DashboardController.php';
require_once 'controllers/recipes/RecipeController.php';
require_once 'controllers/categories/CategoryController.php';

// ============================================================
// METHOD & PATH
// ============================================================
$method = $_SERVER['REQUEST_METHOD'];

if (!empty($_SERVER['PATH_INFO'])) {
    $path = $_SERVER['PATH_INFO'];
} else {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $basePath = '/recipehub-backend';
    if (strpos($path, $basePath) === 0) {
        $path = substr($path, strlen($basePath));
    }
    if (strpos($path, '/index.php') === 0) {
        $path = substr($path, strlen('/index.php'));
    }
}

// ============================================================
// ROUTING
// ============================================================
switch ($method) {
    case 'POST':
        switch ($path) {
            case '/auth/register':
                (new AuthController())->register();
                break;
            case '/auth/login':
                (new AuthController())->login();
                break;
            case '/recipes':
                (new RecipeController())->addRecipe();
                break;
            case '/categories':
                (new CategoryController())->addCategory();
                break;
            default:
                // support POST + _method=PUT (multipart form)
                if (preg_match('/^\/recipes\/(\d+)$/', $path, $m)) {
                    $recipeId = $m[1];
                    $override = isset($_GET['_method']) ? strtoupper($_GET['_method'])
                              : (isset($_POST['_method']) ? strtoupper($_POST['_method']) : null);
                    if ($override === 'PUT') {
                        (new RecipeController())->editRecipe($recipeId);
                        break 2;
                    }
                }
                if (preg_match('/^\/categories\/(\d+)$/', $path, $m)) {
                    $categoryId = $m[1];
                    $override = isset($_GET['_method']) ? strtoupper($_GET['_method'])
                              : (isset($_POST['_method']) ? strtoupper($_POST['_method']) : null);
                    if ($override === 'PUT') {
                        (new CategoryController())->editCategory($categoryId);
                        break 2;
                    }
                }
                Response::notFound("Endpoint tidak ditemukan");
        }
        break;

    case 'GET':
        switch ($path) {
            case '/dashboard':
                (new DashboardController())->getDashboard();
                break;
            case '/recipes':
                (new RecipeController())->getRecipes();
                break;
            case '/categories':
                (new CategoryController())->getCategories();
                break;
            default:
                if (preg_match('/^\/recipes\/(\d+)$/', $path, $m)) {
                    (new RecipeController())->getRecipeDetail($m[1]);
                } else {
                    Response::notFound("Endpoint tidak ditemukan");
                }
        }
        break;

    case 'PUT':
        if (preg_match('/^\/recipes\/(\d+)$/', $path, $m)) {
            (new RecipeController())->editRecipe($m[1]);
        } elseif (preg_match('/^\/categories\/(\d+)$/', $path, $m)) {
            (new CategoryController())->editCategory($m[1]);
        } else {
            Response::notFound("Endpoint tidak ditemukan");
        }
        break;

    case 'DELETE':
        if (preg_match('/^\/recipes\/(\d+)$/', $path, $m)) {
            (new RecipeController())->deleteRecipe($m[1]);
        } elseif (preg_match('/^\/categories\/(\d+)$/', $path, $m)) {
            (new CategoryController())->deleteCategory($m[1]);
        } else {
            Response::notFound("Endpoint tidak ditemukan");
        }
        break;

    default:
        Response::error("Method HTTP tidak didukung", 405);
}