#!/bin/bash
echo "Granting permission of all databases in Aurora DB to read_user !!"
# host to connect with
read -p "Enter your host/endpoint: " host
read -p "Enter admin_user name: " admin_user
read -p "Enter user password: " PASSWORD
export PGPASSWORD=${PASSWORD}
echo "To grant read permissions on all databases"
echo
read -p "Enter the read_user: " read_user

# list of databases
databases=$(psql -l -t -h $host -U $admin_user | cut -d'|' -f1 | s
ed -e 's/ //g' -e '/^$/d')

for i in $databases;
  do
    if [ "$i" != "postgres" ] && [ "$i" != "template0" ] && [ "$i" != "template1" ] && [ "$i" != "template_postgis" ] && [ "$i" != "rdsadmin" ];
    then
      echo $i
      psql -h $host -U $admin_user -d ${i} -c "GRANT CONNECT ON DATABASE ${i} TO ${read_user}"
      echo $?
      psql -h $host -U $admin_user -d ${i} -c "GRANT USAGE ON SCHEMA public TO ${read_user}"
      echo $?
      psql -h $host -U $admin_user -d ${i} -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${read_user}"
      echo $?
      psql -h $host -U $admin_user -d ${i} -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO ${read_user}"
      echo $?
      psql -h $host -U $admin_user -d ${i} -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${read_user}"
      echo $?
    fi
  done
