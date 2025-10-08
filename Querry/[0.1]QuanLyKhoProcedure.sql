-- Lấy Name của Employee theo Id
CREATE PROCEDURE Employee_GetName
    @Id INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT Name
    FROM Employee
    WHERE Id = @Id AND IsDeleted = 0
END
GO

-- Tạo mới Employee
CREATE PROCEDURE Employee_Create
    @Name NVARCHAR(64),
    @Role NVARCHAR(32),
    @PhoneNumber NVARCHAR(15),
    @Email NVARCHAR(64),
    @Address NVARCHAR(256),
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO Employee
    (
        Name, Role, PhoneNumber, Email, Address,
        CreatedBy
    )
    VALUES
    (
        @Name, @Role, @PhoneNumber, @Email, @Address,
        @CreatedBy
    )
END
GO

-- Đọc Employee (có filter + phân trang như mẫu)
CREATE PROCEDURE Employee_Read
    @Id INT = NULL,
    @Name NVARCHAR(64) = NULL,
    @Role NVARCHAR(32) = NULL,
    @PhoneNumber NVARCHAR(15) = NULL,
    @Email NVARCHAR(64) = NULL,
    @CreatedBy NVARCHAR(32) = NULL,
    @CreatedDateStart DATETIME = NULL,
    @CreatedDateEnd DATETIME = NULL,
    @LastModifiedBy NVARCHAR(32) = NULL,
    @LastModifiedDateStart DATETIME = NULL,
    @LastModifiedDateEnd DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX) = '
        SELECT Id, Name, Role, PhoneNumber, Email, Address,
               CreatedBy, CreatedDate, LastModifiedBy, LastModifiedDate, IsDeleted
        FROM Employee
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = '
        @Id INT,
        @Name NVARCHAR(64),
        @Role NVARCHAR(32),
        @PhoneNumber NVARCHAR(15),
        @Email NVARCHAR(64),
        @CreatedBy NVARCHAR(32),
        @CreatedDateStart DATETIME,
        @CreatedDateEnd DATETIME,
        @LastModifiedBy NVARCHAR(32),
        @LastModifiedDateStart DATETIME,
        @LastModifiedDateEnd DATETIME,
        @CreatedDateStartCalculated DATETIME,
        @CreatedDateEndCalculated DATETIME,
        @LastModifiedDateStartCalculated DATETIME,
        @LastModifiedDateEndCalculated DATETIME';

    DECLARE @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart);
    DECLARE @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd);
    DECLARE @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart);
    DECLARE @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += ' AND Id = @Id';
    IF @Name IS NOT NULL AND LEN(@Name) > 0
        SET @Query += ' AND Name LIKE N''%'' + @Name + N''%''';
    IF @Role IS NOT NULL AND LEN(@Role) > 0
        SET @Query += ' AND Role LIKE N''%'' + @Role + N''%''';
    IF @PhoneNumber IS NOT NULL AND LEN(@PhoneNumber) > 0
        SET @Query += ' AND PhoneNumber LIKE N''%'' + @PhoneNumber + N''%''';
    IF @Email IS NOT NULL AND LEN(@Email) > 0
        SET @Query += ' AND Email LIKE N''%'' + @Email + N''%''';
    IF @CreatedBy IS NOT NULL AND LEN(@CreatedBy) > 0
        SET @Query += ' AND CreatedBy = @CreatedBy';
    IF @CreatedDateStart IS NOT NULL
        SET @Query += ' AND CreatedDate > @CreatedDateStartCalculated';
    IF @CreatedDateEnd IS NOT NULL
        SET @Query += ' AND CreatedDate < @CreatedDateEndCalculated';
    IF @LastModifiedBy IS NOT NULL AND LEN(@LastModifiedBy) > 0
        SET @Query += ' AND LastModifiedBy = @LastModifiedBy';
    IF @LastModifiedDateStart IS NOT NULL
        SET @Query += ' AND LastModifiedDate > @LastModifiedDateStartCalculated';
    IF @LastModifiedDateEnd IS NOT NULL
        SET @Query += ' AND LastModifiedDate < @LastModifiedDateEndCalculated';

    EXEC sp_executesql
        @Query,
        @Var,
        @Id = @Id,
        @Name = @Name,
        @Role = @Role,
        @PhoneNumber = @PhoneNumber,
        @Email = @Email,
        @CreatedBy = @CreatedBy,
        @CreatedDateStart = @CreatedDateStart,
        @CreatedDateEnd = @CreatedDateEnd,
        @LastModifiedBy = @LastModifiedBy,
        @LastModifiedDateStart = @LastModifiedDateStart,
        @LastModifiedDateEnd = @LastModifiedDateEnd,
        @CreatedDateStartCalculated = @CreatedDateStartCalculated,
        @CreatedDateEndCalculated = @CreatedDateEndCalculated,
        @LastModifiedDateStartCalculated = @LastModifiedDateStartCalculated,
        @LastModifiedDateEndCalculated = @LastModifiedDateEndCalculated;
