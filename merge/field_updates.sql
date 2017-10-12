CREATE TABLE outcrop_url (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(outcrop_id, url_id)
);

CREATE TABLE inventory_quadrangle (
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	quadrangle_id INT REFERENCES quadrangle(quadrangle_id) NOT NULL,
	PRIMARY KEY(inventory_id, quadrangle_id)
);


ALTER TABLE well ADD COLUMN alt_api_number VARCHAR(14) NULL;
