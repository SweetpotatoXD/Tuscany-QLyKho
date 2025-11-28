USE QLyKho;
GO

-- 1. Thêm nhân viên kế toán
EXEC Employee_Create
    @Name = N'Nguyễn Văn A',
    @Role = N'Kế toán',
    @PhoneNumber = N'0912345678',
    @Email = N'vana@example.com',
    @Address = N'123 Trần Hưng Đạo, Hà Nội',
    @CreatedBy = N'admin';

-- 2. Thêm nhân viên IT
EXEC Employee_Create
    @Name = N'Trần Thị B',
    @Role = N'IT Support',
    @PhoneNumber = N'0987654321',
    @Email = N'tranb@example.com',
    @Address = N'456 Lý Thường Kiệt, TP. Hồ Chí Minh',
    @CreatedBy = N'admin';

-- 3. Thêm nhân viên bán hàng
EXEC Employee_Create
    @Name = N'Lê Văn C',
    @Role = N'Nhân viên kinh doanh',
    @PhoneNumber = N'0905123123',
    @Email = N'levanc@example.com',
    @Address = N'22 Nguyễn Huệ, Đà Nẵng',
    @CreatedBy = N'manager';

-- 4. Thêm nhân viên marketing
EXEC Employee_Create
    @Name = N'Phạm Thị D',
    @Role = N'Marketing',
    @PhoneNumber = N'0933222111',
    @Email = N'phamd@example.com',
    @Address = N'789 Điện Biên Phủ, Cần Thơ',
    @CreatedBy = N'manager';

-- 1️ Tạo tài khoản cho Nguyễn Văn A (Kế toán)
EXEC Account_Create
    @EmployeeId = 1,
    @Username = N'vana',
    @PasswordHash = N'hashed_password_123',  -- giá trị hash (ví dụ)
    @IsAdmin = 0,
    @CreatedBy = N'admin';

-- 2️ Tạo tài khoản cho Trần Thị B (IT Support)
EXEC Account_Create
    @EmployeeId = 2,
    @Username = N'tranb',
    @PasswordHash = N'hashed_password_456',
    @IsAdmin = 1,   -- ví dụ: cho quyền admin
    @CreatedBy = N'admin';

-- 3️ Tạo tài khoản cho Lê Văn C (Kinh doanh)
EXEC Account_Create
    @EmployeeId = 3,
    @Username = N'levanc',
    @PasswordHash = N'hashed_password_789',
    @IsAdmin = 0,
    @CreatedBy = N'manager';

-- 4️ Tạo tài khoản cho Phạm Thị D (Marketing)
EXEC Account_Create
    @EmployeeId = 4,
    @Username = N'phamd',
    @PasswordHash = N'hashed_password_abc',
    @IsAdmin = 0,
    @CreatedBy = N'manager';

-- 1️ Khách hàng cá nhân
EXEC Customer_Create
    @Name = N'Nguyễn Văn Minh',
    @CustomerType = N'Cá nhân',
    @PhoneNumber = '0901234567',
    @Email = 'nguyenvanminh@example.com',
    @Address = N'25 Lý Thường Kiệt, Hà Nội',
    @CreatedBy = N'admin';

-- 2️ Khách hàng doanh nghiệp
EXEC Customer_Create
    @Name = N'Công ty TNHH ABC',
    @CustomerType = N'Doanh nghiệp',
    @PhoneNumber = '0988123456',
    @Email = 'contact@abccompany.vn',
    @Address = N'12 Nguyễn Huệ, TP. Hồ Chí Minh',
    @CreatedBy = N'manager';

-- 3️ Khách hàng cá nhân
EXEC Customer_Create
    @Name = N'Lê Thị Hồng',
    @CustomerType = N'Cá nhân',
    @PhoneNumber = '0912345678',
    @Email = 'lethihong@gmail.com',
    @Address = N'89 Pasteur, Đà Nẵng',
    @CreatedBy = N'staff01';

