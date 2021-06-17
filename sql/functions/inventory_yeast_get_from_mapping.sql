CREATE OR REPLACE FUNCTION functions.inventory_yeast_get_from_mapping(
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
            HINT = 'inventory_yeast_get_from_mapping';
    END IF;


    --
    -- Function body starts here
    --

    SELECT
        inventory_yeast_id
    INTO
        l_id
    FROM
        data.inventory_yeast_mapping
    WHERE
        name = i_name;


    --
    -- Return here
    --

    IF l_id IS NULL THEN
        RAISE SQLSTATE 'RC404'
        USING MESSAGE = 'MAPPING_NOT_FOUND',
            DETAIL = 'no mapping found for that name!',
            HINT = 'inventory_yeast_get_from_mapping';
    ELSE
        RETURN l_id;
    END IF;

END;

$$ LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.inventory_yeast_get_from_mapping OWNER TO shbf_writer;
