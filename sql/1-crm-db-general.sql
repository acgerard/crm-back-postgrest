CREATE EXTENSION IF NOT EXISTS pgcrypto;
ALTER DATABASE crm SET "app.jwt_secret" TO 'yuHBBCHMhWLAJvmrlWXtQ9qF54sEf2vS';

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

create role anonymous noinherit nologin;
create role crm_user noinherit nologin;
create role crm_back noinherit login PASSWORD 'password';

grant anonymous to crm_back;
grant crm_user to crm_back;
grant anonymous to crm_user;