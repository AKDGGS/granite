SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;


-- Create function to populate path cache
CREATE OR REPLACE FUNCTION container_path_cache_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.parent_container_id IS NOT NULL THEN
		NEW.path_cache := (
			WITH RECURSIVE t AS ((
				SELECT 0 AS depth, c.name, c.container_id,
					c.parent_container_id
				FROM container AS c
				WHERE container_id = NEW.parent_container_id
			) UNION ALL (
				SELECT t.depth + 1 AS depth, c.name, t.container_id,
					c.parent_container_id
				FROM container AS c
				JOIN t ON c.container_id = t.parent_container_id
				WHERE depth <= 20
			))
			SELECT STRING_AGG(name, '/' ORDER BY depth DESC) AS path
			FROM t
			GROUP BY container_id
		) || '/' || NEW.name;
	ELSE
		NEW.path_cache := NEW.name;
	END IF;
	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

-- Set trigger to populate path cache
DROP TRIGGER IF EXISTS container_path_cache_tr ON container;
CREATE TRIGGER container_path_cache_tr
BEFORE INSERT OR UPDATE ON container
FOR EACH ROW EXECUTE PROCEDURE container_path_cache_fn();


-- Create function/trigger for inventory change logging
CREATE OR REPLACE FUNCTION inventory_container_log_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NEW.container_id IS NOT NULL THEN
			INSERT INTO inventory_container_log (
				inventory_id, destination
			) VALUES (
				NEW.inventory_id, (
					SELECT path_cache FROM container
					WHERE container_id = NEW.container_id
				)
			);
		END IF;
	ELSIF TG_OP = 'UPDATE' THEN
		IF COALESCE(OLD.container_id, 0) <> COALESCE(NEW.container_id, 0) THEN
			INSERT INTO inventory_container_log (
				inventory_id, destination
			) VALUES (
				NEW.inventory_id, (
					SELECT path_cache FROM container
					WHERE container_id = NEW.container_id
				)
			);
		END IF;
  END IF;

  RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS inventory_container_log_tr ON inventory;
CREATE TRIGGER inventory_container_log_tr
AFTER INSERT OR UPDATE ON inventory
FOR EACH ROW EXECUTE PROCEDURE inventory_container_log_fn();


-- Create function/trigger for container change logging
CREATE OR REPLACE FUNCTION container_log_fn()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NEW.parent_container_id IS NOT NULL THEN
			INSERT INTO container_log (
				container_id, destination
			) VALUES (
				NEW.container_id, (
					SELECT path_cache FROM container
					WHERE container_id = NEW.parent_container_id
				)
			);
		END IF;
	ELSIF TG_OP = 'UPDATE' THEN
		IF COALESCE(OLD.parent_container_id, 0) <> COALESCE(NEW.parent_container_id, 0) THEN
			INSERT INTO container_log (
				container_id, destination
			) VALUES (
				NEW.container_id, (
					SELECT path_cache FROM container
					WHERE container_id = NEW.parent_container_id
				)
			);
		END IF;
  END IF;

  RETURN NEW;
END; $$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS container_log_tr ON container;
CREATE TRIGGER container_log_tr
AFTER INSERT OR UPDATE ON container
FOR EACH ROW EXECUTE PROCEDURE container_log_fn();


-- Create function for modified date touching on update/insert
CREATE OR REPLACE FUNCTION modified_date_fn()
RETURNS TRIGGER AS $$
BEGIN
	NEW.modified_date = NOW();
	RETURN NEW;
END; $$ language 'plpgsql';

-- Create function for modified user touching on update/insert
CREATE OR REPLACE FUNCTION modified_user_fn()
RETURNS TRIGGER AS $$
BEGIN
	NEW.modified_user = session_user;
	RETURN NEW;
END; $$ language 'plpgsql';

-- Set trigger for inventory modified date
DROP TRIGGER IF EXISTS inventory_modified_date_tr ON inventory;
CREATE TRIGGER inventory_modified_date_tr BEFORE INSERT OR UPDATE ON inventory
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();

-- Set trigger for inventory modified user
DROP TRIGGER IF EXISTS inventory_modified_user_tr ON inventory;
CREATE TRIGGER inventory_modified_user_tr BEFORE INSERT OR UPDATE ON inventory
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();

-- Set trigger for outcrop modified date
DROP TRIGGER IF EXISTS outcrop_modified_date_tr ON outcrop;
CREATE TRIGGER outcrop_modified_date_tr BEFORE INSERT OR UPDATE ON outcrop
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();

-- Set trigger for outcrop modified user
DROP TRIGGER IF EXISTS outcrop_modified_user_tr ON outcrop;
CREATE TRIGGER outcrop_modified_user_tr BEFORE INSERT OR UPDATE ON outcrop
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();

-- Set trigger for borehole modified date
DROP TRIGGER IF EXISTS borehole_modified_date_tr ON borehole;
CREATE TRIGGER borehole_modified_date_tr BEFORE INSERT OR UPDATE ON borehole
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();

-- Set trigger for borehole modified user
DROP TRIGGER IF EXISTS borehole_modified_user_tr ON borehole;
CREATE TRIGGER borehole_modified_user_tr BEFORE INSERT OR UPDATE ON borehole
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();

-- Set trigger for well modified date
DROP TRIGGER IF EXISTS well_modified_date_tr ON well;
CREATE TRIGGER well_modified_date_tr BEFORE INSERT OR UPDATE ON well
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();

-- Set trigger for well modified user
DROP TRIGGER IF EXISTS well_modified_user_tr ON well;
CREATE TRIGGER well_modified_user_tr BEFORE INSERT OR UPDATE ON well
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();


COMMIT;
