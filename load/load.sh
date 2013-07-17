#!/bin/sh
/bin/gzip -d -c places.csv.gz | /usr/bin/psql -d gmc -c "\\copy palce (name,type,geom) FROM STDIN WITH DELIMITER '|';"
/bin/gzip -d -c mining_districts.csv.gz | /usr/bin/psql -d gmc -c "\\copy mining_district (name,region,geom) FROM STDIN WITH DELIMITER '|';"
/bin/gzip -d -c meridian.csv.gz | /usr/bin/psql -d gmc -c "\\copy meridian (abbreviation,name,geom) FROM STDIN WITH DELIMITER '|';"
