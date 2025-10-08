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