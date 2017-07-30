DROP TABLE IF EXISTS process, sample, sample_file, inventory_sample,
	sample_inventory, sample_process_inventory, visitor,
	sample_person, sample_note, sample_publication, sample_file;

CREATE TABLE sample (
	sample_id SERIAL PRIMARY KEY,
	sample_agreement_id INT NOT NULL,
	created DATE NOT NULL DEFAULT NOW(),
	analysis DATE NOT NULL,
	due DATE NOT NULL,
	completed DATE NULL,
	publish DATE NULL,
	description TEXT NULL,
	deliverable TEXT NULL,
	stash JSONB
);

CREATE TABLE sample_inventory (
	sample_inventory_id SERIAL PRIMARY KEY,
	sample_id INT REFERENCES sample(sample_id) NOT NULL,
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	interval NUMRANGE NULL,
	interval_unit_id INT REFERENCES unit(unit_id) NULL,
	mass_gr NUMERIC(10,4) NULL,
	description TEXT NULL,
	stash JSONB
);

CREATE TABLE sample_person (
	sample_id INT REFERENCES sample(sample_id) NOT NULL,
	person_id INT REFERENCES person(person_id) NOT NULL,
	PRIMARY KEY(sample_id, person_id)
);

CREATE TABLE sample_note (
	sample_id INT REFERENCES sample(sample_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(sample_id, note_id)
);

CREATE TABLE sample_publication (
	sample_id INT REFERENCES sample(sample_id),
	publication_id INT REFERENCES publication(publication_id),
	PRIMARY KEY(sample_id, publication_id)
);

CREATE TABLE sample_file (
	sample_id INT REFERENCES sample(sample_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(sample_id, file_id)
);
