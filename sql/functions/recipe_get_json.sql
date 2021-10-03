-- TODO: Add all connected tables.

CREATE OR REPLACE FUNCTION functions.recipe_get_json(
    -- IN VARIABLES
    IN i_id uuid
)

RETURNS jsonb AS $$

DECLARE
    l_json jsonb;

BEGIN

    --
    -- Checking of input params starts here
    --

    IF i_id IS NULL THEN
        RAISE SQLSTATE 'RC400'
        USING MESSAGE = 'EMPTY_ID',
            DETAIL = 'id is empty!',
            HINT = 'recipe_get_json';
    END IF;

    --
    -- Function body starts here
    --

    SELECT
        row_to_json(t) AS recipe
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
            updated,

            -- Build hops json list
            (
                SELECT
                    array_to_json(array_agg(row_to_json(h)))
                FROM (
                    SELECT
                        ih.id AS inventory_hop_id,
                        ih.name AS name,
                        amount,
                        amount_unit,
                        phase,
                        added_at,
                        added_at_unit
                    FROM
                        data.recipe_hop rh
                    INNER JOIN
                        data.inventory_hop ih
                    ON
                        ih.id = rh.inventory_hop_id
                    WHERE
                        rh.recipe_id = r.id
                ) h
            ) AS hop,

            -- Build fermentables json list
            (
                SELECT
                    array_to_json(array_agg(row_to_json(f)))
                FROM (
                    SELECT
                        infe.id AS inventory_fermentable_id,
                        infe.name AS name,
                        amount,
                        amount_unit,
                        phase
                    FROM
                        data.recipe_fermentable rf
                    INNER JOIN
                        data.inventory_fermentable infe
                    ON
                        infe.id = rf.inventory_fermentable_id
                    WHERE
                        rf.recipe_id = r.id
                ) f
            ) AS fermentable,

            -- Build yeast json list
            (
                SELECT
                    array_to_json(array_agg(row_to_json(y)))
                FROM (
                    SELECT
                        iy.id AS inventory_yeast_id,
                        iy.name AS name,
                        amount,
                        amount_unit,
                        fermentation_time,
                        fermentation_unit,
                        fermentation_order
                    FROM
                        data.recipe_yeast ry
                    INNER JOIN
                        data.inventory_yeast iy
                    ON
                        iy.id = ry.inventory_yeast_id
                    WHERE
                        ry.recipe_id = r.id
                ) y
            ) AS yeast,

            -- Build adjunct json list
            (
                SELECT
                    array_to_json(array_agg(row_to_json(a)))
                FROM (
                    SELECT
                        ia.id AS inventory_adjunct_id,
                        ia.name AS name,
                        amount,
                        amount_unit,
                        added_at,
                        added_at_unit,
                        phase
                    FROM
                        data.recipe_adjunct ra
                    INNER JOIN
                        data.inventory_adjunct ia
                    ON
                        ia.id = ra.inventory_adjunct_id
                    WHERE
                        ra.recipe_id = r.id
                ) a
            ) AS adjunct
        FROM
            data.recipe AS r
        WHERE
            id = i_id
    ) AS t
    INTO
        l_json;

    --
    -- Return here
    --

    RETURN l_json;

END;

$$ LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = data, pg_temp;

ALTER FUNCTION functions.recipe_get_json OWNER TO shbf_writer;
