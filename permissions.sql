-- This file contains a set of sample permissions. They assume a role
-- called GMC exists that governs general read/write persmisions for users
-- in that role. It also assumes a use called "gmc_app" has the only
-- valid permissions to the 'token' table.
REVOKE ALL ON SCHEMA public FROM public;

GRANT SELECT, INSERT, DELETE, UPDATE ON ALL TABLES IN SCHEMA public TO GROUP gmc;
GRANT USAGE ON SCHEMA public TO GROUP gmc;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO GROUP gmc;

-- Keep the token table from everyone except the webapp
REVOKE ALL ON TABLE token FROM gmc;
GRANT SELECT ON TABLE token TO gmc_app;
GRANT SELECT, USAGE ON SEQUENCE token_token_id_seq TO gmc_app;
