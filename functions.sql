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
