CREATE TABLE IF NOT EXISTS `v_weed_plants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `stage` tinyint NOT NULL DEFAULT 1,
  `water` tinyint NOT NULL DEFAULT 100,
  `health` tinyint NOT NULL DEFAULT 100,
  `stageProgress` tinyint NOT NULL DEFAULT 0,
  `data` varchar(50) NOT NULL,
  `coords` tinytext NOT NULL,
  `harvestable` bit NOT NULL DEFAULT 0,
  `dead` bit NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP()
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;