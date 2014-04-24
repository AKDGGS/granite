#!/bin/sh
DATABASE=$1
if [ -z "$DATABASE" ]; then
	echo No database specified.
	exit
fi

/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f drop.sql
RETVAL=$?

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f gmc.sql
	RETVAL=$?
fi

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f trigger.sql
	RETVAL=$?
fi

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f index.sql
	RETVAL=$?
fi

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f view.sql
	RETVAL=$?
fi

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f permissions.sql
	RETVAL=$?
fi

if [ $RETVAL == 0 ]; then
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -c "VACUUM FULL ANALYZE"
	RETVAL=$?
fi
