-- //For question 1
SELECT read_month, count(*) AS number_of_reads
FROM consumption
WHERE read_year = 2018
GROUP BY read_month;

-- // For question 2
SELECT DISTINCT customer_id 
FROM consumption 
WHERE read_year = 2018
  AND customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM consumption 
    WHERE read_year = 2018 
      AND read_month = 12
  )
;

-- // For question 3 
SELECT p.zipcode, cp.read_year, cp.read_month, (sum(total_gallons_used) / md.days) AS gpd
FROM property p 
INNER JOIN customer c ON p.property_id = c.property_id
INNER JOIN consumption cp ON c.customer_id = cp.customer_id
INNER JOIN month_days md ON cp.read_year = md.year AND cp.read_month = md.month
GROUP BY p.zipcode, cp.read_year, cp.read_month;

-- // For question 4
-- year over year
SELECT c1.customer_id, c1.read_month, concat(c1.read_year, '-', c2.read_year), c2.total_gallons_used / c1.total_gallons_used * 100 AS year_over_year
FROM (
    SELECT *
    FROM consumption 
) c1 LEFT JOIN (
    SELECT *
    FROM consumption 
) c2  ON c1.customer_id = c2.customer_id AND  c1.read_month = c2.read_month AND c1.read_year = c2.read_year - 1
WHERE c2.customer_id IS NOT NULL;

-- month over month
SELECT c1.customer_id, c1.read_year, concat(c1.read_month, '-', c2.read_month), c2.total_gallons_used / c1.total_gallons_used * 100 AS month_over_month
FROM (
    SELECT *
    FROM consumption 
    WHERE customer_id = 1
    AND read_year = 2018
) c1 LEFT JOIN (
    SELECT *
    FROM consumption 
    WHERE customer_id = 1
    AND read_year = 2018
) c2  ON c1.customer_id = c2.customer_id AND  c1.read_year = c2.read_year AND c1.read_month = c2.read_month - 1
 WHERE c2.customer_id IS NOT NULL;

-- // For question 5
SELECT c.name, p.address, p.city, p.state, p.zipcode
FROM consumption cp
INNER JOIN consumption_goal cg ON cp.customer_id = cg.customer_id AND cp.read_year = cg.read_year AND cp.read_month = cg.read_month AND cp.total_gallons_used > cg.goal_gallons
INNER JOIN customer c ON cp.customer_id = c.customer_id
INNER JOIN property p ON p.property_id = c.property_id
WHERE STR_TO_DATE(CONCAT(cp.read_year, '-', cp.read_month, '-01'), '%Y-%m-%d') > DATE_SUB(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-01'), '%Y-%m-%d'), INTERVAL 6 MONTH)
;


-- // Schema Design - Survey & Response
CREATE TABLE `survey` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_question` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `survey_id` int(11) unsigned NOT NULL DEFAULT '0',
  `question` varchar(1024) NOT NULL DEFAULT '',
  `text_or_choice` enum('text','choice') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `survey_id` (`survey_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_question_choice` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `survey_question_id` int(11) unsigned NOT NULL DEFAULT '0',
  `description` varchar(2048) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `survey_question_id` (`survey_question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `response_text` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `responder_id` varchar(40) DEFAULT '',
  `survey_question_id` int(11) unsigned NOT NULL DEFAULT '0',
  `answer` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `responder_id` (`responder_id`,`survey_question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `response_choice` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `responder_id` varchar(40) NOT NULL DEFAULT '',
  `survey_question_id` int(11) unsigned NOT NULL DEFAULT '0',
  `survey_question_choice_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `responder_id` (`responder_id`,`survey_question_id`),
  KEY `survey_question_id` (`survey_question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
