SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for wallboard
-- ----------------------------
DROP TABLE IF EXISTS `wallboard`;
CREATE TABLE `wallboard` (
  `wallboard_id` int(9) NOT NULL AUTO_INCREMENT,
  `avg_talk_time` varchar(255) NOT NULL,
  `avg_wait_time` varchar(255) NOT NULL,
  `calls_abandoned` int(9) NOT NULL,
  `calls_answered` int(9) NOT NULL,
  `calls_serviced_now` int(9) NOT NULL,
  `calls_waiting` int(9) NOT NULL,
  `longest_wait_time` varchar(255) NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`wallboard_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
