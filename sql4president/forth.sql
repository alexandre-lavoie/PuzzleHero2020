--
-- SQL-Forth: a sqlite3 implementation of ANSI Forth
--
-- TODO: Implement everything
-- 

WITH RECURSIVE
tmp AS (
     SELECT
        command AS orig_command,
        0 as steps,
        0 as stop,
        '' as stack,
        SUBSTR(command, 0, INSTR(command, ' ')) AS car,
        SUBSTR(command, INSTR(command, ' ') + 1) || ' ' AS command
     FROM (SELECT * FROM code LIMIT 1)
     UNION ALL
     SELECT
     orig_command,
     steps + 1,
     -- stop
     LENGTH(SUBSTR(command, INSTR(command, ' ') + 1)) = 0 AND LENGTH(SUBSTR(command, 0, INSTR(command, ' '))) = 0,
     -- stack
     CASE
         WHEN car = '' THEN
         stack
         -- int litteral
         WHEN printf('%d', car) = car THEN
             car || ' ' || stack
         -- operators
         WHEN car = '+' THEN
             CASE
                 WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2
                 THEN 'ERROR'
                 ELSE
                 CAST(
                    CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS INTEGER)
                    + CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS INTEGER)
                 AS TEXT) || ' ' ||
                 SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
             END
         ELSE
             'ERROR'
     END,
     SUBSTR(command, 0, INSTR(command, ' ')) AS car,
     SUBSTR(command, INSTR(command, ' ') + 1) AS cdr
     FROM tmp
     WHERE
     stack != 'ERROR' AND
     NOT stop
)
SELECT SUBSTR(stack, 0, INSTR(stack, ' '))
FROM tmp
GROUP BY steps
HAVING steps=(SELECT MAX(steps) FROM tmp AS t);