END
GO

-- Update Employee
CREATE PROCEDURE Employee_Update
    @Id INT,
    @Name NVARCHAR(64),
    @Role NVARCHAR(32),
    @PhoneNumber NVARCHAR(15),
    @Email NVARCHAR(64),
    @Address NVARCHAR(256),
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Employee
    SET Name = @Name,
        Role = @Role,
        PhoneNumber = @PhoneNumber,
        Email = @Email,
        Address = @Address,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm Employee
CREATE PROCEDURE Employee_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    UPDATE Employee
    SET IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE Id = @Id AND IsDeleted = 0;
END
GO

-- Lấy Username theo Id
CREATE PROCEDURE Account_GetUsername
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Username
    FROM Account
    WHERE Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới Account
CREATE PROCEDURE Account_Create
    @EmployeeId INT,
    @Username NVARCHAR(32),
    @PasswordHash NVARCHAR(256),
    @IsAdmin BIT,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Account
    (
        EmployeeId, Username, PasswordHash, IsAdmin, CreatedBy
    )
    VALUES
    (
        @EmployeeId, @Username, @PasswordHash, @IsAdmin, @CreatedBy
    )
END
GO

-- Đọc Account
CREATE PROCEDURE Account_Read
    @Id INT = NULL,
    @EmployeeId INT = NULL,
    @Username NVARCHAR(32) = NULL,
    @IsAdmin BIT = NULL,
    @CreatedBy NVARCHAR(32) = NULL,
    @CreatedDateStart DATETIME = NULL,
    @CreatedDateEnd DATETIME = NULL,
    @LastModifiedBy NVARCHAR(32) = NULL,
    @LastModifiedDateStart DATETIME = NULL,
    @LastModifiedDateEnd DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX) = '
        SELECT Id, EmployeeId, Username, PasswordHash, IsAdmin,
               CreatedBy, CreatedDate, LastModifiedBy, LastModifiedDate, IsDeleted
        FROM Account
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = '
        @Id INT,
        @EmployeeId INT,
        @Username NVARCHAR(32),
        @IsAdmin BIT,
        @CreatedBy NVARCHAR(32),
        @CreatedDateStart DATETIME,
        @CreatedDateEnd DATETIME,
        @LastModifiedBy NVARCHAR(32),
        @LastModifiedDateStart DATETIME,
        @LastModifiedDateEnd DATETIME,
        @CreatedDateStartCalculated DATETIME,
        @CreatedDateEndCalculated DATETIME,
        @LastModifiedDateStartCalculated DATETIME,
        @LastModifiedDateEndCalculated DATETIME';

    DECLARE @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart);
    DECLARE @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd);
    DECLARE @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart);
    DECLARE @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += ' AND Id = @Id';
    IF @EmployeeId IS NOT NULL AND @EmployeeId > 0
        SET @Query += ' AND EmployeeId = @EmployeeId';
    IF @Username IS NOT NULL AND LEN(@Username) > 0
        SET @Query += ' AND Username LIKE N''%'' + @Username + N''%''';
    IF @IsAdmin IS NOT NULL
        SET @Query += ' AND IsAdmin = @IsAdmin';
    IF @CreatedBy IS NOT NULL AND LEN(@CreatedBy) > 0
        SET @Query += ' AND CreatedBy = @CreatedBy';
    IF @CreatedDateStart IS NOT NULL
        SET @Query += ' AND CreatedDate > @CreatedDateStartCalculated';
    IF @CreatedDateEnd IS NOT NULL
        SET @Query += ' AND CreatedDate < @CreatedDateEndCalculated';
    IF @LastModifiedBy IS NOT NULL AND LEN(@LastModifiedBy) > 0
        SET @Query += ' AND LastModifiedBy = @LastModifiedBy';
    IF @LastModifiedDateStart IS NOT NULL
        SET @Query += ' AND LastModifiedDate > @LastModifiedDateStartCalculated';
    IF @LastModifiedDateEnd IS NOT NULL
        SET @Query += ' AND LastModifiedDate < @LastModifiedDateEndCalculated';

    EXEC sp_executesql
        @Query,
        @Var,
        @Id = @Id,
        @EmployeeId = @EmployeeId,
        @Username = @Username,
        @IsAdmin = @IsAdmin,
        @CreatedBy = @CreatedBy,
        @CreatedDateStart = @CreatedDateStart,
        @CreatedDateEnd = @CreatedDateEnd,
        @LastModifiedBy = @LastModifiedBy,
        @LastModifiedDateStart = @LastModifiedDateStart,
        @LastModifiedDateEnd = @LastModifiedDateEnd,
        @CreatedDateStartCalculated = @CreatedDateStartCalculated,
        @CreatedDateEndCalculated = @CreatedDateEndCalculated,
        @LastModifiedDateStartCalculated = @LastModifiedDateStartCalculated,
        @LastModifiedDateEndCalculated = @LastModifiedDateEndCalculated;
