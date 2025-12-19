-- ==========================================================
-- PROJECT: Talabat System Architecture
-- MODULE: Business Logic & Programmability
-- TOOLS USED: Oracle SQL, PL/SQL, draw.io
-- Developed individually to manage core system operations.
-- This module handles automated calculations and state management.
-- ==========================================================

-- ----------------------------------------------------------
-- 1. FUNCTION: get_order_total
-- Description: Calculates total cost (Items + Delivery Fee)
-- ----------------------------------------------------------
CREATE OR REPLACE FUNCTION get_order_total(p_order_id IN INT) 
RETURN DECIMAL IS
    v_items_total DECIMAL(10,2);
    v_delivery_fee DECIMAL(10,2);
BEGIN

    SELECT SUM(mi.price * omi.quantity)
    INTO v_items_total
    FROM Order_Contains_MenuItems omi
    JOIN Menu_Item mi ON omi.item_id = mi.item_id
    WHERE omi.order_id = p_order_id;

    SELECT r.delivery_fee
    INTO v_delivery_fee
    FROM Orders o
    JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_id = p_order_id;

    RETURN v_items_total + v_delivery_fee;
END;


-- ----------------------------------------------------------
-- 2. PROCEDURE: update_order_status
-- Description: Updates status and payment timestamp
-- ----------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id IN INT,
    p_new_status IN VARCHAR2
) IS
BEGIN
    UPDATE Orders
    SET status = p_new_status,
        payment_time = CASE WHEN p_new_status = 'Delivered' THEN CURRENT_TIMESTAMP ELSE payment_time END
    WHERE order_id = p_order_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order ' || p_order_id || ' status updated to ' || p_new_status);
END;


-- ----------------------------------------------------------
-- 3. PROCEDURE: add_restaurant_review
-- Description: Validates rating (1-5) and inserts review
-- ----------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_restaurant_review(
    p_review_id IN INT,
    p_rating IN INT,
    p_comment IN VARCHAR2,
    p_restaurant_id IN INT,
    p_customer_id IN INT
) IS
BEGIN
    IF p_rating < 1 OR p_rating > 5 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Rating must be between 1 and 5 stars.');
    END IF;

    INSERT INTO Review (review_id, rating, comment_text, restaurant_id, customer_id)
    VALUES (p_review_id, p_rating, p_comment, p_restaurant_id, p_customer_id);
    
    COMMIT;
END;