-- 4️ Khách hàng doanh nghiệp
EXEC Customer_Create
    @Name = N'Công ty Cổ phần XYZ',
    @CustomerType = N'Doanh nghiệp',
    @PhoneNumber = '0933777888',
    @Email = 'info@xyzcorp.vn',
    @Address = N'77 Điện Biên Phủ, Cần Thơ',
    @CreatedBy = N'manager';

-- 5️ Khách hàng cá nhân
EXEC Customer_Create
    @Name = N'Phạm Quốc Bảo',
    @CustomerType = N'Cá nhân',
    @PhoneNumber = '0977555444',
    @Email = 'phamquocbao@yahoo.com',
    @Address = N'10 Trần Phú, Hải Phòng',
    @CreatedBy = N'admin';
GO

-- 1️ Nhà cung cấp nguyên liệu thực phẩm
EXEC Supplier_Create
    @Name = N'Công ty TNHH Thực phẩm An Phát',
    @Email = 'contact@anphatfoods.vn',
    @PhoneNumber = '0901112233',
    @Address = N'120 Trần Hưng Đạo, Hà Nội',
    @Description = N'Chuyên cung cấp thực phẩm tươi sống cho các nhà hàng và siêu thị.',
    @CreatedBy = N'admin';

-- 2️ Nhà cung cấp thiết bị văn phòng
EXEC Supplier_Create
    @Name = N'Công ty Cổ phần Thiết bị Văn phòng Minh Tâm',
    @Email = 'sales@minhtamoffice.vn',
    @PhoneNumber = '0912333444',
    @Address = N'45 Lý Thường Kiệt, TP. Hồ Chí Minh',
    @Description = N'Cung cấp máy in, giấy và thiết bị văn phòng các loại.',
    @CreatedBy = N'manager';

-- 3️ Nhà cung cấp bao bì
EXEC Supplier_Create
    @Name = N'Công ty TNHH Bao Bì Trung Nam',
    @Email = 'info@baobitrungnam.vn',
    @PhoneNumber = '0988999777',
    @Address = N'88 Nguyễn Văn Linh, Đà Nẵng',
    @Description = N'Chuyên sản xuất bao bì nhựa, carton cho doanh nghiệp sản xuất hàng tiêu dùng.',
    @CreatedBy = N'staff01';

-- 4️ Nhà cung cấp thiết bị điện tử
EXEC Supplier_Create
    @Name = N'Công ty TNHH Điện tử Sao Việt',
    @Email = 'support@saoviettech.vn',
    @PhoneNumber = '0933666555',
    @Address = N'200 Điện Biên Phủ, Cần Thơ',
    @Description = N'Phân phối linh kiện và thiết bị điện tử chính hãng từ Nhật Bản và Hàn Quốc.',
    @CreatedBy = N'manager';

-- 5️ Nhà cung cấp hàng tiêu dùng
EXEC Supplier_Create
    @Name = N'Công ty TNHH TM-DV Hưng Thịnh',
    @Email = 'hungthinh@htgroup.vn',
    @PhoneNumber = '0977123123',
    @Address = N'15 Nguyễn Trãi, Hải Phòng',
    @Description = N'Cung cấp hàng tiêu dùng nhanh (FMCG) cho hệ thống bán lẻ toàn quốc.',
    @CreatedBy = N'admin';
GO

-- 1️ Sản phẩm từ Nhà cung cấp 1 - Thực phẩm An Phát
EXEC Product_Create
    @SupplierId = 1,
    @Name = N'Thịt bò Úc đông lạnh 1kg',
    @Quantity = 120,
    @Unit = N'kg',
    @CreatedBy = N'admin';

EXEC Product_Create
    @SupplierId = 1,
    @Name = N'Cá hồi phi lê 500g',
    @Quantity = 200,
    @Unit = N'gói',
    @CreatedBy = N'manager';

-- 2️ Sản phẩm từ Nhà cung cấp 2 - Minh Tâm Office
EXEC Product_Create
    @SupplierId = 2,
    @Name = N'Máy in laser HP 107w',
    @Quantity = 25,
    @Unit = N'chiếc',
    @CreatedBy = N'admin';

