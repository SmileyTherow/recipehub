<?php
class Response {
    public static function success($data = null, $message = "Success") {
        // Set header agar response di-recognize sebagai JSON
        header('Content-Type: application/json');
        
        // Set HTTP status code 200 (OK)
        http_response_code(200);
        
        // Buat array response
        $response = [
            "success" => true,
            "message" => $message
        ];
        
        // Jika ada data, tambahkan ke response
        if ($data !== null) {
            $response["data"] = $data;
        }
        
        // Output sebagai JSON string
        echo json_encode($response);
        
        // Hentikan eksekusi script
        exit();
    }
    
    public static function error($message = "Error", $status = 400) {
        // Set header
        header('Content-Type: application/json');
        
        // Set HTTP status code
        http_response_code($status);
        
        // Buat response
        $response = [
            "success" => false,
            "message" => $message
        ];
        
        // Output JSON
        echo json_encode($response);
        exit();
    }
    
    public static function notFound($message = "Data tidak ditemukan") {
        self::error($message, 404);
    }
    
    public static function unauthorized($message = "Unauthorized") {
        self::error($message, 401);
    }
    
    public static function badRequest($message = "Bad Request") {
        self::error($message, 400);
    }
}
?>