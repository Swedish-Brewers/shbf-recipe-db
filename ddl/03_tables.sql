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

DROP TYPE IF EXISTS data.state CASCADE;
CREATE TYPE data.state AS ENUM (
    'active',
    'inactive'
);

DROP TYPE IF EXISTS data.enum_amount_unit CASCADE;
CREATE TYPE data.enum_amount_unit AS ENUM (
    'g',
    'kg',
    'ml',
    'pkg'
);

DROP TYPE IF EXISTS data.enum_added_at_unit CASCADE;
CREATE TYPE data.enum_added_at_unit AS ENUM (
    'minute',
    'day',
    'week',
    'hour'
);

DROP TYPE IF EXISTS data.enum_phase CASCADE;
CREATE TYPE data.enum_phase AS ENUM (
    'mash',
    'boil',
    'whirlpool',
    'flameout',
    'secondary',
    'dryhop'
);


CREATE TABLE IF NOT EXISTS data.inventory_hop (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL UNIQUE,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_hop OWNER TO shbf_writer;


CREATE TABLE IF NOT EXISTS data.inventory_hop_mapping (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_hop_id      uuid NOT NULL REFERENCES data.inventory_hop (id),
    name                  text NOT NULL,
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
    inventory_fermentable_id     uuid NOT NULL REFERENCES data.inventory_fermentable (id),
    name                         text NOT NULL,
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
    inventory_yeast_id    uuid NOT NULL REFERENCES data.inventory_yeast (id),
    name                  text NOT NULL,
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
    inventory_adjunct_id  uuid NOT NULL REFERENCES data.inventory_adjunct (id),
    name                  text NOT NULL,
    created               timestamptz NOT NULL DEFAULT NOW(),
    updated               timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.inventory_adjunct_mapping OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS inventory_adjunct_mapping_inventory_adjunct_id_idx ON data.inventory_adjunct_mapping (inventory_adjunct_id);


CREATE TABLE IF NOT EXISTS data.brewer (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.brewer OWNER TO shbf_writer;

CREATE TABLE IF NOT EXISTS data.award (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text NOT NULL,
    created     timestamptz NOT NULL DEFAULT NOW(),
    updated     timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.award OWNER TO shbf_writer;

CREATE TABLE IF NOT EXISTS data.recipe (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name          text NOT NULL,
    version       text,
    description   text,
    equipment     text,
    mash_data     jsonb,
    water_data    jsonb,
    batch_size    integer,
    state         data.enum_state NOT NULL DEFAULT 'inactive',
    created       timestamptz NOT NULL DEFAULT NOW(),
    updated       timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe OWNER TO shbf_writer;

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
    unit                         data.enum_amount_unit NOT NULL DEFAULT 'g',
    phase                        data.enum_phase NOT NULL DEFAULT 'mash',
    created                      timestamptz NOT NULL DEFAULT NOW()
);

ALTER TABLE data.recipe_malt OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_fermentable_recipe_id_idx ON data.recipe_fermentable (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_fermentable_inventory_fermentable_id_idx ON data.recipe_fermentable (inventory_fermentable_id);


CREATE TABLE IF NOT EXISTS data.recipe_hop (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id             uuid NOT NULL REFERENCES data.recipe (id),
    inventory_hop_id      uuid NOT NULL REFERENCES data.inventory_hop (id),
    amount                numeric NOT NULL,
    unit                  data.enum_amount_unit NOT NULL DEFAULT 'g',
    phase                 data.enum_phase NOT NULL DEFAULT 'boil',
    added_at              integer NOT NULL,
    added_at_unit         data.enum_added_at_unit NOT NULL DEFAULT 'minute',
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
    unit                  data.enum_amount_unit NOT NULL DEFAULT 'pkg',
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
    created               timestamptz NOT NULL DEFAULT NOW(),

    CHECK (CASE WHEN phase = 'boil' THEN added_at IS NOT NULL AND added_at_unit IS NOT NULL ELSE TRUE END)
);

ALTER TABLE data.recipe_adjunct OWNER TO shbf_writer;
CREATE INDEX IF NOT EXISTS recipe_adjunct_recipe_id_idx ON data.recipe_adjunct (recipe_id);
CREATE INDEX IF NOT EXISTS recipe_adjunct_inventory_adjunct_id_idx ON data.recipe_adjunct (inventory_adjunct_id);


