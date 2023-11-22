--solving the Hanoi towers problem using a cyclic solution (without recursion)
DECLARE
n NUMBER := 5; -- you can set any value
TYPE v_varray  IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
v_varray_1 v_varray; --declare three lists (in our case index tables)
v_varray_2 v_varray;
v_varray_3 v_varray;

v_end NUMBER; --variable for the number of steps
temp NUMBER; -- variable to write to the list

min_v_1 NUMBER; -- The minimum value from the first list
min_v_2 NUMBER; -- The minimum value from the second list
min_v_3 NUMBER; -- The minimum value from the third list

BEGIN
v_end := 2**N - 1; --number of step

    FOR i IN 1..N LOOP -- Filling in lists
    v_varray_1(i) := i;
    v_varray_2(i) := 0;
    v_varray_3(i) := 0;
    DBMS_OUTPUT.PUT_LINE (v_varray_1(i) ||' '|| v_varray_2(i) ||' '|| v_varray_3(i)); -- Output of the source list
    END LOOP;
DBMS_OUTPUT.PUT_LINE (' ');

FOR step IN 1..v_end LOOP --main loop

min_v_1 := n + 1; -- assign the minimum value greater than possible by 1
min_v_2 := n + 1;
min_v_3 := n + 1;

FOR i IN 1..N LOOP -- Search for the minimum in each of the lists
 IF ( v_varray_1(i) < min_v_1) AND (v_varray_1(i) <> 0) THEN
  min_v_1 :=  v_varray_1(i);
 END IF;
 IF ( v_varray_2(i) < min_v_2) AND (v_varray_2(i) <> 0)  THEN
  min_v_2 :=  v_varray_2(i);
 END IF;
 IF ( v_varray_3(i) < min_v_3) AND (v_varray_3(i) <> 0)  THEN
  min_v_3 :=  v_varray_3(i);
 END IF;
END LOOP;

IF n MOD 2 = 1 THEN -- For an even number
IF   step MOD 3 = 1 THEN -- If step 1, 4, 7...
    IF min_v_1 <  min_v_2 THEN -- check from which list in which we will record and write it down
          FOR i IN  1..N LOOP
              IF v_varray_1(i) = min_v_1 THEN
              v_varray_1(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_2(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_2(i) = 0 AND v_varray_2(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_2(temp) := min_v_1 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_2(i) = min_v_2 THEN
              v_varray_2(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_1(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_1(i) = 0 AND v_varray_1(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_1(temp) := min_v_2 ;
  END IF;
ELSIF  step MOD 3 = 2 THEN  -- If step 2, 5, 8...
 IF min_v_1 <  min_v_3 THEN
          FOR i IN  1..N LOOP
              IF v_varray_1(i) = min_v_1 THEN
              v_varray_1(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_3(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_3(i) = 0 AND v_varray_3(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_3(temp) := min_v_1 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_3(i) = min_v_3 THEN
              v_varray_3(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_1(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_1(i) = 0 AND v_varray_1(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_1(temp) := min_v_3 ;
  END IF;  
        
ELSIF  step MOD 3 = 0 THEN -- If step 3, 6, 9... 
       IF min_v_2 <  min_v_3 THEN
          FOR i IN  1..N LOOP
              IF v_varray_2(i) = min_v_2 THEN
              v_varray_2(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_3(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_3(i) = 0 AND v_varray_3(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_3(temp) := min_v_2 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_3(i) = min_v_3 THEN
              v_varray_3(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_2(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_2(i) = 0 AND v_varray_2(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_2(temp) := min_v_3 ;
  END IF; 
      
END IF;
ELSE -- For an even number

IF   step MOD 3 = 2 THEN --If the step number is 2, 5, 8...
    IF min_v_1 <  min_v_2 THEN
          FOR i IN  1..N LOOP
              IF v_varray_1(i) = min_v_1 THEN
              v_varray_1(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_2(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_2(i) = 0 AND v_varray_2(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_2(temp) := min_v_1 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_2(i) = min_v_2 THEN
              v_varray_2(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_1(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_1(i) = 0 AND v_varray_1(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_1(temp) := min_v_2 ;
  END IF;
ELSIF  step MOD 3 = 1 THEN  --If the step number is 1, 4, 7...
 IF min_v_1 <  min_v_3 THEN
          FOR i IN  1..N LOOP
              IF v_varray_1(i) = min_v_1 THEN
              v_varray_1(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_3(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_3(i) = 0 AND v_varray_3(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_3(temp) := min_v_1 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_3(i) = min_v_3 THEN
              v_varray_3(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_1(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_1(i) = 0 AND v_varray_1(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_1(temp) := min_v_3 ;
  END IF;  
        
ELSIF  step MOD 3 = 0 THEN  -- If the step number is 3, 6, 9...
       IF min_v_2 <  min_v_3 THEN
          FOR i IN  1..N LOOP
              IF v_varray_2(i) = min_v_2 THEN
              v_varray_2(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_3(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_3(i) = 0 AND v_varray_3(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_3(temp) := min_v_2 ;
        
    ELSE 
              FOR i IN  1..N LOOP
              IF v_varray_3(i) = min_v_3 THEN
              v_varray_3(i) := 0;
              END IF;      
          END LOOP;
          
          IF  v_varray_2(n) = 0 THEN
              temp := n;
              ELSE
                  FOR i IN 1..N-1 LOOP
                      IF v_varray_2(i) = 0 AND v_varray_2(i + 1) <> 0 THEN
                      temp := i;
                  END IF;
                  END LOOP;
         END IF;
          
          v_varray_2(temp) := min_v_3 ;
  END IF; 
      
END IF;

END IF;

temp := 0; --Zeroing a variable to write to the list
    FOR i IN 1..N LOOP --Output of intermediate lists
    DBMS_OUTPUT.PUT_LINE (v_varray_1(i) ||' '|| v_varray_2(i) ||' '|| v_varray_3(i));
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE (' ');

END LOOP;
END;
