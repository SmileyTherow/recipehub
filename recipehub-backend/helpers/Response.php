<?php
/**
 * File: helpers/Response.php
 * Fungsi: Helper untuk format response JSON
 */

class Response {
    
    /**
     * Method: success()
     * Fungsi: Send response success (HTTP 200)
     * Parameter: 
     *   - $data (mixed): data yang akan dikirim (bisa null)
     *   - $message (string): pesan sukses
     * Return: void (langsung output & exit)
     */
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
    
    /**
     * Method: error()
     * Fungsi: Send response error (HTTP 400 atau sesuai status)
     * Parameter:
     *   - $message (string): pesan error
     *   - $status (int): HTTP status code (default 400)
     * Return: void (langsung output & exit)
     */
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
    
    /**
     * Method: notFound()
     * Fungsi: Send response 404 Not Found
     * Parameter:
     *   - $message (string): pesan not found
     * Return: void (langsung output & exit)
     */
    public static function notFound($message = "Data tidak ditemukan") {
        self::error($message, 404);
    }
    
    /**
     * Method: unauthorized()
     * Fungsi: Send response 401 Unauthorized
     * Parameter:
     *   - $message (string): pesan unauthorized
     * Return: void (langsung output & exit)
     */
    public static function unauthorized($message = "Unauthorized") {
        self::error($message, 401);
    }
    
    /**
     * Method: badRequest()
     * Fungsi: Send response 400 Bad Request
     * Parameter:
     *   - $message (string): pesan bad request
     * Return: void (langsung output & exit)
     */
    public static function badRequest($message = "Bad Request") {
        self::error($message, 400);
    }
}
?>