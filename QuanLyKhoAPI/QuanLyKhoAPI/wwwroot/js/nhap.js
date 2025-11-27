const RECEIPT_API = "/api/InboundReceipt";
const DETAIL_API = "/api/InboundDetail";

let tempDetails = [];
let originalDetailIds = [];
let editingIndex = -1;

$(document).ready(function () {
    loadReceipts();
    $('#receiptModal').modal({ closable: false, onDeny: () => true });

    $("#btnToggleFilter").click(() => $("#filterArea").slideToggle());
    $("#btnSearch").click(loadReceipts);
    $("#btnClearSearch").click(() => {
        $("#filterArea input").val("");
        loadReceipts();
    });

    $("#btnAdd").click(() => {
        resetForm();
        $("#modalHeader").text("Tạo phiếu nhập kho mới");
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        $("#receiptDate").val(now.toISOString().slice(0, 16));
        $('#receiptModal').modal('show');
    });

    $("#btnSaveModal").click(() => $("#receiptForm").submit());

    $("#receiptForm > .fields input[required]").on("blur", function () {
        const input = $(this);
        if (!input.val().trim()) {
            input.closest('.field').addClass('error');
        } else {
            input.closest('.field').removeClass('error');
        }
        checkGlobalInputError();
    });

    $("#receiptForm > .fields input").on("input", function () {
        $(this).closest('.field').removeClass('error');
        $("#globalError").hide();
    });

    $("#productEntryArea input").on("input", function () {
        const field = $(this).closest('.field');
        field.removeClass('error');
        field.find('.validation-msg').remove();
        $("#productError").hide();
    });

    $("#btnAddProductRow").click(function () {
        const elId = $("#prodId");
        const elQty = $("#prodQty");
        const elPrice = $("#prodPrice");

        const valId = elId.val().trim();
        const valQty = elQty.val().trim();
        const valPrice = elPrice.val().trim();

        let hasError = false;

        if (!valId) { elId.closest('.field').addClass('error'); hasError = true; }
        if (!valQty || parseFloat(valQty) <= 0) { elQty.closest('.field').addClass('error'); hasError = true; }
        if (!valPrice || parseFloat(valPrice) <= 0) { elPrice.closest('.field').addClass('error'); hasError = true; }

        if (hasError) {
            $("#productError").show();
            return;
        }

        $("#productError").hide();

        const pId = parseInt(valId);
        const pQty = parseInt(valQty); // Số lượng có thể là int
        const pPrice = parseInt(valPrice); // Đơn giá là int theo yêu cầu của bạn

        if (editingIndex === -1) {
            const existing = tempDetails.find(x => x.productId === pId);
            if (existing) {
                alert("Sản phẩm này đã có trong danh sách");
                elId.closest('.field').addClass('error');
                return;
            }
        } else {
            const duplicate = tempDetails.find((x, idx) => x.productId === pId && idx !== editingIndex);
            if (duplicate) {
                alert("Sản phẩm trùng với dòng khác");
                elId.closest('.field').addClass('error');
                return;
            }
        }

        const rowData = {
            id: editingIndex === -1 ? 0 : tempDetails[editingIndex].id,
            productId: pId,
            quantity: pQty,
            unitPrice: pPrice,
            total: pQty * pPrice
        };

        if (editingIndex === -1) {
            tempDetails.push(rowData);
        } else {
            tempDetails[editingIndex] = rowData;
            editingIndex = -1;
            $("#btnAddProductRow").html('<i class="plus icon"></i> Thêm');
            $("#btnAddProductRow").removeClass("orange").addClass("blue");
            $("#prodId").prop("disabled", false);
            $("#prodId").closest('.field').removeClass('disabled');
        }

        $("#prodId, #prodQty, #prodPrice").val("");
        $("#prodId").focus();
        $("#productEntryArea .field").removeClass("error");
        renderDetailTable();

        if ($("#globalErrorContent").text().includes("sản phẩm")) {
            $("#globalError").hide();
        }
    });
});

