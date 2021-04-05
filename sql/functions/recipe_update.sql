CREATE OR REPLACE FUNCTION functions.recipe_update(
    -- IN VARIABLES
    IN i_id uuid,
    IN i_event_id uuid,
    IN i_name text,
    IN i_batch_size integer,
    IN i_og numeric,
    IN i_fg numeric,
    IN i_abv numeric,
    IN i_equipment text,
    IN i_version text DEFAULT NULL,
    IN i_description text DEFAULT NULL,
    IN i_style text DEFAULT NULL,
    IN i_mash_data jsonb DEFAULT NULL,
    IN i_water_data jsonb DEFAULT NULL,
    IN i_state data.enum_state DEFAULT 'inactive'
)

RETURNS uuid AS $$

DECLARE
    l_id uuid;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF i_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_ID',
            DETAIL = 'id is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_event_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_EVENT_ID',
            DETAIL = 'evnt_id is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_name IS NULL OR i_name = '' THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_NAME',
            DETAIL = 'name is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_batch_size IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_BATCH_SIZE',
            DETAIL = 'batch_size is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_og IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_OG',
            DETAIL = 'og is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_fg IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_FG',
            DETAIL = 'fg is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_abv IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_ABV',
            DETAIL = 'abv is empty!',
            HINT = 'recipe_update';
    END IF;

    IF i_equipment IS NULL OR i_equipment = '' THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_EQUIPMENT',
            DETAIL = 'equipment is empty!',
            HINT = 'recipe_update';
    END IF;

    --
    -- Function body starts here
    --

    UPDATE
        data.recipe
    SET
        event_id = i_event_id,
        name = i_name,
        style = i_style,
        version = i_version,
        description = i_description,
        equipment = i_equipment,
        mash_data = i_mash_data,
        water_data = i_water_data,
        batch_size = i_batch_size,
        og = i_og,
        fg = i_fg,
        abv = i_abv,
        state = i_state,
        updated = NOW()
    WHERE
        id = i_id
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

ALTER FUNCTION functions.recipe_update OWNER TO shbf_writer;
