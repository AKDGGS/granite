-- Make well operator:
-- Takes three parameters, the well_id, the operator name (an organization)
-- and a boolean to indicate if the operator is current(true) or
-- a previous operator(false)
DROP FUNCTION IF EXISTS public.mk_welloperator(INT, VARCHAR, BOOLEAN);
CREATE FUNCTION public.mk_welloperator(
	wid INT, operator VARCHAR, current BOOLEAN
) RETURNS int AS $$
	DECLARE
		oid INT;
	BEGIN
		SELECT organization_id INTO oid 
		FROM organization 
		WHERE LOWER(TRIM(name)) = LOWER(TRIM(operator))
		LIMIT 1;

		IF NOT FOUND THEN
			INSERT INTO organization (
				name, organization_type_id
			) VALUES (
				LOWER(TRIM(operator)),
				(
					SELECT organization_type_id
					FROM organization_type
					WHERE name = 'energy'
				)
			) RETURNING organization_id INTO oid;
		END IF;

		PERFORM well_id FROM well_operator
		WHERE well_id = wid AND organization_id = oid;

		IF NOT FOUND THEN
			INSERT INTO well_operator (
				well_id, organization_id, is_current
			) VALUES (
				wid, oid, current
			);
		END IF;

		RETURN oid;
	END;
$$ LANGUAGE plpgsql;


-- Make well point:
-- Takes two parameters, well_id, point (as a geography)
DROP FUNCTION IF EXISTS public.mk_wellpoint(INT, GEOGRAPHY);
CREATE FUNCTION public.mk_wellpoint(
	wid INT, pnt GEOGRAPHY
) RETURNS int AS $$
	DECLARE
		pid INT;
	BEGIN
		SELECT point_id INTO pid
		FROM point
		WHERE geog = pnt
		LIMIT 1;

		IF NOT FOUND THEN
			INSERT INTO point (description, geog)
			VALUES ('well surface point', pnt)
			RETURNING point_id INTO pid;
		END IF;

		PERFORM well_id FROM well_point
		WHERE well_id = wid AND point_id = pid;

		IF NOT FOUND THEN
			INSERT INTO well_point (
				well_id, point_id
			) VALUES (
				wid, pid
			);
		END IF;

		RETURN pid;
	END
$$ LANGUAGE plpgsql;


-- Makes a container path, that is, ANC/01/02 creates three containers,
-- with three paths. The barcode is attached to the final of the
-- created path elements.
-- Takes three parameters: An array of container names, an array
-- of container types (which it creates if they aren't found
-- and a barcode.
DROP FUNCTION IF EXISTS public.mk_container_path(VARCHAR[], VARCHAR[], VARCHAR);
CREATE FUNCTION public.mk_container_path(
	paths VARCHAR[], types VARCHAR[], bcode VARCHAR
) RETURNS int AS $$
	DECLARE
		pid INT := NULL;
		cid INT;
		plen INT;
		tid INT;
	BEGIN
		plen := ARRAY_LENGTH(paths, 1);
		
		-- Die if the array lengths don't match
		IF plen <> ARRAY_LENGTH(types, 1) THEN
			RAISE EXCEPTION 'Path and type lengths are not the same.';
		END IF;
		
		-- Loop over container path
		FOR i IN 1 .. plen LOOP
			cid := NULL;

			-- Does this container exist?
			IF pid IS NULL THEN
				SELECT container_id INTO cid
				FROM container
				WHERE LOWER(name) = LOWER(paths[i])
					AND parent_container_id IS NULL
				LIMIT 1;
			ELSE
				SELECT container_id INTO cid
				FROM container
				WHERE LOWER(name) = LOWER(paths[i])
					AND parent_container_id = pid
				LIMIT 1;
			END IF;

			IF cid IS NULL THEN
				-- Find the type
				SELECT container_type_id INTO tid
				FROM container_type
				WHERE LOWER(name) = LOWER(types[i])
				LIMIT 1;

				-- or insert as needed
				IF NOT FOUND THEN
					INSERT INTO container_type (name) VALUES (types[i])
					RETURNING container_type_id INTO tid;
				END IF;
		
				-- Insert container
				INSERT INTO container (
					name, parent_container_id, container_type_id,
					barcode
				) VALUES (
					paths[i], pid, tid,
					CASE WHEN i <> plen THEN NULL ELSE bcode END
				) RETURNING container_id INTO cid;
			END IF;

			-- Set parent_id to current container_id for next iteration
			pid := cid;
		END LOOP;

		RETURN pid;
	END
$$ LANGUAGE plpgsql;
