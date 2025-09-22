
CREATE DATABASE QLyKho

CREATE TABLE Employee(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(64),
	Role NVARCHAR(32),
	PhoneNumber NVARCHAR(15),
	Email NVARCHAR(64) UNIQUE,
	Address NVARCHAR(256),

	CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);

CREATE TABLE Account(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT FOREIGN KEY REFERENCES Employee(Id),
    Username NVARCHAR(32) UNIQUE,
    PasswordHash NVARCHAR(256), -- Store hashed passwords
    IsAdmin BIT NOT NULL DEFAULT 0, -- Flag to indicate admin privileges
    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);

