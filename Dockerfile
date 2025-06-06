# filepath: /c:/Users/hoangns/Desktop/sqlserver-docker-alwayson/Dockerfile
FROM mcr.microsoft.com/mssql/server:2022-preview-ubuntu-22.04
EXPOSE 1433
EXPOSE 5022

LABEL "MAINTAINER" "Enrique Catalá <enrique@enriquecatala.com> | <ecatala@solidq.com> | @enriquecatala"
LABEL "Project" "SQL Server AlwaysOn Demo Node"

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD="PaSSw0rd"
ENV MSSQL_PID=Developer

# Certificate previously generated (see Readme.md)
ARG CERTFILE=certificate/dbm_certificate.cer
ARG CERTFILE_PWD=certificate/dbm_certificate.pvk

# Switch to root to create directories
USER root
RUN mkdir -p /usr/certificate

WORKDIR /usr/
COPY ${CERTFILE} ./certificate/dbm_certificate.cer
COPY ${CERTFILE_PWD} ./certificate/dbm_certificate.pvk

# Enable availability groups
RUN /opt/mssql/bin/mssql-conf set hadr.hadrenabled 1

# Switch back to default user
USER mssql

# Run SQL Server process
CMD ["/opt/mssql/bin/sqlservr"]