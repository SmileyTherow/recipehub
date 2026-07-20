<?php
/**
 * File: helpers/FileUpload.php
 * Fungsi: Helper untuk upload & delete file gambar
 */

class FileUpload {
    
    // Konstanta konfigurasi file upload
    const MAX_FILE_SIZE = 5242880;  // 5MB dalam bytes (5 * 1024 * 1024)
    const UPLOAD_DIR = __DIR__ . '/../uploads/recipes/';    
    const ALLOWED_TYPES = [
        'image/jpeg',
        'image/jpg',
        'image/pjpeg',
        'image/png',
        'image/gif',
        'image/webp'
    ];
    const ALLOWED_EXT = ['jpg', 'jpeg', 'png', 'gif'];
    
    /**
     * Method: uploadImage()
     * Fungsi: Upload file gambar dengan validasi
     * Parameter:
     *   - $file (array): array dari $_FILES['image']
     * Return: string (nama file) atau false jika gagal
     */
    public static function uploadImage($file) {
        // Debug logging: log incoming file array
        error_log("[FileUpload] uploadImage called. \$_FILES['image']=" . print_r($file, true));

        // Validasi 1: Cek apakah file ada dan tidak ada error
        if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
            $err = isset($file['error']) ? $file['error'] : 'no_file';
            error_log("[FileUpload] file missing or upload error. error_code=" . var_export($err, true));
            return false;
        }
        
        // Validasi 2: Cek ukuran file
        if ($file['size'] > self::MAX_FILE_SIZE) {
            Response::error(
                "Ukuran file: ".$file['size']." bytes, maksimal ".self::MAX_FILE_SIZE." bytes",
                400
            );
        }
        
        
        
        // Validasi 4: Cek extension file
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($ext, self::ALLOWED_EXT)) {
            error_log("[FileUpload] disallowed file extension: " . var_export($ext, true));
            return false;
        }
        
        // Generate nama file unik
        $fileName = self::generateFileName($ext);
        
        // Buat folder uploads jika belum ada
        if (!is_dir(self::UPLOAD_DIR)) {
            $mkdirResult = @mkdir(self::UPLOAD_DIR, 0777, true);
            error_log("[FileUpload] mkdir attempted for " . self::UPLOAD_DIR . ", result=" . var_export($mkdirResult, true));
        }
        $dirExists = is_dir(self::UPLOAD_DIR);
        error_log("[FileUpload] upload dir exists? " . var_export($dirExists, true) . " (path=" . self::UPLOAD_DIR . ")");

        // Tentukan path destination
        $uploadPath = self::UPLOAD_DIR . $fileName;
        error_log("[FileUpload] uploadPath=" . $uploadPath);

        // Move file dari tmp ke folder uploads
        $moveResult = move_uploaded_file($file['tmp_name'], $uploadPath);

        if ($moveResult) {
            return $fileName;
        }

        Response::error(
            "move_uploaded_file gagal. Path: ".$uploadPath,
            400
        );
    }
    
    /**
     * Method: deleteFile()
     * Fungsi: Hapus file dari server
     * Parameter:
     *   - $fileName (string): nama file yang akan dihapus
     * Return: boolean (true jika berhasil, false jika gagal)
     */
    public static function deleteFile($fileName) {
        // Tentukan path file
        $filePath = self::UPLOAD_DIR . $fileName;
        
        // Cek apakah file ada, jika ada hapus
        if (file_exists($filePath)) {
            return unlink($filePath);  // unlink = delete file
        }
        
        return false;  // File tidak ada
    }
    
    /**
     * Method: generateFileName()
     * Fungsi: Generate nama file yang unik & aman
     * Parameter:
     *   - $ext (string): extension file (jpg, png, dll)
     * Return: string (nama file unik)
     * 
     * Contoh output: 1704067200_5432.jpg
     */
    private static function generateFileName($ext) {
        // Kombinasi timestamp (detik saat ini) + random number
        $timestamp = time();            // Contoh: 1704067200
        $random = rand(1000, 9999);     // Contoh: 5432
        
        // Gabungkan: timestamp_random.extension
        $fileName = $timestamp . '_' . $random . '.' . $ext;
        
        return $fileName;
    }
}
?>