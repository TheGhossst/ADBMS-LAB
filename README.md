### IF NO ORACLE-XE

```bash
sudo docker pull gvenzl/oracle-xe:21
```
### ELSE
```bash

docker start oracle-xe 
docker exec -it oracle-xe sqlplus system/YourPassword@XEPDB1
```
