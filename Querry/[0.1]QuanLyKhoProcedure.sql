USE QLyKho;
GO

-- Lấy Name của Employee theo Id
CREATE OR ALTER PROCEDURE Employee_GetName
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
CREATE OR ALTER PROCEDURE Employee_Create
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
CREATE OR ALTER PROCEDURE Employee_Read
    @Id INT = NULL,
    @Name NVARCHAR(64) = NULL,
    @Role NVARCHAR(32) = NULL,
    @PhoneNumber NVARCHAR(15) = NULL,
    @Email NVARCHAR(64) = NULL,
    @Address NVARCHAR(255) = NULL,
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
        @Address NVARCHAR(255),
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
    IF @Address IS NOT NULL AND LEN(@Address) > 0
            SET @Query += N' AND Address LIKE N''%'' + @Address + N''%''';
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
        @Address = @Address,
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
-- Get Validate Email PhoneNumber Employee
CREATE OR ALTER PROCEDURE [dbo].[Employee_CheckDuplicate]
    @PhoneNumber NVARCHAR(15) = NULL,
    @Email NVARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Name, PhoneNumber, Email
    FROM Employee
    WHERE IsDeleted = 0
    AND (
        (@Email IS NOT NULL AND @Email <> '' AND Email = @Email)
        OR
        (@PhoneNumber IS NOT NULL AND @PhoneNumber <> '' AND PhoneNumber = @PhoneNumber)
    )
END
GO

-- Update Employee
CREATE OR ALTER PROCEDURE Employee_Update
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
CREATE OR ALTER PROCEDURE Employee_SoftDelete
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
CREATE OR ALTER PROCEDURE Account_GetUsername
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
CREATE OR ALTER PROCEDURE Account_Create
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
CREATE OR ALTER PROCEDURE Account_Read
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
CREATE OR ALTER PROCEDURE Account_Update
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
CREATE OR ALTER PROCEDURE Account_SoftDelete
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
CREATE OR ALTER PROCEDURE Customer_Create
    @Name NVARCHAR(255),
    @CustomerType NVARCHAR(50),
    @PhoneNumber VARCHAR(15),
    @Email VARCHAR (255),
    @Address NVARCHAR(255),
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

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
CREATE OR ALTER PROCEDURE Customer_GetName
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
CREATE OR ALTER PROCEDURE Customer_Read
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
CREATE OR ALTER PROCEDURE Customer_Update
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
CREATE OR ALTER PROCEDURE Customer_SoftDelete
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

-- Tạo mới Supplier
CREATE OR ALTER PROCEDURE Supplier_Create
    @Name NVARCHAR(255),
    @Email VARCHAR(255) = NULL,
    @PhoneNumber VARCHAR(10) = NULL,
    @Address NVARCHAR(255) = NULL,
    @Description NVARCHAR(500) = NULL,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Supplier
    (
        Name, Email, PhoneNumber, Address, Description, CreatedBy
    )
    VALUES
    (
        @Name, @Email, @PhoneNumber, @Address, @Description, @CreatedBy
    );
END
GO

-- Đọc Supplier
CREATE OR ALTER PROCEDURE Supplier_Read
    @Id INT = NULL,
    @Name NVARCHAR(255) = NULL,
    @Email VARCHAR(255) = NULL,
    @PhoneNumber VARCHAR(10) = NULL,
    @Address NVARCHAR(255) = NULL,
    @Description NVARCHAR(500) = NULL,
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
            Email,
            PhoneNumber,
            Address,
            Description,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM Supplier
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @Name NVARCHAR(255),
        @Email VARCHAR(255),
        @PhoneNumber VARCHAR(10),
        @Address NVARCHAR(255),
        @Description NVARCHAR(500),
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

    DECLARE 
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @Name IS NOT NULL AND LEN(@Name) > 0
        SET @Query += N' AND Name LIKE N''%'' + @Name + N''%''';
    IF @Email IS NOT NULL AND LEN(@Email) > 0
        SET @Query += N' AND Email LIKE N''%'' + @Email + N''%''';
    IF @PhoneNumber IS NOT NULL AND LEN(@PhoneNumber) > 0
        SET @Query += N' AND PhoneNumber LIKE N''%'' + @PhoneNumber + N''%''';
    IF @Address IS NOT NULL AND LEN(@Address) > 0
        SET @Query += N' AND Address LIKE N''%'' + @Address + N''%''';
    IF @Description IS NOT NULL AND LEN(@Description) > 0
        SET @Query += N' AND Description LIKE N''%'' + @Description + N''%''';
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
        @Email = @Email,
        @PhoneNumber = @PhoneNumber,
        @Address = @Address,
        @Description = @Description,
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

