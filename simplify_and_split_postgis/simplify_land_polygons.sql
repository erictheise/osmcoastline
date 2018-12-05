-- ======================================================================
--
-- Simplify land polygons
--
-- Parameters:
--   tolerance: Tolerance for simplification algorithm, higher values
--              mean more simplification
--   min_area:  Polygons with smaller area than this will not appear
--              in the output
--
-- Call like this:
-- psql -d $DB -v tolerance=$TOLERANCE -v min_area=$MIN_AREA -f simplify_land_polygons.sql
--
-- for instance:
-- psql -d coastlines -v tolerance=300 -v min_area=300000 -f simplify_land_polygons.sql
--
-- ======================================================================

INSERT INTO simplified_land_polygons (fid, tolerance, min_area, geom)
    SELECT ogc_fid, :tolerance, :min_area, ST_SimplifyPreserveTopology(wkb_geometry, :tolerance)
        FROM land_polygons
        WHERE ST_Area(wkb_geometry) > :min_area;

CREATE INDEX
    ON simplified_land_polygons
    USING GIST (geom)
    WHERE tolerance=:tolerance AND min_area=:min_area;

