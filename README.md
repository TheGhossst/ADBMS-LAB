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
Username : system
Password: YourPassword
Service (Database) : XEPDB1
