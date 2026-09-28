CreateThread(function()
    Wait(2000) 

    
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_warns` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `reason` text NOT NULL,
            `admin` varchar(50) NOT NULL,
            `date` timestamp NOT NULL DEFAULT current_timestamp(),
            `active` boolean NOT NULL DEFAULT 1,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_warns^0')
    end)

    
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_bans` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `ban_id` varchar(20) NOT NULL UNIQUE,
            `player_name` varchar(50) DEFAULT NULL,
            `license` varchar(50) DEFAULT NULL,
            `license2` varchar(50) DEFAULT NULL,
            `steam` varchar(50) DEFAULT NULL,
            `discord` varchar(50) DEFAULT NULL,
            `fivem` varchar(50) DEFAULT NULL,
            `xbl` varchar(50) DEFAULT NULL,
            `live` varchar(50) DEFAULT NULL,
            `ip` varchar(50) DEFAULT NULL,
            `reason` text NOT NULL,
            `banned_by_name` varchar(50) NOT NULL,
            `banned_by_identifier` varchar(50) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `expire` timestamp NULL DEFAULT NULL,
            `is_permanent` boolean NOT NULL DEFAULT 0,
            `active` boolean NOT NULL DEFAULT 1,
            `expired_at` timestamp NULL DEFAULT NULL,
            `evidence` text DEFAULT NULL,
            `notes` text DEFAULT NULL,
            PRIMARY KEY (`id`),
            INDEX `idx_license` (`license`),
            INDEX `idx_license2` (`license2`),
            INDEX `idx_steam` (`steam`),
            INDEX `idx_discord` (`discord`),
            INDEX `idx_fivem` (`fivem`),
            INDEX `idx_xbl` (`xbl`),
            INDEX `idx_live` (`live`),
            INDEX `idx_ip` (`ip`),
            INDEX `idx_active` (`active`),
            INDEX `idx_expire` (`expire`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_bans^0')
    end)

    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_reports` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `sender` varchar(50) NOT NULL,
            `type` varchar(20) NOT NULL DEFAULT 'player',
            `title` varchar(100) NOT NULL,
            `reported` varchar(50) DEFAULT NULL,
            `reason` text NOT NULL,
            `status` varchar(20) NOT NULL DEFAULT 'pending',
            `date` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_reports^0')
    end)
    
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_playtime` (
            `identifier` varchar(50) NOT NULL,
            `playtime` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_playtime^0')
    end)
    
    MySQL.query.await('SET FOREIGN_KEY_CHECKS = 1')

    
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_groups` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL UNIQUE,
            `color` varchar(20) DEFAULT '#3b82f6',
            `permissions` text DEFAULT NULL,
            `description` varchar(255) DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_groups^0')

    
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_staff` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL,
            `identifier` varchar(50) NOT NULL UNIQUE,
            `group_id` int(11) DEFAULT NULL,
            `status` ENUM('pending', 'approved', 'rejected', 'disabled') NOT NULL DEFAULT 'pending',
            `apply_reason` text DEFAULT NULL,
            `reject_reason` text DEFAULT NULL,
            `permissions` text DEFAULT NULL,
            `added_by` varchar(50) DEFAULT 'System',
            `is_active` boolean NOT NULL DEFAULT 1,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `approved_at` timestamp NULL DEFAULT NULL,
            `approved_by` varchar(50) DEFAULT NULL,
            `rejected_at` timestamp NULL DEFAULT NULL,
            `rejected_by` varchar(50) DEFAULT NULL,
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`),
            INDEX `idx_identifier` (`identifier`),
            INDEX `idx_status` (`status`),
            INDEX `idx_group_id` (`group_id`),
            INDEX `idx_is_active` (`is_active`),
            CONSTRAINT `fk_staff_group` FOREIGN KEY (`group_id`) REFERENCES `xeno_admin_groups` (`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_staff^0')

    
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_webhooks` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(100) NOT NULL,
            `url` text NOT NULL,
            `events` text DEFAULT NULL,
            `description` varchar(255) DEFAULT NULL,
            `is_active` boolean NOT NULL DEFAULT 1,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_webhooks^0')
    end)

    
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `xeno_admin_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `type` varchar(30) NOT NULL DEFAULT 'system',
            `message` text NOT NULL,
            `admin_name` varchar(50) DEFAULT NULL,
            `target_name` varchar(50) DEFAULT NULL,
            `details` text DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            INDEX `idx_type` (`type`),
            INDEX `idx_created` (`created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function()
        DebugLog('^2[Xeno-AdminMenu] Checked/Created table: xeno_admin_logs^0')
    end)
end)
