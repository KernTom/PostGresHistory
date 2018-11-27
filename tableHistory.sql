CREATE TABLE public.history
(
    oid bigserial,
    table_name character varying(120) COLLATE pg_catalog."default" NOT NULL,
    column_name character varying(120) COLLATE pg_catalog."default" NOT NULL,
    timestamp timestamp with time zone NOT NULL DEFAULT clock_timestamp(),
    db_user_name character varying(120) COLLATE pg_catalog."default" NOT NULL DEFAULT "current_user"(),
    app_name character varying(120) COLLATE pg_catalog."default" NOT NULL DEFAULT current_setting('application_name'::text),
    old_value text COLLATE pg_catalog."default" NOT NULL DEFAULT ''::character varying,
    new_value text COLLATE pg_catalog."default" NOT NULL DEFAULT ''::character varying,
    column_oid bigint NOT NULL,
    operation character varying(120) COLLATE pg_catalog."default" NOT NULL,
    table_oid oid NOT NULL,
    ordinal_position_of_column integer NOT NULL,
    transaction_began timestamp with time zone NOT NULL DEFAULT transaction_timestamp(),
    application_user bigint
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
