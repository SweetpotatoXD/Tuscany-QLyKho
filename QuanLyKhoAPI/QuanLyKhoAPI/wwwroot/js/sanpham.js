const API_PRODUCT = "/api/Product";
const API_SUPPLIER = "/api/Supplier";

let supplierMap = {};
let allProducts = [];

$(document).ready(async function () {
    await loadSuppliers();
    loadProducts();

    $('#productModal').modal({ closable: false, onDeny: () => true });

    $("#btnToggleFilter").click(() => $("#filterArea").slideToggle());

    $("#btnSearch").click(renderAndFilter);

    $("#btnClearSearch").click(() => {
        $("#filterArea input").val("");
        $("#searchSupplierId").val("");
        $("#sortQuantity").val("");
        renderAndFilter();
    });

    $("#btnAdd").click(() => {
        resetForm();
        $("#modalHeader").text("Thêm Sản phẩm mới");
        $("#hiddenId").val("");
        $('#productModal').modal('show');
    });

    $("#btnSaveModal").click(() => $("#productForm").submit());

    $("#productForm input[required], #productForm select[required]").on("blur change", function () {
        validateField($(this));
        checkGlobalError();
    });

    $("#productForm input, #productForm select").on("input change", function () {
        $(this).closest('.field').removeClass('error');
        $("#globalError").hide();
    });
});

function loadProducts() {
    $.ajax({
        url: API_PRODUCT,
        type: "GET",
        success: function (res) {
            if (res.isSuccess && res.data) {
                allProducts = res.data;
                renderAndFilter();
            } else {
                allProducts = [];
                renderAndFilter();
            }
        }
    });
}

// --- HÀM QUAN TRỌNG: LỌC VÀ SẮP XẾP ---
function renderAndFilter() {
    const sId = $("#searchId").val().trim();
    const sName = $("#searchName").val().trim().toLowerCase();
    const sUnit = $("#searchUnit").val().trim().toLowerCase();
    const sSup = $("#searchSupplierId").val();
    const sSort = $("#sortQuantity").val();

    // 1. Lọc
    let filtered = allProducts.filter(p => {
        if (sId && p.id != sId && p.Id != sId) return false;

        const pName = (p.name || p.Name || "").toLowerCase();
        if (sName && !pName.includes(sName)) return false;

        const pUnit = (p.unit || p.Unit || "").toLowerCase();
        if (sUnit && !pUnit.includes(sUnit)) return false;

        const pSupId = p.supplierId || p.SupplierId;
        if (sSup && pSupId != sSup) return false;

        return true;
    });

    // 2. Sắp xếp
    if (sSort) {
        // Nếu người dùng chọn sắp xếp theo Tồn kho
        filtered.sort((a, b) => {
            const qtyA = a.quantity || a.Quantity || 0;
            const qtyB = b.quantity || b.Quantity || 0;
            return sSort === 'asc' ? qtyA - qtyB : qtyB - qtyA;
        });
    } else {
        // === MẶC ĐỊNH: SẮP XẾP ID TĂNG DẦN (A - B) ===
        filtered.sort((a, b) => {
            const idA = a.id || a.Id;
            const idB = b.id || b.Id;
            return idA - idB; // Nhỏ trước, lớn sau
        });
    }

    // 3. Vẽ bảng
    const tbody = $("#productTable tbody");
    tbody.empty();

    if (filtered.length === 0) {
        tbody.append("<tr><td colspan='6' class='center aligned'>Không tìm thấy sản phẩm nào</td></tr>");
        return;
    }

    filtered.forEach(p => {
        const supId = p.supplierId || p.SupplierId;
        const supName = supplierMap[supId] || "-";

        const tr = `<tr>
            <td>${p.id || p.Id}</td>
            <td style="font-weight:bold">${p.name || p.Name}</td>
            <td>${p.unit || p.Unit}</td>
            <td>${supName}</td>
            <td style="color:#db2828; font-weight:bold">${p.quantity || p.Quantity || 0}</td>
            <td class="action-col">
                <button class="ui blue mini button editBtn" 
                    data-id="${p.id || p.Id}"
                    data-name="${p.name || p.Name}"
                    data-unit="${p.unit || p.Unit}"
                    data-sup="${supId}"
                    data-qty="${p.quantity || p.Quantity || 0}">Sửa</button>
                <button class="ui red mini button deleteBtn" data-id="${p.id || p.Id}">Xóa</button>
            </td>
        </tr>`;
        tbody.append(tr);
    });
}