EXEC Product_Create
    @SupplierId = 2,
    @Name = N'Giấy A4 Double A 80gsm (500 tờ)',
    @Quantity = 500,
    @Unit = N'ream',
    @CreatedBy = N'manager';

-- 3️ Sản phẩm từ Nhà cung cấp 3 - Bao Bì Trung Nam
EXEC Product_Create
    @SupplierId = 3,
    @Name = N'Túi nhựa trong 30x40cm',
    @Quantity = 2000,
    @Unit = N'cái',
    @CreatedBy = N'staff01';

EXEC Product_Create
    @SupplierId = 3,
    @Name = N'Thùng carton 5 lớp 40x60x40',
    @Quantity = 500,
    @Unit = N'thùng',
    @CreatedBy = N'manager';

-- 4️ Sản phẩm từ Nhà cung cấp 4 - Sao Việt Electronics
EXEC Product_Create
    @SupplierId = 4,
    @Name = N'Chip vi xử lý Intel i5 Gen12',
    @Quantity = 40,
    @Unit = N'cái',
    @CreatedBy = N'manager';

EXEC Product_Create
    @SupplierId = 4,
    @Name = N'Màn hình LG 24 inch Full HD',
    @Quantity = 35,
    @Unit = N'cái',
    @CreatedBy = N'admin';

-- 5️ Sản phẩm từ Nhà cung cấp 5 - Hưng Thịnh FMCG
EXEC Product_Create
    @SupplierId = 5,
    @Name = N'Nước giặt Omo Matic 3.6L',
    @Quantity = 300,
    @Unit = N'chai',
    @CreatedBy = N'admin';

EXEC Product_Create
    @SupplierId = 5,
    @Name = N'Khăn giấy Pulppy 10 cuộn',
    @Quantity = 600,
    @Unit = N'bịch',
    @CreatedBy = N'staff01';
GO

-- 1️ Phiếu nhập hàng thực phẩm
EXEC InboundReceipt_Create
    @ReceiptDate = '2025-01-15',
    @EmployeeId = 1,
    @SupplierId = 1,
    @TotalPrice = 36000000, 
    @Note = N'Nhập thịt bò Úc và cá hồi phi lê từ An Phát',
    @CreatedBy = N'admin';

-- 2️ Phiếu nhập thiết bị văn phòng
EXEC InboundReceipt_Create
    @ReceiptDate = '2025-02-05',
    @EmployeeId = 2,
    @SupplierId = 2,
    @TotalPrice = 44500000, 
    @Note = N'Nhập giấy A4 và máy in từ Minh Tâm Office',
    @CreatedBy = N'manager';

-- 3️ Phiếu nhập bao bì
EXEC InboundReceipt_Create
    @ReceiptDate = '2025-03-10',
    @EmployeeId = 3,
    @SupplierId = 3,
    @TotalPrice = 3900000,
    @Note = N'Nhập thùng carton và túi nhựa từ Trung Nam',
    @CreatedBy = N'staff01';

-- 4️ Phiếu nhập linh kiện điện tử
EXEC InboundReceipt_Create
    @ReceiptDate = '2025-04-12',
    @EmployeeId = 2,
    @SupplierId = 4,
    @TotalPrice = 100000000,
    @Note = N'Nhập chip Intel và màn hình LG từ Sao Việt',
    @CreatedBy = N'manager';

-- 5️ Phiếu nhập hàng tiêu dùng
EXEC InboundReceipt_Create
    @ReceiptDate = '2025-05-25',
    @EmployeeId = 4,
    @SupplierId = 5,
    @TotalPrice = 15000000,
    @Note = N'Nhập nước giặt Omo và khăn giấy Pulppy từ Hưng Thịnh',
    @CreatedBy = N'admin';
GO

-- 1️ Chi tiết phiếu nhập hàng thực phẩm (An Phát - ReceiptId = 1)
EXEC InboundDetail_Create
    @InboundReceiptId = 1,
    @ProductId = 1,           -- Thịt bò Úc đông lạnh 1kg
    @Quantity = 50,
    @UnitPrice = 320000,
    @CreatedBy = N'admin';