-- Cập nhật Supplier
CREATE OR ALTER PROCEDURE Supplier_Update
    @Id INT,
    @Name NVARCHAR(255),
    @Email VARCHAR(255),
    @PhoneNumber VARCHAR(10),
    @Address NVARCHAR(255),
    @Description NVARCHAR(500),
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Supplier
    SET
        Name = @Name,
        Email = @Email,
        PhoneNumber = @PhoneNumber,
        Address = @Address,
        Description = @Description,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm Supplier
CREATE OR ALTER PROCEDURE Supplier_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Supplier
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới Product
CREATE OR ALTER PROCEDURE Product_Create
    @SupplierId INT,
    @Name NVARCHAR(255),
    @Quantity INT = 0,
    @Unit NVARCHAR(20),
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Product
    (
        SupplierId, Name, Quantity, Unit, CreatedBy
    )
    VALUES
    (
        @SupplierId, @Name, @Quantity, @Unit, @CreatedBy
    );
END
GO

-- Lấy Name của Product qua Id
CREATE OR ALTER PROCEDURE Product_GetName
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Name
    FROM Product
    WHERE Id = @Id
      AND IsDeleted = 0;
END
GO

-- Đọc Product
CREATE OR ALTER PROCEDURE Product_Read
    @Id INT = NULL,
    @SupplierId INT = NULL,
    @Name NVARCHAR(255) = NULL,
    @Unit NVARCHAR(20) = NULL,
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
            SupplierId,
            Name,
            Quantity,
            Unit,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM Product
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @SupplierId INT,
        @Name NVARCHAR(255),
        @Unit NVARCHAR(20),
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

    DECLARE 
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @SupplierId IS NOT NULL AND @SupplierId > 0
        SET @Query += N' AND SupplierId = @SupplierId';
    IF @Name IS NOT NULL AND LEN(@Name) > 0
        SET @Query += N' AND Name LIKE N''%'' + @Name + N''%''';
    IF @Unit IS NOT NULL AND LEN(@Unit) > 0
        SET @Query += N' AND Unit LIKE N''%'' + @Unit + N''%''';
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
        @SupplierId = @SupplierId,
        @Name = @Name,
        @Unit = @Unit,
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

-- Update Product
CREATE OR ALTER PROCEDURE Product_Update
    @Id INT,
    @SupplierId INT,
    @Name NVARCHAR(255),
    @Quantity INT,
    @Unit NVARCHAR(20),
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Product
    SET
        SupplierId = @SupplierId,
        Name = @Name,
        Quantity = @Quantity,
        Unit = @Unit,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm Product
CREATE OR ALTER PROCEDURE Product_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Product
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới InboundReceipt
CREATE OR ALTER PROCEDURE InboundReceipt_Create
    @ReceiptDate DATETIME,
    @EmployeeId INT,
    @SupplierId INT,
    @Note NVARCHAR(255),
    @TotalPrice INT,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO InboundReceipt
    (
        ReceiptDate, EmployeeId, SupplierId, TotalPrice, Note, CreatedBy
    )
    VALUES
    (
        @ReceiptDate, @EmployeeId, @SupplierId, @TotalPrice, @Note, @CreatedBy
    );
