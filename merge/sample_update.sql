DROP TABLE IF EXISTS process, sample, sample_file, inventory_sample,
	sample_inventory, sample_process_inventory, visitor, sample_deliverable,
	sample_person, sample_note, sample_publication, sample_file;


CREATE TABLE sample (
	sample_id SERIAL PRIMARY KEY,
	sample_agreement_id INT NOT NULL,
	person_id INT REFERENCES person(person_id) NOT NULL,
	organization_id INT REFERENCES organization(organization_id) NULL,
	description TEXT NULL,
	publish DATE NULL,
	modified_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	modified_user VARCHAR(64) NOT NULL
);

DROP TRIGGER IF EXISTS sample_modified_date_tr ON sample;
CREATE TRIGGER sample_modified_date_tr BEFORE INSERT OR UPDATE ON sample
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();
DROP TRIGGER IF EXISTS sample_modified_user_tr ON sample;
CREATE TRIGGER sample_modified_user_tr BEFORE INSERT OR UPDATE ON sample
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();


CREATE TABLE sample_inventory (
	sample_inventory_id SERIAL PRIMARY KEY,
	sample_id INT REFERENCES sample(sample_id) NOT NULL,
	inventory_id INT REFERENCES inventory(inventory_id) NULL,
	interval NUMRANGE NULL,
	interval_unit_id INT REFERENCES unit(unit_id) NULL,
	description TEXT NOT NULL,
	modified_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	modified_user VARCHAR(64) NOT NULL
);

DROP TRIGGER IF EXISTS sample_inventory_modified_date_tr ON sample_inventory;
CREATE TRIGGER sample_inventory_modified_date_tr BEFORE INSERT OR UPDATE ON sample_inventory
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();
DROP TRIGGER IF EXISTS sample_inventory_modified_user_tr ON sample_inventory;
CREATE TRIGGER sample_inventory_modified_user_tr BEFORE INSERT OR UPDATE ON sample_inventory
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();


CREATE TABLE sample_deliverable (
	sample_deliverable_id SERIAL PRIMARY KEY,
	sample_inventory_id INT REFERENCES sample_inventory(sample_inventory_id) NOT NULL,
	due DATE NOT NULL,
	completed DATE NULL,
	description TEXT NOT NULL,
	modified_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	modified_user VARCHAR(64) NOT NULL
);

DROP TRIGGER IF EXISTS sample_deliverable_modified_date_tr ON sample_deliverable;
CREATE TRIGGER sample_deliverable_modified_date_tr BEFORE INSERT OR UPDATE ON sample_deliverable
FOR EACH ROW EXECUTE PROCEDURE modified_date_fn();
DROP TRIGGER IF EXISTS sample_deliverable_modified_user_tr ON sample_deliverable;
CREATE TRIGGER sample_deliverable_modified_user_tr BEFORE INSERT OR UPDATE ON sample_deliverable
FOR EACH ROW EXECUTE PROCEDURE modified_user_fn();


CREATE TABLE sample_note (
	sample_id INT REFERENCES sample(sample_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(sample_id, note_id)
);


CREATE TABLE sample_file (
	sample_id INT REFERENCES sample(sample_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(sample_id, file_id)
);
