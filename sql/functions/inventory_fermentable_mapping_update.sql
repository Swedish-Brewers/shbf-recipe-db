CREATE OR REPLACE FUNCTION functions.inventory_fermentable_mapping_update(
    -- IN VARIABLES
    IN i_inventory_fermentable_id uuid,
    IN i_maps uuid[]
)

RETURNS boolean AS $$

DECLARE
    l_map_uuid uuid;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF i_inventory_fermentable_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_INVENTORY_FERMENTABLE_ID',
            DETAIL = 'inventory_fermentable_id is empty!',
            HINT = 'inventory_fermentable_mapping_update';
    END IF;

    IF i_maps IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_MAPS',
            DETAIL = 'maps is empty!',
            HINT = 'inventory_fermentable_mapping_update';
    END IF;

    IF array_length(i_maps, 1) = 0 THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'MAPS_ZERO_LENGTH',
            DETAIL = 'maps has zero length!',
            HINT = 'inventory_fermentable_mapping_update';
    END IF;

    --
    -- Function body starts here
    --

    FOREACH l_map_uuid IN ARRAY i_maps LOOP

        UPDATE
            data.inventory_fermentable_mapping
        SET
            inventory_fermentable_id = i_inventory_fermentable_id,
            updated = NOW()
        WHERE
            id = l_map_uuid;

    END LOOP;


    --
    -- Return here
    --

    RETURN TRUE;

END;

$$ LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.inventory_fermentable_mapping_update OWNER TO shbf_writer;
