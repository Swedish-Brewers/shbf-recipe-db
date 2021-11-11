CREATE OR REPLACE FUNCTION functions.search_result(
    -- IN VARIABLES
    IN i_ids uuid[],
    IN i_order_by_column data.enum_order_by_column DEFAULT 'abv',
    IN i_order_by_asc_desc data.enum_order_by_asc_desc DEFAULT 'desc',
    IN i_limit integer DEFAULT NULL,
    IN i_offset integer DEFAULT 0,
    IN i_vitals jsonb DEFAULT NULL
)

RETURNS jsonb AS $$

DECLARE
	l_json jsonb;
    l_vitals text;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF (i_ids IS NULL OR array_length(i_ids, 1) = 0) THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_IDS',
            DETAIL = 'ids are empty!',
            HINT = 'search_result';
    END IF;

    --
    -- Function body starts here
    --

    -- Build a vitals delimiter string
    IF i_vitals IS NOT NULL THEN
        WITH a AS (
            SELECT
                key,
                value
            FROM
                jsonb_each(i_vitals)
            WHERE
                key IN ('og', 'fg', 'abv')
        )
        SELECT
            string_agg(
                (
                    (CASE WHEN value::jsonb->'max' IS NOT NULL THEN (' AND ' || key || ' <= ' || (SELECT a.value::jsonb->>'max' FROM a AS b WHERE a.key = b.key) || ' ') ELSE '' END)
                    ||
                    (CASE WHEN value::jsonb->'min' IS NOT NULL THEN (' AND ' || key || ' >= ' || (SELECT a.value::jsonb->>'min' FROM a AS b WHERE a.key = b.key) || ' ') ELSE '' END)
                ),
                ' '
            )
        INTO
            l_vitals
        FROM
            a;
    END IF;


    -- Build a minimal result for listing recipes
	-- TODO: Decide on what columns to show

	EXECUTE('
		SELECT
			array_to_json(array_agg(row_to_json(r))) AS result
		FROM (
			SELECT
				id,
				name,
				style,
				version,
				description,
				equipment,
				mash_data,
				water_data,
				batch_size,
				og,
				fg,
				abv,
				state,
				created,
				updated
			FROM
				data.recipe
			WHERE
				id = ANY(ARRAY[''' || array_to_string(i_ids, '''::uuid,''') || '''::uuid])

                ' || (CASE WHEN l_vitals IS NOT NULL THEN l_vitals ELSE '' END) ||

                (CASE WHEN i_order_by_column IS NOT NULL THEN (
            ' ORDER BY
				data.recipe.' || i_order_by_column::text || ' ' || i_order_by_asc_desc::text
                ) ELSE ' ' END) || '

			LIMIT ' || (CASE WHEN i_limit IS NULL THEN 'ALL' ELSE i_limit::text END) || '

			OFFSET ' || i_offset::text || '
		) AS r
		')
	INTO
		l_json;

	RETURN l_json;
END;

$$ LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.search_result OWNER TO shbf_writer;
