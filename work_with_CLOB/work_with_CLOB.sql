--Working with CLOB type columns
CREATE OR REPLACE 
PACKAGE PC_CLOB AS
-- Procedure for converting to uppercase in a given range
PROCEDURE CLOB_UPPER(table_name VARCHAR2, column_name VARCHAR2, start_pos NUMBER, end_pos NUMBER);
-- Procedure for replacing an old value with a new one
PROCEDURE CLOB_CHANGE(table_name VARCHAR2, column_name VARCHAR2, old_value CLOB, new_value CLOB);
-- Procedures for searching by conditions
PROCEDURE CLOB_FIND(table_name VARCHAR2, column_name VARCHAR2, text_length NUMBER); -- the condition is equality of the length of the text
PROCEDURE CLOB_FIND(table_name VARCHAR2, column_name VARCHAR2, text CLOB); -- the presence of a substring in the string
END PC_CLOB;
/
CREATE OR REPLACE
PACKAGE BODY PC_CLOB AS
-- A function that checks whether a table exists, whether a column exists, and whether it is a CLOB type 
FUNCTION CHECK_VALUES (table_name VARCHAR2, column_name VARCHAR2) RETURN BOOLEAN AS
     clob_column NUMBER;
     column_exists NUMBER;
     table_exists NUMBER;
     flag BOOLEAN := FALSE;
     BEGIN
     SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = UPPER(table_name);
        IF table_exists > 0 THEN
            SELECT COUNT(*) INTO column_exists
            FROM user_tab_columns
            WHERE table_name = UPPER(table_name) AND column_name = UPPER(column_name);
        
            IF column_exists > 0 THEN
                SELECT COUNT(*) INTO clob_column
                FROM user_tab_columns
                WHERE table_name = UPPER(table_name) AND column_name = UPPER(column_name) AND data_type = 'CLOB';
                
IF clob_column = 1 THEN
                flag := TRUE;
                END IF;
            END IF;
        END IF;

    RETURN (flag); -- If all conditions are met, it returns TRUE, otherwise FALSE
  END CHECK_VALUES;

  PROCEDURE CLOB_UPPER(table_name VARCHAR2, column_name VARCHAR2, start_pos NUMBER, end_pos NUMBER) AS
  sql_upper VARCHAR2(1000);
  v_check BOOLEAN;
  first_simbol NUMBER := start_pos - 1;
  middle_simbol NUMBER := end_pos - start_pos;
  BEGIN
    v_check := CHECK_VALUES(table_name, column_name);
    
    IF v_check THEN 
   sql_upper  := 'UPDATE ' || table_name || 
                 ' SET ' || column_name || ' = SUBSTR(' || column_name || ', 1, :first_simbol) || ' ||
                 'UPPER(SUBSTR(' || column_name || ', :start_pos, :middle_simbol)) || ' ||
                 'SUBSTR(' || column_name || ', :end_pos)';
    EXECUTE IMMEDIATE sql_upper  USING  first_simbol, start_pos, middle_simbol, end_pos;
    ELSE DBMS_OUTPUT.PUT_LINE('Conditions not met! ');
    END IF;
  END CLOB_UPPER;

  PROCEDURE CLOB_CHANGE(table_name VARCHAR2, column_name VARCHAR2, old_value CLOB, new_value CLOB) AS
  sql_change VARCHAR2(1000);
  v_check BOOLEAN;
  BEGIN
   v_check :=  CHECK_VALUES (table_name, column_name);
   
    IF v_check THEN 
    sql_change := 'UPDATE ' || table_name || ' SET ' || column_name || ' =  REPLACE(' || column_name || ', :old_value, :new_value)';
    EXECUTE IMMEDIATE sql_change USING old_value, new_value; 
    ELSE DBMS_OUTPUT.PUT_LINE('Conditions not met! ');
    END IF;

  END CLOB_CHANGE;

  PROCEDURE CLOB_FIND(table_name VARCHAR2, column_name VARCHAR2, text_length NUMBER) AS
  sql_find VARCHAR2(1000);
  v_check BOOLEAN;
  TYPE my_refcsr_type IS REF CURSOR;
  cur_clob  my_refcsr_type;
  str_clob  CLOB;

  BEGIN
   v_check :=  CHECK_VALUES (table_name, column_name);
   
    IF v_check THEN 
    sql_find := 'SELECT '|| column_name ||' FROM ' || table_name || 
                 ' WHERE LENGTH(' || column_name || ')  = :text_length';
        IF text_length IS NULL THEN OPEN cur_clob FOR sql_find;
        ELSE OPEN cur_clob FOR sql_find USING text_length; 
        END IF;
    LOOP
    FETCH cur_clob INTO str_clob;
    EXIT WHEN cur_clob%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(str_clob);
  END LOOP;
  CLOSE cur_clob;
    ELSE DBMS_OUTPUT.PUT_LINE('Не выполнены условия !');
    END IF;

  END CLOB_FIND;

  PROCEDURE CLOB_FIND(table_name VARCHAR2, column_name VARCHAR2, text CLOB) AS
  sql_find VARCHAR2(1000);
  v_check BOOLEAN;
  new_text CLOB := '%'|| text ||'%';
  TYPE my_refcsr_type IS REF CURSOR;
  cur_clob  my_refcsr_type;
  str_clob  CLOB;
  BEGIN
   v_check :=  CHECK_VALUES (table_name, column_name);
   
    IF v_check THEN 
    sql_find := 'SELECT '|| column_name ||' FROM ' || table_name || 
                 ' WHERE ' || column_name || ' LIKE :new_text';
      IF text IS NULL THEN OPEN cur_clob FOR sql_find;
        ELSE OPEN cur_clob FOR sql_find USING new_text; 
        END IF;
    LOOP
    FETCH cur_clob INTO str_clob;
    EXIT WHEN cur_clob%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(str_clob);
  END LOOP;
  CLOSE cur_clob;
    ELSE DBMS_OUTPUT.PUT_LINE('Conditions not met!');
    END IF;
  END CLOB_FIND;

END PC_CLOB;
/
--Creating a table for checking the package operation
--DROP TABLE CLOBTEST;
CREATE TABLE CLOBTEST (
    ID NUMBER PRIMARY KEY,
    TEXT CLOB
);

INSERT INTO CLOBTEST (ID, TEXT)
VALUES (1, 'Это текст первой записи.');

INSERT INTO CLOBTEST (ID, TEXT)
VALUES (2, 'Это текст второй записи.');

INSERT INTO CLOBTEST (ID, TEXT)
VALUES (3, 'Это текст третьей записи.');

SELECT * FROM CLOBTEST;
/
-- check on a column of type not CLOB
EXECUTE PC_CLOB.CLOB_UPPER('EMPLOYEES', 'LAST_NAME', 5, 10);
/
-- check the first procedure
EXECUTE PC_CLOB.CLOB_UPPER('CLOBTEST', 'TEXT', 5, 10);
/
-- check the second procedure
EXECUTE PC_CLOB.CLOB_CHANGE('CLOBTEST', 'TEXT', 'Это текст третьей записи.', 'Это новый текст третьей записи.');
/
-- check the third procedure for searching by length
EXECUTE PC_CLOB.CLOB_FIND('CLOBTEST', 'TEXT', 24);
/
-- check the third procedure for searching by substring
DECLARE
my_text CLOB := 'текст';
BEGIN
PC_CLOB.CLOB_FIND('CLOBTEST', 'TEXT', my_text);
END;

