
create schema if not exists crm;

create table if not exists
crm.clients (
  id    BIGSERIAL not null,
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
    CONSTRAINT product_code_fkey FOREIGN KEY (product_code) REFERENCES products(code)
);
grant all on table crm.spanco to crm_user;

