--Task: Create a trigger that, when creating a link between existing tables (ALTER TABLE command) 
-- and creating a table with a link (CREATE TABLE command), will provide a cascading update mode between tables
------------------------------------------
--Declaring a package with a procedure for creating a cascade update trigger
create or replace PACKAGE PC_CREATE_TRIGG AUTHID CURRENT_USER AS 
PROCEDURE CREATE_TRIGG(p_table_name VARCHAR2);
END PC_CREATE_TRIGG;
/
--Package Body
create or replace PACKAGE BODY PC_CREATE_TRIGG AS
   PROCEDURE CREATE_TRIGG(p_table_name VARCHAR2) AS
    v_main_table_name VARCHAR2(30000) := UPPER(p_table_name);
    v_sub_table_name VARCHAR2(30000) := UPPER(p_table_name);
    cnt NUMBER(30) := 0;
    temp1 NUMBER(30);
    temp2 NUMBER(30);
    
    compoz_cnt_1 NUMBER(30) := 0;
    compoz_cnt_2 NUMBER(30) := 0;
    
    new_column_name_stm VARCHAR2(30000);
    old_column_name_stm VARCHAR2(30000);
    
    TYPE string_array IS TABLE OF VARCHAR2(100);
    first_column_name_arr string_array;
    second_column_name_arr string_array;
        
  BEGIN
-- consider all the links for the table and write them to the cursor
        FOR cur IN (SELECT DISTINCT cc.table_name AS r_table_name,
                    cc.column_name AS r_column_name,
                    uc.constraint_name,
                    cr.table_name,
                    cr.column_name
                FROM user_cons_columns cc
                JOIN user_constraints uc 
                ON cc.constraint_name = uc.constraint_name
                JOIN user_cons_columns cr
                ON uc.r_constraint_name = cr.constraint_name
                WHERE uc.constraint_type = 'R'
                    AND uc.r_constraint_name IN (SELECT constraint_name
                                                FROM user_constraints
                                                WHERE table_name =  v_main_table_name
                                                    AND constraint_type = 'P')
                ORDER BY cc.table_name) LOOP
--Variables for composite communication
SELECT COUNT(*) INTO compoz_cnt_1 FROM user_cons_columns WHERE table_name = cur.table_name;
SELECT COUNT(*) INTO compoz_cnt_2 FROM user_cons_columns WHERE table_name = cur.r_table_name;

-- If the connection is recursive
            IF cur.table_name = cur.r_table_name THEN
     EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || cur.r_table_name || '_TRG' ||
    ' FOR UPDATE OF '|| cur.column_name || ' ON '|| cur.r_table_name ||' COMPOUND TRIGGER '||
    'TYPE row_type IS TABLE OF '|| cur.r_table_name || '%ROWTYPE' || '; '||
    'TYPE ids_type IS TABLE OF ROWID; ' ||
    'TYPE flag_type IS TABLE OF boolean;' ||
    'rows_l row_type := row_type(); ' ||
    'ids ids_type := ids_type(); ' ||
    'flags flag_type := flag_type();' ||
    'counter NUMBER := 1; ' ||
    'BEFORE STATEMENT IS ' ||
   ' BEGIN ' ||
    'SELECT * BULK COLLECT INTO rows_l FROM ' || cur.r_table_name || '; '||
    'SELECT ROWID BULK COLLECT INTO ids FROM ' || cur.r_table_name || '; '||
    'flags.EXTEND(rows_l.COUNT);' ||
    'FOR i IN 1..rows_l.COUNT LOOP flags(i) := false; END LOOP;' ||
    'UPDATE ' ||  cur.r_table_name  || ' SET '|| cur.r_column_name ||' = NULL; ' ||
    'END BEFORE STATEMENT; '||
    'BEFORE EACH ROW IS ' ||
    'BEGIN ' ||
    'FOR i IN 1..rows_l.COUNT LOOP ' ||
    'IF rows_l(i).' || cur.r_column_name ||' = :OLD.' || cur.column_name ||' AND flags(i) != true '||' THEN rows_l(i).' || cur.r_column_name || ':= :NEW.' || cur.column_name || '; flags(i) := true; '||
   'END IF;' ||
   'END LOOP;' ||
   'END BEFORE EACH ROW; ' ||
   'AFTER STATEMENT IS ' ||
    'BEGIN ' ||
    'FORALL i IN 1..rows_l.COUNT ' ||
    'UPDATE ' || cur.r_table_name ||
    ' SET ' || cur.r_column_name || ' = rows_l(i).' || cur.r_column_name || ' WHERE ROWID = ids(i); '||
    'END AFTER STATEMENT; ' ||
    'END; ';
