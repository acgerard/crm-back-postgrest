
create schema if not exists crm;

grant usage on schema crm to anonymous;
grant usage on schema crm to crm_user;

-- login
create or replace function
crm.login(email text, pass text) returns basic_auth.jwt_token as $$
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


grant execute on function crm.login(text,text) to anonymous;


create table if not exists
crm.clients (
  id    BIGSERIAL primary key not null,
  data     JSONB not null
);

grant all on table crm.clients to crm_user;
grant all on SEQUENCE crm.clients_id_seq TO crm_user;

create table if not exists
crm.products (
    code text primary key  check (length(code) < 100),
    name text,
    data JSONB not null
);

grant all on table crm.products to crm_user;

create table if not exists crm.spanco(
    product_code text not null,
    promo text not null,
    clients jsonb not null,
    CONSTRAINT product_code_fkey FOREIGN KEY (product_code) REFERENCES products(code),
    CONSTRAINT spanco_key PRIMARY KEY (product_code, promo)
);
grant all on table crm.spanco to crm_user;