EXEC InboundDetail_Create
    @InboundReceiptId = 1,
    @ProductId = 2,           -- Cá hồi phi lê 500g
    @Quantity = 80,
    @UnitPrice = 250000,
    @CreatedBy = N'admin';
GO

-- 2️ Chi tiết phiếu nhập thiết bị văn phòng (Minh Tâm Office - ReceiptId = 2)
EXEC InboundDetail_Create
    @InboundReceiptId = 2,
    @ProductId = 3,           -- Máy in laser HP 107w
    @Quantity = 10,
    @UnitPrice = 3500000,
    @CreatedBy = N'manager';

EXEC InboundDetail_Create
    @InboundReceiptId = 2,
    @ProductId = 4,           -- Giấy A4 Double A 80gsm
    @Quantity = 100,
    @UnitPrice = 95000,
    @CreatedBy = N'manager';
GO

-- 3 Chi tiết phiếu nhập bao bì (Bao Bì Trung Nam - ReceiptId = 3)
EXEC InboundDetail_Create
    @InboundReceiptId = 3,
    @ProductId = 5,           -- Túi nhựa trong 30x40cm
    @Quantity = 1000,
    @UnitPrice = 1500,
    @CreatedBy = N'staff01';

EXEC InboundDetail_Create
    @InboundReceiptId = 3,
    @ProductId = 6,           -- Thùng carton 5 lớp 40x60x40
    @Quantity = 200,
    @UnitPrice = 12000,
    @CreatedBy = N'manager';
GO

-- 4️ Chi tiết phiếu nhập linh kiện điện tử (Sao Việt - ReceiptId = 4)
EXEC InboundDetail_Create
    @InboundReceiptId = 4,
    @ProductId = 7,           -- Chip Intel i5 Gen12
    @Quantity = 15,
    @UnitPrice = 4800000,
    @CreatedBy = N'manager';

EXEC InboundDetail_Create
    @InboundReceiptId = 4,
    @ProductId = 8,           -- Màn hình LG 24 inch Full HD
    @Quantity = 10,
    @UnitPrice = 2800000,
    @CreatedBy = N'admin';
GO

-- 5️ Chi tiết phiếu nhập hàng tiêu dùng (Hưng Thịnh - ReceiptId = 5)
EXEC InboundDetail_Create
    @InboundReceiptId = 5,
    @ProductId = 9,           -- Nước giặt Omo Matic 3.6L
    @Quantity = 60,
    @UnitPrice = 160000,
    @CreatedBy = N'admin';

EXEC InboundDetail_Create
    @InboundReceiptId = 5,
    @ProductId = 10,          -- Khăn giấy Pulppy 10 cuộn
    @Quantity = 120,
    @UnitPrice = 45000,
    @CreatedBy = N'staff01';
GO

-- 1️ Phiếu xuất cho khách hàng cá nhân Nguyễn Văn Minh
EXEC OutboundReceipt_Create
    @ReceiptDate = '2025-06-01',
    @EmployeeId = 3,        -- Lê Văn C (Kinh doanh)
    @CustomerId = 1,        -- Nguyễn Văn Minh
    @TotalPrice = 4450000,
    @Status = N'Đã thanh toán',
    @Note = N'Xuất 10 kg thịt bò Úc và 5 gói cá hồi',
    @CreatedBy = N'manager';

-- 2️ Phiếu xuất cho khách hàng doanh nghiệp ABC
EXEC OutboundReceipt_Create
    @ReceiptDate = '2025-06-05',
    @EmployeeId = 1,        -- Nguyễn Văn A (Kế toán)
    @CustomerId = 2,        -- Công ty TNHH ABC
    @TotalPrice = 11750000,
    @Status = N'Đã thanh toán',
    @Note = N'Xuất 2 máy in và 50 ream giấy A4',
    @CreatedBy = N'admin';

-- 3️ Phiếu xuất cho khách hàng cá nhân Lê Thị Hồng
EXEC OutboundReceipt_Create
    @ReceiptDate = '2025-06-10',
    @EmployeeId = 3,        -- Lê Văn C
    @CustomerId = 3,        -- Lê Thị Hồng
    @TotalPrice = 390000,
    @Status = N'Đã thanh toán',
    @Note = N'Xuất 100 túi nhựa và 20 thùng carton',
    @CreatedBy = N'staff01';

