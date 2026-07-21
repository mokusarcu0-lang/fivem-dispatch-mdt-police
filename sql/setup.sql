-- Database Setup Script for FiveM Police System

-- ============================================
-- DISPATCH CALLS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `dispatch_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_type` varchar(50) NOT NULL,
  `coords` varchar(255) NOT NULL,
  `description` varchar(255),
  `created_by` varchar(50),
  `assigned_to` varchar(50),
  `status` varchar(20) DEFAULT 'pending',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `closed_at` timestamp NULL,
  PRIMARY KEY (`id`),
  INDEX `status` (`status`),
  INDEX `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- WANTED PLAYERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `player_wanted` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizen_id` varchar(50) NOT NULL UNIQUE,
  `wanted_level` int(11) DEFAULT 0,
  `reason` varchar(255),
  `set_by` varchar(50),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_id` (`citizen_id`),
  INDEX `wanted_level` (`wanted_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- JAIL PLAYERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `player_jail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizen_id` varchar(50) NOT NULL UNIQUE,
  `jail_time` int(11) NOT NULL,
  `reason` varchar(255),
  `jailed_by` varchar(50),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `released_at` timestamp NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_id` (`citizen_id`),
  INDEX `jail_time` (`jail_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- PLAYER NOTES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `player_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizen_id` varchar(50) NOT NULL,
  `note` text NOT NULL,
  `created_by` varchar(50),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `citizen_id` (`citizen_id`),
  INDEX `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- POLICE LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS `police_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_name` varchar(50),
  `player_id` varchar(50),
  `action` varchar(100),
  `details` text,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `player_id` (`player_id`),
  INDEX `action` (`action`),
  INDEX `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- INSERT DEFAULT DATA (OPTIONAL)
-- ============================================

-- Example dispatch types (optional)
INSERT IGNORE INTO `dispatch_calls` (`call_type`, `coords`, `description`, `status`) 
VALUES 
  ('assault', '{"x": 425.5, "y": -979.5, "z": 29.4}', 'Támadás bejelentése', 'pending'),
  ('robbery', '{"x": 450.5, "y": -950.5, "z": 25.4}', 'Rablás az ARPA-ban', 'pending');

-- Grant permissions (if needed)
-- GRANT ALL PRIVILEGES ON `your_database`.`dispatch_calls` TO 'fivem_user'@'localhost';
-- GRANT ALL PRIVILEGES ON `your_database`.`player_wanted` TO 'fivem_user'@'localhost';
-- GRANT ALL PRIVILEGES ON `your_database`.`player_jail` TO 'fivem_user'@'localhost';
-- GRANT ALL PRIVILEGES ON `your_database`.`player_notes` TO 'fivem_user'@'localhost';
-- GRANT ALL PRIVILEGES ON `your_database`.`police_logs` TO 'fivem_user'@'localhost';
-- FLUSH PRIVILEGES;
