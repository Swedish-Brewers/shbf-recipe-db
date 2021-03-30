CREATE OR REPLACE FUNCTION functions.recipe_add_adjunct(
    -- IN VARIABLES
    IN i_recipe_id uuid,
    IN i_inventory_adjunct_id uuid,
    IN i_amount numeric,
    IN i_added_at integer,
    IN i_amount_unit data.enum_amount_unit DEFAULT 'g',
    IN i_added_at_unit data.enum_added_at_unit DEFAULT 'minute',
    IN i_phase data.enum_phase DEFAULT 'boil',
    IN i_data jsonb DEFAULT NULL
)

RETURNS uuid AS $$

DECLARE
    l_id uuid;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF i_recipe_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_RECIPE_ID',
            DETAIL = 'recipe_id is empty!',
            HINT = 'recipe_add_adjunct';
    END IF;

    IF i_inventory_adjunct_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_INVENTORY_adjunct_ID',
            DETAIL = 'inventory_adjunct_id is empty!',
            HINT = 'recipe_add_adjunct';
    END IF;

    IF i_amount IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_AMOUNT',
            DETAIL = 'amount is empty!',
            HINT = 'recipe_add_adjunct';
    END IF;

    IF i_added_at IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_ADDED_AT',
            DETAIL = 'added_at is empty!',
            HINT = 'recipe_add_adjunct';
    END IF;

    --
    -- Function body starts here
    --

    INSERT INTO
        data.recipe_adjunct (
            recipe_id,
            inventory_adjunct_id,
            amount,
            added_at,
            amount_unit,
            added_at_unit,
            phase,
            data
        ) VALUES (
            i_recipe_id,
            i_inventory_adjunct_id,
            i_amount,
            i_added_at,
            i_amount_unit,
            i_added_at_unit,
            i_phase,
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

ALTER FUNCTION functions.recipe_add_adjunct OWNER TO shbf_writer;
