-- Should the database ever be re-created, this will 
-- set the appropriate permissions
REVOKE ALL ON schema public FROM public;
GRANT SELECT, INSERT, DELETE, UPDATE ON ALL TABLES IN SCHEMA public TO GROUP gmc;
GRANT USAGE ON SCHEMA public TO GROUP gmc;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO GROUP gmc;
