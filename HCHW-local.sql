DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_session_booking;
DROP TABLE IF EXISTS therapeutic_session;
DROP TABLE IF EXISTS class_session;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS sub_payment;
DROP TABLE IF EXISTS wellness_class;
DROP TABLE IF EXISTS therapeutic;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS therapists;
DROP TABLE IF EXISTS manager;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS user_type;
drop view if exists therapeutic_session_info;
drop view if exists member_therapeutic_booking_info;
drop view if exists therapeutic_session_payment;


create table members (
member_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
username varchar(255) not null unique,
user_password varchar(255) not null,
title varchar(255),
firstname varchar(255) not null,
lastname varchar(255) not null,
phone_number varchar(255) not null,
email varchar(255) not null,
dob DATE not null,
health_info varchar(255),
profile_image varchar(255),
user_position varchar(255)
);



create table therapists (
therapists_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
username varchar(255) not null unique,
user_password varchar(255) not null,
firstname varchar(255) not null,
lastname varchar(255) not null,
email varchar(255) not null,
profile_image varchar(255),
phone_number varchar(255),
therapists_position varchar(255),
therapist_profile varchar(255)
);




create table manager (
manager_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
username varchar(255) not null unique,
user_password varchar(255) not null,
firstname varchar(255) not null,
lastname varchar(255) not null,
email varchar(255) not null,
profile_image varchar(255)
);



create table sub_payment (
                payment_id int(255) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                paid boolean not null,
                paid_date DATETIME not null,
                member_id int(6) UNSIGNED not null,
                payment_amount decimal(7,2) not null,
                constraint FK_MEMBER_ID FOREIGN KEY (member_id) references members(member_id)
);

create table subscription(
                sub_id int(255) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                annual_sub boolean,
                monthly_sub boolean,
                sub_start_date DATETIME not null,
                sub_end_date DATETIME not null,
                member_id int(6) UNSIGNED not null,
                payment_id int(255) UNSIGNED,
                constraint FK_SUB_MEMBER_ID FOREIGN KEY (member_id) references members(member_id),
                constraint FK_PAYMENT_ID FOREIGN KEY (payment_id) references sub_payment(payment_id)
);

create table locations (
                location_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                descriptions varchar(255) not null
);

create table therapeutic (
                therapeutic_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                therapeutic_type varchar(255) not null,
                therapeutic_description varchar(255)
);

CREATE TABLE wellness_class (
                class_id int unsigned NOT NULL AUTO_INCREMENT,
                class_name varchar(45) NOT NULL,
                class_description varchar(255) NOT NULL,
                class_therapist_id int unsigned NOT NULL,
                image_name varchar (45) NOT NULL,
                PRIMARY KEY (class_id),
                KEY FK_CLASS_THERAPIST_ID_idx (class_therapist_id),
                CONSTRAINT FK_CLASS_THERAPIST_ID FOREIGN KEY (class_therapist_id) REFERENCES therapists (therapists_id)
);

