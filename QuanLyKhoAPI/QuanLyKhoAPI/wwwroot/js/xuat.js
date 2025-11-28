const RECEIPT_API = "/api/OutboundReceipt";
const DETAIL_API = "/api/OutboundDetail";
const EMPLOYEE_API = "/api/Employee/Employee";
const CUSTOMER_API = "/api/Customer";
const PRODUCT_API = "/api/Product";
const SUPPLIER_API = "/api/Supplier";

let tempDetails = [];
let originalDetailIds = [];
let editingIndex = -1;

let employeeMap = {};
let customerMap = {};
let productMap = {};
let allProducts = [];

$(document).ready(async function () {
    await loadMetadata();
    loadReceipts();

    $('#receiptModal').modal({ closable: false, onDeny: () => true });

    // [Click xóa lỗi]
    $("#customerId").parent().on('click', function () {
        clearError($(this).closest('.field'));
    });
    $("#prodId").parent().on('click', function () {
        clearError($(this).closest('.field'));
        $("#productError").hide();
    });

    // [LOGIC MỚI] Sự kiện chọn NCC -> Lọc sản phẩm
    $("#filterSupplier").change(function () {
        const supId = $(this).val();
        filterProductDropdown(supId);
    });

    // Bộ lọc trang chủ
    $("#btnToggleFilter").click(() => $("#filterArea").slideToggle());
    $("#btnSearch").click(loadReceipts);
    $("#btnClearSearch").click(() => {
        $("#filterArea input").val("");
        $("#searchEmployee").val("");
        $("#searchCustomer").val("");
        $("#sortTotalPrice").val("");
        $("#searchNote").val("");
        loadReceipts();
    });

    // Nút Tạo mới
    $("#btnAdd").click(() => {
        resetForm();
        $("#modalHeader").text("Tạo phiếu xuất kho mới");
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        $("#receiptDate").val(now.toISOString().slice(0, 16));
        $('#receiptModal').modal('show');
    });

    // Nút Lưu Modal
    $("#btnSaveModal").click(() => $("#receiptForm").submit());

    // Validation
    $("#receiptForm > .fields input[required], #receiptForm > .fields select[required]").on("blur change", function () {
        validateField($(this));
        checkGlobalInputError();
    });
    $("#receiptForm > .fields input, #receiptForm > .fields select").on("input change", function () {
        $(this).closest('.field').removeClass('error');
        $("#globalError").hide();
    });
    $("#productEntryArea input, #productEntryArea select").on("input change", function () {
        clearError($(this).closest('.field'));
        $("#productError").hide();
    });

    // Nút Thêm/Lưu dòng sản phẩm
    $("#btnAddProductRow").click(function () {
        const elId = $("#prodId");
        const elQty = $("#prodQty");
        const elPrice = $("#prodPrice");

        const valId = elId.val();
        const valQty = elQty.val().trim();
        const valPrice = elPrice.val().trim();

        // Reset lỗi vùng nhập liệu
        $("#productEntryArea .field").removeClass('error');
        $("#productEntryArea .validation-msg").remove();
        $("#productError").hide();

        let hasEmpty = false;
        if (!valId) { elId.closest('.field').addClass('error'); hasEmpty = true; }
        if (!valQty) { elQty.closest('.field').addClass('error'); hasEmpty = true; }
        if (!valPrice) { elPrice.closest('.field').addClass('error'); hasEmpty = true; }

        if (hasEmpty) {
            $("#productError").show();
            return;
        }

        let hasLogicError = false;
        const pId = parseInt(valId);
        const pQty = parseFloat(valQty);
        const pPrice = parseFloat(valPrice);

        if (pQty <= 0) { showInlineError(elQty, "Số lượng phải lớn hơn 0"); hasLogicError = true; }
        if (pPrice < 0) { showInlineError(elPrice, "Đơn giá không được âm"); hasLogicError = true; }

        // Check trùng (chỉ khi thêm mới)
        if (editingIndex === -1) {
            const existing = tempDetails.find(x => x.productId === pId);
            if (existing) {
                showInlineError(elId.closest('.field'), "Sản phẩm này đã có trong danh sách");
                hasLogicError = true;
            }
        }

        if (hasLogicError) return;

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
        }

        exitEditMode();
        renderDetailTable();

        // Không khóa NCC/Khách hàng ở đây (theo yêu cầu mới)
    });

    $("#btnCancelEdit").click(function () {
        exitEditMode();
    });

    setupDateConstraints("#searchDateStart", "#searchDateEnd");
});

