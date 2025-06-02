SET SQL_SAFE_UPDATES = 0;

-- Step 1: Create a cleaned copy from the imported raw data
DROP TABLE IF EXISTS cafe_cleaned;

CREATE TABLE cafe_cleaned AS
SELECT * FROM cafe_data;

-- Step 2: Standardise error tokens as NULLs
UPDATE cafe_cleaned
SET 
  `Item` = CASE WHEN LOWER(`Item`) IN ('error', 'unknown', '') THEN NULL ELSE `Item` END,
  `Quantity` = CASE WHEN CAST(`Quantity` AS CHAR) IN ('ERROR', 'UNKNOWN', 'unknown', '') THEN NULL ELSE `Quantity` END,
  `Price Per Unit` = CASE WHEN CAST(`Price Per Unit` AS CHAR) IN ('ERROR', 'UNKNOWN', 'unknown', '') THEN NULL ELSE `Price Per Unit` END,
  `Total Spent` = CASE WHEN CAST(`Total Spent` AS CHAR) IN ('ERROR', 'UNKNOWN', 'unknown', '') THEN NULL ELSE `Total Spent` END,
  `Payment Method` = CASE WHEN LOWER(`Payment Method`) IN ('error', 'unknown', '') THEN NULL ELSE `Payment Method` END,
  `Location` = CASE WHEN LOWER(`Location`) IN ('error', 'unknown', '') THEN NULL ELSE `Location` END,
  `Transaction Date` = CASE WHEN `Transaction Date` IN ('ERROR', 'UNKNOWN', 'unknown', '') THEN NULL ELSE `Transaction Date` END;
 
 UPDATE cafe_cleaned
SET `Item` = 
  CASE 
    WHEN `Item` IS NULL AND `Price Per Unit` = 5 THEN 'Salad'
    WHEN `Item` IS NULL AND `Price Per Unit` = 2 THEN 'Coffee'
    WHEN `Item` IS NULL AND `Price Per Unit` = 1.5 THEN 'Tea'
    WHEN `Item` IS NULL AND `Price Per Unit` = 1 THEN 'Cookie'
    WHEN `Item` IS NULL AND `Price Per Unit` = 3 THEN 'Juice'
    WHEN `Item` IS NULL AND `Price Per Unit` = 4 THEN 'Sandwich'
    ELSE `Item`
  END;
 
  UPDATE cafe_cleaned
SET `Location` = 'Takeaway'
WHERE `Location` IS NULL;

UPDATE cafe_cleaned
SET `Transaction Date` = DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 365) DAY)
WHERE `Transaction Date` IS NULL;
  
  -- Step 3: Fill missing Payment Method with 'Digital Wallet'
UPDATE cafe_cleaned
SET `Payment Method` = 'Digital Wallet'
WHERE `Payment Method` IS NULL;

-- Step 4: Fill missing Location with 'Takeaway'
UPDATE cafe_cleaned
SET Location = 'Takeaway'
WHERE 'Location' IS NULL;

-- Step 5: Recalculate missing Quantity, Price, or Total using known values
-- Quantity = Total / Price
UPDATE cafe_cleaned
SET Quantity = `Total Spent` / `Price Per Unit`
WHERE Quantity IS NULL AND `Total Spent` IS NOT NULL AND `Price Per Unit` IS NOT NULL;

-- Price Per Unit = Total / Quantity
UPDATE cafe_cleaned
SET `Price Per Unit` = `Total Spent` / Quantity
WHERE `Price Per Unit` IS NULL AND `Total Spent` IS NOT NULL AND Quantity IS NOT NULL;

-- Total Spent = Quantity * Price
UPDATE cafe_cleaned
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Total Spent` IS NULL AND Quantity IS NOT NULL AND `Price Per Unit` IS NOT NULL;

-- Re-enable safe update mode if desired
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM cafe_cleaned;