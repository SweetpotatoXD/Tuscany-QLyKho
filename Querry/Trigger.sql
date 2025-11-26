-- Thay đổi khi nhập kho
CREATE OR ALTER TRIGGER TR_InboundDetail_AfterInsert
ON InboundDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tăng tồn kho (Quantity) của sản phẩm
    UPDATE P
    SET P.Quantity = P.Quantity + I.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    WHERE P.IsDeleted = 0; -- Chỉ cập nhật sản phẩm chưa bị xóa mềm
END
GO

CREATE OR ALTER TRIGGER TR_InboundDetail_AfterUpdate
ON InboundDetail
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- -------------------------------------------------------------------
    -- PHẦN 1: Xử lý thay đổi Số lượng (Quantity)
    -- -------------------------------------------------------------------
    -- Cập nhật tồn kho theo chênh lệch (Mới - Cũ)
    UPDATE P
    SET P.Quantity = P.Quantity + (I.Quantity - D.Quantity) 
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE P.IsDeleted = 0 
      AND I.Quantity <> D.Quantity; -- Chỉ chạy khi Quantity thay đổi

    -- -------------------------------------------------------------------
    -- PHẦN 2: Xử lý thay đổi Trạng thái Xóa Mềm (IsDeleted)
    -- -------------------------------------------------------------------

    -- 2.1. Xử lý khi Xóa Mềm (0 -> 1): GIẢM tồn kho
    UPDATE P
    SET P.Quantity = P.Quantity - D.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE I.IsDeleted = 1 
      AND D.IsDeleted = 0 
      AND I.Quantity = D.Quantity; -- Không thay đổi số lượng, chỉ thay đổi IsDeleted

    -- 2.2. Xử lý khi Khôi phục (1 -> 0): TĂNG tồn kho
    UPDATE P
    SET P.Quantity = P.Quantity + I.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE I.IsDeleted = 0 
      AND D.IsDeleted = 1 
      AND I.Quantity = D.Quantity; -- Không thay đổi số lượng, chỉ thay đổi IsDeleted
END
GO

CREATE OR ALTER TRIGGER TR_InboundDetail_AfterDelete
ON InboundDetail
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Giảm tồn kho CHỈ KHI chi tiết bị xóa chưa bị đánh dấu IsDeleted = 1
    UPDATE P
    SET P.Quantity = P.Quantity - D.Quantity 
    FROM Product P
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE P.IsDeleted = 0 AND D.IsDeleted = 0; -- D.IsDeleted = 0: đảm bảo chi tiết bị xóa là bản ghi đang hoạt động
END
GO

-- Thay đổi khi xuất kho
CREATE OR ALTER TRIGGER TR_OutboundDetail_AfterInsert
ON OutboundDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Bước 1: Giảm tồn kho (Quantity) của sản phẩm
    UPDATE P
    SET P.Quantity = P.Quantity - I.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    WHERE P.IsDeleted = 0; 
    
    -- Bước 2: Kiểm tra tồn kho âm (QUAN TRỌNG)
    IF EXISTS (
        SELECT 1 
        FROM Product 
        -- Kiểm tra những sản phẩm vừa bị cập nhật mà bị âm tồn kho
        WHERE Quantity < 0 AND Id IN (SELECT ProductId FROM inserted)
    )
    BEGIN
        -- Báo lỗi và hủy giao dịch
        RAISERROR (N'Lỗi: Số lượng tồn kho không đủ để xuất hàng.', 16, 1);
        ROLLBACK TRANSACTION; 
        RETURN;
    END
END
GO

CREATE OR ALTER TRIGGER TR_OutboundDetail_AfterUpdate
ON OutboundDetail
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- -------------------------------------------------------------------
    -- PHẦN 1: Xử lý thay đổi Số lượng (Quantity)
    -- -------------------------------------------------------------------
    
    -- Cập nhật tồn kho theo chênh lệch (Cũ - Mới)
    UPDATE P
    SET P.Quantity = P.Quantity + (D.Quantity - I.Quantity) -- (Cũ - Mới): Nếu mới < cũ -> Tăng tồn kho
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE P.IsDeleted = 0 
      AND I.Quantity <> D.Quantity; -- Chỉ chạy khi Quantity thay đổi

    -- -------------------------------------------------------------------
    -- PHẦN 2: Xử lý thay đổi Trạng thái Xóa Mềm (IsDeleted)
    -- -------------------------------------------------------------------

    -- 2.1. Xử lý khi Xóa Mềm (0 -> 1): TĂNG tồn kho (Hoàn lại hàng)
    UPDATE P
    SET P.Quantity = P.Quantity + D.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE I.IsDeleted = 1 
      AND D.IsDeleted = 0 
      AND I.Quantity = D.Quantity; -- Chỉ thay đổi IsDeleted

    -- 2.2. Xử lý khi Khôi phục (1 -> 0): GIẢM tồn kho (Xuất hàng lại)
    UPDATE P
    SET P.Quantity = P.Quantity - I.Quantity
    FROM Product P
    INNER JOIN inserted I ON P.Id = I.ProductId
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE I.IsDeleted = 0 
      AND D.IsDeleted = 1 
      AND I.Quantity = D.Quantity; -- Chỉ thay đổi IsDeleted

    -- -------------------------------------------------------------------
    -- PHẦN 3: Kiểm tra Tồn kho Âm sau khi Cập nhật (áp dụng cho toàn bộ khối)
    -- -------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM Product WHERE Quantity < 0 AND Id IN (SELECT ProductId FROM inserted))
    BEGIN
        RAISERROR (N'Lỗi: Điều chỉnh hoặc Khôi phục xuất kho làm tồn kho bị âm.', 16, 1);
        ROLLBACK TRANSACTION; 
        RETURN;
    END
END
GO

CREATE OR ALTER TRIGGER TR_OutboundDetail_AfterDelete
ON OutboundDetail
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tăng tồn kho CHỈ KHI chi tiết bị xóa chưa bị đánh dấu IsDeleted = 1 (Xóa Thực bản ghi hoạt động)
    UPDATE P
    SET P.Quantity = P.Quantity + D.Quantity 
    FROM Product P
    INNER JOIN deleted D ON P.Id = D.ProductId
    WHERE P.IsDeleted = 0 AND D.IsDeleted = 0; -- D.IsDeleted = 0: đảm bảo chi tiết bị xóa là bản ghi đang hoạt động
END
GO