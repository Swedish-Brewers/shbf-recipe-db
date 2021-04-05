CREATE OR REPLACE FUNCTION functions.clear_db()

RETURNS boolean AS $$

BEGIN

    --
    -- Function body starts here
    --

    TRUNCATE TABLE data.inventory_hop CASCADE;
    TRUNCATE TABLE data.inventory_hop_mapping CASCADE;
    TRUNCATE TABLE data.inventory_fermentable CASCADE;
    TRUNCATE TABLE data.inventory_fermentable_mapping CASCADE;
    TRUNCATE TABLE data.inventory_yeast CASCADE;
    TRUNCATE TABLE data.inventory_yeast_mapping CASCADE;
    TRUNCATE TABLE data.inventory_adjunct CASCADE;
    TRUNCATE TABLE data.inventory_adjunct_mapping CASCADE;
    TRUNCATE TABLE data.brewer CASCADE;
    TRUNCATE TABLE data.award CASCADE;
    TRUNCATE TABLE data.event CASCADE;
    TRUNCATE TABLE data.recipe CASCADE;
    TRUNCATE TABLE data.recipe_award CASCADE;
    TRUNCATE TABLE data.recipe_brewer CASCADE;
    TRUNCATE TABLE data.recipe_fermentable CASCADE;
    TRUNCATE TABLE data.recipe_hop CASCADE;
    TRUNCATE TABLE data.recipe_yeast CASCADE;
    TRUNCATE TABLE data.recipe_adjunct CASCADE;
    TRUNCATE TABLE data.import_source CASCADE;
    TRUNCATE TABLE data.import CASCADE;

    --
    -- Return here
    --

    RETURN TRUE;

END;

$$ LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.clear_db OWNER TO shbf_writer;