// --- SUBMIT FORM ---
$("#receiptForm").on("submit", async function (e) {
    e.preventDefault();

    let hasEmpty = false;
    $("#receiptForm > .fields input[required], #receiptForm > .fields select[required]").each(function () {
        if (!$(this).val() || !$(this).val().toString().trim()) {
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
        $("#globalErrorContent").text("Phiếu xuất phải có ít nhất 1 sản phẩm");
        $("#globalError").show();
        scrollToFirstError();
        return;
    }

    $("#globalError").hide();

    const id = $("#hiddenId").val();
    const isUpdate = !!id;
    const calculatedTotal = tempDetails.reduce((sum, item) => sum + item.total, 0);

    const masterData = {
        ReceiptDate: $("#receiptDate").val(),
        EmployeeId: $("#employeeId").val(),
        CustomerId: $("#customerId").val(),
        Status: $("#status").val(),
        Note: $("#note").val(),
        TotalPrice: calculatedTotal,
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

        // Xử lý chi tiết (Thêm/Sửa/Xóa)
        const currentIds = tempDetails.map(x => x.id);
        const itemsToDeleteIds = originalDetailIds.filter(oldId => !currentIds.includes(oldId));

        // Thêm mới
        for (const item of tempDetails.filter(x => x.id === 0)) {
            const data = { OutboundReceiptId: currentReceiptId, ProductId: item.productId, Quantity: item.quantity, UnitPrice: item.unitPrice, CreatedBy: "Admin" };
            await $.ajax({ url: `${DETAIL_API}?${$.param(data)}`, type: "POST" });
        }
        // Cập nhật
        for (const item of tempDetails.filter(x => x.id > 0)) {
            const data = { OutboundReceiptId: currentReceiptId, ProductId: item.productId, Quantity: item.quantity, UnitPrice: item.unitPrice, LastModifiedBy: "Admin" };
            await $.ajax({ url: `${DETAIL_API}/${item.id}?${$.param(data)}`, type: "PUT" });
        }
        // Xóa
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

// --- LOAD DATA ---
async function loadMetadata() {
    try {
        const [empRes, cusRes, prodRes, supRes] = await Promise.all([
            $.ajax({ url: EMPLOYEE_API, type: "GET" }),
            $.ajax({ url: CUSTOMER_API, type: "GET" }),
            $.ajax({ url: PRODUCT_API, type: "GET" }),
            $.ajax({ url: SUPPLIER_API, type: "GET" })
        ]);

        fillDropdown($("#employeeId"), empRes.data, $("#searchEmployee"));
        fillDropdown($("#customerId"), cusRes.data, $("#searchCustomer"));

        // Fill dropdown lọc NCC
        const filterSupSelect = $("#filterSupplier");
        filterSupSelect.empty().append('<option value="">-- Tất cả --</option>');
        if (supRes.isSuccess && supRes.data) {
            supRes.data.forEach(s => {
                filterSupSelect.append(`<option value="${s.id || s.Id}">${s.name || s.Name}</option>`);
            });
        }

        // Fill dropdown sản phẩm gốc (chưa lọc)
        const prodSelect = $("#prodId");
        prodSelect.empty().append('<option value="">-- Chọn sản phẩm --</option>');
        if (prodRes.isSuccess && prodRes.data) {
            allProducts = prodRes.data;
            prodRes.data.forEach(p => {
                const id = p.id || p.Id;
                const name = p.name || p.Name;
                productMap[id] = name;
                prodSelect.append(`<option value="${id}">${name}</option>`);
            });
        }

        // Init UI Semantic
        $('.ui.dropdown').dropdown();

    } catch (e) { console.error("Lỗi tải danh mục:", e); }
}

function fillDropdown(select, data, searchSelect) {
    select.empty().append(`<option value="">-- Chọn --</option>`);
    if (searchSelect) searchSelect.empty().append(`<option value="">-- Tất cả --</option>`);

    if (data) {
        data.forEach(item => {
            const id = item.id || item.Id;
            const name = item.name || item.Name;

            select.append(`<option value="${id}">${name}</option>`);
            if (searchSelect) searchSelect.append(`<option value="${id}">${name}</option>`);

            if (select.attr('id') === 'employeeId') employeeMap[id] = name;
            if (select.attr('id') === 'customerId') customerMap[id] = name;
        });
    }
}

// Lọc dropdown sản phẩm theo NCC
function filterProductDropdown(supplierId) {
    const prodSelect = $("#prodId");
    prodSelect.empty().append('<option value="">-- Chọn sản phẩm --</option>');

    let filtered = allProducts;
    if (supplierId) {
        filtered = allProducts.filter(p => {
            const pSupId = p.supplierId || p.SupplierId;
            return pSupId == supplierId;
        });
    }

    filtered.forEach(p => {
        const id = p.id || p.Id;
        const name = p.name || p.Name;
        prodSelect.append(`<option value="${id}">${name}</option>`);
    });

    // Sau khi lọc xong, reset giá trị đang chọn về rỗng
    prodSelect.dropdown('clear');
}

// --- LOGIC GIAO DIỆN & VALIDATION ---

function scrollToFirstError() {
    const firstErrorField = $("#receiptForm .field.error").first();
    const modalScrollContainer = $('.ui.modal.active.scrolling');
    const scrollTarget = modalScrollContainer.length > 0 ? modalScrollContainer : $('html, body');

    if (firstErrorField.length > 0) {
        scrollTarget.animate({ scrollTop: firstErrorField.offset().top + scrollTarget.scrollTop() - 150 }, 500);
        firstErrorField.find('input, select').first().focus();
    } else if ($("#globalError").is(":visible")) {
        scrollTarget.animate({ scrollTop: $("#globalError").offset().top + scrollTarget.scrollTop() - 150 }, 500);
    }
}

function checkGlobalInputError() {
    let hasEmpty = false;
    $("#receiptForm > .fields input[required], #receiptForm > .fields select[required]").each(function () {
        if (!$(this).val() || !$(this).val().trim()) hasEmpty = true;
    });
    if (hasEmpty) { $("#globalErrorContent").text("Không để trống ô dữ liệu bắt buộc"); $("#globalError").show(); } else { $("#globalError").hide(); }
}

function validateField(input) {
    if (!input.val() || !input.val().trim()) { input.closest('.field').addClass('error'); }
    else { input.closest('.field').removeClass('error'); }
}

function showInlineError(inputElement, msg) {
    const fieldDiv = inputElement.closest('.field');
    fieldDiv.find('.validation-msg').remove();
    fieldDiv.addClass('error');
    fieldDiv.append(`<div class="validation-msg">${msg}</div>`);
}

function clearError(field) {
    if (field.hasClass('error')) {
        field.removeClass('error');
        field.find('.validation-msg').remove();
    }
}

// Thoát chế độ sửa chi tiết
function exitEditMode() {
    editingIndex = -1;

    $("#prodId").dropdown('clear');
    $("#prodQty").val("");
    $("#prodPrice").val("");

    // Mở khóa dropdown sản phẩm & NCC
    $("#prodId").parent().removeClass('disabled');
    $("#filterSupplier").parent().removeClass('disabled'); // Mở khóa

    $("#btnCancelEdit").hide();
    $("#btnAddProductRow").html('<i class="plus icon"></i> Thêm');
    $("#btnAddProductRow").removeClass("orange").addClass("blue");

    $("#productEntryArea .field").removeClass('error');
    $("#productEntryArea .validation-msg").remove();
    $("#productError").hide();
}

// Vào chế độ sửa chi tiết
window.editTempDetail = function (index) {
    const item = tempDetails[index];

    // Tìm NCC của sản phẩm để điền vào ô lọc (giúp dropdown hiển thị đúng tên SP)
    const prodInfo = allProducts.find(p => (p.id || p.Id) == item.productId);
    if (prodInfo) {
        const supId = prodInfo.supplierId || prodInfo.SupplierId;
        $("#filterSupplier").dropdown('set selected', supId);
        filterProductDropdown(supId);
    } else {
        $("#filterSupplier").dropdown('clear');
        filterProductDropdown("");
    }

    $("#prodId").dropdown('set selected', item.productId);
    $("#prodQty").val(item.quantity);
    $("#prodPrice").val(item.unitPrice);

    // Khóa dropdown sản phẩm & NCC khi đang sửa chi tiết
    $("#prodId").parent().addClass('disabled');
    $("#filterSupplier").parent().addClass('disabled');

    editingIndex = index;

    $("#btnCancelEdit").show();
    $("#btnAddProductRow").html('<i class="save icon"></i> Lưu');
    $("#btnAddProductRow").removeClass("blue").addClass("orange");

    $("#prodQty").focus();
}

window.removeTempDetail = function (index) {
    if (index === editingIndex) {
        exitEditMode();
    } else if (index < editingIndex) {
        editingIndex--;
    }
    tempDetails.splice(index, 1);
    renderDetailTable();
}

// --- CLICK NÚT SỬA PHIẾU ---
$(document).on("click", ".editBtn", async function () {
    const row = $(this).closest("tr");
    const receiptId = $(this).data("id");
    try {
        resetForm();
        $("#hiddenId").val(receiptId);
        $("#receiptId").val(receiptId);
        $("#modalHeader").text("Cập nhật phiếu xuất kho");

        const dateText = row.find("td:eq(1)").text();
        const dateParts = dateText.split('/');
        if (dateParts.length === 3) {
            const dateObj = new Date(`${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
            if (!isNaN(dateObj)) {
                dateObj.setMinutes(dateObj.getMinutes() - dateObj.getTimezoneOffset());
                $("#receiptDate").val(dateObj.toISOString().slice(0, 16));
            }
        }

        const receiptRes = await $.ajax({ url: RECEIPT_API, type: "GET", data: { Id: receiptId } });
        if (receiptRes.isSuccess && receiptRes.data.length > 0) {
            const r = receiptRes.data[0];
            $("#employeeId").dropdown('set selected', r.employeeId || r.EmployeeId);
            $("#customerId").dropdown('set selected', r.customerId || r.CustomerId);
            $("#status").dropdown('set selected', r.status || r.Status);
            $("#note").val(r.note || r.Note);
        }

        const detailRes = await $.ajax({ url: DETAIL_API, type: "GET", data: { OutboundReceiptId: receiptId } });
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

            // Tự động điền NCC của SP đầu tiên vào ô lọc cho tiện, NHƯNG KHÔNG KHÓA
            if (tempDetails.length > 0) {
                const firstProdId = tempDetails[0].productId;
                const prodInfo = allProducts.find(p => (p.id || p.Id) == firstProdId);
                if (prodInfo) {
                    const supId = prodInfo.supplierId || prodInfo.SupplierId;
                    $("#filterSupplier").dropdown('set selected', supId);
                    filterProductDropdown(supId);
                }
            }
        }
        $('#receiptModal').modal('show');
    } catch (err) { console.error(err); alert("Lỗi tải chi tiết."); }
});

function loadReceipts() {
    const params = {
        Id: $("#searchId").val(),
        EmployeeId: $("#searchEmployee").val(),
        CustomerId: $("#searchCustomer").val(),
        ReceiptDateStart: $("#searchDateStart").val(),
        ReceiptDateEnd: $("#searchDateEnd").val(),
        Note: $("#searchNote").val()
    };

    const sortPrice = $("#sortTotalPrice").val();

    $.ajax({
        url: RECEIPT_API, type: "GET", data: params,
        success: function (res) {
            const tbody = $("#receiptTable tbody");
            tbody.empty();

            if (res.isSuccess && res.data) {
                let filtered = res.data;

                if (sortPrice) {
                    filtered.sort((a, b) => {
                        const priceA = a.totalPrice || a.TotalPrice || 0;
                        const priceB = b.totalPrice || b.TotalPrice || 0;
                        return sortPrice === 'asc' ? priceA - priceB : priceB - priceA;
                    });
                } else {
                    filtered.sort((a, b) => {
                        const idA = a.id || a.Id;
                        const idB = b.id || b.Id;
                        return idA - idB;
                    });
                }

                filtered.forEach(r => {
                    const dateStr = r.receiptDate ? new Date(r.receiptDate).toLocaleDateString('vi-VN') : "";
                    const totalMoney = (r.totalPrice || 0).toLocaleString('vi-VN') + " đ";
                    const empName = employeeMap[r.employeeId || r.EmployeeId] || "---";
                    const cusName = customerMap[r.customerId || r.CustomerId] || "---";

                    let statusColor = "";
                    const statusText = r.status || r.Status || "";
                    if (statusText === "Đã thanh toán") statusColor = "color:green; font-weight:bold;";
                    else if (statusText === "Chưa thanh toán") statusColor = "color:orange; font-weight:bold;";

                    const tr = `<tr>
                        <td>${r.id || r.Id}</td>
                        <td>${dateStr}</td>
                        <td>${empName}</td>
                        <td>${cusName}</td>
                        <td style="${statusColor}">${statusText}</td>
                        <td style="font-weight:bold; color:#2185d0">${totalMoney}</td>
                        <td>${r.note || r.Note || ''}</td>
                        <td class="action-col"><button class="ui blue mini button editBtn" data-id="${r.id || r.Id}">Sửa</button><button class="ui red mini button deleteBtn" data-id="${r.id || r.Id}">Xóa</button></td>
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
        const prodName = productMap[item.productId] || "SP ID: " + item.productId;
        tbody.append(`<tr>
            <td>${prodName}</td> <td>${item.quantity}</td>
            <td>${item.unitPrice.toLocaleString('vi-VN')}</td>
            <td>${item.total.toLocaleString('vi-VN')}</td>
            <td class="action-col"><button type="button" class="ui blue mini icon button" onclick="editTempDetail(${index})" title="Sửa"><i class="pencil alternate icon"></i></button><button type="button" class="ui red mini icon button" onclick="removeTempDetail(${index})" title="Xóa"><i class="trash icon"></i></button></td>
        </tr>`);
    });
    $("#totalAmount").text(total.toLocaleString('vi-VN') + " đ");
}

function resetForm() {
    $("#receiptForm")[0].reset();
    $("#hiddenId").val("");

    $("#employeeId").dropdown('clear');
    $("#customerId").dropdown('clear');
    $("#prodId").dropdown('clear');
    $("#status").dropdown('set selected', 'Chưa thanh toán');

    // Reset và mở khóa lọc NCC
    $("#filterSupplier").dropdown('clear');
    $("#filterSupplier").parent().removeClass('disabled');
    filterProductDropdown("");

    tempDetails = [];
    originalDetailIds = [];

    exitEditMode();

    $("#customerId").parent().removeClass('disabled');

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

function setupDateConstraints(startId, endId) {
    $(startId).on("change", function () { $(endId).attr("min", $(this).val()); });
    $(endId).on("change", function () { $(startId).attr("max", $(this).val()); });
}