-- modify table structure
-- change added missing col0 field
ALTER TABLE Table1 ADD COLUMN col0 VARCHAR(100) DEFAULT 'text' AFTER id;