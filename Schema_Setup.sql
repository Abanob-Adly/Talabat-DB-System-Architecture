-- ==========================================================
-- Project: Talabat Application System Database
-- Description: Oracle SQL Script for Creating and Populating the Database
-- Team Leader: Anthony George Shaker
-- ==========================================================

-- 1. Drop Tables (Ordered to avoid Foreign Key constraints)
DROP TABLE Order_Contains_MenuItems;
DROP TABLE Review;
DROP TABLE Orders;
DROP TABLE Menu_Item;
DROP TABLE Restaurant_Services_Contact;
DROP TABLE Customer_Address;
DROP TABLE Address;
DROP TABLE Driver;
DROP TABLE Restaurant;
DROP TABLE Customer;

-- 2. Create Tables
CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY,
    name          VARCHAR2(70) NOT NULL,
    email         VARCHAR2(100) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
    password      VARCHAR2(50) NOT NULL CHECK (LENGTH(password) >= 8),
    phone         VARCHAR2(30) NOT NULL
);

CREATE TABLE Restaurant (
    restaurant_id INT PRIMARY KEY,
    name          VARCHAR2(150) NOT NULL,
    delivery_fee  DECIMAL(10,2) DEFAULT 0 CHECK (delivery_fee >= 0)
);

CREATE TABLE Address (
    address_id      INT PRIMARY KEY,
    gps_coordinates VARCHAR2(255),
    street_name     VARCHAR2(150) NOT NULL,
    building_num    VARCHAR2(50) NOT NULL,
    city            VARCHAR2(100) NOT NULL,
    restaurant_id   INT,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Customer_Address (
    address_id    INT,
    customer_id   INT,
    PRIMARY KEY (address_id, customer_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Restaurant_Services_Contact (
    restaurant_id   INT,
    services_phone  VARCHAR2(50),
    PRIMARY KEY (restaurant_id, services_phone),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Menu_Item (
    item_id        INT PRIMARY KEY,
    name           VARCHAR2(150) NOT NULL,
    price          DECIMAL(10,2) NOT NULL CHECK (price > 0),
    description    VARCHAR2(4000),
    restaurant_id  INT NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Driver (
    driver_id      INT PRIMARY KEY,
    name           VARCHAR2(150) NOT NULL,
    license_plate  VARCHAR2(50) NOT NULL UNIQUE,
    model          VARCHAR2(100) NOT NULL,
    color          VARCHAR2(50) NOT NULL,
    phone          VARCHAR2(50) NOT NULL
);

CREATE TABLE Orders (
    order_id        INT PRIMARY KEY,
    order_time      TIMESTAMP NOT NULL,
    status          VARCHAR2(50),
    price           DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    restaurant_id   INT NOT NULL,
    customer_id     INT NOT NULL,
    driver_id       INT NOT NULL,
    payment_status  VARCHAR2(50) NOT NULL,
    payment_method  VARCHAR2(50) CHECK (payment_method IN ('Cash','Credit Card','Wallet')),
    payment_time    TIMESTAMP NOT NULL,
    amount          DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    FOREIGN KEY (customer_id)   REFERENCES Customer(customer_id),
    FOREIGN KEY (driver_id)     REFERENCES Driver(driver_id)
);

CREATE TABLE Review (
    review_id      INT PRIMARY KEY,
    rating         INT CHECK (rating BETWEEN 1 AND 5),
    comment_text   VARCHAR2(4000), 
    restaurant_id  INT,
    customer_id    INT,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    FOREIGN KEY (customer_id)   REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Contains_MenuItems (
    order_id  INT,
    item_id   INT,
    quantity  INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES Menu_Item(item_id)
);

-- 3. Insert Data
-- CUSTOMER DATA
INSERT INTO Customer VALUES (1001, 'Omar Khaled', 'omar.k@example.com', 'pass12345', '01000111222');
INSERT INTO Customer VALUES (1002, 'Mariam Adel', 'mariam.a@example.com', 'mypassword', '01033445566');
INSERT INTO Customer VALUES (1003, 'Youssef Samir', 'youssef.s@example.com', 'pass78999', '01099887766');

-- RESTAURANT DATA
INSERT INTO Restaurant VALUES (3001, 'KFC', 21.00);
INSERT INTO Restaurant VALUES (3002, 'MacDonalds', 45.00);
INSERT INTO Restaurant VALUES (3003, 'El Shamy Shawerma', 30.00);
INSERT INTO Restaurant VALUES (3004, 'Pizza King', 30.00);

-- ADDRESS DATA
INSERT INTO Address VALUES (2001, '30.0500,31.2333', 'Dokki St', '22A', 'Giza', 3001);
INSERT INTO Address VALUES (2002, '30.0201,31.2254', 'Nasr City', '10', 'Cairo', 3002);
INSERT INTO Address VALUES (2003, '29.9755,31.1304', 'Maadi Rd', '7', 'Cairo', 3003);
INSERT INTO Address VALUES (2004, '30.0444,31.2357', 'Tahrir Square', '15', 'Cairo', 3004);

-- CUSTOMER_ADDRESS DATA
INSERT INTO Customer_Address VALUES (2001, 1001);
INSERT INTO Customer_Address VALUES (2004, 1001);
INSERT INTO Customer_Address VALUES (2003, 1002);
INSERT INTO Customer_Address VALUES (2002, 1003);

-- RESTAURANT CONTACT DATA
INSERT INTO Restaurant_Services_Contact VALUES (3001, '19019');
INSERT INTO Restaurant_Services_Contact VALUES (3002, '19991');
INSERT INTO Restaurant_Services_Contact VALUES (3003, '01234567890');
INSERT INTO Restaurant_Services_Contact VALUES (3004, '01055667788');

-- MENU ITEMS DATA
INSERT INTO Menu_Item VALUES (5001, 'Twister Sandwich', 75.00, 'Crispy chicken wrap', 3001);
INSERT INTO Menu_Item VALUES (5002, 'Family Bucket', 350.00, '12 pcs chicken', 3001);
INSERT INTO Menu_Item VALUES (5003, 'Big Mac', 95.00, 'Beef double sandwich', 3002);
INSERT INTO Menu_Item VALUES (5004, 'McChicken', 75.00, 'Chicken sandwich', 3002);
INSERT INTO Menu_Item VALUES (5005, 'Chicken Shawerma', 40.00, 'Syrian style wrap', 3003);
INSERT INTO Menu_Item VALUES (5007, 'Margherita Pizza', 70.00, 'Classic cheese pizza', 3004);

-- DRIVER DATA
INSERT INTO Driver VALUES (6001, 'Mostafa Hassan', 'ABC-321', 'Honda', 'Red', '01111111111');
INSERT INTO Driver VALUES (6002, 'Khaled Tarek', 'XYZ-987', 'Yamaha', 'Black', '01222222222');
INSERT INTO Driver VALUES (6003, 'Abanob Adly', 'TTT-555', 'Toyota', 'Blue', '01033333333');

-- ORDERS DATA
INSERT INTO Orders (order_id, order_time, status, price, restaurant_id, customer_id, driver_id, payment_status, payment_method, payment_time, amount) 
VALUES (8001, TO_TIMESTAMP('2025-01-12 13:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Delivered', 75.00, 3001, 1001, 6001, 'Paid', 'Credit Card', TO_TIMESTAMP('2025-01-12 13:10:00', 'YYYY-MM-DD HH24:MI:SS'), 75.00);

INSERT INTO Orders VALUES (8002, TO_TIMESTAMP('2025-01-12 14:10:00', 'YYYY-MM-DD HH24:MI:SS'), 'Delivered', 95.00, 3002, 1002, 6002, 'Paid', 'Cash', TO_TIMESTAMP('2025-01-12 14:20:00', 'YYYY-MM-DD HH24:MI:SS'), 95.00);

INSERT INTO Orders VALUES (8003, TO_TIMESTAMP('2025-01-12 14:55:00', 'YYYY-MM-DD HH24:MI:SS'), 'On the way', 40.00, 3003, 1003, 6003, 'Pending', 'Wallet', TO_TIMESTAMP('2025-01-12 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 40.00);

-- REVIEW DATA
INSERT INTO Review VALUES (4001, 5, 'Fast delivery, hot food. Excellent!', 3001, 1001);
INSERT INTO Review VALUES (4002, 4, 'Burger was good but fries were cold.', 3002, 1002);
INSERT INTO Review VALUES (4003, 5, 'Best shawerma in town!', 3003, 1003);

-- ORDER_CONTAINS_MENUITEMS DATA
INSERT INTO Order_Contains_MenuItems VALUES (8001, 5001, 1);
INSERT INTO Order_Contains_MenuItems VALUES (8002, 5003, 2);
INSERT INTO Order_Contains_MenuItems VALUES (8003, 5005, 2);

COMMIT;