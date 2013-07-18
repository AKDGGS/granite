#!/bin/sh
/bin/gzip -d -c places.csv.gz | /usr/bin/psql -d gmc -c "\\copy place (name,type,geom) FROM STDIN WITH DELIMITER '|';"
/bin/gzip -d -c mining_districts.csv.gz | /usr/bin/psql -d gmc -c "\\copy mining_district (name,region,geom) FROM STDIN WITH DELIMITER '|';"
/bin/gzip -d -c plss.csv.gz | /usr/bin/psql -d gmc -c "\\copy plss (meridian,township,township_dir,range,range_dir,section,geom) FROM STDIN WITH (DELIMITER ',', NULL '');"
