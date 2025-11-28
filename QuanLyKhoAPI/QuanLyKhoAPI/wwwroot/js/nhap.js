const RECEIPT_API = "/api/InboundReceipt";
const DETAIL_API = "/api/InboundDetail";
const EMPLOYEE_API = "/api/Employee/Employee";
const SUPPLIER_API = "/api/Supplier";
const PRODUCT_API = "/api/Product";

let tempDetails = [];
let originalDetailIds = [];
let editingIndex = -1;

let employeeMap = {};
let supplierMap = {};
let productMap = {};
let allProducts = [];

$(document).ready(async function () {
    await loadMetadata();
    loadReceipts();

    $('#receiptModal').modal({ closable: false, onDeny: () => true });

    $("#supplierId").parent().on('click', function () {
        const field = $(this).closest('.field');
        if (field.hasClass('error')) {
            field.removeClass('error');
            field.find('.validation-msg').remove();
        }
    });

    $("#prodId").parent().on('click', function () {
        const field = $(this).closest('.field');
        if (field.hasClass('error')) {
            field.removeClass('error');
            field.find('.validation-msg').remove();
        }
        $("#productError").hide();
    });

    $("#prodOverlay").click(function () {
        const supInput = $("#supplierId");
        if (!supInput.val()) {
            showInlineError(supInput, "Vui lòng chọn Nhà cung cấp trước");
            supInput.closest('.field').transition('pulse');
        }
    });

    $("#supplierId").change(function () {
        const selectedSupId = $(this).val();
        if (selectedSupId) {
            $("#prodOverlay").hide();
            $("#prodId").parent().removeClass('disabled');
        } else {
            $("#prodOverlay").show();
            $("#prodId").parent().addClass('disabled');
        }
        filterProductsBySupplier(selectedSupId);
    });

    $("#btnToggleFilter").click(() => $("#filterArea").slideToggle());
    $("#btnSearch").click(loadReceipts);

    $("#btnClearSearch").click(() => {
        $("#filterArea input").val("");
        $("#searchEmployee").val("");
        $("#searchSupplier").val("");
        $("#sortTotalPrice").val("");
        $("#searchNote").val("");
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

    $("#receiptForm > .fields input[required], #receiptForm > .fields select[required]").on("blur change", function () {
        validateField($(this));
        checkGlobalInputError();
    });

    $("#receiptForm > .fields input, #receiptForm > .fields select").on("input change", function () {
        $(this).closest('.field').removeClass('error');
        $("#globalError").hide();
    });

    $("#productEntryArea input, #productEntryArea select").on("input change", function () {
        const field = $(this).closest('.field');
        field.removeClass('error');
        field.find('.validation-msg').remove();
        $("#productError").hide();
    });

    $("#btnAddProductRow").click(function () {
        if ($("#prodOverlay").is(":visible") && !$("#supplierId").val()) {
            const supInput = $("#supplierId");
            showInlineError(supInput, "Vui lòng chọn Nhà cung cấp trước");
            supInput.closest('.field').transition('pulse');
            return;
        }

        const elId = $("#prodId");
        const elQty = $("#prodQty");
        const elPrice = $("#prodPrice");

        const valId = elId.val();
        const valQty = elQty.val().trim();
        const valPrice = elPrice.val().trim();

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

        if (tempDetails.length > 0) {
            $("#supplierId").parent().addClass('disabled');
        }

        if ($("#globalErrorContent").text().includes("sản phẩm")) {
            $("#globalError").hide();
        }
    });

    $("#btnCancelEdit").click(function () {
        exitEditMode();
    });

    setupDateConstraints("#searchDateStart", "#searchDateEnd");
});

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
        $("#globalErrorContent").text("Phiếu nhập phải có ít nhất 1 sản phẩm");
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
        SupplierId: $("#supplierId").val(),
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

function filterProductsBySupplier(supplierId) {
    const prodSelect = $("#prodId");
    prodSelect.empty().append('<option value="">-- Chọn sản phẩm --</option>');

    if (!supplierId) {
        prodSelect.dropdown('clear');
        $("#prodOverlay").show();
        $("#prodId").parent().addClass('disabled');
        return;
    }

    $("#prodOverlay").hide();
    $("#prodId").parent().removeClass('disabled');

    const filtered = allProducts.filter(p => {
        const pSupId = p.supplierId || p.SupplierId;
        return pSupId == supplierId;
    });

    filtered.forEach(p => {
        const id = p.id || p.Id;
        const name = p.name || p.Name;
        prodSelect.append(`<option value="${id}">${name}</option>`);
    });

    prodSelect.dropdown('clear');
}

async function loadMetadata() {
    try {
        const [empRes, supRes, prodRes] = await Promise.all([
            $.ajax({ url: EMPLOYEE_API, type: "GET" }),
            $.ajax({ url: SUPPLIER_API, type: "GET" }),
            $.ajax({ url: PRODUCT_API, type: "GET" })
        ]);

        const empSelect = $("#employeeId");
        const empSearch = $("#searchEmployee");
        empSelect.empty().append('<option value="">-- Chọn Nhân viên --</option>');
        empSearch.empty().append('<option value="">-- Tất cả --</option>');
        if (empRes.isSuccess && empRes.data) {
            empRes.data.forEach(e => {
                employeeMap[e.id || e.Id] = e.name || e.Name;
                const option = `<option value="${e.id || e.Id}">${e.name || e.Name}</option>`;
                empSelect.append(option);
                empSearch.append(option);
            });
        }

        const supSelect = $("#supplierId");
        const supSearch = $("#searchSupplier");

        supSelect.empty().append('<option value="">-- Chọn Nhà cung cấp --</option>');
        supSearch.empty().append('<option value="">-- Tất cả --</option>');

        if (supRes.isSuccess && supRes.data) {
            supRes.data.forEach(s => {
                supplierMap[s.id || s.Id] = s.name || s.Name;
                const option = `<option value="${s.id || s.Id}">${s.name || s.Name}</option>`;
                supSelect.append(option);
                supSearch.append(option);
            });
        }

        if (prodRes.isSuccess && prodRes.data) {
            allProducts = prodRes.data;
            prodRes.data.forEach(p => {
                productMap[p.id || p.Id] = p.name || p.Name;
            });
        }

        $('#employeeId').dropdown();
        $('#supplierId').dropdown();
        $('#prodId').dropdown();

        $("#prodOverlay").show();
        $("#prodId").parent().addClass('disabled');

    } catch (e) { console.error("Lỗi tải danh mục:", e); }
}

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

function exitEditMode() {
    editingIndex = -1;

    $("#prodId").dropdown('clear');
    $("#prodQty").val("");
    $("#prodPrice").val("");

    if ($("#supplierId").val()) {
        $("#prodId").parent().removeClass('disabled');
        $("#prodOverlay").hide();
    } else {
        $("#prodId").parent().addClass('disabled');
        $("#prodOverlay").show();
    }

    $("#btnCancelEdit").hide();
    $("#btnAddProductRow").html('<i class="plus icon"></i> Thêm');
    $("#btnAddProductRow").removeClass("orange").addClass("blue");

    $("#productEntryArea .field").removeClass('error');
    $("#productEntryArea .validation-msg").remove();
    $("#productError").hide();
}

window.editTempDetail = function (index) {
    const item = tempDetails[index];

    $("#prodId").dropdown('set selected', item.productId);
    $("#prodQty").val(item.quantity);
    $("#prodPrice").val(item.unitPrice);

    $("#prodId").parent().addClass('disabled');
    $("#prodOverlay").hide();

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

    if (tempDetails.length === 0) {
        $("#supplierId").parent().removeClass('disabled');
    }
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

        const receiptRes = await $.ajax({ url: RECEIPT_API, type: "GET", data: { Id: receiptId } });
        let supId = "";
        if (receiptRes.isSuccess && receiptRes.data.length > 0) {
            const r = receiptRes.data[0];
            $("#employeeId").dropdown('set selected', r.employeeId || r.EmployeeId);
            supId = r.supplierId || r.SupplierId;
            $("#supplierId").dropdown('set selected', supId);
            $("#note").val(r.note || r.Note);

            $("#supplierId").parent().addClass('disabled');
        }

        filterProductsBySupplier(supId);

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
        EmployeeId: $("#searchEmployee").val(),
        SupplierId: $("#searchSupplier").val(),
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
                    const supName = supplierMap[r.supplierId || r.SupplierId] || "---";

                    const tr = `<tr>
                        <td>${r.id || r.Id}</td>
                        <td>${dateStr}</td>
                        <td>${empName}</td> 
                        <td>${supName}</td> 
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
    $("#supplierId").dropdown('clear');
    $("#prodId").dropdown('clear');

    tempDetails = [];
    originalDetailIds = [];

    exitEditMode();

    $("#prodOverlay").show();
    $("#prodId").parent().addClass('disabled');

    $("#supplierId").parent().removeClass('disabled');

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