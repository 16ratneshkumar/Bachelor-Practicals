# SQL User, Role, and Index Management

## 1. User Management
### Creating a User
```sql
CREATE USER 'Ratnesh'@'localhost' IDENTIFIED BY 'Ratnesh@123';
```
- This command creates a new MySQL user named `Ratnesh` with access limited to `localhost`.
- The user is authenticated with the password `Ratnesh@123`.

### Viewing Existing Users
```sql
SELECT User, Host FROM mysql.user;
```
- Displays a list of all users and their associated host permissions.

### Dropping a User
```sql
DROP USER 'Ratnesh'@'localhost';
```
- Deletes the user `Ratnesh` from the MySQL server.

## 2. Role Management
### Creating a Role
```sql
CREATE ROLE 'developer';
```
- Defines a new role named `developer`.

### Viewing Role Grants
```sql
SHOW GRANTS FOR 'developer';
```
- Lists all privileges assigned to the `developer` role.

### Dropping a Role
```sql
DROP ROLE 'developer';
```
- Deletes the `developer` role from the database.

## 3. Granting and Revoking Privileges
### Granting Privileges to a Role
```sql
GRANT SELECT, INSERT, UPDATE ON Student_Society.* TO 'developer';
```
- Grants the `developer` role permissions to select, insert, and update data in all tables of the `Student_Society` database.

### Viewing Granted Privileges
```sql
SHOW GRANTS FOR 'developer';
```
- Displays the privileges assigned to the `developer` role.

### Revoking Privileges
```sql
REVOKE UPDATE ON Student_Society.* FROM 'developer';
```
- Removes `UPDATE` privilege from the `developer` role while retaining other granted privileges.

## 4. Index Management
### Creating a Unique Index
```sql
CREATE UNIQUE INDEX Ratnesh ON Student_Society.society (SocID);
```
- Creates a unique index named `Ratnesh` on the `SocID` column of the `society` table within the `Student_Society` database.

### Viewing Indexes
```sql
SHOW INDEX FROM Student_Society.society;
```
- Displays existing indexes on the `society` table.

Alternatively, use:
```sql
SELECT INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_NAME = 'society'
AND TABLE_SCHEMA = 'Student_Society';
```
- Retrieves index details from the `INFORMATION_SCHEMA.STATISTICS` table.

### Dropping an Index
```sql
DROP INDEX Ratnesh ON Student_Society.society;
```
- Removes the `Ratnesh` index from the `society` table.

### Confirming Index Removal
```sql
SHOW INDEX FROM Student_Society.society;
```
- Checks if the index has been successfully removed.

---