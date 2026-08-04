-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 20, 2026 at 03:08 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `recipehub`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `user_id`, `name`, `created_at`, `updated_at`) VALUES
(6, 1, 'makanan utama', '2026-07-19 23:12:03', '2026-07-19 23:12:03'),
(7, 1, 'minuman', '2026-07-19 23:12:47', '2026-07-19 23:12:47'),
(8, 1, 'dessert', '2026-07-19 23:13:04', '2026-07-19 23:13:04');

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

CREATE TABLE `recipes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `ingredients` text NOT NULL,
  `steps` text NOT NULL,
  `cooking_time` int(11) NOT NULL,
  `servings` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recipes`
--

INSERT INTO `recipes` (`id`, `user_id`, `category_id`, `name`, `description`, `ingredients`, `steps`, `cooking_time`, `servings`, `image`, `created_at`, `updated_at`) VALUES
(1, 1, 6, 'nasi goreng', 'Nasi goreng sederhana dengan telur, ayam, dan sayuran yang cocok untuk sarapan atau makan malam.', '- 2 piring nasi putih\n- 2 butir telur\n- 100 gram ayam suwir\n- 2 siung bawang putih\n- 3 siung bawang merah\n- 2 sdm kecap manis\n- 1 sdm saus tiram\n- Garam secukupnya\n- Merica secukupnya\n- Minyak goreng secukupnya\n- Irisan daun bawang', '1. Haluskan bawang merah dan bawang putih.\n2. Tumis bumbu hingga harum.\n3. Masukkan telur, orak-arik.\n4. Tambahkan ayam suwir lalu aduk rata.\n5. Masukkan nasi putih.\n6. Tambahkan kecap manis, saus tiram, garam, dan merica.\n7. Aduk hingga semua bumbu tercampur.\n8. Masukkan daun bawang lalu aduk sebentar.\n9. Angkat dan sajikan.', 20, 2, '1784455169_6039.jpg', '2026-07-17 07:14:31', '2026-07-19 23:12:26'),
(4, 1, 7, 'Jus Alpukat', 'Minuman alpukat yang lembut dan menyegarkan, cocok dinikmati saat cuaca panas.', '2 buah alpukat matang\n300 ml susu cair\n2 sdm susu kental manis\nEs batu secukupnya\nGula secukupnya', 'Belah dan keruk alpukat.\nMasukkan semua bahan ke blender.\nBlender hingga halus.\nTuang ke gelas.\nSajikan dingin.', 10, 2, '1784502860_4957.jpg', '2026-07-19 23:14:20', '2026-07-19 23:14:20');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `created_at`, `updated_at`) VALUES
(1, 'zidan', 'saya@gmail.com', '$2y$10$tlUw3vemWdPvX0n19qzADef.53EB80NR5bKDMrlk3uH1d13WKdtwK', '2026-07-16 03:09:58', '2026-07-16 03:09:58'),
(2, 'dante', 'raya@gmail.com', '$2y$10$8L9j8UBwl2ERuLhwM8ZbIe0XkTuGf4/4tjA0fY9t3Oz5oqrFNckA.', '2026-07-19 00:28:18', '2026-07-19 00:28:18'),
(3, 'fera', 'fera@gmail.com', '$2y$10$vImFGxPeKXHFN579YaxiouzFTDipB38XFsu3fqwyq5ysrC5jdu2ii', '2026-07-19 06:17:10', '2026-07-19 06:17:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_category` (`user_id`,`name`);

--
-- Indexes for table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `recipes`
--
ALTER TABLE `recipes`
  ADD CONSTRAINT `recipes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recipes_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