$("#receiptForm").on("submit", async function (e) {
    e.preventDefault();

    let hasEmpty = false;
    $("#receiptForm > .fields input[required]").each(function () {
        if (!$(this).val().trim()) {
            $(this).closest('.field').addClass('error');
            hasEmpty = true;
        }
    });

    if (hasEmpty) {
        $("#globalErrorContent").text("Không để trống ô dữ liệu bắt buộc");
        $("#globalError").show();
        scrollToFirstError();
        return;
    }

    if (tempDetails.length === 0) {
        $("#globalErrorContent").text("Phiếu nhập phải có ít nhất 1 sản phẩm");
        $("#globalError").show();
        scrollToFirstError();
        return;
    }

    $("#globalError").hide();

    const id = $("#hiddenId").val();
    const isUpdate = !!id;

    // --- TÍNH TỔNG TIỀN (TotalPrice) ---
    const calculatedTotal = tempDetails.reduce((sum, item) => sum + item.total, 0);

    const masterData = {
        ReceiptDate: $("#receiptDate").val(),
        EmployeeId: $("#employeeId").val(),
        SupplierId: $("#supplierId").val(),
        Note: $("#note").val(),
        TotalPrice: calculatedTotal, // Gửi lên API (khớp với tham số int? TotalPrice)
        CreatedBy: "Admin",
        LastModifiedBy: "Admin"
    };

    try {
        let currentReceiptId = id;

        if (isUpdate) {
            const updateUrl = `${RECEIPT_API}/${id}?${$.param(masterData)}`;
            const resUpdate = await $.ajax({ url: updateUrl, type: "PUT" });
            if (!resUpdate.isSuccess) throw new Error(resUpdate.errorMessage);
        } else {
            const createUrl = `${RECEIPT_API}?${$.param(masterData)}`;
            const resCreate = await $.ajax({ url: createUrl, type: "POST" });
            if (!resCreate.isSuccess) throw new Error(resCreate.errorMessage);
            currentReceiptId = resCreate.data.id || resCreate.data.Id;
        }

        const itemsToAdd = tempDetails.filter(x => x.id === 0);
        const itemsToUpdate = tempDetails.filter(x => x.id > 0);
        const currentIds = tempDetails.map(x => x.id);
        const itemsToDeleteIds = originalDetailIds.filter(oldId => !currentIds.includes(oldId));

        for (const item of itemsToAdd) {
            const data = { InboundReceiptId: currentReceiptId, ProductId: item.productId, Quantity: item.quantity, UnitPrice: item.unitPrice, CreatedBy: "Admin" };
            await $.ajax({ url: `${DETAIL_API}?${$.param(data)}`, type: "POST" });
        }
        for (const item of itemsToUpdate) {
            const data = { InboundReceiptId: currentReceiptId, ProductId: item.productId, Quantity: item.quantity, UnitPrice: item.unitPrice, LastModifiedBy: "Admin" };
            await $.ajax({ url: `${DETAIL_API}/${item.id}?${$.param(data)}`, type: "PUT" });
        }
        for (const delId of itemsToDeleteIds) {
            await $.ajax({ url: `${DETAIL_API}/${delId}?lastModifiedBy=Admin`, type: "DELETE" });
        }

        alert(isUpdate ? "Cập nhật thành công!" : "Tạo mới thành công!");
        $('#receiptModal').modal('hide');
        loadReceipts();

    } catch (err) {
        console.error(err);
        let msg = err.responseJSON?.errorMessage || err.message || "Lỗi hệ thống";
        alert("Lỗi: " + msg);
    }
});

function scrollToFirstError() {
    const firstErrorField = $("#receiptForm .field.error").first();
    const modalScrollContainer = $('.ui.modal.active.scrolling');
    const scrollTarget = modalScrollContainer.length > 0 ? modalScrollContainer : $('html, body');

    if (firstErrorField.length > 0) {
        scrollTarget.animate({
            scrollTop: firstErrorField.offset().top + scrollTarget.scrollTop() - 150
        }, 500);
        firstErrorField.find('input').focus();
    } else if ($("#globalError").is(":visible")) {
        scrollTarget.animate({
            scrollTop: $("#globalError").offset().top + scrollTarget.scrollTop() - 150
        }, 500);
    }
}

function checkGlobalInputError() {
    let hasEmpty = false;
    $("#receiptForm > .fields input[required]").each(function () {
        if (!$(this).val().trim()) hasEmpty = true;
    });

    if (hasEmpty) {
        $("#globalErrorContent").text("Không để trống ô dữ liệu bắt buộc");
        $("#globalError").show();
    } else {
        $("#globalError").hide();
    }
}

function showInlineError(inputElement, msg) {
    const fieldDiv = inputElement.closest('.field');
    fieldDiv.find('.validation-msg').remove();
    fieldDiv.addClass('error');
    fieldDiv.append(`<div class="validation-msg">${msg}</div>`);
}

window.editTempDetail = function (index) {
    const item = tempDetails[index];
    $("#prodId").val(item.productId);
    $("#prodQty").val(item.quantity);
    $("#prodPrice").val(item.unitPrice);

    if (item.id > 0) {
        $("#prodId").prop("disabled", true);
        $("#prodId").closest('.field').addClass('disabled');
    } else {
        $("#prodId").prop("disabled", false);
        $("#prodId").closest('.field').removeClass('disabled');
    }

    editingIndex = index;
    $("#btnAddProductRow").html('<i class="save icon"></i> Cập nhật dòng');
    $("#btnAddProductRow").removeClass("blue").addClass("orange");
    $("#prodQty").focus();
}

window.removeTempDetail = function (index) {
    if (index === editingIndex) {
        editingIndex = -1;
        $("#prodId, #prodQty, #prodPrice").val("");
        $("#btnAddProductRow").html('<i class="plus icon"></i> Thêm');
        $("#btnAddProductRow").removeClass("orange").addClass("blue");
        $("#prodId").prop("disabled", false);
        $("#prodId").closest('.field').removeClass('disabled');
    } else if (index < editingIndex) {
        editingIndex--;
    }
    tempDetails.splice(index, 1);
    renderDetailTable();
}

