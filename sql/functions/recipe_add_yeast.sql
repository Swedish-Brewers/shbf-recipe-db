CREATE OR REPLACE FUNCTION functions.recipe_add_yeast(
    -- IN VARIABLES
    IN i_recipe_id uuid,
    IN i_inventory_yeast_id uuid,
    IN i_amount numeric,
    IN i_fermentation_time numeric,
    IN i_amount_unit data.enum_amount_unit DEFAULT 'pkg',
    IN i_fermentation_unit data.enum_fermentation_unit DEFAULT 'day',
    IN i_fermentation_order integer DEFAULT 1,
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
            HINT = 'recipe_add_yeast';
    END IF;

    IF i_inventory_yeast_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_INVENTORY_yeast_ID',
            DETAIL = 'inventory_yeast_id is empty!',
            HINT = 'recipe_add_yeast';
    END IF;

    IF i_amount IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_AMOUNT',
            DETAIL = 'amount is empty!',
            HINT = 'recipe_add_yeast';
    END IF;

    IF i_fermentation_time IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_FERMENTATION_TIME',
            DETAIL = 'fermentation_time is empty!',
            HINT = 'recipe_add_yeast';
    END IF;

    --
    -- Function body starts here
    --

    INSERT INTO
        data.recipe_yeast (
            recipe_id,
            inventory_yeast_id,
            amount,
            amount_unit,
            fermentation_time,
            fermentation_unit,
            fermentation_order,
            data
        ) VALUES (
            i_recipe_id,
            i_inventory_yeast_id,
            i_amount,
            i_amount_unit,
            i_fermentation_time,
            i_fermentation_unit,
            i_fermentation_order,
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

ALTER FUNCTION functions.recipe_add_yeast OWNER TO shbf_writer;
