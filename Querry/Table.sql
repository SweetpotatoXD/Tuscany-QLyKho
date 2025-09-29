
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
GO

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

CREATE TABLE Product(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Quantity INT DEFAULT 0 CHECK (Number >= 0),
    Unit NVARCHAR(20),    
    
    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,
    IsDeleted BIT DEFAULT 0
);
GO

CREATE TABLE InboundReceipt(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReceiptDate DATETIME,
    EmployeeId INT,
    SupplierId INT,
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

    CreatedBy NVARCHAR(32),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedBy NVARCHAR(32),
    LastModifiedDate DATETIME,

    CONSTRAINT Fk_InboundDetail_InboundReceipt FOREIGN KEY (InboundReceiptId) REFERENCES InboundReceipt(Id),
    CONSTRAINT Fk_InboundDetail_Product FOREIGN KEY (ProductId) REFERENCES Product(Id)
);
GO