-- If the connection is non-recursive
            ELSE
            -- If the key is composite
            IF (compoz_cnt_1 = compoz_cnt_2 AND compoz_cnt_1 > 1 )
            THEN 
            SELECT column_name BULK COLLECT INTO first_column_name_arr FROM user_cons_columns WHERE table_name = cur.table_name;
            SELECT column_name BULK COLLECT INTO second_column_name_arr FROM user_cons_columns WHERE table_name = cur.r_table_name;
            new_column_name_stm := second_column_name_arr(1) || ' = :NEW.' || first_column_name_arr(1);
            old_column_name_stm := second_column_name_arr(1) || ' = :OLD.' || first_column_name_arr(1);
            FOR i IN 2..compoz_cnt_1 LOOP
            new_column_name_stm :=  new_column_name_stm ||' ,'|| second_column_name_arr(i) || ' = :NEW.' || first_column_name_arr(i);
            old_column_name_stm :=  old_column_name_stm ||' AND '|| second_column_name_arr(i) || ' = :OLD.' || first_column_name_arr(i);
            END LOOP;
            EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '
                                  || cur.table_name
                                  || '_TRG
                                 AFTER UPDATE ON '
                                  || v_main_table_name
                                  || '
                                 FOR EACH ROW
                                 BEGIN
                                   UPDATE '
                                  || cur.r_table_name
                                  || ' SET '
                                  || new_column_name_stm
                                  || ' WHERE '                           
                                  || old_column_name_stm
                                  || cur.column_name
                                  || ';
                                 END;';
            ELSE -- If the key is not composite
                EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '
                                  || cur.table_name
                                  || '_TRG
                                 AFTER UPDATE ON '
                                  || v_main_table_name
                                  || '
                                 FOR EACH ROW
                                 BEGIN
                                   UPDATE '
                                  || cur.r_table_name
                                  || ' SET '
                                  || cur.r_column_name
                                  || ' = :NEW.'
                                  || cur.column_name
                                  || ' WHERE '
                                  || cur.r_column_name
                                  || ' = :OLD.'
                                  || cur.column_name
                                  || ';
                                 END;';
            END IF; 
            END IF; 
        cnt := cnt + 1;
        END LOOP;
-- If the table has no connection
     IF cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('There is no connection between the tables');
        END IF;
  END CREATE_TRIGG;

END PC_CREATE_TRIGG;
/
--Creating a trigger when creating or changing a table, which will call the procedure and create a trigger for cascading updates
--to do this, we use scheduler, because otherwise an error will occur
create or replace TRIGGER MY_TRIGG_1  AFTER DDL ON SCHEMA BEGIN
    IF
     ORA_DICT_OBJ_TYPE = 'TABLE' 
    THEN 
        dbms_scheduler.create_job(job_name => 'TRIG_CR_'||ORA_DICT_OBJ_NAME||to_char(sysdate,'ddmmyyhh24miss'),
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN PC_CREATE_TRIGG.CREATE_TRIGG(''' || ORA_DICT_OBJ_NAME || '''); END;', 
        start_date      =>     SYSTIMESTAMP,
        end_date =>  SYSTIMESTAMP + NUMTODSINTERVAL(10, 'SECOND'),
        repeat_interval => 'FREQ=SECONDLY;INTERVAL=2',
        ENABLED => TRUE);
    END IF;
END;
/

