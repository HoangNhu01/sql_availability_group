# sqlserver-docker-alwayson

Docker templates to create a SQL Server latest availability group solution with 2 nodes

## How to create an AlwaysOn topology with 2 nodes using docker

You can create a complete environment with 3 AlwaysOn nodes by following the next steps:

1. Build the infrastructure (2 nodes named: sqlNode1, sqlNode2)

```cmd
docker-compose build
```

The [docker-compose](./docker-compose.yml) references the [following docker image](https://hub.docker.com/r/microsoft/mssql-server). 

2. Run the infrastructure

```cmd
docker-compose up
```

_Now, you have a 2 container sharing the network and prepared to be part of a new availability group_

### References

https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-cross-platform?view=sql-server-2017
