-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 18, 2024 at 10:19 PM
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
  `BALANCE` bigint DEFAULT NULL,
  `PERCENTAGE_COLLECTED` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `DATA`
--

INSERT INTO `DATA` (`id`, `rmo_id`, `month_id`, `total_collected`, `BALANCE`, `PERCENTAGE_COLLECTED`) VALUES
(1, 100, 106, '400000000.00', 1600000000, '20.00'),
(2, 101, 106, '300000000.00', 300000000, '50.00'),
(3, 102, 106, '350000000.00', 650000000, '35.00'),
(4, 103, 106, '340000000.00', 5660000000, '5.67'),
(5, 104, 106, '580000000.00', 11420000000, '4.83'),
(6, 105, 106, '56000000.00', 344000000, '14.00'),
(7, 106, 106, '670000000.00', 12330000000, '5.15'),
(8, 107, 106, '34000000.00', 566000000, '5.67'),
(9, 108, 106, '250000000.00', 550000000, '31.25'),
(10, 109, 106, '560000000.00', 24440000000, '2.24'),
(11, 110, 106, '45000000.00', 935000000, '4.59'),
(12, 110, 107, '15000000.00', 920000000, '6.12'),
(13, 102, 107, '250000000.00', 400000000, '60.00');

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
DELIMITER $$
CREATE TRIGGER `update_percentage_collected_before_insert` BEFORE INSERT ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    DECLARE cumulative_total_collected BIGINT;

    -- Get the yearly target for the RMO office
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;

    -- Calculate the cumulative total collected up to and including the current month
    SELECT COALESCE(SUM(total_collected), 0) INTO cumulative_total_collected
    FROM DATA
    WHERE rmo_id = NEW.rmo_id AND month_id <= NEW.month_id;

    -- Add the new entry's collected amount to the cumulative total
    SET cumulative_total_collected = cumulative_total_collected + NEW.total_collected;

    -- Calculate the percentage collected
    IF target > 0 THEN
        SET NEW.PERCENTAGE_COLLECTED = (cumulative_total_collected / target) * 100;
    ELSE
        SET NEW.PERCENTAGE_COLLECTED = 0;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_percentage_collected_before_update` BEFORE UPDATE ON `DATA` FOR EACH ROW BEGIN
    DECLARE target BIGINT;
    DECLARE total_collected_sum BIGINT;

    -- Get the yearly target for the RMO office
    SELECT yt.target INTO target
    FROM YEARLY_TARGETS yt
    JOIN MONTHS m ON m.year = yt.year
    WHERE yt.rmo_id = NEW.rmo_id AND m.id = NEW.month_id;

    -- Calculate the total collected up to and including the current month
    SELECT COALESCE(SUM(total_collected), 0) INTO total_collected_sum
    FROM DATA
    WHERE rmo_id = NEW.rmo_id AND month_id <= NEW.month_id AND id <> NEW.id;

    -- Calculate the percentage collected
    IF target > 0 THEN
        SET NEW.PERCENTAGE_COLLECTED = (total_collected_sum / target) * 100;
    ELSE
        SET NEW.PERCENTAGE_COLLECTED = 0;
    END IF;
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
(23, 'Amina', 'Ally', 'amina.ally', 'Manager', 'aminaally34@gmail.com', 'Dodoma', '$2y$10$jVHXcauFB2dakyaBKdDrcuw9hf49e7S.23SGyCDqHniJ1BvillvOW', '0675654567', 2, 1, '2024-08-16 16:23:52', '2024-08-18 18:59:43', NULL),
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
(5, 100, 2024, 2000000000),
(6, 101, 2024, 600000000),
(7, 102, 2024, 1000000000),
(8, 103, 2024, 6000000000),
(9, 104, 2024, 12000000000),
(10, 105, 2024, 400000000),
(11, 106, 2024, 13000000000),
(12, 107, 2024, 600000000),
(13, 108, 2024, 800000000),
(14, 109, 2024, 25000000000),
(15, 110, 2024, 980000000),
(19, 111, 2024, 350000000);

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `YEARLY_TARGETS`
--
ALTER TABLE `YEARLY_TARGETS`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
