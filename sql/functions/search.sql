CREATE OR REPLACE FUNCTION functions.search(
    -- IN VARIABLES
    IN i_inventory text DEFAULT NULL,
    IN i_input text DEFAULT NULL
)

RETURNS jsonb AS $$

DECLARE
    l_found uuid[];
    l_json jsonb;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF (i_inventory IS NULL OR i_inventory = '') AND (i_input IS NULL OR i_input = '') THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_PARAMETERS',
            DETAIL = 'both inventory and input is empty!',
            HINT = 'search';
    END IF;

    --
    -- Function body starts here
    --

    -- Search input
    IF i_input IS NOT NULL THEN
        l_found := array_cat(l_found, ARRAY(
                SELECT
                    id
                FROM
                    data.search
                WHERE
                    input_search @@ websearch_to_tsquery(i_input)
            )
        );
    END IF;

    -- Search inventory
    IF i_inventory IS NOT NULL THEN
        l_found := array_cat(l_found, ARRAY(
                SELECT
                    id
                FROM
                    data.search
                WHERE
                    inventory_search @@ to_tsquery(replace(i_inventory, '-', ''))
            )
        );
    END IF;

    -- Return here if there are nothing found
    IF array_length(l_found, 1) IS NULL THEN
        RETURN NULL;
    END IF;

    -- Remove duplicates from the result array if both in parameters are used
    IF i_input IS NOT NULL AND i_inventory IS NOT NULL THEN
        l_found := ARRAY(SELECT DISTINCT UNNEST(l_found));
    END IF;

    -- Build a json from the result(s)
    SELECT
        row_to_json(t) AS result
    FROM (
        SELECT
            -- Possibly we want to get the actual recipes here like:
            -- loop the l_found and fetch with recipe_get_json(id)
            array_to_json(l_found) AS recipes,
            (
                SELECT
                    array_to_json(array_agg(row_to_json(h)))
                FROM (
                    SELECT
                        word::uuid AS inventory_id,
                        ndoc AS "count"
                    FROM
                        ts_stat('
                            SELECT
                                inventory_search
                            FROM
                                data.search
                            WHERE
                                id IN (''' || array_to_string(l_found, ''',''') || ''')
                        ')
                ) h
            ) AS statistics
    ) AS t
    INTO
        l_json;

    RETURN l_json;

END;

$$ LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.search OWNER TO shbf_writer;
