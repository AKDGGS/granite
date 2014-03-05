SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;

-- Create function to populate path cache
CREATE OR REPLACE FUNCTION container_path_cache_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.parent_container_id IS NOT NULL THEN
		NEW.path_cache := (
			SELECT path FROM container_path
			WHERE container_id = NEW.parent_container_id
		) || '/' || NEW.name;
	END IF;
	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

-- Set trigger to populate path cache
DROP TRIGGER IF EXISTS container_path_cache_tr ON container;
CREATE TRIGGER container_path_cache_tr
BEFORE INSERT OR UPDATE ON container
FOR EACH ROW EXECUTE PROCEDURE container_path_cache_fn();


-- Create function for container change logging
CREATE OR REPLACE FUNCTION inventory_container_log_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO inventory_container_log (
			inventory_id, container_id
		) VALUES (
			NEW.inventory_id, NEW.container_id
		);
	ELSIF TG_OP = 'UPDATE' THEN
		IF COALESCE(OLD.container_id, 0) <> COALESCE(NEW.container_id, 0) THEN
			INSERT INTO inventory_container_log (
				inventory_id, container_id
			) VALUES (
				NEW.inventory_id, NEW.container_id
			);
		END IF;
	END IF;

	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

-- Set trigger for container change log
DROP TRIGGER IF EXISTS inventory_container_log_tr ON inventory;
CREATE TRIGGER inventory_container_log_tr
AFTER INSERT OR UPDATE ON inventory
FOR EACH ROW EXECUTE PROCEDURE inventory_container_log_fn();


COMMIT;
