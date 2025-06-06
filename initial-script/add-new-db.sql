-- nếu dùng SEEDING_MODE = AUTOMATIC, SQL sẽ tự đồng bộ ShopDev sang Secondary --
CREATE DATABASE ShopDev;
-- Bắt buộc phải ở chế độ FULL và bak 1 lần để sử dụng Always On --
-- Chuyển chế độ ghi log (recovery model) của database ShopDev sang chế độ FULL --
ALTER DATABASE ShopDev SET RECOVERY FULL;
BACKUP DATABASE ShopDev TO DISK = '/var/opt/mssql/backups/ShopDev.bak';
ALTER AVAILABILITY GROUP ag1 ADD DATABASE ShopDev;

-- Kiểm tra trạng thái Availability Group và các database trong nhóm --
SELECT 
    ag.name AS AG_Name,
    dbcs.database_name,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.is_suspended,
    drs.is_commit_participant
FROM 
    sys.availability_groups ag
JOIN 
    sys.availability_databases_cluster dbcs ON ag.group_id = dbcs.group_id
LEFT JOIN 
    sys.dm_hadr_database_replica_states drs ON dbcs.group_database_id = drs.group_database_id
WHERE 
    drs.is_local = 1 -- Optional: chỉ hiển thị bản ghi của node hiện tại
ORDER BY 
    ag.name, dbcs.database_name;
