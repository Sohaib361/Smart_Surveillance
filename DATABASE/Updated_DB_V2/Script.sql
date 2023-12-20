CREATE TABLE user_info (
    CNIC INT PRIMARY KEY,
    full_name VARCHAR(30) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    gender VARCHAR(10),
    age INT,
    phone_number VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    email VARCHAR(30) UNIQUE NOT NULL,
    photo BYTEA NOT NULL
);

CREATE TABLE vehicle_info (
    owner_license_plate VARCHAR(20) REFERENCES user_info(license_plate),  
    vehicle_type VARCHAR(10) NOT NULL,
    vehicle_model VARCHAR(20),
    vehicle_color VARCHAR(10),
    registered_city VARCHAR(30)
);

INSERT INTO user_info (CNIC,  full_name, license_plate, gender, age,  phone_number, address, email, photo)
VALUES
    (2020019, 'Abdul Wahab Abbasi', 'MND690', 'Male', 22, '0321-8329112', 'Karachi', 'u2020019@giki.edu.pk', pg_read_binary_file('D:\DB Images\2020019.png')),
    (2020361, 'M. Sohaib Mohsin', 'KBC695', 'Male', 22, '0300-0475199', 'Faislabad', 'u2020361@giki.edu.pk', pg_read_binary_file('D:\DB Images\2020361.png')),
    (2020174, 'Hussain Ahmed', 'LEC7208', 'Male', 22, '0305-3402286', 'Hyderabad', 'u2020174@giki.edu.pk', pg_read_binary_file('D:\DB Images\2020174.png')),
    (2020140, 'Usman Majeed', 'MN1367', 'Male', 22, '0309-8414304', 'Bahawalpur', 'u2020140@giki.edu.pk', pg_read_binary_file('D:\DB Images\2020140.png'));


INSERT INTO vehicle_info (owner_license_plate, vehicle_type, vehicle_model, vehicle_color, registered_city)
VALUES
    ('MND690', 'Sedan', 'Honda City', 'White','Karachi'),
    ('KBC695','Motorcycle', 'Yamaha','Black','Faislabad'),
    ('LEC7208', 'Sedan', 'Toyota Corolla', 'Silver','Hyderabad'),
    ('MN1367', 'Hatchback', 'Suzuki Mehran', 'White','Bahawalpur');

CREATE TABLE user_credentials (
    CNIC INT PRIMARY KEY REFERENCES user_info(CNIC),
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL
);


ALTER TABLE user_info
ALTER COLUMN gender SET NOT NULL;

ALTER TABLE user_info
ALTER COLUMN age SET NOT NULL;

ALTER TABLE vehicle_info
ALTER COLUMN vehicle_model SET NOT NULL;

ALTER TABLE vehicle_info
ALTER COLUMN vehicle_color SET NOT NULL;

ALTER TABLE vehicle_info
ALTER COLUMN registered_city SET NOT NULL;





   
   
   