CREATE OR REPLACE FUNCTION functions.recipe_create(
    -- IN VARIABLES
    IN i_name text,
    IN i_batch_size integer,
    IN i_equipment text,
    IN i_version text DEFAULT NULL,
    IN i_description text DEFAULT NULL,
    IN i_mash_data jsonb DEFAULT NULL,
    IN i_water_data jsonb DEFAULT NULL
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
            HINT = 'recipe_create';
    END IF;

    IF i_batch_size IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_BATCH_SIZE',
            DETAIL = 'batch_size is empty!',
            HINT = 'recipe_create';
    END IF;

    IF i_equipment IS NULL OR i_equipment = '' THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_EQUIPMENT',
            DETAIL = 'equipment is empty!',
            HINT = 'recipe_create';
    END IF;

    --
    -- Function body starts here
    --

    INSERT INTO
        data.recipe (
            name,
            version,
            description,
            equipment,
            mash_data,
            water_data,
            batch_size
        ) VALUES (
            i_name,
            i_version,
            i_description,
            i_equipment,
            i_mash_data,
            i_water_data,
            i_batch_size
        )
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

ALTER FUNCTION functions.recipe_create OWNER TO shbf_writer;
