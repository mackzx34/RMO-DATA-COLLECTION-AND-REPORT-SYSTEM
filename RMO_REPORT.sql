-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 18, 2024 at 11:17 AM
-- Server version: 8.0.39-0ubuntu0.22.04.1
-- PHP Version: 8.1.2-1ubuntu2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `RMO_REPORT`
--

-- --------------------------------------------------------

--
-- Table structure for table `DATA`
--

CREATE TABLE `DATA` (
  `id` int NOT NULL,
  `rmo_id` int DEFAULT NULL,
  `month_id` int DEFAULT NULL,
  `total_collected` decimal(15,2) DEFAULT NULL,
  `BALANCE` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `DATA`
--

INSERT INTO `DATA` (`id`, `rmo_id`, `month_id`, `total_collected`, `BALANCE`) VALUES
(129, 100, 106, '500000000.00', 1500000000),
(130, 100, 107, '500000000.00', 1000000000),
(131, 100, 108, '500000000.00', 500000000);

--
-- Triggers `DATA`
--
DELIMITER $$
CREATE TRIGGER `update_balance` BEFORE INSERT ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;
    
    SET NEW.BALANCE = target - COALESCE(NEW.total_collected, 0);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_balance_before_insert` BEFORE INSERT ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    DECLARE total_collected_sum BIGINT;

    -- Get the yearly target for the RMO office
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;

    -- Calculate the total collected so far for the RMO office
    SELECT COALESCE(SUM(total_collected), 0) INTO total_collected_sum
    FROM DATA
    WHERE rmo_id = NEW.rmo_id AND month_id <= NEW.month_id;

    -- Set the new balance
    SET NEW.BALANCE = target - total_collected_sum - COALESCE(NEW.total_collected, 0);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_balance_before_update` BEFORE UPDATE ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    DECLARE total_collected_sum BIGINT;

    -- Get the yearly target for the RMO office
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;

    -- Calculate the total collected so far for the RMO office
    SELECT COALESCE(SUM(total_collected), 0) INTO total_collected_sum
    FROM DATA
    WHERE rmo_id = NEW.rmo_id AND month_id <= NEW.month_id AND id <> NEW.id;

    -- Set the updated balance
    SET NEW.BALANCE = target - total_collected_sum - COALESCE(NEW.total_collected, 0);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_balance_on_update` BEFORE UPDATE ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;

    SET NEW.BALANCE = target - COALESCE(NEW.total_collected, 0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `MONTHS`
--

CREATE TABLE `MONTHS` (
  `id` int NOT NULL,
  `month_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `year` varchar(50) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `MONTHS`
--

INSERT INTO `MONTHS` (`id`, `month_name`, `year`) VALUES
(106, 'July', '2024'),
(107, 'August', '2024'),
(108, 'September', '2024'),
(109, 'October', '2024'),
(110, 'November', '2024'),
(111, 'December', '2024'),
(112, 'January', '2025'),
(113, 'February', '2025'),
(114, 'March', '2025'),
(115, 'April', '2025'),
(116, 'May', '2025'),
(117, 'June', '2025');

-- --------------------------------------------------------

--
-- Table structure for table `RMO_OFFICE`
--

CREATE TABLE `RMO_OFFICE` (
  `id` int NOT NULL,
  `office_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `office_location` varchar(50) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `RMO_OFFICE`
--

INSERT INTO `RMO_OFFICE` (`id`, `office_name`, `office_location`) VALUES
(100, 'Arusha', 'Arusha'),
(101, 'Kagera', 'Kagera'),
(102, 'Chunya', 'Mbeya'),
(103, 'Dodoma', 'Dodoma'),
(104, 'Geita', 'Geita'),
(105, 'Handeni', 'Tanga'),
(106, 'Kahama', 'Shinyanga'),
(107, 'Kigoma', 'Kigoma'),
(108, 'Mbeya', 'Mbeya'),
(109, 'Mererani-RMO', 'Manyara'),
(110, 'kilimanjaro', 'Kilimanjaro'),
(111, 'Katavi', 'Katavi');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_roles`
--

CREATE TABLE `tbl_roles` (
  `id` int NOT NULL COMMENT 'role_id',
  `role` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'role_text'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_roles`
--

INSERT INTO `tbl_roles` (`id`, `role`) VALUES
(1, 'Admin'),
(2, 'User');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `id` int NOT NULL,
  `fname` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `lname` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `position` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RMO_OFFICE_NAME` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `mobile` varchar(25) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `roleid` tinyint DEFAULT NULL,
  `isActive` tinyint DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remember_me` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`id`, `fname`, `lname`, `username`, `position`, `email`, `RMO_OFFICE_NAME`, `password`, `mobile`, `roleid`, `isActive`, `created_at`, `updated_at`, `remember_me`) VALUES
(7, 'admin', 'mduma', 'admin.madini', 'Director ', 'adminmadini@gmail.com', 'Tanga', '$2y$10$2tGJwjvZcL/pyXuBYSRvQOfSgsJ6DtlE2zy1.372WPUDH4TF2GERu', '01717090233', 1, 1, '2020-03-12 16:23:01', '2020-03-12 16:23:01', 'ce5ee71b5f412dbcc8420309171736555e4890264929733b7ef8916146d0e113'),
(12, 'John', 'ally', 'Rayhan', 'IT Officer', 'rayhankabir@gmail.com', 'Mererani', '188000e1f0fb4075ae1c659697b96296f982cdc4', '01717090233', 2, 0, '2020-03-12 18:20:24', '2020-03-12 18:20:24', NULL),
(23, 'Amina', 'Ally', 'amina.ally', 'Manager', 'aminaally34@gmail.com', 'Dodoma', '$2y$10$MkJcZLxKygrX6DAvsJjK3u5.o3yL8U7LbZIVub0UfU8jhY1oHKD5K', '0675654567', 2, 1, '2024-08-16 16:23:52', '2024-08-16 16:23:52', NULL),
(24, 'Fatuma', 'Jadi', 'fatuma.jady', 'Manager', 'fatumajady@gmail.com', 'Dar es salaam', '$2y$10$ZJ3HwRwCJ3cgdaqcdvKi6exNrdpYQmxiv8mEzjTEV6rInH/KSUMjm', '0675654567', 2, 1, '2024-08-16 16:26:38', '2024-08-16 16:26:38', NULL),
(25, 'Salim', 'Kachemela', 'salim.kachemela', 'IT Officer', 'salimkache34@gmail.com', 'Dodoma', '$2y$10$c3XHTwuTjS9lRuc8DaWnPOkConVzgUZ6Gc9CdIi0xKXb3nhYTbmXy', '0765453456', 2, 1, '2024-08-16 16:54:52', '2024-08-16 16:54:52', NULL),
(26, 'Job', 'Ally', 'job.ally', 'Manager Habari', 'jobally@gmail.com', 'Dodoma', '$2y$10$ZT3QnaGaNohVdgWpOlDpsuJZYj./9PKoH7.hET0mvdNFPzgiA.QuS', '0765453456', 2, 1, '2024-08-17 11:44:10', '2024-08-17 11:44:10', NULL),
(27, 'Job', 'Ally', 'job.ally', 'Manager Habari', 'jobally@gmail.com', 'Dodoma', '$2y$10$6Vyoj4TrGzyr8/5e6RacW.ECxpwAKbWdgJ9k1pMXZmeWDRL67OU76', '0765453456', 2, 1, '2024-08-17 11:48:32', '2024-08-17 11:48:32', NULL),
(28, 'Job', 'Ally', 'job.ally', 'Manager Habari', 'jobally@gmail.com', 'Dodoma', '$2y$10$PkCQ5ND4Om9JJQGSrOcmiuLZUBnUxI6Xt1rAqS/PNDmtF/odLMvP.', '0765453456', 2, 1, '2024-08-17 11:53:48', '2024-08-17 11:53:48', NULL),
(29, 'Job', 'Ally', 'job.ally', 'Manager Habari', 'jobally@gmail.com', 'Dodoma', '$2y$10$h9okCMlY1ZTak/isfsZ9xOk66xnAov3Ao8lgJGBgevEjXZKtOhre2', '0765453456', 2, 1, '2024-08-17 11:55:11', '2024-08-17 11:55:11', NULL),
(30, 'Fatuma', 'Jadi', 'fatuma.jady', 'Manager IT', 'fatyma23@gmail.com', 'Dodoma', '$2y$10$HyiJigIZZuLOtET0.Y8zvuk928DVMttToJLU.HnHVW3aUF3BzFIDW', '0675654567', 2, 1, '2024-08-17 11:59:37', '2024-08-17 11:59:37', NULL),
(31, 'Fatuma', 'Jadi', 'fatuma.jady', 'Manager IT', 'fatyma23@gmail.com', 'Dodoma', '$2y$10$Za8Tk3VWtGM0DIviBwBQvOyLCHhkRkGbX8s3sdzhUAW6WzsmD2yNe', '0675654567', 2, 1, '2024-08-17 12:00:17', '2024-08-17 12:00:17', NULL),
(32, 'Hello', 'Halima', 'hellogani', 'IT', 'salimkache34@gmail.com', 'Dar es salaam', '$2y$10$hdy87nTQQFaynBlaTnPnHO5Eg9Hkq2DYUTIr6H/W7LytdEEzYNe7e', '0765453456', 2, 0, '2024-08-17 12:04:12', '2024-08-17 12:04:12', NULL),
(33, 'Joseph', 'Roja', 'joseph.roja', 'Junior IT', 'josephroja99@gmail.com', 'Dodoma', '$2y$10$27xIOrcKYl6s2UCTuPbXs.NRNh1zc.yywehRA4zu43PjeG5BSYTGG', '0747793489', 2, 1, '2024-08-17 13:38:43', '2024-08-17 13:38:43', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `YEARLY_TARGETS`
--

CREATE TABLE `YEARLY_TARGETS` (
  `id` int NOT NULL,
  `rmo_id` int NOT NULL,
  `year` year NOT NULL,
  `target` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `YEARLY_TARGETS`
--

INSERT INTO `YEARLY_TARGETS` (`id`, `rmo_id`, `year`, `target`) VALUES
(1, 100, 2024, 2000000000),
(2, 101, 2024, 350000000);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `DATA`
--
ALTER TABLE `DATA`
  ADD PRIMARY KEY (`id`),
  ADD KEY `rmo_id` (`rmo_id`),
  ADD KEY `month_id` (`month_id`);

--
-- Indexes for table `MONTHS`
--
ALTER TABLE `MONTHS`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `RMO_OFFICE`
--
ALTER TABLE `RMO_OFFICE`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_roles`
--
ALTER TABLE `tbl_roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `YEARLY_TARGETS`
--
ALTER TABLE `YEARLY_TARGETS`
  ADD PRIMARY KEY (`id`),
  ADD KEY `rmo_id` (`rmo_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `DATA`
--
ALTER TABLE `DATA`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT for table `MONTHS`
--
ALTER TABLE `MONTHS`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `RMO_OFFICE`
--
ALTER TABLE `RMO_OFFICE`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT for table `tbl_roles`
--
ALTER TABLE `tbl_roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT 'role_id', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `YEARLY_TARGETS`
--
ALTER TABLE `YEARLY_TARGETS`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `DATA`
--
ALTER TABLE `DATA`
  ADD CONSTRAINT `DATA_ibfk_1` FOREIGN KEY (`rmo_id`) REFERENCES `RMO_OFFICE` (`id`),
  ADD CONSTRAINT `DATA_ibfk_2` FOREIGN KEY (`month_id`) REFERENCES `MONTHS` (`id`);

--
-- Constraints for table `YEARLY_TARGETS`
--
ALTER TABLE `YEARLY_TARGETS`
  ADD CONSTRAINT `YEARLY_TARGETS_ibfk_1` FOREIGN KEY (`rmo_id`) REFERENCES `RMO_OFFICE` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
