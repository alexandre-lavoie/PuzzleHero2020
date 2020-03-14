WITH RECURSIVE
tmp AS (
    SELECT
        command AS orig_command,
        0 as steps,
        0 as stop,
		'' as logger,
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
	--logger
	CASE
		WHEN car = '.' THEN
			logger || ' ' || CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS INTEGER)
		ELSE
			logger
	END,
    -- stack 
    CASE
        -- if empty, skip.
        WHEN car = '' THEN
        stack
        -- if integer number.
        WHEN printf('%d', car) = car THEN
            car || ' ' || stack
        WHEN car = '+' THEN
			CASE
                -- If there aren't two values on stack.
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    -- Gets first and second values on top of stack and adds them.
                    CAST(
                        -- Takes first number
                        CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS INTEGER) 
                        +
                        -- Takes second number
                        CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS INTEGER)
                    AS TEXT) 
                    
                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = '-' THEN
			CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    CAST(
                        CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS INTEGER) 
                        - 
                        CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS INTEGER)
                    AS TEXT) 
                    
                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = '*' THEN
			CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    CAST(
                        CAST(
                            CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT) 
                            *
                            CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                        AS INTEGER) 
                    AS TEXT) 
                    
                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = '/' THEN
			CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                WHEN CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS INTEGER) = 0 THEN 
                    'ERROR'
                ELSE
                    CAST(
                        CAST(
                            CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT) 
                            /
                            CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                        AS INTEGER) 
                    AS TEXT)

                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = 'mod' THEN
            CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    CAST(
                        CAST(
                            CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT) 
                            %
                            CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                        AS INTEGER) 
                    AS TEXT)

                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = 'min' THEN
            CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    CAST (
                        CASE
                            WHEN 
                                CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT) 
                                > 
                                CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                            THEN
                                CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                            ELSE
                                CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT)
                        END
                    AS INTEGER)

                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car ='max' THEN
            CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    CAST (
                        CASE
                            WHEN 
                                CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT) 
                                <
                                CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                            THEN
                                CAST(SUBSTR(stack, 0, INSTR(stack, ' ')) AS FLOAT)
                            ELSE
                                CAST(SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ')) AS FLOAT)
                        END
                    AS INTEGER)

                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = 'dup' THEN
            CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 1 THEN 
                    'ERROR'
                ELSE
                    SUBSTR(stack, 0, INSTR(stack, ' '))

                    -- Stack seperator.
                    || ' ' ||
                    
                    stack
            END
        WHEN car = 'swap' THEN
            CASE
                WHEN (LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))) < 2 THEN 
                    'ERROR'
                ELSE
                    -- Second value.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), 0, INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' '))

                    || ' ' ||
                    -- First value.
                    SUBSTR(stack, 0, INSTR(stack, ' '))

                    -- Stack seperator.
                    || ' ' ||
                    
                    -- Remove two previous values from stack.
                    SUBSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), INSTR(SUBSTR(stack, INSTR(stack, ' ') + 1), ' ') + 1)
            END
        WHEN car = 'depth' THEN
            -- Spaces act as seperator, therefore remove total from spaced to get count.
            CAST(
                LENGTH(stack) - LENGTH(REPLACE(stack, ' ', ''))
            AS TEXT)

            -- Stack seperator.
            || ' ' ||
                    
            -- Keeps stack the same.
            stack
        WHEN car = ',' THEN    
            -- Remove previous value from stack.
            SUBSTR(stack, INSTR(stack, ' ') + 1)
        WHEN car = '.' THEN
            -- Remove previous value from stack.
            SUBSTR(stack, INSTR(stack, ' ') + 1)
        ELSE
            -- Error if operator doesn't exist.
            'ERROR'
    END, 
    SUBSTR(command, 0, INSTR(command, ' ')) AS car,
    SUBSTR(command, INSTR(command, ' ') + 1) AS cdr
    FROM tmp
    WHERE
    stack != 'ERROR' AND
    NOT stop
)
SELECT (CASE 
    WHEN LENGTH(logger) > 0 THEN
        logger || ' ' || SUBSTR(stack, 0, INSTR(stack, ' '))
    ELSE
        SUBSTR(stack, 0, INSTR(stack, ' '))
END)
FROM tmp
GROUP BY steps
HAVING steps=(SELECT MAX(steps) FROM tmp AS t);