async function loadSuppliers() {
    try {
        const res = await $.ajax({ url: API_SUPPLIER, type: "GET" });
        if (res.isSuccess && res.data) {
            const selectForm = $("#supplierId");
            const selectSearch = $("#searchSupplierId");

            selectForm.empty().append('<option value="">-- Chọn Nhà cung cấp --</option>');
            selectSearch.empty().append('<option value="">-- Tất cả --</option>');

            res.data.forEach(s => {
                const option = `<option value="${s.id || s.Id}">${s.name || s.Name}</option>`;
                selectForm.append(option);
                selectSearch.append(option);
                supplierMap[s.id || s.Id] = s.name || s.Name;
            });
        }
    } catch (e) { console.error(e); }
}

$("#productForm").on("submit", function (e) {
    e.preventDefault();
    let hasEmpty = false;
    $("#productForm input[required], #productForm select[required]").each(function () {
        if (!validateField($(this))) hasEmpty = true;
    });

    if (hasEmpty) { $("#globalError").show(); return; }

    const id = $("#hiddenId").val();
    const data = {
        Name: $("#name").val().trim(),
        Unit: $("#unit").val().trim(),
        SupplierId: $("#supplierId").val(),
        CreatedBy: "Admin", LastModifiedBy: "Admin"
    };

    const method = id ? "PUT" : "POST";
    const url = id ? `${API_PRODUCT}/${id}?${$.param(data)}` : `${API_PRODUCT}?${$.param(data)}`;

    $.ajax({
        url: url, type: method,
        success: function (res) {
            if (res.isSuccess) {
                $('#productModal').modal('hide');
                alert("Lưu thành công!");
                loadProducts();
            } else { alert("Lỗi: " + res.errorMessage); }
        },
        error: function (xhr) {
            let msg = xhr.responseJSON?.errorMessage || "Lỗi hệ thống";
            alert("Lỗi: " + msg);
        }
    });
});

$(document).on("click", ".editBtn", function () {
    const btn = $(this);
    resetForm();
    $("#hiddenId").val(btn.data("id"));
    $("#maSP").val(btn.data("id"));
    $("#name").val(btn.data("name"));
    $("#unit").val(btn.data("unit"));
    $("#supplierId").val(btn.data("sup"));
    $("#quantity").val(btn.data("qty"));
    $("#modalHeader").text("Cập nhật Sản phẩm");
    $('#productModal').modal('show');
});

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Xóa sản phẩm này?")) return;
    $.ajax({
        url: `${API_PRODUCT}/${$(this).data("id")}?lastModifiedBy=Admin`, type: "DELETE",
        success: function (res) { if (res.isSuccess) loadProducts(); else alert(res.errorMessage); }
    });
});

function validateField(input) {
    if (!input.val() || !input.val().trim()) {
        input.closest('.field').addClass('error');
        return false;
    }
    input.closest('.field').removeClass('error');
    return true;
}

function checkGlobalError() {
    let hasEmpty = false;
    $("#productForm input[required], #productForm select[required]").each(function () {
        if (!$(this).val().trim()) hasEmpty = true;
    });
    if (hasEmpty) $("#globalError").show(); else $("#globalError").hide();
}

function resetForm() {
    $("#productForm")[0].reset();
    $("#hiddenId").val("");
    $("#maSP").val("");
    $("#quantity").val("0");
    $(".field.error").removeClass("error");
    $("#globalError").hide();
}