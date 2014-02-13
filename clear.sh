#1/bin/sh
DATABASE=gmc
/usr/bin/psql -d $DATABASE -f gmc.sql
/usr/bin/psql -d $DATABASE -f trigger.sql
/usr/bin/psql -d $DATABASE -f index.sql
/usr/bin/psql -d $DATABASE -f view.sql
