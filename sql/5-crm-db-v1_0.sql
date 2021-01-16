CREATE SCHEMA if not exists v1_0;

grant usage on schema v1_0 to anonymous;
grant usage on schema v1_0 to crm_user;

-- login
create or replace function
v1_0.login(email text, pass text) returns basic_auth.jwt_token as $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check email and password
  select basic_auth.user_role(email, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 12*60*60 as exp
    ) r
    into result;
  return result;
end;
$$ language plpgsql security definer;


grant execute on function v1_0.login(text,text) to anonymous;

-- clients
create view v1_0.clients as select * from crm.clients;
ALTER VIEW v1_0.clients OWNER TO crm_user;

drop trigger if exists clients_mutation on v1_0.clients;
create trigger clients_mutation
  instead of insert or update or delete on crm.clients
  for each row
  execute procedure crm.clients_mutation_trigger();

create or replace function crm.clients_mutation_trigger() returns trigger as $$
declare
begin
    if (tg_op - DELETE ) then
        --delete client
        return new;
    elseif (tg_op - UPDATE ) then
        --update client
        return new;
    elseif (tg_op - INSERT ) then
        --create client
        return new;
    end if;
end;
$$ security definer language plpgsql;
