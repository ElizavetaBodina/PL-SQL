--search for schema tables and lists of table columns that store a symbolic value specified as a parameter
create or replace FUNCTION GET_STR_COUNT (t_string VARCHAR2, c_string VARCHAR2, p_string_value VARCHAR2)
RETURN NUMBER AS 
s_str VARCHAR2(200);
v_count NUMBER(10);
j NUMBER(10) := 0;
BEGIN

s_str := 'SELECT COUNT(*) FROM ' ||'"'|| t_string  ||'"'|| ' WHERE '  ||'"'|| c_string  ||'"'||' LIKE ('|| q'['%]'|| p_string_value||q'[%']'||')';
EXECUTE IMMEDIATE s_str INTO v_count;

RETURN v_count;
END GET_STR_COUNT;
/
create or replace PROCEDURE TABLES_WITH_COLUMNS (p_string_value VARCHAR2) AS
TYPE TYPE_STR  IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;

TABLE_COLUMNS TYPE_STR;

i NUMBER := 1;

BEGIN

DBMS_OUTPUT.PUT_LINE('Schema tables and columns containing the value ' || p_string_value || ': ');
DBMS_OUTPUT.PUT_LINE('Table           List of columns ');

FOR table_rec IN (SELECT table_name, tablespace_name FROM user_tables WHERE tablespace_name = 'USERS' ORDER BY table_name) LOOP
    FOR column_rec IN (SELECT column_name, data_type FROM user_tab_columns WHERE table_name = table_rec.table_name AND
    (data_type = 'VARCHAR2' OR data_type = 'NUMBER' OR data_type = 'DATE')) LOOP
        IF(GET_STR_COUNT(table_rec.table_name , column_rec.column_name, p_string_value) > 0) THEN       
            TABLE_COLUMNS(i) := column_rec.column_name ||'(' || column_rec.data_type ||')';
            i:= i + 1;
        END IF;
    END LOOP;

    IF TABLE_COLUMNS.COUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE(' ');
     DBMS_OUTPUT.PUT(table_rec.table_name || '      ');  
     DBMS_OUTPUT.PUT(TABLE_COLUMNS(1));
    IF TABLE_COLUMNS.COUNT > 1 THEN
        FOR j IN 2..TABLE_COLUMNS.COUNT LOOP
        DBMS_OUTPUT.PUT(', ' || TABLE_COLUMNS(j));
        END LOOP;
    END IF;
   END IF;

    TABLE_COLUMNS.DELETE;
    i := 1;

END LOOP;
END TABLES_WITH_COLUMNS;
/
EXECUTE TABLES_WITH_COLUMNS('King');