-- 4️ Phiếu xuất cho khách hàng doanh nghiệp XYZ
EXEC OutboundReceipt_Create
    @ReceiptDate = '2025-06-15',
    @EmployeeId = 2,        -- Trần Thị B (IT Support)
    @CustomerId = 4,        -- Công ty Cổ phần XYZ
    @TotalPrice = 32400000,
    @Status = N'Đã thanh toán',
    @Note = N'Xuất 5 chip Intel và 3 màn hình LG',
    @CreatedBy = N'manager';

-- 5️ Phiếu xuất cho khách hàng cá nhân Phạm Quốc Bảo
EXEC OutboundReceipt_Create
    @ReceiptDate = '2025-06-20',
    @EmployeeId = 4,        -- Phạm Thị D (Marketing)
    @CustomerId = 5,        -- Phạm Quốc Bảo
    @TotalPrice = 7050000,
    @Status = N'Đã thanh toán',
    @Note = N'Xuất 30 chai nước giặt và 50 bịch khăn giấy Pulppy',
    @CreatedBy = N'admin';
GO

-- 1. Chi tiết phiếu xuất 1
EXEC OutboundDetail_Create
    @OutboundReceiptId = 1,
    @ProductId = 1,  -- Thịt bò Úc đông lạnh 1kg
    @Quantity = 10,
    @UnitPrice = 320000,
    @CreatedBy = N'manager';

EXEC OutboundDetail_Create
    @OutboundReceiptId = 1,
    @ProductId = 2,  -- Cá hồi phi lê 500g
    @Quantity = 5,
    @UnitPrice = 250000,
    @CreatedBy = N'manager';
GO

-- 2. Chi tiết phiếu xuất 2
EXEC OutboundDetail_Create
    @OutboundReceiptId = 2,
    @ProductId = 3,  -- Máy in laser HP 107w
    @Quantity = 2,
    @UnitPrice = 3500000,
    @CreatedBy = N'admin';

EXEC OutboundDetail_Create
    @OutboundReceiptId = 2,
    @ProductId = 4,  -- Giấy A4 Double A 80gsm
    @Quantity = 50,
    @UnitPrice = 95000,
    @CreatedBy = N'admin';
GO

-- 3. Chi tiết phiếu xuất 3
EXEC OutboundDetail_Create
    @OutboundReceiptId = 3,
    @ProductId = 5,  -- Túi nhựa trong 30x40cm
    @Quantity = 100,
    @UnitPrice = 1500,
    @CreatedBy = N'staff01';

EXEC OutboundDetail_Create
    @OutboundReceiptId = 3,
    @ProductId = 6,  -- Thùng carton 5 lớp 40x60x40
    @Quantity = 20,
    @UnitPrice = 12000,
    @CreatedBy = N'staff01';
GO

-- 4. Chi tiết phiếu xuất 4
EXEC OutboundDetail_Create
    @OutboundReceiptId = 4,
    @ProductId = 7,  -- Chip Intel i5 Gen12
    @Quantity = 5,
    @UnitPrice = 4800000,
    @CreatedBy = N'manager';

EXEC OutboundDetail_Create
    @OutboundReceiptId = 4,
    @ProductId = 8,  -- Màn hình LG 24 inch Full HD
    @Quantity = 3,
    @UnitPrice = 2800000,
    @CreatedBy = N'manager';
GO

-- 5. Chi tiết phiếu xuất 5
EXEC OutboundDetail_Create
    @OutboundReceiptId = 5,
    @ProductId = 9,  -- Nước giặt Omo Matic 3.6L
    @Quantity = 30,
    @UnitPrice = 160000,
    @CreatedBy = N'admin';

EXEC OutboundDetail_Create
    @OutboundReceiptId = 5,
    @ProductId = 10, -- Khăn giấy Pulppy 10 cuộn
    @Quantity = 50,
    @UnitPrice = 45000,
    @CreatedBy = N'admin';
GO