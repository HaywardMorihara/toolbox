# SQL Cheatsheet

## Connection

### Local Setup
```bash
createdb my_database
psql my_database
```

### Docker (Postgres)
```bash
docker exec -it $(docker ps -qf name=reference_todos-pg_server-1) psql -U compass reference_todosgo
```

### Change Database
```
\c <database_name>
```

## Help & General Commands

```
\?          List all commands
\q          Exit psql
```

## Databases & Schemas

```
\l          See all databases (default is postgres)
\dn         See schemas
\dt         List tables
\dt *.*     List all tables in all schemas
\dt <SCHEMA_NAME>.*  List tables in specific schema
```

## Roles & Users

```
\du         List all roles
SELECT * FROM pg_roles;  Query all roles
```

## Table Information

```
\d <table_name>                  Describe table / see columns
\d <schema>.<table_name>         Describe table in specific schema
```

## Performance

```
\timing on  Enable query execution timing
```

## Export Data to CSV

```sql
\copy (
  SELECT
    email,
    array_agg(roles.name) as roles
  FROM
    people_model.users u,
    unnest(u.roles) as roleId,
    people_model.roles
  WHERE
    u.active AND
    roleId = roles.role_id AND
    roles.name IN (
      'Staff__DRS_Lead',
      'Staff__DRS_Non_Lead'
    )
  GROUP BY u.email
) TO 'drs_lead_users.csv' CSV HEADER
```

## Local Databases

```
multi_tenant_poc
```

**Tip:** List all local databases with `\l` in psql or `psql -l` from the command line.
```bash
psql -l
```
