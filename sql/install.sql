-- Event
\i ./functions/event_create.sql

-- Recipes
\i ./functions/recipe_create.sql
\i ./functions/recipe_update.sql
\i ./functions/recipe_add_hop.sql
\i ./functions/recipe_add_fermentable.sql
\i ./functions/recipe_add_yeast.sql
\i ./functions/recipe_add_adjunct.sql
\i ./functions/recipe_get_json.sql

-- Inventory
\i ./functions/inventory_hop_create.sql
\i ./functions/inventory_hop_mapping_create.sql
\i ./functions/inventory_hop_mapping_update.sql
\i ./functions/inventory_hop_get_from_mapping.sql
\i ./functions/inventory_fermentable_create.sql
\i ./functions/inventory_fermentable_mapping_create.sql
\i ./functions/inventory_fermentable_mapping_update.sql
\i ./functions/inventory_fermentable_get_from_mapping.sql
\i ./functions/inventory_yeast_create.sql
\i ./functions/inventory_yeast_mapping_create.sql
\i ./functions/inventory_yeast_mapping_update.sql
\i ./functions/inventory_yeast_get_from_mapping.sql
\i ./functions/inventory_adjunct_create.sql
\i ./functions/inventory_adjunct_mapping_create.sql
\i ./functions/inventory_adjunct_mapping_update.sql
\i ./functions/inventory_adjunct_get_from_mapping.sql

-- Search
\i ./functions/search.sql

-- Development
\i ./functions/clear_db.sql
