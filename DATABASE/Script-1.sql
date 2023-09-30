CREATE TABLE owner_info (
    owner_id INT PRIMARY KEY,
    owner_name VARCHAR(100) NOT NULL,
    owner_gender VARCHAR(10),
    owner_age INT,
    contact_number VARCHAR(20),
    email_address VARCHAR(50),
    license_plate_number VARCHAR(20) UNIQUE,
    owner_picture BYTEA
);

CREATE TABLE vehicle_info (
    vehicle_type VARCHAR(50) NOT NULL,
    vehicle_model VARCHAR(50),
    registered_city VARCHAR(50),
    owner_license_plate_number VARCHAR(20) REFERENCES owner_info(license_plate_number)
);

INSERT INTO owner_info (owner_id,  owner_name, owner_gender, owner_age, contact_number, email_address, license_plate_number, owner_picture)
VALUES
    (2020019, 'Abdul Wahab Abbasi', 'Male', 22, '0321-8329112', 'u2020019@giki.edu.pk', 'IGP-061', pg_read_binary_file('D:\DB Images\2020019.png')),
    (2020361, 'M. Sohaib Mohsin', 'Male', 22, '0300-0475199', 'u2020361@giki.edu.pk', 'AWA-103', pg_read_binary_file('D:\DB Images\2020361.png')),
    (2020174, 'Hussain Ahmed', 'Male', 22, '0305-3402286', 'u2020174@giki.edu.pk', 'AHF-479', pg_read_binary_file('D:\DB Images\2020174.png'));


INSERT INTO vehicle_info (vehicle_type, vehicle_model, registered_city, owner_license_plate_number)
VALUES
    ('Car', 'Toyota Corolla', 'New York', 'IGP-061'),
    ('Motorcycle', 'Honda CBR', 'Los Angeles', 'AWA-103'),
    ('Truck', 'Ford F-150', 'Chicago', 'AHF-479');

SELECT
    o.owner_id,
    o.owner_name,
    o.owner_gender,
    o.owner_age,
    o.contact_number AS owner_contact_number,
    o.email_address AS owner_email,
    o.owner_picture
FROM
    vehicle_info v
JOIN
    owner_info o ON v.owner_license_plate_number = o.license_plate_number
WHERE
    v.owner_license_plate_number = 'IGP-061';


   
   
   