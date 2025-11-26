USE master;
GO

DROP DATABASE IF EXISTS QLyKho;
GO

CREATE DATABASE QLyKho
GO

USE QLyKho;
GO

CREATE TABLE Employee(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(64),
	Role NVARCHAR(32),
	PhoneNumber VARCHAR(15),
	Email VARCHAR(64),
	Address NVARCHAR(256),

	CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);
GO

CREATE UNIQUE INDEX UX_Employee_Email
    ON Employee(Email)
    WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_Employee_Phone
    ON Employee(PhoneNumber)
    WHERE IsDeleted = 0;
GO

CREATE TABLE Account(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT FOREIGN KEY REFERENCES Employee(Id),
    Username NVARCHAR(32),
    PasswordHash VARCHAR(256), -- Store hashed passwords
    IsAdmin BIT NOT NULL DEFAULT 0, -- Flag to indicate admin privileges

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);
GO

CREATE UNIQUE INDEX UX_Account_Username
    ON Account(Username)
    WHERE IsDeleted = 0;
GO

CREATE TABLE Customer(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,               
    CustomerType NVARCHAR(50) CHECK (CustomerType IN (N'Cá nhân',N'Doanh nghiệp')), -- Loại KH
    PhoneNumber VARCHAR(15),
    Email VARCHAR(255),
    Address NVARCHAR(255),
    Debt INT DEFAULT 0, 

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);
GO

CREATE UNIQUE INDEX UX_Customer_Email
    ON Customer(Email)
    WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_Customer_Phone
    ON Customer(PhoneNumber)
    WHERE IsDeleted = 0;
GO

CREATE TABLE Supplier (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL, 
    Email VARCHAR(255),
    PhoneNumber VARCHAR(10), 
    Address NVARCHAR(255),
    Description NVARCHAR(500),

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);
GO

CREATE UNIQUE INDEX UX_Supplier_Email
    ON Supplier(Email)
    WHERE IsDeleted = 0;
GO
CREATE UNIQUE INDEX UX_Supplier_Phone
    ON Supplier(PhoneNumber)
    WHERE IsDeleted = 0;
GO

CREATE TABLE Product(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SupplierId INT ,
    Name NVARCHAR(255),
    Quantity INT DEFAULT 0 CHECK (Quantity >= 0),
    Unit NVARCHAR(20),    
    
    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0,

    CONSTRAINT Fk_Product_Supplier FOREIGN KEY (SupplierId) REFERENCES Supplier(Id)
);
GO

CREATE TABLE InboundReceipt(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReceiptDate DATETIME,
    EmployeeId INT,
    SupplierId INT,
    TotalPrice INT,
    Note NVARCHAR(255),

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0,

    CONSTRAINT Fk_InboundReceipt_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(Id),
    CONSTRAINT Fk_InboundReceipt_Supplier FOREIGN KEY (SupplierId) REFERENCES Supplier(Id)
);
GO

CREATE TABLE InboundDetail(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    InboundReceiptId INT,
    ProductId INT,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice INT NOT NULL CHECK (UnitPrice > 0),
    Subtotal AS (Quantity*UnitPrice),

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0,

    CONSTRAINT Fk_InboundDetail_InboundReceipt FOREIGN KEY (InboundReceiptId) REFERENCES InboundReceipt(Id),
    CONSTRAINT Fk_InboundDetail_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
GO

CREATE TABLE OutboundReceipt(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReceiptDate DATETIME,
    EmployeeId INT,
    CustomerId INT,
    TotalPrice INT,
    Note NVARCHAR(255),

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0,

    CONSTRAINT Fk_OutboundReceipt_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(Id),
    CONSTRAINT Fk_OutboundReceipt_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
);
GO

CREATE TABLE OutboundDetail(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OutboundReceiptId INT,
    ProductId INT,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice INT NOT NULL CHECK (UnitPrice > 0),
    Subtotal AS (Quantity*UnitPrice),
    
    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0,
        
    CONSTRAINT Fk_OutboundDetail_OutboundReceipt FOREIGN KEY (OutboundReceiptId) REFERENCES OutboundReceipt(Id),
    CONSTRAINT Fk_OutboundDetail_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
GO

CREATE TABLE AuditLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Time DATETIME DEFAULT SYSUTCDATETIME(),
    Operation NVARCHAR(16), -- 'INSERT', 'UPDATE', 'DELETE'
    ChangeSource NVARCHAR(32),
    Users NVARCHAR(32),
    TableName NVARCHAR(64),
    TableId NVARCHAR(64),
    FieldChanges NVARCHAR(128),
    Data NVARCHAR(2048) -- stored as JSON
);
GO