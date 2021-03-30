--
-- Documentation:
--
-- * Types to create in the database
--

DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM pg_type INNER JOIN pg_namespace ON pg_type.typnamespace = pg_namespace.oid WHERE typname = 'enum_state' AND nspname = 'data'
    ) THEN
        CREATE TYPE data.enum_state AS ENUM (
            'active',
            'inactive'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_type INNER JOIN pg_namespace ON pg_type.typnamespace = pg_namespace.oid WHERE typname = 'enum_amount_unit' AND nspname = 'data'
    ) THEN
        CREATE TYPE data.enum_amount_unit AS ENUM (
            'g',
            'kg',
            'ml',
            'pkg'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_type INNER JOIN pg_namespace ON pg_type.typnamespace = pg_namespace.oid WHERE typname = 'enum_added_at_unit' AND nspname = 'data'
    ) THEN
        CREATE TYPE data.enum_added_at_unit AS ENUM (
            'minute',
            'day',
            'week',
            'hour'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_type INNER JOIN pg_namespace ON pg_type.typnamespace = pg_namespace.oid WHERE typname = 'enum_phase' AND nspname = 'data'
    ) THEN
        CREATE TYPE data.enum_phase AS ENUM (
            'mash',
            'overnight',
            'boil',
            'whirlpool',
            'hopstand',
            'flameout',
            'firstwort',
            'primary',
            'secondary',
            'dryhop'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_type INNER JOIN pg_namespace ON pg_type.typnamespace = pg_namespace.oid WHERE typname = 'enum_fermentation_unit' AND nspname = 'data'
    ) THEN
        CREATE TYPE data.enum_fermentation_unit AS ENUM (
            'day',
            'week'
        );
    END IF;

END
$$;

