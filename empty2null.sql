CREATE OR REPLACE FUNCTION public.empty2null(
	character varying)
    RETURNS character varying
    LANGUAGE 'sql'
    COST 100
    VOLATILE 
AS $BODY$

   SELECT CASE WHEN $1 = '' THEN NULL ELSE $1 END;

$BODY$;