END
GO

-- Đọc InboundReceipt (READ động)
CREATE OR ALTER PROCEDURE InboundReceipt_Read
    @Id INT = NULL,
    @ReceiptDateStart DATETIME = NULL,
    @ReceiptDateEnd DATETIME = NULL,
    @EmployeeId INT = NULL,
    @SupplierId INT = NULL,
    @Note NVARCHAR(255) = NULL,
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
            ReceiptDate,
            EmployeeId,
            SupplierId,
            TotalPrice,
            Note,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM InboundReceipt
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @ReceiptDateStart DATETIME,
        @ReceiptDateEnd DATETIME,
        @EmployeeId INT,
        @SupplierId INT,
        @Note NVARCHAR(255),
        @CreatedBy NVARCHAR(32),
        @CreatedDateStart DATETIME,
        @CreatedDateEnd DATETIME,
        @LastModifiedBy NVARCHAR(32),
        @LastModifiedDateStart DATETIME,
        @LastModifiedDateEnd DATETIME,
        @ReceiptDateStartCalculated DATETIME,
        @ReceiptDateEndCalculated DATETIME,
        @CreatedDateStartCalculated DATETIME,
        @CreatedDateEndCalculated DATETIME,
        @LastModifiedDateStartCalculated DATETIME,
        @LastModifiedDateEndCalculated DATETIME';

    DECLARE
        @ReceiptDateStartCalculated DATETIME = DATEADD(SECOND, -1, @ReceiptDateStart),
        @ReceiptDateEndCalculated DATETIME = DATEADD(SECOND, 1, @ReceiptDateEnd),
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @ReceiptDateStart IS NOT NULL
        SET @Query += N' AND ReceiptDate > @ReceiptDateStartCalculated';
    IF @ReceiptDateEnd IS NOT NULL
        SET @Query += N' AND ReceiptDate < @ReceiptDateEndCalculated';
    IF @EmployeeId IS NOT NULL AND @EmployeeId > 0
        SET @Query += N' AND EmployeeId = @EmployeeId';
    IF @SupplierId IS NOT NULL AND @SupplierId > 0
        SET @Query += N' AND SupplierId = @SupplierId';
    IF @Note IS NOT NULL AND LEN(@Note) > 0
        SET @Query += N' AND Note LIKE N''%'' + @Note + N''%''';
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
        @ReceiptDateStart = @ReceiptDateStart,
        @ReceiptDateEnd = @ReceiptDateEnd,
        @EmployeeId = @EmployeeId,
        @SupplierId = @SupplierId,
        @Note = @Note,
        @CreatedBy = @CreatedBy,
        @CreatedDateStart = @CreatedDateStart,
        @CreatedDateEnd = @CreatedDateEnd,
        @LastModifiedBy = @LastModifiedBy,
        @LastModifiedDateStart = @LastModifiedDateStart,
        @LastModifiedDateEnd = @LastModifiedDateEnd,
        @ReceiptDateStartCalculated = @ReceiptDateStartCalculated,
        @ReceiptDateEndCalculated = @ReceiptDateEndCalculated,
        @CreatedDateStartCalculated = @CreatedDateStartCalculated,
        @CreatedDateEndCalculated = @CreatedDateEndCalculated,
        @LastModifiedDateStartCalculated = @LastModifiedDateStartCalculated,
        @LastModifiedDateEndCalculated = @LastModifiedDateEndCalculated;
END
GO


-- Cập nhật InboundReceipt
CREATE OR ALTER PROCEDURE InboundReceipt_Update
    @Id INT,
    @ReceiptDate DATETIME,
    @EmployeeId INT,
    @SupplierId INT,
    @TotalPrice INT,
    @Note NVARCHAR(255),
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE InboundReceipt
    SET
        ReceiptDate = @ReceiptDate,
        EmployeeId = @EmployeeId,
        SupplierId = @SupplierId,
        TotalPrice = @TotalPrice,
        Note = @Note,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO


