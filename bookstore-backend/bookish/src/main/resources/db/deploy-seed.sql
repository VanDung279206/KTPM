-- Fresh deployment: schema and public book catalog only.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE `authors` (
  `author_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `bio` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  PRIMARY KEY (`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `book_authors` (
  `book_id` int NOT NULL,
  `author_id` int NOT NULL,
  PRIMARY KEY (`book_id`,`author_id`),
  KEY `author_id` (`author_id`),
  CONSTRAINT `book_authors_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`),
  CONSTRAINT `book_authors_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `book_categories` (
  `book_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`book_id`,`category_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `book_categories_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`),
  CONSTRAINT `book_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `books` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `price` decimal(38,2) DEFAULT NULL,
  `stock` int DEFAULT NULL,
  `sale_percent` int DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted` bit(1) DEFAULT NULL,
  PRIMARY KEY (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cart` (
  `cart_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`cart_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cart_items` (
  `cart_item_id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int DEFAULT NULL,
  `book_id` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  PRIMARY KEY (`cart_item_id`),
  KEY `cart_id` (`cart_id`),
  KEY `book_id` (`book_id`),
  CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`cart_id`),
  CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `chatbot_logs` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `message` text,
  `response` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`chat_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `chatbot_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `notifications` (
  `notification_id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `is_read` bit(1) NOT NULL,
  `link` varchar(500) DEFAULT NULL,
  `message` text,
  `title` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `FK9y21adhxn0ayjhfocscqox7bh` (`user_id`),
  CONSTRAINT `FK9y21adhxn0ayjhfocscqox7bh` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `order_items` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `book_id` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `price` decimal(38,2) DEFAULT NULL,
  PRIMARY KEY (`order_item_id`),
  KEY `order_id` (`order_id`),
  KEY `book_id` (`book_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `order_promotions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `promotion_id` int NOT NULL,
  `discount_type` varchar(20) NOT NULL,
  `discount_amount` decimal(38,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `promotion_id` (`promotion_id`),
  CONSTRAINT `order_promotions_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `order_promotions_ibfk_2` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `total_price` decimal(38,2) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `shipping_address` text,
  `created_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `shipping_fee` decimal(38,2) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `subtotal` decimal(38,2) DEFAULT NULL,
  `discount_amount` decimal(38,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `promotion_usage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promotion_id` int NOT NULL,
  `user_id` int NOT NULL,
  `order_id` int NOT NULL,
  `used_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_promotion_user` (`promotion_id`,`user_id`),
  KEY `user_id` (`user_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `promotion_usage_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`),
  CONSTRAINT `promotion_usage_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `promotion_usage_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `promotions` (
  `promotion_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `discount_type` enum('PERCENT','FIXED','FREESHIP') DEFAULT NULL,
  `discount_value` decimal(38,2) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `usage_limit` int DEFAULT NULL,
  `used_count` int DEFAULT NULL,
  `min_order_value` decimal(38,2) DEFAULT NULL,
  `max_discount` decimal(38,2) DEFAULT NULL,
  PRIMARY KEY (`promotion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `return_requests` (
  `return_id` int NOT NULL AUTO_INCREMENT,
  `account_holder` varchar(255) DEFAULT NULL,
  `admin_note` text,
  `bank_account` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `reason` enum('BROKEN','CHANGE_MIND','NOT_AS_DESCRIBED','OTHER','WRONG_BOOK') NOT NULL,
  `refund_amount` decimal(38,2) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`return_id`),
  KEY `FKbski88d6kewx0cbj5pk7nes01` (`order_id`),
  KEY `FK6pd9hi2rbbct43io2pgcma1sh` (`user_id`),
  CONSTRAINT `FK6pd9hi2rbbct43io2pgcma1sh` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKbski88d6kewx0cbj5pk7nes01` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `book_id` int DEFAULT NULL,
  `rating` int DEFAULT NULL,
  `comment` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `UK8dwwvmbh89prx5sbwddb860tc` (`user_id`,`book_id`),
  KEY `book_id` (`book_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `role` enum('USER','STAFF','ADMIN') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `verification_code` varchar(255) DEFAULT NULL,
  `verification_code_expiry` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `wishlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wishlist_user_book` (`user_id`,`book_id`),
  KEY `fk_wishlist_book` (`book_id`),
  KEY `idx_wishlist_user` (`user_id`),
  CONSTRAINT `fk_wishlist_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `authors` VALUES (5,'Paulo Coelho','Nhà văn người Brazil, nổi tiếng với tiểu thuyết Nhà Giả Kim.','1947-08-24'),(7,'Dale Carnegie','Tác giả người Mỹ, nổi tiếng với các cuốn sách kỹ năng sống và giao tiếp.','1888-11-24'),(8,'Napoleon Hill','Tác giả người Mỹ, nổi tiếng với các triết lý thành công và tư duy tích cực.','1883-10-26'),(9,'Haruki Murakami','Tiểu thuyết gia người Nhật nổi tiếng thế giới với văn phong huyền bí độc đáo.','1949-01-13'),(11,'Antoine de Saint-Exup├⌐ry','Nhà văn và phi công người Pháp, tác giả cuốn Hoàng Tử Bé.','1900-06-29'),(12,'Victor Hugo','Đại văn hào người Pháp, tác giả cuốn Những Người Khốn Khổ.','1802-02-26'),(13,'Robin Sharma','Tác giả và diễn giả người Canada chuyên về phát triển bản thân và lãnh đạo.','1964-06-16'),(15,'Tô Hoài','Nhà văn Việt Nam nổi tiếng với Dế Mèn Phiêu Lưu Ký.','1920-09-27'),(16,'Stephen King','Vua truyện kinh dị người Mỹ.','1947-09-21'),(17,'Fyodor Dostoevsky','Đại văn hào người Nga, tác giả cuốn Tội Ác Và Hình Phạt.','1821-11-11'),(18,'George Orwell','Nhà văn người Anh nổi tiếng với các tác phẩm châm biếm chính trị xã hội.','1903-06-25'),(19,'Khuyß║┐t danh','Tác giả dân gian Việt Nam.',NULL),(20,'Vũ Trọng Phụng','Nhà văn hiện thực trào phúng xuất sắc của văn học Việt Nam.','1912-10-20'),(21,'Ngô Tất Tố','Nhà văn hiện thực Việt Nam, tác giả của Tắt Đèn.','1894-01-01'),(22,'Nguyễn Du','Đại thi hào dân tộc Việt Nam, tác giả của Truyện Kiều.','1765-01-03'),(23,'Nam Cao','Là nhà văn phê phán xã hội phong kiến.','1917-10-29'),(24,'Cố Mạn','Nữ tác giả ngôn tình nổi tiếng Trung Quốc với các tác phẩm Bên Nhau Trọn Đời, Yêu Em Từ Cái Nhìn Đầu Tiên.','1981-01-01'),(25,'Diệp Lạc Vô Tâm','Nữ tác giả ngôn tình nổi tiếng Trung Quốc với nhiều tác phẩm xuất sắc.','1985-01-01'),(27,'Lâu Vũ Tình','Tác giả ngôn tình Trung Quốc nổi tiếng với Thất Tịch Không Mưa.','1987-01-01'),(29,'Đường Thất Công Tử','Nữ tác giả ngôn tình cổ đại Trung Quốc, nổi tiếng với Tam Sinh Tam Thế.','1979-01-01'),(31,'Tuế Kiến','Là một tác giả truyện ngôn tình Trung Quốc.','1998-01-01'),(32,'Trúc Dĩ','Nữ tác giả truyện ngôn tình Trung Quốc thế hệ 9x, nổi tiếng với thể loại thanh xuân ngọt ngào như Khó Dỗ Dành, Vụng trộm không thể giấu.','1999-01-01'),(33,'Thiên Sơn Trà Khách','Nữ tác giả ngôn tình Trung Quốc nổi tiếng với các tác phẩm cổ đại, trọng sinh, nữ cường như Tướng Môn Độc Hậu.','1992-01-01'),(34,'J. K. Rowling','Nữ nhà văn người Anh, tác giả của bộ tiểu thuyết giả tưởng nổi tiếng thế giới Harry Potter.','1965-07-31');

INSERT INTO `book_authors` VALUES (4,5),(6,7),(20,15),(25,18),(22,21),(28,22),(29,23),(30,24),(31,24),(32,25),(34,27),(37,29),(41,31),(40,32),(45,32),(42,33),(43,34),(44,34);

INSERT INTO `book_categories` VALUES (4,6),(6,7),(20,9),(22,10),(25,10),(28,10),(29,10),(30,16),(31,16),(32,16),(34,16),(37,16),(40,16),(41,16),(42,16),(45,16),(43,17),(44,17),(43,18),(44,18);

INSERT INTO `books` VALUES (4,'Nhà Giả Kim','Cuốn tiểu thuyết nổi tiếng của Paulo Coelho kể về hành trình đi tìm kho báu và ý nghĩa cuộc đời của chàng chăn cừu Santiago.',89000.00,49,10,'/uploads/nha_gia_kim.jpg','2026-03-19 20:07:52',_binary '\0'),(6,'Đắc Nhân Tâm','Cuốn sách kinh điển về nghệ thuật giao tiếp và chinh phục lòng người của Dale Carnegie.',98000.00,80,10,'/uploads/dac_nhan_tam.jpg','2026-03-19 20:11:13',_binary '\0'),(20,'Dế Mèn Phiêu Lưu Ký','Câu chuyện phiêu lưu của chú dế mèn dũng cảm qua ngòi bút tài hoa của Tô Hoài.',55000.00,88,0,'/uploads/de_men_phieu_luu_ki.jpg','2026-03-23 09:57:01',_binary '\0'),(22,'Tắt Đèn','Tác phẩm hiện thực xuất sắc của Ngô Tất Tố về số phận người nông dân Việt Nam trước Cách mạng.',48000.00,80,0,'/uploads/tat_den.jpg','2026-03-23 09:57:01',_binary ''),(25,'Trại Súc Vật','Ngụ ngôn chính trị sắc bén của George Orwell về cách quyền lực bị lạm dụng.',85000.00,50,5,'/uploads/trai_suc_vat.jpg','2026-03-23 09:57:01',_binary ''),(28,'Truyện Kiều','Kiệt tác văn học Việt Nam của Nguyễn Du, kể về cuộc đời đầy bi kịch của nàng Kiều tài sắc.',75000.00,0,0,'/uploads/truyen_kieu.jpg','2026-03-23 09:57:01',_binary '\0'),(29,'Lão Hạc','Truyện ngắn cảm động của Nam Cao về người nông dân nghèo giàu lòng tự trọng và tình yêu thương.',42000.00,84,0,'/uploads/lao_hac.jpg','2026-03-23 09:57:01',_binary '\0'),(30,'Bên Nhau Trọn Đời','Câu chuyện tình yêu đầy cảm động giữa Hà Dĩ Thâm và Triệu Mặc Sênh — từ ghế nhà trường qua bao biến cố mới về bên nhau. Tác phẩm đã được chuyển thể thành phim truyền hình đình đám.',89000.00,98,10,'/uploads/ben_nhau_tron_doi.jpg','2026-03-23 10:24:04',_binary '\0'),(31,'Yêu Em Từ Cái Nhìn Đầu Tiên','Chuyện tình ngọt ngào giữa Tiêu Nại và Bối Vi Vi bắt đầu từ thế giới game online. Mối tình xứng đôi vừa lứa, trong sáng và đầy lãng mạn của tuổi học trò.',85000.00,89,5,'/uploads/yeu_em_tu_cai_nhin_dau_tien.jpg','2026-03-23 10:24:04',_binary '\0'),(32,'Mãi Mãi Là Bao Xa','Câu chuyện tình yêu xa của nhà khoa học và cô nữ sinh năng động. Sau bao năm xa cách tưởng chừng không thể gặp lại, họ đã quay về bên nhau sống cuộc đời hạnh phúc.',82000.00,84,0,'/uploads/mai_mai_la_bao_xa.jpg','2026-03-23 10:24:04',_binary '\0'),(34,'Thất Tịch Không Mưa','Mối tình buồn đầy xúc động của Thẩm Thiên Tình — yêu thầm người anh trai cùng cha khác mẹ suốt bao năm. Câu chuyện ngược tâm khiến hàng triệu độc giả rơi nước mắt.',88000.00,78,10,'/uploads/that_tich_khong_mua.jpg','2026-03-23 10:24:04',_binary '\0'),(37,'Tam Sinh Tam Thế Chẩm Thượng Thư','Chuyện tình xuyên ba kiếp luân hồi của Bạch Phượng Cửu và Dạ Hoa — Đế quân Thiên Cung. Bối cảnh tiên giới huyền ảo tráng lệ với những tình tiết bi thương, lãng mạn khó quên.',95000.00,84,10,'/uploads/tam_sinh_tam_the.jpg','2026-03-23 10:24:04',_binary '\0'),(40,'Khó dỗ dành','Thông tin chi tiết về sách truyện Khó Dỗ Dành:\nTác giả: Trúc Dĩ.\nThể loại: Ngôn tình, hiện đại, lãng mạn, gương vỡ lại lành.\nNhân vật chính: Ôn Dĩ Phàm (xinh đẹp, nội tâm phức tạp) và Tang Diên (thâm tình, kiêu ngạo).\nNội dung: Câu chuyện kể về sự gặp lại của hai người bạn học cũ. Dù trải qua nhiều hiểu lầm và thử thách, họ vẫn dành cho nhau tình yêu chân thành và nỗ lực vượt qua khó khăn để đến với nhau.',2000.00,0,0,'/uploads/kho_do_danh_2.jpg','2026-03-25 22:41:16',_binary '\0'),(41,'Hồ Điệp và Kình Ngư','“Tuổi thọ của một con bướm nằm trong khoảng ba ngày đến một tháng, mà đa số các con bướm chỉ có một tuần tuổi thọ.”\n\n“Em cũng giống chúng vậy, sinh mạng chỉ kéo dài vài tháng thôi, có lẽ còn ngắn hơn thế nữa.”\n\n_\n\nLần đầu tiên Hồ Điệp gặp Kinh Du, anh cho rằng cô là thiếu nữ chán đời muốn tự tử.\n\nLần thứ hai gặp nhau, anh chẳng mấy bận tâm nói với Hồ Điệp rằng: “Hôm nay nếu cậu nhảy xuống thì tôi sẽ không cứu cậu nữa đâu.”\n\nVề sau lại đến cô bảo anh: “Kinh Du, đừng đau khổ vì em.”\n\nThật lâu sau này, Kinh Du trở lại sân đấu và đạt được vinh quang thuộc về mình.\n\nDưới ánh đèn sáng ngời, anh chợt nhớ lại giọng nói và dáng vẻ của cô thiếu nữ ấy rồi thốt ra một câu không đầu không đuôi trước muôn vàn người — “Anh không đau khổ, chỉ là cảm thấy vào khoảnh khắc này, có em ở đây thì sẽ tốt hơn biết bao.”\n\n“Anh là cá voi ngao du đại dương, chợt vào một ngày tình cờ, một chú bướm vô tình xông vào tần số của anh. Đó là giây phút đẹp đẽ nhất trong cuộc đời anh.”\n\n*\n\nThiếu nữ mắc bệnh ung thư x Thiếu niên bơi lội\n\nTruyện ngắn/BE\n\nHồ Điệp là vận động viên trượt băng nghệ thuật, sau đó cô qua đời vào mùa hè\n\nCâu đầu tiên trong văn án là nguồn internet\n\nTag: Hoa quý mùa mưa, nhân duyên tình cờ gặp gỡ, thiên chi kiều tử\n\nNhân vật chính: Hồ Điệp, Kinh Du\n\nMột câu giới thiệu đơn giản: Khoảnh khắc đẹp đẽ nhất trong cuộc đời\n\nLập ý: Dù cho con đường phía trước đầy khó khăn, cũng đừng quên mất ước mơ',2000.00,0,0,'/uploads/HoDiep_KinhNgu.jpg','2026-03-29 21:49:46',_binary '\0'),(42,'Tướng môn độc hậu','Đích nữ nhà tướng quân, tính tình ôn nhu trầm tĩnh, lưu luyến si mê Định Vương, hy sinh vì tình.\n\nSáu năm theo phò tá chỉ mong trở thành mẫu nghi thiên hạ.\n\nGiúp hắn đấu tranh giành thiên hạ, lập quốc hưng thịnh, còn mạo hiểm ở lại nơi đất khách quê người làm con tin, nhưng sau năm năm trở về, hậu cung đã không còn chỗ dung thân.\n\nMỹ nhân trong ngực hắn kiều diễm tươi cười: “Tỷ tỷ, giang sơn nay đã yên ổn rồi, ngươi cũng nên lui đi.”\n\nNữ nhi chết thảm, Thái tử bị phế. Thẩm gia cả đội trung liệt, không một ai may mắn thoát khỏi. Toàn bộ sụp đổ, tang thương bao trùm.\n\nThẩm Diệu không thể nào nghĩ tới, tình cảm phu thê hoạn nạn có nhau, tình chàng ý thiếp ngày nào lại thành một hồi gặp dịp thì chơi, thật đáng chê cười!\nHắn nói: “Nể tình ngươi theo trẫm hai mươi năm, ban cho ngươi toàn thây, mau tạ ơn”\n\nBa thước lụa trắng ban xuống, Thẩm Diệu lập lời thề độc: “Ngày ta chết, mọi thứ sẽ cùng chôn theo!”\n\nTrọng sinh vào năm mười bốn tuổi, lúc bi kịch chưa xảy ra, người thân vẫn còn, nàng vẫn là đích nữ nhà tướng quân ôn nhu nho nhã.\nThân thích luôn rắp tâm hại người, đường tỷ đường muội lại ác độc vô tình, di nương mới vào cửa như hổ rình mồi, còn có tra nam ý muốn giở trò đều có đủ?\n\nCó gia tộc muốn bảo hộ, đại thù muốn báo, còn có giang sơn đế vị, cũng muốn chia một phần. Đời này, thử xem là ai đấu với ai!\n\nNhưng Tiêu hầu gia Tạ gia, mang thương cưỡi ngựa vô cùng kiệt xuất, đứng ở trên đầu tường nhà nàng ngạo nghễ: “Chỉ là cái hoàng quyền thôi, nhớ kỹ, thiên hạ thuộc về nàng, nhưng nàng— là của ta!”',240000.00,5,12,'/uploads/tuong_mon_doc_hau.jpg','2026-04-02 09:09:49',_binary '\0'),(43,'Harry Potter và hòn đá phù thủy','Nhân vật chính của bộ truyện là cậu bé thiếu niên Harry Potter. Bố mẹ của cậu bị Chúa tể Voldemort sát hại bởi vì một lời tiên tri. Khi hắn định giết Harry thì bị tiêu diệt bởi Lời nguyền chết chóc, biến thành một linh hồn không sống cũng không chết. Ngay lúc đó, trên trán Harry xuất hiện dấu hiệu duy nhất của lời nguyền, một tia chớp đặc biệt.\n\nKhi biết cậu là người duy nhất sống sót trước lời nguyền, cộng đồng phù thủy đã gọi cậu là \"Đứa bé sống sót\". Sau cái chết của bố mẹ, cậu sống cùng với dì dượng. Nhưng vì gia đình dì cậu ghét những người có quyền năng phép thuật, nên không hề tiết lộ cho Harry biết về khả năng của mình. Thế rồi, đến ngày sinh nhật thứ 11, thân phận của cậu cũng bị hé lộ.\n\nNhững ngày tháng sau đó, cậu đi học tại trường Hogwarts – một trường học phép thuật và đã được học thêm nhiều phép thuật kì diệu. Tại đó, cậu có cho mình một nhóm bạn thân, gồm Ron và Hermion. Bộ ba đã gắn bó, đồng hành với nhau bất chấp sự khác biệt về thân phận, dòng máu. Câu chuyện của Harry ở trường học phép thuật cũng dần dần được hé mở…',150000.00,4,10,'/uploads/hon_da_phu_thuy.jpg','2026-04-05 13:50:29',_binary '\0'),(44,'Harry Potter và Phòng chứa bí mật','Nhân vật chính của bộ truyện là cậu bé thiếu niên Harry Potter. Bố mẹ của cậu bị Chúa tể Voldemort sát hại bởi vì một lời tiên tri. Khi hắn định giết Harry thì bị tiêu diệt bởi Lời nguyền chết chóc, biến thành một linh hồn không sống cũng không chết. Ngay lúc đó, trên trán Harry xuất hiện dấu hiệu duy nhất của lời nguyền, một tia chớp đặc biệt.\n\nKhi biết cậu là người duy nhất sống sót trước lời nguyền, cộng đồng phù thủy đã gọi cậu là \"Đứa bé sống sót\". Sau cái chết của bố mẹ, cậu sống cùng với dì dượng. Nhưng vì gia đình dì cậu ghét những người có quyền năng phép thuật, nên không hề tiết lộ cho Harry biết về khả năng của mình. Thế rồi, đến ngày sinh nhật thứ 11, thân phận của cậu cũng bị hé lộ.\n\nNhững ngày tháng sau đó, cậu đi học tại trường Hogwarts – một trường học phép thuật và đã được học thêm nhiều phép thuật kì diệu. Tại đó, cậu có cho mình một nhóm bạn thân, gồm Ron và Hermion. Bộ ba đã gắn bó, đồng hành với nhau bất chấp sự khác biệt về thân phận, dòng máu. Câu chuyện của Harry ở trường học phép thuật cũng dần dần được hé mở…',160000.00,5,15,'/uploads/phong_chua_bi_mat.jpg','2026-04-05 14:04:00',_binary '\0'),(45,'Trọn bộ 2 quyển - Khó Dỗ Dành','Sau sáu năm, Ôn Dĩ Phàm vô tình gặp lại Tang Diên tại một quán bar. Hai người là bạn học cùng lớp cấp 3 và khi đó cô đã từng phải lòng anh, tuy nhiên vì một số lý do, cô đã buộc phải từ chối tình cảm của anh khiến họ rời xa nhau. Để không cảm thấy ngượng ngùng, hai người đã giả vờ không quen biết nhau.[6] Vì nhiều tình huống mà hai người buộc phải đối mặt với nhau khi cùng sống chung dưới một mái nhà. Bản chất mối quan hệ của họ thay đổi khi Ôn Dĩ Phàm biết được rằng cô bị mộng du vào ban đêm. Tình trạng này của cô đã trở nên tồi tệ hơn do một số tổn thương đến từ gia đình trong quá khứ, và khi cô phát hiện ra mình tỉnh dậy trong phòng của Tang Diên thì từ đó cuộc sống của hai người ngày càng trở nên gắn kết với nhau hơn.',284700.00,6,0,'/uploads/kho_do_danh.jpg','2026-04-17 11:19:31',_binary '\0');

INSERT INTO `categories` VALUES (6,'Văn học'),(7,'Kỹ năng sống'),(9,'Văn học thiếu nhi'),(10,'Văn học cổ điển'),(16,'Ngôn tình'),(17,'Phiêu lưu'),(18,'Giả tưởng');
SET FOREIGN_KEY_CHECKS=1;
