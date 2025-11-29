using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Security.Principal;

namespace GioiThieuCty.Models.DB
{
    public class Admin
    {
        public int Id { get; set; }
        public string Username { get; set; }
    }
    public class AuditLog
    {
        public int Id { get; set; }
        public DateTime? Time { get; set; }
        public string? Operation { get; set; }
        public string? ChangeSource { get; set; }
        public string? Users { get; set; }
        public string? TableName { get; set; }
        public string? TableId { get; set; }
        public string? FieldChanges { get; set; }
        public string? Data { get; set; }
        /*CREATE TABLE[dbo].[AuditLog]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Time] datetime DEFAULT sysutcdatetime() NULL,
        [Operation] nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [ChangeSource] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Users] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [TableName] nvarchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [TableId] nvarchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [FieldChanges] nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Data] nvarchar(2048) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,*/
    }
    public class Account
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public bool IsAdmin { get; set; }

        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public int? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE Account(
        Id INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeId INT FOREIGN KEY REFERENCES Employee(Id),
        Username NVARCHAR(32) UNIQUE,
        PasswordHash VARCHAR(256), -- Store hashed passwords
        IsAdmin BIT NOT NULL DEFAULT 0, -- Flag to indicate admin privileges

        CreatedBy NVARCHAR(32),
        CreatedDate DATETIME DEFAULT GETDATE(),
        LastModifiedBy NVARCHAR(32),
        LastModifiedDate DATETIME,
        IsDeleted BIT DEFAULT 0*/
    }
    public class Customer
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string? CustomerType { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
        public string? Address { get; set; }
        public int? Debt { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE[dbo].[Customer]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL,
        [CustomerType] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [PhoneNumber] varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Email] varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Address] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Debt] int DEFAULT 0 NULL,
        [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedDate] datetime DEFAULT getdate() NULL,
        [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [LastModifiedDate]
            datetime NULL,
        [IsDeleted] bit DEFAULT 0 NULL,*/
    }
    public class Employee
    {
        public int? Id { get; set; }
        public string? Name { get; set; }
        public string? Role { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
        public string? Address { get; set; }

        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE Employee(
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(64),
	    Role NVARCHAR(32),
	    PhoneNumber VARCHAR(15) UNIQUE,
	    Email VARCHAR(64) UNIQUE,
	    Address NVARCHAR(256),

	    CreatedBy NVARCHAR(32),
        CreatedDate DATETIME DEFAULT GETDATE(),
        LastModifiedBy NVARCHAR(32),
        LastModifiedDate DATETIME,
        IsDeleted BIT DEFAULT 0*/
    }
    public class InboundDetail
    {
        public int Id { get; set; }
        public int? InboundReceiptId { get; set; }
        public int? ProductId { get; set; }
        public int Quantity { get; set; }
        public int UnitPrice { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }

        /*CREATE TABLE[dbo].[InboundDetail]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [InboundReceiptId] int NULL,
        [ProductId] int NULL,
        [Quantity] int NOT NULL,
        [UnitPrice] int NOT NULL,
        [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedDate] datetime DEFAULT getdate() NULL,
        [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [LastModifiedDate]
        datetime NULL,*/
    }
    public class InboundReceipt
    {
        public int Id { get; set; }
        public DateTime? ReceiptDate { get; set; }
        public int? EmployeeId { get; set; }
        public int? SupplierId { get; set; }
        public int? TotalPrice { get; set; }
        public string? Note { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*        CREATE TABLE[dbo].[InboundReceipt]
                (
                [Id] int IDENTITY(1,1) NOT NULL,
                [ReceiptDate] datetime NULL,
                [EmployeeId] int NULL,
                [SupplierId] int NULL,
                [Note] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [CreatedDate] datetime DEFAULT getdate() NULL,
                [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [LastModifiedDate]
                    datetime NULL,
                [IsDeleted] bit DEFAULT 0 NULL,*/
    }
    public class OutboundDetail
    {
        public int Id { get; set; }
        public int? OutboundReceiptId { get; set; }
        public int? ProductId { get; set; }
        public int Quantity { get; set; }
        public int UnitPrice { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE[dbo].[OutboundDetail]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [OutboundReceiptId] int NULL,
        [ProductId] int NULL,
        [Quantity] int NOT NULL,
        [UnitPrice] int NOT NULL,
        [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedDate] datetime DEFAULT getdate() NULL,
        [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [LastModifiedDate]
        datetime NULL,*/
    }
    public class OutboundReceipt
    {
        public int Id { get; set; }
        public DateTime? ReceiptDate { get; set; }
        public int? EmployeeId { get; set; }
        public int? CustomerId { get; set; }
        public int? TotalPrice { get; set; }
        public string? Status { get; set; }
        public string? Note { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE[dbo].[OutboundReceipt]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [ReceiptDate] datetime NULL,
        [EmployeeId] int NULL,
        [CustomerId] int NULL,
        [Note] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedDate] datetime DEFAULT getdate() NULL,
        [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [LastModifiedDate]
            datetime NULL,
        [IsDeleted] bit DEFAULT 0 NULL,*/
    }
    public class Product
    {
        public int Id { get; set; }
        public int? SupplierId { get; set; }
        public string? Name { get; set; }
        public int? Quantity { get; set; }
        public string? Unit { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*CREATE TABLE[dbo].[Product]
        (
        [Id] int IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [Quantity] int DEFAULT 0 NULL,
        [Unit] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [CreatedDate] datetime DEFAULT getdate() NULL,
        [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
        [LastModifiedDate]
            datetime NULL,
        [IsDeleted] bit DEFAULT 0 NULL,*/
    }
    public class Supplier
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? Description { get; set; }

        public string? CreatedBy { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public bool? IsDeleted { get; set; }
        /*        CREATE TABLE[dbo].[Supplier]
                (
                [Id] int IDENTITY(1,1) NOT NULL,
                [Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL,
                [Email] varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [PhoneNumber] varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [Address] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [Description] nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [CreatedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [CreatedDate] datetime DEFAULT getdate() NULL,
                [LastModifiedBy] nvarchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
                [LastModifiedDate]
                    datetime NULL,
                [IsDeleted] bit DEFAULT 0 NULL,*/
    }
}