-- Xóa mềm InboundReceipt
CREATE OR ALTER PROCEDURE InboundReceipt_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE InboundReceipt
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới InboundDetail
CREATE OR ALTER PROCEDURE InboundDetail_Create
    @InboundReceiptId INT,
    @ProductId INT,
    @Quantity INT,
    @UnitPrice INT,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO InboundDetail
    (
        InboundReceiptId, ProductId, Quantity, UnitPrice, CreatedBy
    )
    VALUES
    (
        @InboundReceiptId, @ProductId, @Quantity, @UnitPrice, @CreatedBy
    );
END
GO

-- Đọc InboundDetail
CREATE OR ALTER PROCEDURE InboundDetail_Read
    @Id INT = NULL,
    @InboundReceiptId INT = NULL,
    @ProductId INT = NULL,
    @QuantityFrom INT = NULL,
    @QuantityTo INT = NULL,
    @UnitPriceFrom INT = NULL,
    @UnitPriceTo INT = NULL,
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
            InboundReceiptId,
            ProductId,
            Quantity,
            UnitPrice,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM InboundDetail
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @InboundReceiptId INT,
        @ProductId INT,
        @QuantityFrom INT,
        @QuantityTo INT,
        @UnitPriceFrom INT,
        @UnitPriceTo INT,
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

    DECLARE 
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @InboundReceiptId IS NOT NULL AND @InboundReceiptId > 0
        SET @Query += N' AND InboundReceiptId = @InboundReceiptId';
    IF @ProductId IS NOT NULL AND @ProductId > 0
        SET @Query += N' AND ProductId = @ProductId';
    IF @QuantityFrom IS NOT NULL
        SET @Query += N' AND Quantity >= @QuantityFrom';
    IF @QuantityTo IS NOT NULL
        SET @Query += N' AND Quantity <= @QuantityTo';
    IF @UnitPriceFrom IS NOT NULL
        SET @Query += N' AND UnitPrice >= @UnitPriceFrom';
    IF @UnitPriceTo IS NOT NULL
        SET @Query += N' AND UnitPrice <= @UnitPriceTo';
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
        @InboundReceiptId = @InboundReceiptId,
        @ProductId = @ProductId,
        @QuantityFrom = @QuantityFrom,
        @QuantityTo = @QuantityTo,
        @UnitPriceFrom = @UnitPriceFrom,
        @UnitPriceTo = @UnitPriceTo,
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

-- Cập nhật InboundDetail
CREATE OR ALTER PROCEDURE InboundDetail_Update
    @Id INT,
    @InboundReceiptId INT,
    @ProductId INT,
    @Quantity INT,
    @UnitPrice INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE InboundDetail
    SET
        InboundReceiptId = @InboundReceiptId,
        ProductId = @ProductId,
        Quantity = @Quantity,
        UnitPrice = @UnitPrice,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm InboundDetail
CREATE OR ALTER PROCEDURE InboundDetail_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE InboundDetail
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới OutboundReceipt
CREATE OR ALTER PROCEDURE OutboundReceipt_Create
    @ReceiptDate DATETIME,
    @EmployeeId INT,
    @CustomerId INT,
    @TotalPrice INT,
    @Status NVARCHAR(50),
    @Note NVARCHAR(255) = NULL,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OutboundReceipt
    (
        ReceiptDate, EmployeeId, CustomerId, Status, Note, CreatedBy
    )
    VALUES
    (
        @ReceiptDate, @EmployeeId, @CustomerId, @Status, @Note, @CreatedBy
    );
END
GO

