#1/bin/sh
DATABASE=gmc

/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -f gmc.sql
RETVAL=$?

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
	/usr/bin/psql -v ON_ERROR_STOP=1 -d $DATABASE -c "VACUUM FULL ANALYZE"
	RETVAL=$?
fi
