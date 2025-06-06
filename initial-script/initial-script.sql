-- Sử dụng trên cả primary và secondary --
CREATE LOGIN dbm_login WITH PASSWORD = 'Pa$$w0rd';

CREATE USER dbm_user FOR LOGIN dbm_login;

USE master;
-- Tạo master key và certificate --
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PaSSw0rd';
-- Tạo certificate cho Database Mirroring(nếu cert hết hạn) --
CREATE CERTIFICATE dbm_certificate AUTHORIZATION dbm_user
FROM
    FILE = '/usr/certificate/dbm_certificate.cer' WITH PRIVATE KEY (
        FILE = '/usr/certificate/dbm_certificate.pvk',
        DECRYPTION BY PASSWORD = 'Pa$$w0rd'
    ) CREATE CERTIFICATE dbm_certificate AUTHORIZATION dbm_user WITH SUBJECT = 'Database Mirroring Certificate',
    START_DATE = '2024-06-01',
    EXPIRY_DATE = '2030-06-01';

-- Nếu cần backup lại certificate và mount lại cho cả primary và 2nd--
BACKUP CERTIFICATE dbm_certificate TO FILE = '/var/opt/mssql/certs/dbm_certificate.cer' WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/certs/dbm_certificate.pvk',
    ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
);
-- Nếu trùng tên cần xóa certificate cũ --
DROP CERTIFICATE dbm_certificate;

-- Tạo Database Mirroring Endpoint bảo mật với dbm_certificate--
CREATE ENDPOINT [Hadr_endpoint] AS TCP (LISTENER_IP = (0.0.0.0), LISTENER_PORT = 5022) FOR DATA_MIRRORING (
    ROLE = ALL,
    AUTHENTICATION = CERTIFICATE dbm_certificate,
    ENCRYPTION = REQUIRED ALGORITHM AES
);
-- Bật Endpoint sẵn sàng lắng nghe--
ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;
-- Cấp quyền cho login dbm_login để kết nối với Endpoint --
GRANT CONNECT ON ENDPOINT :: [Hadr_endpoint] TO [dbm_login];
-- Kiểm tra trạng thái Endpoint --
SELECT
    name,
    state_desc
FROM
    sys.endpoints
WHERE
    type_desc = 'DATABASE_MIRRORING';

-- Tạo Availability Group trên Primary --
CREATE AVAILABILITY GROUP [AG1] WITH (CLUSTER_TYPE = NONE) FOR REPLICA ON N 'sqlNode1' WITH (
    ENDPOINT_URL = N 'tcp://sqlNode1:5022',
    AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
),
N 'sqlNode2' WITH (
    ENDPOINT_URL = N 'tcp://sqlNode2:5022',
    AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
) DROP AVAILABILITY GROUP [AG1] 

-- Join Availability Group trên 2nd --            
ALTER AVAILABILITY GROUP [ag1]
JOIN WITH (CLUSTER_TYPE = NONE) ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE