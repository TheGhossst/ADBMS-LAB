```bash
sudo apt install docker
```

```bash
docker pull gvenzl/oracle-xe
```

```bash
docker run -d \
--name oracle-xe \
-p 1521:1521 \
-e ORACLE_PASSWORD=YourPassword \
gvenzl/oracle-xe
```

```bash
docker exec -it oracle-xe sqlplus system/YourPassword@XEPDB1
```
# Oracle Docker Credentials

Username: system  
Password: YourPassword  
Service (Database): XEPDB1


# Mysql password
```bash
MyNewStrongPassword123!
```

# XML
```bash
sudo mysqldump -u <username> -p --xml <dbname> > <filename>.xml
```
```bash
sudo mysqldump -u root -p --xml bank > bank2.xml
```
