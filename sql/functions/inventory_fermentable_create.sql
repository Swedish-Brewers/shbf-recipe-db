CREATE OR REPLACE FUNCTION functions.inventory_fermentable_create(
    -- IN VARIABLES
    IN i_name text
)

RETURNS uuid AS $$

DECLARE
    l_id uuid;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF i_name IS NULL OR i_name = '' THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_NAME',
            DETAIL = 'name is empty!',
            HINT = 'inventory_fermentable_create';
    END IF;


    --
    -- Function body starts here
    --

    INSERT INTO
        data.inventory_fermentable (
            name
        ) VALUES (
            i_name
        )
    ON CONFLICT
        (name)
    DO UPDATE SET
        name = EXCLUDED.name,
        updated = NOW()
    RETURNING
        id
    INTO
        l_id;

    --
    -- Return here
    --

    RETURN l_id;

END;

$$ LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.inventory_fermentable_create OWNER TO shbf_writer;