create table therapeutic_session(
                session_id int(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                start_time DATETIME not null,
                end_time DATETIME not null,
                session_length TINYINT(255) UNSIGNED not null,
                attended boolean,
                member_id int(6) UNSIGNED,
                therapists_id int(6) UNSIGNED not null,
                location_id int(6) UNSIGNED not null,
                therapeutic_id int(6) UNSIGNED not null,
                payment_id int(255) UNSIGNED,
                booked boolean not null,
                constraint FK_THERAPEUTIC_SESSION_MEMBER_ID FOREIGN KEY (member_id) references members(member_id),
                constraint FK_THERAPEUTIC_SESSION_THERAPISTS_ID FOREIGN KEY (therapists_id) references therapists(therapists_id),
                constraint FK_THERAPEUTIC_SESSION_LOCATION_ID FOREIGN KEY (location_id) references locations(location_id),
                constraint FK_THERAPEUTIC_SESSION_SUB_PAYMENT FOREIGN KEY (payment_id) references sub_payment(payment_id),
                constraint FK_THERAPEUTIC_SESSION_THERAPEUTIC_ID_1 FOREIGN KEY (therapeutic_id) references therapeutic(therapeutic_id)
);



CREATE TABLE class_session (
                session_id int unsigned NOT NULL AUTO_INCREMENT,
                start_time time NOT NULL,
                end_time time NOT NULL,
                location_id int unsigned NOT NULL,
                class_id int unsigned NOT NULL,
                capacity int unsigned NOT NULL,
                PRIMARY KEY (session_id),
KEY FK_CLASS_SESSION_LOCATION_ID (location_id),
KEY FK_CLASS_SESSION_CLASS_ID (class_id),
CONSTRAINT FK_CLASS_SESSION_CLASS_ID FOREIGN KEY (class_id) REFERENCES wellness_class (class_id),
CONSTRAINT FK_CLASS_SESSION_LOCATION_ID FOREIGN KEY (location_id) REFERENCES locations (location_id)
);

CREATE TABLE class_session_booking (
                id int NOT NULL AUTO_INCREMENT,
                member_id int unsigned NOT NULL,
                session_id int unsigned NOT NULL,
                session_date date NOT NULL,
                PRIMARY KEY (id),
                UNIQUE KEY id_UNIQUE (id),
                KEY FK_BOOKED_SESSION_ID_idx (session_id),
                KEY FK_BOOKED_MEMBER_ID_idx (member_id),
                CONSTRAINT FK_BOOKED_MEMBER_ID FOREIGN KEY (member_id) REFERENCES members (member_id),
                CONSTRAINT FK_BOOKED_SESSION_ID FOREIGN KEY (session_id) REFERENCES class_session (session_id)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT UNSIGNED,
    class_session_id INT UNSIGNED,
    class_session_booking_id INT,
    attended BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (class_session_id) REFERENCES class_session(session_id),
    FOREIGN KEY (class_session_booking_id) REFERENCES class_session_booking(id)
);

INSERT INTO members
(username, user_password, title, firstname, lastname, phone_number, email, dob, health_info, profile_image, user_position)
VALUES
('feifei', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'feifei', 'song', '12345', 'Feifei.Song@lincolnuni.ac.nz', '2001-01-01', '', '', ''),
('mia', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'mia', 'zhang', '12345', 'Mia.Zhao@lincolnuni.ac.nz', '2001-01-01', '', '', ''),
('jason', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'jason', 'lin', '1234', 'Jason.Lin2@lincolnuni.ac.nz','2001-01-01', '', '', ''),
('jenny', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'jenny', 'chen', '1234','Jianing.Chen@lincolnuni.ac.nz', '2001-01-01', '', '', ''),
('kevin', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'kevin', 'li','1234', 'Kevin.Li@lincolnuni.ac.nz', '2001-01-01', '', '', ''),
('alice', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Alice', 'Johnson', '5550100', 'alice.johnson@example.com', '1990-05-15', '', '', ''),
('bob', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Bob', 'Smith', '5550101', 'bob.smith@example.com', '1992-07-08', '', '', ''),
('carol', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Dr', 'Carol', 'Martinez', '5550102', 'carol.martinez@example.com', '1985-03-22', '', '', ''),
('david', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'David', 'Lee', '5550103', 'david.lee@example.com', '1988-12-01', '', '', ''),
('emma', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Emma', 'Wilson', '5550104', 'emma.wilson@example.com', '1991-09-19', '', '', ''),
('frank', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Frank', 'Taylor', '5550105', 'frank.taylor@example.com', '1993-02-11', '', '', ''),
('grace', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Grace', 'Brown', '5550106', 'grace.brown@example.com', '1989-08-30', '', '', ''),
('henry', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Henry', 'Davis', '5550107', 'henry.davis@example.com', '1994-04-05', '', '', ''),
('isabella', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Isabella', 'Miller', '5550108', 'isabella.miller@example.com', '1996-06-21', '', '', ''),
('jacob', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Jacob', 'Wilson', '5550109', 'jacob.wilson@example.com', '1990-10-14', '', '', ''),
('kate', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Kate', 'Moore', '5550110', 'kate.moore@example.com', '1995-03-05', '', '', ''),
('liam', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Liam', 'Clark', '5550111', 'liam.clark@example.com', '1992-07-24', '', '', ''),
('Cecelia', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Cecelia', 'Hernandez', '5550112', 'Cecelia.hernandez@example.com', '1993-01-13', '', '', ''),
('noah', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Noah', 'Lopez', '5550113', 'noah.lopez@example.com', '1991-05-22', '', '', ''),
('olivia', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Olivia', 'Gonzalez', '5550114', 'olivia.gonzalez@example.com', '1994-11-15', '', '', ''),
('peter', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Peter', 'Harris', '5550115', 'peter.harris@example.com', '1987-02-25', '', '', ''),
('quinn', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Quinn', 'Young', '5550116', 'quinn.young@example.com', '1996-09-17', '', '', ''),
('rachel', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Rachel', 'King', '5550117', 'rachel.king@example.com', '1995-08-09', '', '', ''),
('steven', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Mr', 'Steven', 'Scott', '5550118', 'steven.scott@example.com', '1990-12-03', '', '', ''),
('tina', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ms', 'Tina', 'Evans', '5550119', 'tina.evans@example.com', '1989-07-27', '', '', '');


INSERT INTO class_session_booking 
(member_id,session_id,session_date) 
VALUES 
(1,1,'2024-04-25'),
(1,8,'2024-04-26'),
(1,2,'2024-04-25'),
(1,15,'2024-04-27'),
(2,1,'2024-04-25'),
(2,8,'2024-04-26'),
(2,2,'2024-04-25'),
(2,15,'2024-04-27'),
(3,1,'2024-04-25'),
(3,8,'2024-04-26'),
(3,2,'2024-04-25'),
(3,15,'2024-04-27');

INSERT INTO attendance 
(member_id,class_session_id,class_session_booking_id,attended) 
VALUES 
(1,1,1,1),
(1,8,2,1),
(1,2,3,1),
(1,15,4,1),
(2,1,5,1),
(2,8,6,0),
(2,2,7,1),
(2,15,8,0),
(3,1,9,1),
(3,8,10,0),
(3,2,11,1),
(3,15,12,0);




INSERT INTO therapists
(username, user_password, firstname, lastname, email, profile_image,phone_number,therapists_position,therapist_profile)
VALUES
('Ashley', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Ashley', 'Sun', 'ashley@gamil.com', '','02102340388','Acupuncturist','Certified Acupuncturist'),
('Jordan', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Jordan', 'Smith', 'Jordan@gmail.com', '','02102340388','Massage Therapist','Certified in Swedish and Deep Tissue Massage'),
('Taylor', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Taylor', 'Lee', 'Taylor@gmail.com', '','02102340388','Chiropractor','Doctor of Chiropractic'),
('Morgan', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Morgan', 'Rivera', 'Morgan@gmail.com', '','02102340388','Nutritionist','Bachelor in Nutrition Science'),
('Emily', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'Emily', 'Thompson', 'Emily@gmail.com', '','02102340388','Yoga Instructor and Wellness Coach','200-Hour Yoga Teacher Training Certified, Certified Wellness Coach');



INSERT INTO manager
(username, user_password, firstname, lastname, email, profile_image)
VALUES
('feifei', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'feifei', 'song', 'feifei@gamil.com', ''),
('mia', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'mia', 'zhang', 'mia@gmail.com', ''),
('jason', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'jason', 'lin', 'jason@gmail.com', ''),
('jenny', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'jenny', 'chen', 'jenny@gmail.com', ''),
('kevin', '6d7ddd63fb79f256c5c0f7c02071a65d24242acc94412fa6e8530cba85539baf', 'kevin', 'li', 'kevin@gmail.com', '');


INSERT INTO locations (descriptions) VALUES
('Outdoor Garden'),
('Indoor Poolside'),
('Main Hall'),
('Yoga Studio'),
('Massage Room');

INSERT INTO therapeutic (therapeutic_type, therapeutic_description) VALUES
('acupuncture', 'A session used to treat pain'),
('chiropractic care', 'examine and treat problems of the bones, muscles and joints.'),
('swedish massage', 'A relaxing full body massage'),
('Reflexology', 'Foot massage that targets specific points'),
('Reiki', 'Energy healing session');

INSERT INTO sub_payment (paid, paid_date, member_id, payment_amount) VALUES
(true, '2023-06-01 13:10:00', 1, 2000.00),   #annual
(true, '2024-03-28 16:09:00', 2,167.00),   #monthly
(true, '2023-02-01 15:30:00', 3, 2000.00),   #annual
(true, '2024-02-04 10:00:00', 4,167.00),   #monthly
(true, '2023-01-03 12:45:00', 5, 2000.00),   #annual
(true, '2023-06-15 12:00:00', 6, 2000.00),    -- annual
(true, '2023-11-15 16:30:00', 7, 167.00),     -- monthly
(true, '2023-09-01 11:20:00', 8, 2000.00),    -- annual
(true, '2024-02-20 09:50:00', 9, 167.00),     -- monthly
(true, '2023-05-01 14:00:00', 10, 2000.00),   -- annual
(true, '2023-07-20 10:30:00', 11, 167.00),    -- monthly
(true, '2023-08-05 15:45:00', 12, 2000.00),   -- annual
(true, '2024-01-10 17:05:00', 13, 167.00),    -- monthly
(true, '2023-04-07 08:00:00', 14, 2000.00),   -- annual
(true, '2023-10-30 12:10:00', 15, 167.00),    -- monthly
(true, '2023-12-25 18:00:00', 16, 2000.00),   -- annual
(true, '2024-03-22 07:25:00', 17, 167.00),    -- monthly
(true, '2023-02-14 16:45:00', 18, 2000.00),   -- annual
(true, '2024-05-09 13:10:00', 19, 167.00),    -- monthly
(true, '2023-06-03 09:20:00', 20, 2000.00),   -- annual
(true, '2023-07-10 15:00:00', 21, 167.00),    -- monthly
(true, '2023-08-15 17:30:00', 22, 2000.00),   -- annual
(true, '2024-01-22 14:45:00', 23, 167.00),    -- monthly
(true, '2023-03-18 10:50:00', 24, 2000.00),   -- annual
(true, '2023-11-28 16:05:00', 25, 167.00);    -- monthly

INSERT INTO therapeutic_session (start_time, end_time, session_length, attended, member_id, therapists_id, location_id, therapeutic_id, payment_id, booked) VALUES
('2023-05-01 09:00:00', '2023-05-01 09:45:00', 45, false, 1, 1, 5, 1, 1, false),
('2023-05-02 10:00:00', '2023-05-02 10:45:00', 45, false, 2, 2, 5, 2, 2, true),
('2023-05-03 11:00:00', '2023-05-03 11:45:00', 45, false, 3, 3, 5, 3, 3, false),
('2023-05-04 12:00:00', '2023-05-04 12:45:00', 45, false, 4, 4, 5, 4, 4, false),
('2023-05-05 13:00:00', '2023-05-05 13:45:00', 45, false, 5, 5, 1, 5, 5, false),
('2023-03-29 13:00:00', '2023-03-29 13:45:00', 45, false, 5, 5, 1, 5, 5, false),
('2023-03-26 13:00:00', '2023-03-26 13:45:00', 45, false, 5, 5, 1, 5, 5, false),
('2023-06-01 09:00:00', '2023-06-01 10:30:00', 90, true, 6, 1, 2, 1, 6, true),
('2023-06-02 10:15:00', '2023-06-02 11:00:00', 45, true, 7, 2, 3, 2, 7, true),
('2023-06-03 12:00:00', '2023-06-03 12:45:00', 45, false, 8, 3, 4, 3, 8, true),
('2023-06-04 14:00:00', '2023-06-04 14:45:00', 45, true, 9, 4, 5, 4, 9, false),
('2023-06-05 16:00:00', '2023-06-05 16:45:00', 45, false, 10, 5, 1, 5, 10, true),
('2023-06-06 08:00:00', '2023-06-06 08:45:00', 45, false, 11, 1, 2, 1, 11, false),
('2023-06-07 09:30:00', '2023-06-07 10:15:00', 45, true, 12, 2, 3, 2, 12, true),
('2023-06-08 11:00:00', '2023-06-08 11:45:00', 45, false, 13, 3, 4, 3, 13, false),
('2023-06-09 13:30:00', '2023-06-09 14:15:00', 45, true, 14, 4, 5, 4, 14, true),
('2023-06-10 15:00:00', '2023-06-10 15:45:00', 45, true, 15, 5, 1, 5, 15, false),
('2023-06-11 16:30:00', '2023-06-11 17:15:00', 45, false, 16, 1, 2, 1, 16, true),
('2023-06-12 18:00:00', '2023-06-12 18:45:00', 45, true, 17, 2, 3, 2, 17, false),
('2023-06-13 19:30:00', '2023-06-13 20:15:00', 45, false, 18, 3, 4, 3, 18, true);


INSERT INTO wellness_class (class_name,class_description,class_therapist_id,image_name) VALUES
('Pilates','Discover the transformative power of Pilates at our hub, where you\'ll strengthen your core, improve flexibility, and enhance overall body coordination through dynamic and mindful exercises.',1,'pilates'),
('Taichi','Experience the ancient art of Tai Chi at our hub, where you\'ll cultivate balance, harmony, and inner peace through gentle, flowing movements and mindfulness practice.',2,'taichi'),
('Stress management','Explore effective stress management techniques at our hub, where you\'ll learn to cultivate resilience, reduce tension, and enhance well-being through relaxation, mindfulness, and self-care practices. n, mindfulness, and self-care practices.',3,'stress_management'),
('Medication','Discover the benefits of medication management at our hub, where you\'ll learn essential skills for safe and effective medication use, optimizing your health and well-being.',4,'medication'),
('Cardio workout exercise','Join our cardio workout exercise class to boost your cardiovascular fitness, burn calories, and improve overall health with dynamic and energizing workouts.',5,'cardio_workout'),
('Mindfulness','Experience the transformative power of mindfulness at our hub, where you\'ll cultivate present-moment awareness, reduce stress, and enhance mental well-being through guided meditation and mindful practices.',1,'mindfulness'),
('Yoga','Embark on a journey of self-discovery and holistic wellness with our yoga classes, where you\'ll harmonize body, mind, and spirit through breath work, mindful movement, and relaxation techniques.',2,'yoga');

INSERT INTO class_session (start_time,end_time,location_id,class_id,capacity) VALUES
('09:00:00','10:00:00',1,1,15),
('10:30:00','11:30:00',2,2,15),
('12:00:00','13:00:00',3,3,15),
('13:30:00','14:30:00',4,4,15),
('15:00:00','16:00:00',5,5,15),
('16:30:00','17:30:00',1,6,15),
('18:00:00','19:00:00',2,7,15),
('07:00:00', '08:00:00', 1, 1, 20),
('08:15:00', '09:15:00', 2, 2, 25),
('09:30:00', '10:30:00', 3, 3, 30),
('10:45:00', '11:45:00', 4, 4, 20),
('12:00:00', '13:00:00', 5, 5, 25),
('13:15:00', '14:15:00', 1, 6, 20),
('14:30:00', '15:30:00', 2, 7, 15),
('08:00:00', '09:00:00', 3, 1, 30),
('09:15:00', '10:15:00', 4, 2, 20),
('10:30:00', '11:30:00', 5, 3, 25),
('11:45:00', '12:45:00', 1, 4, 20),
('13:00:00', '14:00:00', 2, 5, 15),
('15:15:00', '16:15:00', 3, 6, 30);


create view therapeutic_session_info as (
select
	sl.session_id,
	sl.therapists_id,
	sl.start_time,
	sl.end_time,
	sl.session_length,
	sl.therapeutic_type,
	sl.descriptions as location
from
	(
	select
		s.*,
		l.descriptions
	from
		(
		select
			ts.* ,
			t.therapeutic_type
		from
			therapeutic_session ts
		left join therapeutic t on
			ts.therapeutic_id = t.therapeutic_id) s
	left join locations l on
		s.location_id = l.location_id
		) sl
);



create view member_therapeutic_booking_info as  (
select
	tstlc.session_id,
	tstlc.start_time,
	tstlc.end_time,
	tstlc.session_length,
	tstlc.member_id,
	tstlc.payment_id,
	tstlc.is_attended as attened,
	tstlc.therapist_firstname,
	tstlc.therapist_lastname,
	tstlc.descriptions as locations,
	t2.therapeutic_type,
	t2.therapeutic_description
from
	(
	SELECT
		tst.*,
		lc.descriptions
	from
		(
		SELECT
			ts.session_id ,
			ts.start_time ,
			ts.end_time ,
			ts.session_length ,
			ts.member_id ,
			ts.location_id ,
			ts.therapists_id ,
			ts.therapeutic_id ,
			ts.payment_id ,
			ts.booked ,
			if(ts.attended = 0 ,
			"No" ,
			"Yes") as is_attended,
			t.firstname as therapist_firstname,
			t.lastname as therapist_lastname
		from
			therapeutic_session ts
		left join therapists t on
			ts.therapists_id = t.therapists_id
) tst
	left join locations lc on
		tst.location_id = lc.location_id
	) tstlc
left join therapeutic t2 on
	tstlc.therapeutic_id = t2.therapeutic_id
);


INSERT INTO subscription
(annual_sub, monthly_sub, sub_start_date, sub_end_date, member_id, payment_id)
VALUES
(TRUE, FALSE, '2023-02-01 13:10:00', '2024-06-01 13:10:00', 1, 1),  #annual
(FALSE, TRUE, '2023-11-20 16:09:00', '2024-04-28 16:09:00', 2, 2),  #monthly
(TRUE, FALSE, '2023-02-01 15:30:00', '2024-02-01 15:30:00', 3, 3),  #annual
(FALSE, TRUE, '2024-02-04 10:00:00', '2024-03-04 10:00:00', 4, 4),  #monthly
(TRUE, FALSE, '2023-01-03 12:45:00', '2024-01-03 12:45:00', 5,5),   #annual
(TRUE, FALSE, '2023-06-15 12:00:00', '2024-06-15 12:00:00', 6, 6),
(FALSE, TRUE, '2023-11-15 16:30:00', '2023-12-15 16:30:00', 7, 7),
(TRUE, FALSE, '2023-09-01 11:20:00', '2024-09-01 11:20:00', 8, 8),
(FALSE, TRUE, '2024-02-20 09:50:00', '2024-03-20 09:50:00', 9, 9),
(TRUE, FALSE, '2023-05-01 14:00:00', '2024-05-01 14:00:00', 10, 10),
(FALSE, TRUE, '2023-07-20 10:30:00', '2023-08-20 10:30:00', 11, 11),
(TRUE, FALSE, '2023-08-05 15:45:00', '2024-08-05 15:45:00', 12, 12),
(FALSE, TRUE, '2024-01-10 17:05:00', '2024-02-10 17:05:00', 13, 13),
(TRUE, FALSE, '2023-04-07 08:00:00', '2024-04-07 08:00:00', 14, 14),
(FALSE, TRUE, '2023-10-30 12:10:00', '2023-11-30 12:10:00', 15, 15),
(TRUE, FALSE, '2023-12-25 18:00:00', '2024-12-25 18:00:00', 16, 16),
(FALSE, TRUE, '2024-03-22 07:25:00', '2024-04-22 07:25:00', 17, 17),
(TRUE, FALSE, '2023-02-14 16:45:00', '2024-02-14 16:45:00', 18, 18),
(FALSE, TRUE, '2024-05-09 13:10:00', '2024-06-09 13:10:00', 19, 19),
(TRUE, FALSE, '2023-06-03 09:20:00', '2024-06-03 09:20:00', 20, 20),
(FALSE, TRUE, '2023-07-10 15:00:00', '2023-08-10 15:00:00', 21, 21),
(TRUE, FALSE, '2023-08-15 17:30:00', '2024-08-15 17:30:00', 22, 22),
(FALSE, TRUE, '2024-01-22 14:45:00', '2024-02-22 14:45:00', 23, 23),
(TRUE, FALSE, '2023-03-18 10:50:00', '2024-03-18 10:50:00', 24, 24),
(FALSE, TRUE, '2023-11-28 16:05:00', '2023-12-28 16:05:00', 25, 25);


create view  therapeutic_session_payment as(
select
	ts.session_id,
	ts.member_id,
	ts.therapeutic_id,
	ts.payment_id,
	sp.paid_date ,
	sp.payment_amount

from
	therapeutic_session ts
left join sub_payment sp on
	sp.payment_id = ts.payment_id
	where sp.paid  = 1
);


