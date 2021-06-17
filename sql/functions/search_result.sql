CREATE OR REPLACE FUNCTION functions.search_result(
    -- IN VARIABLES
    IN i_ids uuid[],
    IN i_order_by_column data.enum_order_by_column DEFAULT 'abv',
    IN i_order_by_asc_desc data.enum_order_by_asc_desc DEFAULT 'desc',
    IN i_limit integer DEFAULT NULL,
    IN i_offset integer DEFAULT 0
)

RETURNS jsonb AS $$

DECLARE
	l_json jsonb;

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

    -- Build a minimal result for listing recipes
	-- TODO: Decide on what columns to show

	EXECUTE ('
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
				id = ANY(ARRAY[''' || array_to_string(i_ids, '''::uuid,''') || '''])
			ORDER BY
				data.recipe.' || i_order_by_column::text || ' ' || i_order_by_asc_desc::text || '
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
