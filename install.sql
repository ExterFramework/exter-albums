CREATE TABLE IF NOT EXISTS `exter-albums` (
  `id`       INT(11) NOT NULL AUTO_INCREMENT,
  `owner`    VARCHAR(100) NOT NULL,
  `date`     DATE NOT NULL DEFAULT (CURRENT_DATE),
  `url`      TEXT NOT NULL,
  `video`    TEXT DEFAULT NULL,
  `uniq`     BIGINT(20) DEFAULT NULL,
  `category` VARCHAR(50) DEFAULT 'all',
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
