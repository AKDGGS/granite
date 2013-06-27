#!/bin/sh
/usr/bin/psql -d gmc -c "\\copy place (name,type,geom) FROM 'places.csv' WITH DELIMITER '|';"
/usr/bin/psql -d gmc -c "\\copy mining_district (name,region,geom) FROM 'mining_districts.csv' WITH DELIMITER '|';"

