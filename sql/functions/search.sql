CREATE OR REPLACE FUNCTION functions.search(
    -- IN VARIABLES
    IN i_inventory text DEFAULT NULL,
    IN i_input text DEFAULT NULL,
    IN i_order_by_column data.enum_order_by_column DEFAULT 'abv',
    IN i_order_by_asc_desc data.enum_order_by_asc_desc DEFAULT 'desc',
    IN i_limit integer DEFAULT NULL,
    IN i_offset integer DEFAULT 0
)

RETURNS jsonb AS $$

DECLARE
    l_found uuid[];
    l_json jsonb;

BEGIN

    --
    -- Checking of input params starts here
    --

    -- Enable if we don't want a possible full table scan
    --IF (i_inventory IS NULL OR i_inventory = '') AND (i_input IS NULL OR i_input = '') THEN
    --    RAISE SQLSTATE 'RC400'
    --    USING MESSAGE = 'EMPTY_PARAMETERS',
    --        DETAIL = 'both inventory and input is empty!',
    --        HINT = 'search';
    --END IF;

    --
    -- Function body starts here
    --

    -- Search input
    l_found := array_cat(l_found, ARRAY(
            SELECT
                id
            FROM
                data.search
            WHERE
                (
                    CASE WHEN
                        i_input IS NULL
                    THEN
                        TRUE
                    ELSE
                        input_search @@ websearch_to_tsquery(i_input)
                    END
                )
                AND (
                    CASE WHEN
                        i_inventory IS NULL
                    THEN
                        TRUE
                    ELSE
                        inventory_search @@ to_tsquery(replace(i_inventory, '-', ''))
                    END
                )
        )
    );

    -- Return here if there are nothing found
    IF array_length(l_found, 1) IS NULL THEN
        RETURN NULL;
    END IF;


    -- Build a json from the result(s)
    SELECT
        row_to_json(t) AS result
    FROM (
        SELECT
            array_length(l_found, 1) AS recipe_count,
            (
                SELECT
                    *
                FROM
                    functions.search_result(
                        l_found,
                        i_order_by_column,
                        i_order_by_asc_desc,
                        i_limit,
                        i_offset
                    )
            ) AS recipes,
            -- This can be removed if we don't want to query search_result by itself
            -- or the dataset gets too large for clients to handle.
            array_to_json(l_found) AS recipe_ids,
            (
                SELECT
                    array_to_json(array_agg(row_to_json(h)))
                FROM (
                    SELECT
                        word::uuid AS inventory_id,
                        inventory AS inventory_type,
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
                    LEFT JOIN
                        data.inventory_usage
                    ON
                        data.inventory_usage.id = word::uuid
                    WHERE
                        char_length(word) = 32
                ) h
            ) AS statistics
    ) AS t
    INTO
        l_json;

    RETURN l_json;

END;

$$ LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.search OWNER TO shbf_writer;
