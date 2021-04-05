--
-- Documentation:
--
-- * All tables have an id that's an uuid and is called "id"
--
-- * The tables and views should be named in singular; "account"
--   and not "accounts".
--
-- * Every time a table is referenced, the column should be named what it
--   refers to for clarity. An example would be account_id, which should then
--   refer to account table with column id.
--

CREATE TABLE IF NOT EXISTS data.inventory_hop (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_hop OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.inventory_hop_mapping (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_hop_id      uuid REFERENCES data.inventory_hop (id),
    name                  text NOT NULL UNIQUE,
    created               timestamptz NOT NULL DEFAULT NOW(),
    updated               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_hop_mapping OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS inventory_hop_mapping_inventory_hop_id_idx ON data.inventory_hop_mapping (inventory_hop_id);


CREATE TABLE IF NOT EXISTS data.inventory_fermentable (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_fermentable OWNER TO shbf_writer;

CREATE TABLE IF NOT EXISTS data.inventory_fermentable_mapping (
    id                           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_fermentable_id     uuid REFERENCES data.inventory_fermentable (id),
    name                         text NOT NULL UNIQUE,
    created                      timestamptz NOT NULL DEFAULT NOW(),
    updated                      timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_fermentable_mapping OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS inventory_fermentable_mapping_inventory_fermentable_id_idx ON data.inventory_fermentable_mapping (inventory_fermentable_id);


CREATE TABLE IF NOT EXISTS data.inventory_yeast (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_yeast OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.inventory_yeast_mapping (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_yeast_id    uuid REFERENCES data.inventory_yeast (id),
    name                  text NOT NULL UNIQUE,
    created               timestamptz NOT NULL DEFAULT NOW(),
    updated               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_yeast_mapping OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS inventory_yeast_mapping_inventory_yeast_id_idx ON data.inventory_yeast_mapping (inventory_yeast_id);


CREATE TABLE IF NOT EXISTS data.inventory_adjunct (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_adjunct OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.inventory_adjunct_mapping (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_adjunct_id  uuid REFERENCES data.inventory_adjunct (id),
    name                  text NOT NULL UNIQUE,
    created               timestamptz NOT NULL DEFAULT NOW(),
    updated               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_adjunct_mapping OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS inventory_adjunct_mapping_inventory_adjunct_id_idx ON data.inventory_adjunct_mapping (inventory_adjunct_id);


CREATE TABLE IF NOT EXISTS data.event (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL,
    start_at    timestamptz NOT NULL,
    finish_at   timestamptz NOT NULL,
    location    text NOT NULL,
    data        jsonb,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW(),

    UNIQUE(name, location, start_at)
);

ALTER TABLE data.event OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.brewer (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.brewer OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.award (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id    uuid NOT NULL REFERENCES data.event (id),
    name        text NOT NULL,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW(),

    UNIQUE(event_id, name)
);

ALTER TABLE data.award OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.recipe (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id      uuid NOT NULL REFERENCES data.event (id),
    name          text NOT NULL,
    style         text,
    version       text,
    description   text,
    equipment     text,
    mash_data     jsonb,
    water_data    jsonb,
    batch_size    integer NOT NULL,
    og            numeric NOT NULL,
    fg            numeric NOT NULL,
    abv           numeric NOT NULL,
    state         data.enum_state NOT NULL DEFAULT 'inactive',
    created       timestamptz NOT NULL DEFAULT NOW(),
    updated       timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_event_id_idx ON data.recipe (event_id);


CREATE TABLE IF NOT EXISTS data.recipe_award (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    award_id              uuid NOT NULL REFERENCES data.award (id),
    created               timestamptz NOT NULL DEFAULT NOW(),

    UNIQUE(recipe_id, award_id)
);

ALTER TABLE data.recipe_award OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_award_recipe_id_idx ON data.recipe_award (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_award_award_id_idx ON data.recipe_award (award_id);


CREATE TABLE IF NOT EXISTS data.recipe_brewer (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    brewer_id             uuid NOT NULL REFERENCES data.brewer (id),
    created               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe_brewer OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_brewer_recipe_id_idx ON data.recipe_brewer (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_brewer_brewer_id_idx ON data.recipe_brewer (brewer_id);


CREATE TABLE IF NOT EXISTS data.recipe_fermentable (
    id                           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id                    uuid NOT NULL REFERENCES data.recipe (id),
    inventory_fermentable_id     uuid NOT NULL REFERENCES data.inventory_fermentable (id),
    amount                       numeric NOT NULL,
    amount_unit                  data.enum_amount_unit NOT NULL DEFAULT 'g',
    phase                        data.enum_phase NOT NULL DEFAULT 'mash',
    data                         jsonb,
    created                      timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe_fermentable OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_fermentable_recipe_id_idx ON data.recipe_fermentable (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_fermentable_inventory_fermentable_id_idx ON data.recipe_fermentable (inventory_fermentable_id);


CREATE TABLE IF NOT EXISTS data.recipe_hop (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    inventory_hop_id      uuid NOT NULL REFERENCES data.inventory_hop (id),
    amount                numeric NOT NULL,
    amount_unit           data.enum_amount_unit NOT NULL DEFAULT 'g',
    phase                 data.enum_phase NOT NULL DEFAULT 'boil',
    added_at              integer NOT NULL,
    added_at_unit         data.enum_added_at_unit NOT NULL DEFAULT 'minute',
    data                  jsonb,
    created               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe_hop OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_hop_recipe_id_idx ON data.recipe_hop (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_hop_inventory_hop_id_idx ON data.recipe_hop (inventory_hop_id);


CREATE TABLE IF NOT EXISTS data.recipe_yeast (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    inventory_yeast_id    uuid NOT NULL REFERENCES data.inventory_yeast (id),
    amount                numeric NOT NULL,
    amount_unit           data.enum_amount_unit NOT NULL DEFAULT 'pkg',
    fermentation_time     numeric,
    fermentation_unit     data.enum_fermentation_unit DEFAULT 'day',
    fermentation_order    integer DEFAULT 1,
    data                  jsonb,
    created               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe_yeast OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_yeast_recipe_id_idx ON data.recipe_yeast (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_yeast_inventory_yeast_id_idx ON data.recipe_yeast (inventory_yeast_id);


CREATE TABLE IF NOT EXISTS data.recipe_adjunct (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    inventory_adjunct_id  uuid NOT NULL REFERENCES data.inventory_adjunct (id),
    amount                numeric NOT NULL,
    amount_unit           data.enum_amount_unit NOT NULL DEFAULT 'g',
    phase                 data.enum_phase NOT NULL DEFAULT 'boil',
    added_at              integer,
    added_at_unit         data.enum_added_at_unit DEFAULT 'minute',
    data                  jsonb,
    created               timestamptz NOT NULL DEFAULT NOW(),

    CHECK (CASE WHEN phase = 'boil' THEN added_at IS NOT NULL AND added_at_unit IS NOT NULL ELSE TRUE END)
);

ALTER TABLE data.recipe_adjunct OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_adjunct_recipe_id_idx ON data.recipe_adjunct (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_adjunct_inventory_adjunct_id_idx ON data.recipe_adjunct (inventory_adjunct_id);


CREATE TABLE IF NOT EXISTS data.import_source (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name                  text NOT NULL UNIQUE,
    description           text,
    data                  jsonb,
    created               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.import_source OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.import (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    import_source_id      uuid NOT NULL REFERENCES data.import_source (id),
    identifier            text NOT NULL,
    data                  jsonb,
    created               timestamptz NOT NULL DEFAULT NOW(),

    UNIQUE(import_source_id, identifier)
);

ALTER TABLE data.import OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS import_import_source_id_idx ON data.import (import_source_id);
CREATE INDEX IF NOT EXISTS import_identifier_idx ON data.import (identifier);


CREATE MATERIALIZED VIEW IF NOT EXISTS data.inventory_usage AS
    SELECT
       'hop' AS inventory,
       inventory_hop_id AS id,
       i.name,
       COUNT(*)
    FROM
        data.recipe_hop
    INNER JOIN
        data.recipe r
    ON
        r.id = data.recipe_hop.recipe_id
        AND r.state = 'active'
    INNER JOIN
        data.inventory_hop i
    ON
        i.id = data.recipe_hop.inventory_hop_id
    GROUP BY
        inventory_hop_id,
        i.name

    UNION ALL

    SELECT
       'fermentable' AS inventory,
       inventory_fermentable_id AS id,
       i.name,
       COUNT(*)
    FROM
        data.recipe_fermentable
    INNER JOIN
        data.recipe r
    ON
        r.id = data.recipe_fermentable.recipe_id
        AND r.state = 'active'
    INNER JOIN
        data.inventory_fermentable i
    ON
        i.id = data.recipe_fermentable.inventory_fermentable_id
    GROUP BY
        inventory_fermentable_id,
        i.name

    UNION ALL

    SELECT
       'yeast' AS inventory,
       inventory_yeast_id AS id,
       i.name,
       COUNT(*)
    FROM
        data.recipe_yeast
    INNER JOIN
        data.recipe r
    ON
        r.id = data.recipe_yeast.recipe_id
        AND r.state = 'active'
    INNER JOIN
        data.inventory_yeast i
    ON
        i.id = data.recipe_yeast.inventory_yeast_id
    GROUP BY
        inventory_yeast_id,
        i.name

    UNION ALL

    SELECT
       'adjunct' AS inventory,
       inventory_adjunct_id AS id,
       i.name,
       COUNT(*)
    FROM
        data.recipe_adjunct
    INNER JOIN
        data.recipe r
    ON
        r.id = data.recipe_adjunct.recipe_id
        AND r.state = 'active'
    INNER JOIN
        data.inventory_adjunct i
    ON
        i.id = data.recipe_adjunct.inventory_adjunct_id
    GROUP BY
        inventory_adjunct_id,
        i.name
;

ALTER TABLE data.inventory_usage OWNER TO shbf_writer;
CREATE UNIQUE INDEX IF NOT EXISTS inventory_usage_id_idx ON data.inventory_usage (id);
CREATE INDEX IF NOT EXISTS inventory_usage_name_idx ON data.inventory_usage (name text_pattern_ops);
REFRESH MATERIALIZED VIEW data.inventory_usage;


CREATE MATERIALIZED VIEW IF NOT EXISTS data.search AS
    SELECT
        r.id,
        (
            to_tsvector(
                CONCAT(
                    r.name,
                    ' ',
                    r.version,
                    ' ',
                    r.description,
                    ' ',
                    r.equipment,
                    ' ',
                    r.batch_size::text,
                    ' ',
                    r.og::text,
                    ' ',
                    r.fg::text,
                    ' ',
                    r.abv::text
                )
            )
            ||
            COALESCE(jsonb_to_tsvector(r.mash_data, '["all"]'), '')
            ||
            COALESCE(jsonb_to_tsvector(r.water_data, '["all"]'), '')
            ||

            -- Get the proper names of all inventory into the input_search column
            to_tsvector(
                COALESCE(
                    (
                        SELECT
                            string_agg(
                                (
                                    SELECT
                                        name
                                    FROM
                                        data.inventory_hop
                                    WHERE
                                        data.inventory_hop.id = data.recipe_hop.inventory_hop_id
                                )::text,
                                ' '
                            )
                        FROM
                            data.recipe_hop
                        WHERE
                            data.recipe_hop.recipe_id = r.id
                    ),
                    ''
                )
            )
            ||
            to_tsvector(
                COALESCE(
                    (
                        SELECT
                            string_agg(
                                (
                                    SELECT
                                        name
                                    FROM
                                        data.inventory_fermentable
                                    WHERE
                                        data.inventory_fermentable.id = data.recipe_fermentable.inventory_fermentable_id
                                )::text,
                                ' '
                            )
                        FROM
                            data.recipe_fermentable
                        WHERE
                            data.recipe_fermentable.recipe_id = r.id
                    ),
                    ''
                )
            )
            ||
            to_tsvector(
                COALESCE(
                    (
                        SELECT
                            string_agg(
                                (
                                    SELECT
                                        name
                                    FROM
                                        data.inventory_yeast
                                    WHERE
                                        data.inventory_yeast.id = data.recipe_yeast.inventory_yeast_id
                                )::text,
                                ' '
                            )
                        FROM
                            data.recipe_yeast
                        WHERE
                            data.recipe_yeast.recipe_id = r.id
                    ),
                    ''
                )
            )
            ||
            to_tsvector(
                COALESCE(
                    (
                        SELECT
                            string_agg(
                                (
                                    SELECT
                                        name
                                    FROM
                                        data.inventory_adjunct
                                    WHERE
                                        data.inventory_adjunct.id = data.recipe_adjunct.inventory_adjunct_id
                                )::text,
                                ' '
                            )
                        FROM
                            data.recipe_adjunct
                        WHERE
                            data.recipe_adjunct.recipe_id = r.id
                    ),
                    ''
                )
            )
        ) AS input_search,
        -- This column will strictly be used for uuid search
        (
            SELECT
                to_tsvector(
                    (
                        SELECT
                            CONCAT(
                                hop.data,
                                ' ',
                                fermentable.data,
                                ' ',
                                yeast.data,
                                ' ',
                                adjunct.data
                            )
                        FROM (
                            SELECT string_agg(replace(inventory_hop_id::text, '-', ''), ' ') AS data FROM data.recipe_hop WHERE data.recipe_hop.recipe_id = r.id
                        ) hop

                        LEFT JOIN (
                            SELECT string_agg(replace(inventory_fermentable_id::text, '-', ''), ' ') AS data FROM data.recipe_fermentable WHERE data.recipe_fermentable.recipe_id = r.id
                        ) fermentable
                        ON
                            TRUE

                        LEFT JOIN (
                            SELECT string_agg(replace(inventory_yeast_id::text, '-', ''), ' ') AS data FROM data.recipe_yeast WHERE data.recipe_yeast.recipe_id = r.id
                        ) yeast
                        ON
                            TRUE

                        LEFT JOIN (
                            SELECT string_agg(replace(inventory_adjunct_id::text, '-', ''), ' ') AS data FROM data.recipe_adjunct WHERE data.recipe_adjunct.recipe_id = r.id
                        ) adjunct
                        ON
                            TRUE
                    )::text
                )
        ) AS inventory_search
    FROM
        data.recipe r
    WHERE
        r.state = 'active'
;

ALTER TABLE data.search OWNER TO shbf_writer;
CREATE UNIQUE INDEX IF NOT EXISTS search_id_idx ON data.search (id);
CREATE INDEX IF NOT EXISTS search_input_search_idx ON data.search USING GIN (input_search);
CREATE INDEX IF NOT EXISTS search_inventory_search_idx ON data.search USING GIN (inventory_search);
REFRESH MATERIALIZED VIEW data.search;

