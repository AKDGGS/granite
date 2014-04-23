#!/bin/sh
DATABASE=$1
if [ -z "$DATABASE" ]; then
	echo No database specified.
	exit
fi

/bin/gzip -d -c place.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY place (name,type,geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c mining_district.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY mining_district (name,geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c plss.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY plss (meridian,township,township_dir,range,range_dir,section,geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c utm.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY utm (zone,geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c quadrangle.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY quadrangle (name, alt_name, abbr, alt_abbr, scale, geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c energy_district.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY energy_district (name, geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"

/bin/gzip -d -c gmc_region.csv.gz | /usr/bin/psql -d $DATABASE -c \
	"\\COPY gmc_region (name, geog) FROM STDIN WITH (FORMAT CSV, DELIMITER '|');"
