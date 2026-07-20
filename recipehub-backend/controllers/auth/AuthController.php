<?php

/**
 * File: controllers/auth/AuthController.php
 * Fungsi: Handle authentication (register & login)
 */

class AuthController
{

    // Property untuk User model
    private $user;

    /**
     * Constructor
     * Fungsi: Inisialisasi User model
     */
    public function __construct()
    {
        $this->user = new User();
    }

    /**
     * Method: register()
     * Fungsi: Handle user registration
     * Request: POST /auth/register
     * Body: { name, email, password }
     * Response: success atau error
     */
    public function register()
    {
        // 1. EXTRACT DATA DARI REQUEST
        // isset() = cek apakah key ada
        // trim() = hapus whitespace di awal & akhir
        $name = isset($_POST['name']) ? trim($_POST['name']) : null;
        $email = isset($_POST['email']) ? trim($_POST['email']) : null;
        $password = isset($_POST['password']) ? $_POST['password'] : null;

        // 2. VALIDASI INPUT

        // Cek semua field harus diisi
        if (empty($name) || empty($email) || empty($password)) {
            Response::badRequest("Semua field harus diisi");
        }

        // Validasi format email menggunakan FILTER_VALIDATE_EMAIL
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Response::badRequest("Format email tidak valid");
        }

        // Validasi password minimal 6 karakter
        if (strlen($password) < 6) {
            Response::badRequest("Password minimal 6 karakter");
        }

        // Cek apakah email sudah terdaftar
        if ($this->user->emailExists($email)) {
            // Status 409 = Conflict (resource sudah ada)
            Response::error("Email sudah terdaftar", 409);
        }

        // 3. CREATE USER DI DATABASE
        // Buat array data untuk di-pass ke model
        $data = [
            'name' => $name,
            'email' => $email,
            'password' => $password
        ];

        // Call User model create method
        // Method ini akan hash password & INSERT ke database
        $userId = $this->user->create($data);

        // Cek apakah create berhasil
        if (!$userId) {
            Response::error("Gagal membuat user, silakan coba lagi");
        }

        // 4. RETURN SUCCESS RESPONSE
        Response::success(null, "Registrasi berhasil. Silakan login");
    }

    /**
     * Method: login()
     * Fungsi: Handle user login
     * Request: POST /auth/login
     * Body: { email, password }
     * Response: { user_id, name, email } atau error
     */
    public function login()
    {
        // 1. EXTRACT DATA DARI REQUEST
        $email = isset($_POST['email']) ? trim($_POST['email']) : null;
        $password = isset($_POST['password']) ? $_POST['password'] : null;

        // 2. VALIDASI INPUT
        if (empty($email) || empty($password)) {
            Response::badRequest("Email dan password harus diisi");
        }

        // 3. FIND USER BY EMAIL
        // Query ke database untuk cari user dengan email ini
        $userData = $this->user->findByEmail($email);

        // Cek apakah user ditemukan
        if (!$userData) {
            // Status 401 = Unauthorized
            Response::error("Email tidak ditemukan", 401);
        }

        // 4. VERIFY PASSWORD
        // Bandingkan password yang diinput dengan hash di database
        // password_verify($plain_password, $hashed_password)
        if (!password_verify($password, $userData['password'])) {
            Response::error("Password salah", 401);
        }

        // 5. RETURN SUCCESS RESPONSE
        // Return data yang dibutuhkan Flutter
        $response = [
            'user_id' => $userData['id'],
            'name' => $userData['name'],
            'email' => $userData['email']
        ];

        Response::success($response, "Login berhasil");
    }
}