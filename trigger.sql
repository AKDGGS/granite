SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;

-- Create function to populate path cache
CREATE OR REPLACE FUNCTION container_path_cache_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.parent_container_ID IS NOT NULL THEN
		NEW.path_cache := (
			SELECT path FROM container_path
			WHERE container_id = NEW.parent_container_id
		);
	END IF;
	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

-- Set trigger to populate path cache
CREATE TRIGGER container_path_cache_tr
BEFORE INSERT OR UPDATE ON container
FOR EACH ROW EXECUTE PROCEDURE container_path_cache_fn();
