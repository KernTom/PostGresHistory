-- FUNCTION: public.do_history()

-- DROP FUNCTION public.do_history();

CREATE FUNCTION public.do_history()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF 
AS $BODY$

DECLARE
    ri RECORD; 
    oldValue TEXT;
    newValue TEXT;
    isColumnSignificant BOOLEAN;
    isValueModified BOOLEAN;
    ModificationTime TIMESTAMP;
	application TEXT;
	userID TEXT;
BEGIN

	select empty2null(split_part(current_setting('application_name'),'|',1)), empty2null(split_part(current_setting('application_name'),'|',2)) INTO application, userID;	

     RAISE NOTICE 'Start %',TG_OP;

    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
        ModificationTime = clock_timestamp();

	RAISE NOTICE 'Get Columns from  %',quote_literal(TG_TABLE_SCHEMA)||'.'||quote_literal(TG_TABLE_NAME);
        
        FOR ri IN
            
            SELECT ordinal_position, column_name, data_type
            FROM information_schema.columns
            WHERE
                table_schema = TG_TABLE_SCHEMA
            AND table_name = TG_TABLE_NAME
            ORDER BY ordinal_position
        LOOP

	    IF ( ri.data_type NOT IN ('bytea') ) THEN
 
		    EXECUTE 'SELECT ($1)."' || ri.column_name || '"::text' INTO newValue USING NEW;
	     
		    IF (TG_OP = 'INSERT') THEN  
			oldValue := ''::varchar;
		    ELSE   
			EXECUTE 'SELECT ($1)."' || ri.column_name || '"::text' INTO oldValue USING OLD;
		    END IF;

		    RAISE NOTICE 'old Value / new Value %',oldValue||' / '||newValue;
		    
		    isColumnSignificant := (position( '_x_' in ri.column_name ) < 1) AND (ri.column_name <> 'pkey_') AND (ri.column_name <> 'record_modified_');
		    IF isColumnSignificant THEN
			isValueModified := oldValue <> newValue;
			IF isValueModified THEN

			    RAISE NOTICE 'doing Insert for column %',ri.column_name;
						
			    INSERT INTO public.history ( operation,table_oid, table_name, column_oid, column_name, ordinal_position_of_column, old_value, new_value, application_user )
			    VALUES ( TG_OP, TG_RELID, TG_TABLE_NAME, NEW.oid, ri.column_name::VARCHAR, ri.ordinal_position, oldValue::VARCHAR, newValue::VARCHAR, userID::bigint );
			END IF;
		    END IF;

	    END IF;
        END LOOP;
   
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
       
        INSERT INTO public.history ( operation,table_oid, table_name, column_oid, column_name, ordinal_position_of_column, old_value, new_value, application_user )
        VALUES ( TG_OP, TG_RELID, TG_TABLE_NAME, OLD.oid, ''::VARCHAR, 0, ''::VARCHAR, ''::VARCHAR, userID::bigint );
        RETURN OLD;
       
    END IF;
    
    RAISE EXCEPTION 'Unexpectedly reached the bottom of this function without calling RETURN.';
END;

$BODY$;

