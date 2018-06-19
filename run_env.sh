docker rm -f mtrcs01srv01prd
docker rm -f mtrcs01srv02prd
docker rm -f mtrcs01srv03prd
docker rm -f mtrcs01srv04prd
docker rm -f mysql-stable-qa
docker rm -f mongo-stable-qa
docker rm -f redis-stable

docker run -d --name=mtrcs01srv01prd -h mtrcs01srv01prd --net br-ansible --ip 172.18.10.101 -v /var/www/mandu-metrics/:/var/www/mandu-metrics/ alpine37/metrics:v1
docker run -d --name=mtrcs01srv02prd -h mtrcs01srv02prd --net br-ansible --ip 172.18.10.102 -v /var/www/mandu-metrics/:/var/www/mandu-metrics/ alpine37/metrics:v1
docker run -d --name=mtrcs01srv03prd -h mtrcs01srv03prd --net br-ansible --ip 172.18.10.103 -v /var/www/mandu-metrics/:/var/www/mandu-metrics/ alpine37/metrics:v1
docker run -d --name=mtrcs01srv04prd -h mtrcs01srv04prd --net br-ansible --ip 172.18.10.104 -v /var/www/mandu-metrics/:/var/www/mandu-metrics/ alpine37/metrics:v1
docker run --name=mysql-stable-qa --net br-ansible --ip 172.18.10.191 -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/db -d mysql/mysql-server:stb
docker run --name=mongo-stable-qa --net br-ansible --ip 172.18.10.190 -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/backups -d mongo/mongo-server:stb
docker run --name=redis-stable --net br-ansible --ip 172.18.10.192 -d redis:alpine


docker run --name=mysql-stable-qa-56 --net br-ansible --ip 172.18.10.156 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=qa -e MYSQL_ROOT_HOST=% -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/db -d mysql/mysql-server:5.6

docker run --name=mariadb-stable-qa-102 --net br-ansible --ip 172.18.10.160 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=qa -e MYSQL_ROOT_HOST=% -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/db -d mariadb:10.2


#docker run --name=mysql-stable-qa --net br-ansible --ip 172.18.10.191 -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/db -d mysql/mysql-server:stb
#docker logs mysql1 2>&1 | grep GENERATED
#Ig3KZEkiHoL!yftEtYc4S)UgC@q
#docker exec -it mysql1 mysql -uroot -p
#ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
#CREATE USER 'root'@'%' IDENTIFIED BY '123456';
#GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '123456';

#docker run --name=mongo-stable-qa --net br-ansible --ip 172.18.10.190 -v /home/jcamino/Documentos/mandu/DevOps/BK_DB/:/data/backups -d mongo/mongo-server:stb
#mongorestore --drop -d metrics /data/backups/metrics
