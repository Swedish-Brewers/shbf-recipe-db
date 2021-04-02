CREATE OR REPLACE FUNCTION functions.event_create(
    -- IN VARIABLES
    IN i_name text,
    IN i_start_at timestamptz,
    IN i_finish_at timestamptz,
    IN i_location text,
    IN i_data jsonb DEFAULT NULL
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
            HINT = 'event_create';
    END IF;

    IF i_start_at IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_START_AT',
            DETAIL = 'start_at is empty!',
            HINT = 'event_create';
    END IF;

    IF i_finish_at IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_FINISH_AT',
            DETAIL = 'finish_at is empty!',
            HINT = 'event_create';
    END IF;

    IF i_location IS NULL OR i_location = '' THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_LOCATION',
            DETAIL = 'location is empty!',
            HINT = 'event_create';
    END IF;

    --
    -- Function body starts here
    --

    INSERT INTO
        data.event (
            name,
            start_at,
            finish_at,
            location,
            data
        ) VALUES (
            i_name,
            i_start_at,
            i_finish_at,
            i_location,
            i_data
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

ALTER FUNCTION functions.event_create OWNER TO shbf_writer;
