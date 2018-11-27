# PostGresHistory
Does History of INSERT, UPDATE and DELETE statements on a specific table

# Introduction
History is often needed in database driven projects and discussed more often. I used some specials i have to mention. 

- history is done by simply adding a trigger to the table to monitor
- the table to monitor MUST have a column "oid"
- here is a simple helper function "empty2null". It only converts really empty string to null to reduce typing CASTS or CASE CLAUSES
- i've added the create script for the history table for easy startup
- i dont use the "auto" feature oid in tables, because on large databases it could run out of range. i'm add this column always by my self of type bigserial
- if you want to track your application userid you can set the global value **application_name** like 'yourMethod|1234'. first is used as method, url, or any other identifier you like, second is your userId. I do that to track wich function,class or RESTAPI Uri was called to change the tupel and i use the application userID to recognize the specific user

# Usage
- create a history table, feel free to use script added
- perhaps add indexes to history table for performance issues 
- create both function **empty2null** and **do_history** to your public schema
- add a trigger to your table to monitor and use the trigger function **do_history**
- in your query framework simply set your application_name by 
<code sql>
  set application_name to 'yourMethod|1234';
 </code>
 

# That's all

Feel free to comment. I like discussions and improvements