END
GO

-- Update Account
CREATE PROCEDURE Account_Update
    @Id INT,
    @EmployeeId INT,
    @Username NVARCHAR(32),
    @PasswordHash NVARCHAR(256),
    @IsAdmin BIT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    UPDATE Account
    SET EmployeeId = @EmployeeId,
        Username = @Username,
        PasswordHash = @PasswordHash,
        IsAdmin = @IsAdmin,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm Account
CREATE PROCEDURE Account_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    UPDATE Account
    SET IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới Customer
CREATE PROCEDURE Customer_Create
    @Name NVARCHAR(255),
    @CustomerType NVARCHAR(50),
    @PhoneNumber VARCHAR(15),
    @Email VARCHAR (255),
    @Address NVARCHAR(255),
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    INSERT INTO Customer
    (
        Name, CustomerType, PhoneNumber, Email, Address,CreatedBy
    )
    VALUES
    (
        @Name, @CustomerType, @PhoneNumber, @Email, @Address, @CreatedBy
    )
END
GO

--Lấy Name của Customer qua Id
CREATE PROCEDURE Customer_GetName
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Name
    FROM Customer
    WHERE Id = @Id
        AND IsDeleted = 0;
END
GO

-- Đọc Customer
CREATE PROCEDURE Customer_Read
    @Id INT = NULL,
    @Name NVARCHAR(255) = NULL,
    @CustomerType NVARCHAR(50) = NULL,
    @PhoneNumber VARCHAR(15) = NULL,
    @Email VARCHAR(255) = NULL,
    @Address NVARCHAR(255) = NULL,
    @DebtFrom INT = NULL,
    @DebtTo INT = NULL,
    @CreatedBy NVARCHAR(32) = NULL,
    @CreatedDateStart DATETIME = NULL,
    @CreatedDateEnd DATETIME = NULL,
    @LastModifiedBy NVARCHAR(32) = NULL,
    @LastModifiedDateStart DATETIME = NULL,
    @LastModifiedDateEnd DATETIME = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX) = N'
        SELECT
	        Id,
	        Name,
	        CustomerType,
	        PhoneNumber,
	        Email,
	        Address,
	        Debt,
	        CreatedBy,
	        CreatedDate,
	        LastModifiedBy,
	        LastModifiedDate,
	        IsDeleted
	    FROM Customer
	    WHERE IsDeleted = 0';
    
    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @Name NVARCHAR(255),
        @CustomerType NVARCHAR(50),
        @PhoneNumber VARCHAR(15),
        @Email VARCHAR(255),
        @Address NVARCHAR(255),
        @DebtFrom INT,
        @DebtTo INT,
        @CreatedBy NVARCHAR(32),
        @CreatedDateStart DATETIME,
        @CreatedDateEnd DATETIME,
        @LastModifiedBy NVARCHAR(32),
        @LastModifiedDateStart DATETIME,
        @LastModifiedDateEnd DATETIME,
        @CreatedDateStartCalculated DATETIME,
        @CreatedDateEndCalculated DATETIME,
        @LastModifiedDateStartCalculated DATETIME,
        @LastModifiedDateEndCalculated DATETIME';

    DECLARE @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart);
    DECLARE @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd);
    DECLARE @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart);
    DECLARE @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);
  
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @Name IS NOT NULL AND LEN(@Name) > 0
        SET @Query += N' AND Name LIKE N''%'' + @Name + N''%''';
    IF @CustomerType IS NOT NULL AND LEN(@CustomerType) > 0
        SET @Query += N' AND CustomerType LIKE N''%'' + @CustomerType + N''%''';
    IF @PhoneNumber IS NOT NULL AND LEN(@PhoneNumber) > 0
        SET @Query += N' AND PhoneNumber LIKE N''%'' + @PhoneNumber + N''%''';
    IF @Email IS NOT NULL AND LEN(@Email) > 0
        SET @Query += N' AND Email LIKE N''%'' + @Email + N''%''';
    IF @Address IS NOT NULL AND LEN(@Address) > 0
        SET @Query += N' AND Address LIKE N''%'' + @Address + N''%''';
    IF @DebtFrom IS NOT NULL
        SET @Query += N' AND Debt >= @DebtFrom';
    IF @DebtTo IS NOT NULL 
        SET @Query += N' AND Debt <= @DebtTo';
    IF @CreatedBy IS NOT NULL AND LEN(@CreatedBy) > 0
        SET @Query += N' AND CreatedBy = @CreatedBy';
    IF @CreatedDateStart IS NOT NULL
        SET @Query += N' AND CreatedDate > @CreatedDateStartCalculated';
    IF @CreatedDateEnd IS NOT NULL
        SET @Query += N' AND CreatedDate < @CreatedDateEndCalculated';
    IF @LastModifiedBy IS NOT NULL AND LEN(@LastModifiedBy) > 0
        SET @Query += N' AND LastModifiedBy = @LastModifiedBy';
    IF @LastModifiedDateStart IS NOT NULL
        SET @Query += N' AND LastModifiedDate > @LastModifiedDateStartCalculated';
    IF @LastModifiedDateEnd IS NOT NULL
        SET @Query += N' AND LastModifiedDate < @LastModifiedDateEndCalculated';
    
    EXEC sp_executesql
        @Query,
        @Var,
        @Id = @Id,
        @Name = @Name,
        @CustomerType = @CustomerType,
        @PhoneNumber = @PhoneNumber,
        @Email = @Email,
        @Address = @Address,
        @DebtFrom = @DebtFrom,
        @DebtTo = @DebtTo,
        @CreatedBy = @CreatedBy,
        @CreatedDateStart = @CreatedDateStart,
        @CreatedDateEnd = @CreatedDateEnd,
        @LastModifiedBy = @LastModifiedBy,
        @LastModifiedDateStart = @LastModifiedDateStart,
        @LastModifiedDateEnd = @LastModifiedDateEnd,
        @CreatedDateStartCalculated = @CreatedDateStartCalculated,
        @CreatedDateEndCalculated = @CreatedDateEndCalculated,
        @LastModifiedDateStartCalculated = @LastModifiedDateStartCalculated,
        @LastModifiedDateEndCalculated = @LastModifiedDateEndCalculated;
END
GO

--Update Customer
CREATE PROCEDURE Customer_Update
    @Id INT,
    @Name NVARCHAR(255),
    @CustomerType NVARCHAR(50),
    @PhoneNumber VARCHAR(15),
    @Email VARCHAR (255),
    @Address NVARCHAR(255),
    @Debt INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    UPDATE Customer
    SET
        Name = @Name,
        CustomerType = @CustomerType,
        PhoneNumber = @PhoneNumber,
        Email = @Email,
        Address = @Address,
        Debt = @Debt,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0
END
GO

--Xóa mềm Customer
CREATE PROCEDURE Customer_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    UPDATE Customer
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0
END
GO

