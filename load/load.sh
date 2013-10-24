#!/bin/sh
DATABASE=gmc
/bin/gzip -d -c places.csv.gz | /usr/bin/psql -d $DATABASE -c "\\copy place (name,type,geom) FROM STDIN WITH (FORMAT CSV);"
/bin/gzip -d -c mining_districts.csv.gz | /usr/bin/psql -d $DATABASE -c "\\copy mining_district (name,region,geom) FROM STDIN WITH (FORMAT CSV);"
/bin/gzip -d -c plss.csv.gz | /usr/bin/psql -d $DATABASE -c "\\copy plss (meridian,township,township_dir,range,range_dir,section,geom) FROM STDIN WITH (DELIMITER '|', NULL '');"
/bin/gzip -d -c utm.csv.gz | /usr/bin/psql -d $DATABASE -c "\\copy utm (zone,geom) FROM STDIN WITH (FORMAT CSV);"
/bin/gzip -d -c quadrangle.csv.gz | /usr/bin/psql -d $DATABASE -c "\\copy quadrangle (name, alt_name, abbr, alt_abbr, scale, geom) FROM STDIN WITH (FORMAT CSV);"
