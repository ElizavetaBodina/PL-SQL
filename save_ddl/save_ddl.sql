--Task: Create a package to save DDL commands in a file to create individual schema objects, groups of objects of the same type, or all objects.
CREATE OR REPLACE PACKAGE ddl_save_pkg AS
PROCEDURE save_ddl (p_object_type in VARCHAR2, p_object_name in VARCHAR2, p_file_name  in VARCHAR2); --Creating individual objects
PROCEDURE save_ddl_group(p_object_type in VARCHAR2, p_file_name in VARCHAR2); --Creating groups of objects
PROCEDURE save_ddl_all(p_file_name in VARCHAR2 ); --Creating all objects
    
END ddl_save_pkg;
/
CREATE OR REPLACE PACKAGE BODY ddl_save_pkg AS
    PROCEDURE save_ddl (p_object_type IN VARCHAR2, p_object_name in VARCHAR2, p_file_name  in VARCHAR2) AS
    p_type VARCHAR2(30) := UPPER(p_object_type);
    p_name VARCHAR2(30) := UPPER(p_object_name);
    l_file UTL_FILE.FILE_TYPE; 
    BEGIN
        l_file := UTL_FILE.FOPEN('STUD_PLSQL', p_file_name, 'W');
        UTL_FILE.PUT_LINE(l_file, DBMS_METADATA.GET_DDL(p_type, p_name));
        UTL_FILE.FCLOSE(l_file);
         EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;

   PROCEDURE save_ddl_group(p_object_type in VARCHAR2, p_file_name in VARCHAR2) AS
    v_file UTL_FILE.FILE_TYPE;
-- cursor for storing object types and names
    CURSOR v_cursor IS
    SELECT object_name, object_type
    FROM user_objects
    WHERE object_type = UPPER(p_object_type);    
  BEGIN 
    v_file := UTL_FILE.FOPEN('STUD_PLSQL', p_file_name, 'W');
--The loop goes through and records the data of all the elements of the group
    FOR rec IN v_cursor LOOP
    UTL_FILE.PUT(v_file, DBMS_METADATA.GET_DDL(rec.object_type, rec.object_name));
    END LOOP;
    UTL_FILE.FCLOSE(v_file);
  EXCEPTION
    WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
  END;

 PROCEDURE save_ddl_all(p_file_name in VARCHAR2) AS
    v_file UTL_FILE.FILE_TYPE;
-- The cursor selects all objects except the package bodies and LOB, because their ddl cannot be obtained
    CURSOR v_cursor IS
    SELECT object_name, object_type
    FROM user_objects
    WHERE object_type!='PACKAGE BODY'
    AND object_type!='LOB' ;    
  BEGIN
    v_file := UTL_FILE.FOPEN('STUD_PLSQL', p_file_name, 'W');
    FOR rec IN v_cursor LOOP
    UTL_FILE.PUT(v_file, DBMS_METADATA.GET_DDL(rec.object_type, rec.object_name));
    END LOOP;
    UTL_FILE.FCLOSE(v_file);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
  END;
END ddl_save_pkg;
/
--save the code for creating the EMPLOYEES table
EXECUTE ddl_save_pkg .save_ddl('TABLE', 'EMPLOYEES', 'emp_table.xml');
--how to view ddl code
DECLARE
  file_handle UTL_FILE.FILE_TYPE;
  file_content VARCHAR2(32767);
BEGIN
  file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'emp_table.xml', 'R');
  LOOP
    UTL_FILE.GET_LINE(file_handle, file_content);
    DBMS_OUTPUT.PUT_LINE(file_content);
  END LOOP;
  UTL_FILE.FCLOSE(file_handle);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END;
/
--save the code for creating all view
EXECUTE ddl_save_pkg .save_ddl_group('VIEW', 'view.xml');
--how to view ddl code
DECLARE
  file_handle UTL_FILE.FILE_TYPE;
  file_content VARCHAR2(32767);
BEGIN
  file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'view.xml', 'R');
  LOOP
    UTL_FILE.GET_LINE(file_handle, file_content);
    DBMS_OUTPUT.PUT_LINE(file_content);
  END LOOP;
  UTL_FILE.FCLOSE(file_handle);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END;