-- Đọc OutboundReceipt
CREATE OR ALTER PROCEDURE OutboundReceipt_Read
    @Id INT = NULL,
    @ReceiptDateStart DATETIME = NULL,
    @ReceiptDateEnd DATETIME = NULL,
    @EmployeeId INT = NULL,
    @CustomerId INT = NULL,
    @Note NVARCHAR(255) = NULL,
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
            ReceiptDate,
            EmployeeId,
            CustomerId,
            TotalPrice,
            Status,
            Note,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM OutboundReceipt
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @ReceiptDateStart DATETIME,
        @ReceiptDateEnd DATETIME,
        @EmployeeId INT,
        @CustomerId INT,
        @Note NVARCHAR(255),
        @CreatedBy NVARCHAR(32),
        @CreatedDateStart DATETIME,
        @CreatedDateEnd DATETIME,
        @LastModifiedBy NVARCHAR(32),
        @LastModifiedDateStart DATETIME,
        @LastModifiedDateEnd DATETIME,
        @ReceiptDateStartCalculated DATETIME,
        @ReceiptDateEndCalculated DATETIME,
        @CreatedDateStartCalculated DATETIME,
        @CreatedDateEndCalculated DATETIME,
        @LastModifiedDateStartCalculated DATETIME,
        @LastModifiedDateEndCalculated DATETIME';

    DECLARE 
        @ReceiptDateStartCalculated DATETIME = DATEADD(SECOND, -1, @ReceiptDateStart),
        @ReceiptDateEndCalculated DATETIME = DATEADD(SECOND, 1, @ReceiptDateEnd),
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @ReceiptDateStart IS NOT NULL
        SET @Query += N' AND ReceiptDate > @ReceiptDateStartCalculated';
    IF @ReceiptDateEnd IS NOT NULL
        SET @Query += N' AND ReceiptDate < @ReceiptDateEndCalculated';
    IF @EmployeeId IS NOT NULL AND @EmployeeId > 0
        SET @Query += N' AND EmployeeId = @EmployeeId';
    IF @CustomerId IS NOT NULL AND @CustomerId > 0
        SET @Query += N' AND CustomerId = @CustomerId';
    IF @Note IS NOT NULL AND LEN(@Note) > 0
        SET @Query += N' AND Note LIKE N''%'' + @Note + N''%''';
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
        @ReceiptDateStart = @ReceiptDateStart,
        @ReceiptDateEnd = @ReceiptDateEnd,
        @EmployeeId = @EmployeeId,
        @CustomerId = @CustomerId,
        @Note = @Note,
        @CreatedBy = @CreatedBy,
        @CreatedDateStart = @CreatedDateStart,
        @CreatedDateEnd = @CreatedDateEnd,
        @LastModifiedBy = @LastModifiedBy,
        @LastModifiedDateStart = @LastModifiedDateStart,
        @LastModifiedDateEnd = @LastModifiedDateEnd,
        @ReceiptDateStartCalculated = @ReceiptDateStartCalculated,
        @ReceiptDateEndCalculated = @ReceiptDateEndCalculated,
        @CreatedDateStartCalculated = @CreatedDateStartCalculated,
        @CreatedDateEndCalculated = @CreatedDateEndCalculated,
        @LastModifiedDateStartCalculated = @LastModifiedDateStartCalculated,
        @LastModifiedDateEndCalculated = @LastModifiedDateEndCalculated;
END
GO

-- Cập nhật OutboundReceipt
CREATE OR ALTER PROCEDURE OutboundReceipt_Update
    @Id INT,
    @ReceiptDate DATETIME,
    @EmployeeId INT,
    @CustomerId INT,
    @TotalPrice INT,
    @Status NVARCHAR(50),
    @Note NVARCHAR(255),
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE OutboundReceipt
    SET
        ReceiptDate = @ReceiptDate,
        EmployeeId = @EmployeeId,
        CustomerId = @CustomerId,
        TotalPrice = @TotalPrice,
        Status = @Status,
        Note = @Note,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm OutboundReceipt
