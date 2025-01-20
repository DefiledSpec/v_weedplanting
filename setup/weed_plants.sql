CREATE TABLE IF NOT EXISTS `v_weed_plants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stage` tinyint(4) NOT NULL DEFAULT 1,
  `water` tinyint(4) NOT NULL DEFAULT 100,
  `health` tinyint(4) NOT NULL DEFAULT 100,
  `stageProgress` tinyint(4) NOT NULL DEFAULT 0,
  `data` text NOT NULL,
  `coords` tinytext NOT NULL,
  `harvestable` bit(1) NOT NULL DEFAULT b'0',
  `dead` bit(1) NOT NULL DEFAULT b'0',
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4;
