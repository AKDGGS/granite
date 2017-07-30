CREATE TABLE outcrop_url (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(outcrop_id, url_id)
);

ALTER TABLE well ADD COLUMN alt_api_number VARCHAR(14) NULL;