CREATE OR ALTER PROCEDURE OutboundReceipt_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE OutboundReceipt
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Tạo mới OutboundDetail
CREATE OR ALTER PROCEDURE OutboundDetail_Create
    @OutboundReceiptId INT,
    @ProductId INT,
    @Quantity INT,
    @UnitPrice INT,
    @CreatedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OutboundDetail
    (
        OutboundReceiptId, ProductId, Quantity, UnitPrice, CreatedBy
    )
    VALUES
    (
        @OutboundReceiptId, @ProductId, @Quantity, @UnitPrice, @CreatedBy
    );
END
GO

-- Đọc OutboundDetail
CREATE OR ALTER PROCEDURE OutboundDetail_Read
    @Id INT = NULL,
    @OutboundReceiptId INT = NULL,
    @ProductId INT = NULL,
    @QuantityFrom INT = NULL,
    @QuantityTo INT = NULL,
    @UnitPriceFrom INT = NULL,
    @UnitPriceTo INT = NULL,
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
            OutboundReceiptId,
            ProductId,
            Quantity,
            UnitPrice,
            CreatedBy,
            CreatedDate,
            LastModifiedBy,
            LastModifiedDate,
            IsDeleted
        FROM OutboundDetail
        WHERE IsDeleted = 0';

    DECLARE @Var NVARCHAR(MAX) = N'
        @Id INT,
        @OutboundReceiptId INT,
        @ProductId INT,
        @QuantityFrom INT,
        @QuantityTo INT,
        @UnitPriceFrom INT,
        @UnitPriceTo INT,
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

    DECLARE 
        @CreatedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @CreatedDateStart),
        @CreatedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @CreatedDateEnd),
        @LastModifiedDateStartCalculated DATETIME = DATEADD(SECOND, -1, @LastModifiedDateStart),
        @LastModifiedDateEndCalculated DATETIME = DATEADD(SECOND, 1, @LastModifiedDateEnd);

    -- Điều kiện động
    IF @Id IS NOT NULL AND @Id > 0
        SET @Query += N' AND Id = @Id';
    IF @OutboundReceiptId IS NOT NULL AND @OutboundReceiptId > 0
        SET @Query += N' AND OutboundReceiptId = @OutboundReceiptId';
    IF @ProductId IS NOT NULL AND @ProductId > 0
        SET @Query += N' AND ProductId = @ProductId';
    IF @QuantityFrom IS NOT NULL
        SET @Query += N' AND Quantity >= @QuantityFrom';
    IF @QuantityTo IS NOT NULL
        SET @Query += N' AND Quantity <= @QuantityTo';
    IF @UnitPriceFrom IS NOT NULL
        SET @Query += N' AND UnitPrice >= @UnitPriceFrom';
    IF @UnitPriceTo IS NOT NULL
        SET @Query += N' AND UnitPrice <= @UnitPriceTo';
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
        @OutboundReceiptId = @OutboundReceiptId,
        @ProductId = @ProductId,
        @QuantityFrom = @QuantityFrom,
        @QuantityTo = @QuantityTo,
        @UnitPriceFrom = @UnitPriceFrom,
        @UnitPriceTo = @UnitPriceTo,
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

-- Cập nhật OutboundDetail
CREATE OR ALTER PROCEDURE OutboundDetail_Update
    @Id INT,
    @OutboundReceiptId INT,
    @ProductId INT,
    @Quantity INT,
    @UnitPrice INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE OutboundDetail
    SET
        OutboundReceiptId = @OutboundReceiptId,
        ProductId = @ProductId,
        Quantity = @Quantity,
        UnitPrice = @UnitPrice,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO

-- Xóa mềm OutboundDetail
CREATE OR ALTER PROCEDURE OutboundDetail_SoftDelete
    @Id INT,
    @LastModifiedBy NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE OutboundDetail
    SET
        IsDeleted = 1,
        LastModifiedBy = @LastModifiedBy,
        LastModifiedDate = GETDATE()
    WHERE
        Id = @Id AND IsDeleted = 0;
END
GO