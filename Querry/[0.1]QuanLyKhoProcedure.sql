-- Lấy Name của Employee theo Id
CREATE PROCEDURE Employee_GetName
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Name
    FROM Employee
    WHERE Id = @Id AND IsDeleted = 0;
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
    SET NOCOUNT ON;

    INSERT INTO Employee
    (
        Name, Role, PhoneNumber, Email, Address,
        CreatedBy
    )
    VALUES
    (
        @Name, @Role, @PhoneNumber, @Email, @Address,
        @CreatedBy
    );

    SELECT Id, Name, Role, PhoneNumber, Email, Address, CreatedBy, CreatedDate
    FROM Employee
    WHERE Id = SCOPE_IDENTITY();
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
    @LastModifiedDateEnd DATETIME = NULL,
    @PageOffset INT = NULL,
    @PageSize INT = NULL
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
        @PageOffset INT,
        @PageSize INT,
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

    IF @PageSize IS NOT NULL AND @PageOffset IS NOT NULL
        SET @Query += ' ORDER BY Id OFFSET @PageOffset ROWS FETCH NEXT @PageSize ROWS ONLY';

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
        @PageOffset = @PageOffset,
        @PageSize = @PageSize,
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
    );

    SELECT Id, EmployeeId, Username, PasswordHash, IsAdmin, CreatedBy, CreatedDate
    FROM Account
    WHERE Id = SCOPE_IDENTITY();
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
    @LastModifiedDateEnd DATETIME = NULL,
    @PageOffset INT = NULL,
    @PageSize INT = NULL
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
        @PageOffset INT,
        @PageSize INT,
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

    IF @PageSize IS NOT NULL AND @PageOffset IS NOT NULL
        SET @Query += ' ORDER BY Id OFFSET @PageOffset ROWS FETCH NEXT @PageSize ROWS ONLY';

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
        @PageOffset = @PageOffset,
        @PageSize = @PageSize,
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
    SET NOCOUNT ON;

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
