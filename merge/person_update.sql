ALTER TABLE person ADD COLUMN cell VARCHAR(25) NULL;
ALTER TABLE person ADD COLUMN fax VARCHAR(25) NULL;
ALTER TABLE person ADD COLUMN remark TEXT NULL;

CREATE TABLE address (
	address_id SERIAL PRIMARY KEY,
	address VARCHAR(255) NOT NULL,
	city VARCHAR(100) NOT NULL,
	state VARCHAR(2) NOT NULL,
	zip VARCHAR(15) NOT NULL,
	country VARCHAR(100) NOT NULL
);

CREATE TABLE address_type (
	address_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);
INSERT INTO address_type (name) VALUES ('Mailing Address');
INSERT INTO address_type (name) VALUES ('Physical Address');

CREATE TABLE person_address (
	person_id INT NOT NULL REFERENCES person(person_id),
	address_id INT NOT NULL REFERENCES address(address_id),
	address_type_id INT NOT NULL REFERENCES address_type(address_type_id),
	PRIMARY KEY(person_id, address_id, address_type_id)
);