$(document).on("click", ".editBtn", async function () {
    const row = $(this).closest("tr");
    const receiptId = $(this).data("id");
    try {
        resetForm();
        $("#hiddenId").val(receiptId);
        $("#receiptId").val(receiptId);
        $("#modalHeader").text("Cập nhật phiếu nhập kho");

        const dateText = row.find("td:eq(1)").text();
        const dateParts = dateText.split('/');
        if (dateParts.length === 3) {
            const dateObj = new Date(`${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
            if (!isNaN(dateObj)) {
                dateObj.setMinutes(dateObj.getMinutes() - dateObj.getTimezoneOffset());
                $("#receiptDate").val(dateObj.toISOString().slice(0, 16));
            }
        }
        $("#employeeId").val(row.find("td:eq(2)").text());
        $("#supplierId").val(row.find("td:eq(3)").text() === '-' ? '' : row.find("td:eq(3)").text());

        // Cột ghi chú bây giờ là cột thứ 6 (index 5) vì đã thêm cột Tổng tiền
        // Cột Tổng tiền là cột thứ 5 (index 4)
        $("#note").val(row.find("td:eq(5)").text());

        const detailRes = await $.ajax({ url: DETAIL_API, type: "GET", data: { InboundReceiptId: receiptId } });
        if (detailRes.isSuccess && detailRes.data) {
            tempDetails = detailRes.data.map(d => ({
                id: d.id || d.Id,
                productId: d.productId || d.ProductId,
                quantity: d.quantity || d.Quantity,
                unitPrice: d.unitPrice || d.UnitPrice,
                total: (d.quantity || d.Quantity) * (d.unitPrice || d.UnitPrice)
            }));
            originalDetailIds = tempDetails.map(x => x.id);
            renderDetailTable();
        }
        $('#receiptModal').modal('show');
    } catch (err) { console.error(err); alert("Lỗi tải chi tiết."); }
});

function loadReceipts() {
    const params = {
        Id: $("#searchId").val(),
        SupplierId: $("#searchSupplier").val(),
        ReceiptDateStart: $("#searchDateStart").val(),
        ReceiptDateEnd: $("#searchDateEnd").val()
    };
    $.ajax({
        url: RECEIPT_API, type: "GET", data: params,
        success: function (res) {
            const tbody = $("#receiptTable tbody");
            tbody.empty();
            if (res.isSuccess && res.data) {
                res.data.forEach(r => {
                    const dateStr = r.receiptDate ? new Date(r.receiptDate).toLocaleDateString('vi-VN') : "";
                    // Hiển thị Tổng tiền (TotalPrice)
                    const totalMoney = (r.totalPrice || 0).toLocaleString('vi-VN') + " đ";

                    const tr = `<tr>
                        <td>${r.id || r.Id}</td>
                        <td>${dateStr}</td>
                        <td>${r.employeeId || r.EmployeeId}</td>
                        <td>${r.supplierId || r.SupplierId || '-'}</td>
                        <td style="font-weight:bold; color:#2185d0">${totalMoney}</td>
                        <td>${r.note || r.Note || ''}</td>
                        <td>
                            <button class="ui blue mini button editBtn" data-id="${r.id || r.Id}">Sửa</button>
                            <button class="ui red mini button deleteBtn" data-id="${r.id || r.Id}">Xóa</button>
                        </td>
                    </tr>`;
                    tbody.append(tr);
                });
            }
        }
    });
}

function renderDetailTable() {
    const tbody = $("#detailTable tbody");
    tbody.empty();
    let total = 0;
    tempDetails.forEach((item, index) => {
        total += item.total;
        tbody.append(`<tr>
            <td>${item.productId}</td>
            <td>${item.quantity}</td>
            <td>${item.unitPrice.toLocaleString('vi-VN')}</td>
            <td>${item.total.toLocaleString('vi-VN')}</td>
            <td>
                <button type="button" class="ui blue mini icon button" onclick="editTempDetail(${index})" title="Sửa"><i class="pencil alternate icon"></i></button>
                <button type="button" class="ui red mini icon button" onclick="removeTempDetail(${index})" title="Xóa"><i class="trash icon"></i></button>
            </td>
        </tr>`);
    });
    $("#totalAmount").text(total.toLocaleString('vi-VN') + " đ");
}

function resetForm() {
    $("#receiptForm")[0].reset();
    $("#hiddenId").val("");
    tempDetails = [];
    originalDetailIds = [];
    editingIndex = -1;
    $("#btnAddProductRow").html('<i class="plus icon"></i> Thêm');
    $("#btnAddProductRow").removeClass("orange").addClass("blue");
    $("#prodId").prop("disabled", false);
    $("#prodId").closest('.field').removeClass('disabled');
    renderDetailTable();
    $(".field.error").removeClass("error");
    $(".validation-msg").remove();
    $("#globalError").hide();
    $("#productError").hide();
}

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Xóa phiếu này?")) return;
    const id = $(this).data("id");
    $.ajax({
        url: `${RECEIPT_API}/${id}?lastModifiedBy=Admin`, type: "DELETE",
        success: function (res) { if (res.isSuccess) { alert("Đã xóa"); loadReceipts(); } else { alert("Lỗi: " + res.errorMessage); } }
    });
});