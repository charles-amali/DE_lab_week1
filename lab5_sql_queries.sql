-- creating triggers
DELIMITER //

CREATE TRIGGER update_inventory
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    -- Get current inventory for the product
    SELECT quantity INTO current_stock FROM Inventories WHERE product_id = NEW.product_id;

    -- Check if there is enough stock
    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for this product';
    ELSE
        -- Update inventory
        UPDATE Inventories
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END//

DELIMITER ;



-- creating stored procedures
DELIMITER //
CREATE PROCEDURE UpdateCustomerStatus(IN customerID INT)
BEGIN
    DECLARE total_order_value DECIMAL(10, 2);

    -- Calculate the total order value for the customer
    SELECT SUM(quantity * price) INTO total_order_value
    FROM orders
    JOIN Order_Items ON orders.order_id = Order_Items.order_id
    WHERE orders.customer_id = customerID;

    -- Update the customer status
    IF total_order_value > 10000 THEN
        UPDATE Customers SET status = 'VIP' WHERE customer_id = customerID;
    ELSE
        UPDATE Customers SET status = 'Regular' WHERE customer_id = customerID;
    END IF;
END//
DELIMITER ;

-- Example
CALL UpdateCustomerStatus(10); -- updating customer with ID 10