const API_BASE = "/api/Supplier";

$(document).ready(function () {
    loadSuppliers();

    $('#supplierModal').modal({
        closable: false,
        onDeny: function () { return true; }
    });

    // Logic Validation: Rời chuột khỏi ô bắt buộc -> Nếu rỗng thì đỏ viền, xóa chữ lỗi
    $("#supplierForm input[required]").on("blur", function () {
        const input = $(this);
        const val = input.val().trim();
        const field = input.closest('.field');

        if (!val) {
            field.addClass('error');
            field.find('.validation-msg').remove();
        } else {
            if (field.find('.validation-msg').length === 0) {
                field.removeClass('error');
            }
        }
        checkGlobalError();
    });

    // Check Email (Format & Trùng)
    $("#email").on("blur", function () {
        const input = $(this);
        const val = input.val().trim();
        if (!val) return;

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(val)) {
            showInlineError(input, "Email không đúng định dạng");
            return;
        }
        checkExistence("Email", input);
    });

    // Check SĐT (Format & Trùng)
    $("#phone").on("blur", function () {
        const input = $(this);
        const val = input.val().trim();
        if (!val) return;

        const phoneRegex = /^[0-9]+$/;
        if (!phoneRegex.test(val)) {
            showInlineError(input, "Số điện thoại chỉ được chứa số");
            return;
        }
        if (val.length < 10 || val.length > 11) {
            showInlineError(input, "SĐT phải từ 10-11 số");
            return;
        }
        checkExistence("PhoneNumber", input);
    });

    // Nhập lại -> Xóa lỗi
    $("#supplierForm input").on("input", function () {
        const field = $(this).closest('.field');
        field.removeClass('error');
        field.find('.validation-msg').remove();
        checkGlobalError();
    });

    $("#btnToggleFilter").click(function () { $("#filterArea").slideToggle(); });
    $("#btnSearch").click(function () { loadSuppliers(); });
    $("#btnClearSearch").click(function () {
        $("#filterArea input").val("");
        loadSuppliers();
    });

    $("#btnAdd").click(function () {
        resetForm();
        $("#modalHeader").text("Thêm Nhà cung cấp mới");
        $("#hiddenId").val("");
        $('#supplierModal').modal('show');
    });

    $("#btnSaveModal").click(function () {
        $("#btnRealSubmit").click();
    });
});

$("#supplierForm").on("submit", function (e) {
    e.preventDefault();

    let hasEmpty = false;
    $("#supplierForm input[required]").each(function () {
        if (!$(this).val().trim()) {
            $(this).closest('.field').addClass('error');
            $(this).closest('.field').find('.validation-msg').remove();
            hasEmpty = true;
        }
    });

    let hasFormatError = !validateFormatFull();

    checkGlobalError();

    if (hasEmpty || hasFormatError || $(".field.error").length > 0) {
        return;
    }

    const id = $("#hiddenId").val();
    const data = {
        Name: $("#name").val().trim(),
        PhoneNumber: $("#phone").val().trim(),
        Email: $("#email").val().trim(),
        Address: $("#address").val().trim(),
        Description: $("#description").val().trim(),
        CreatedBy: "Admin",
        LastModifiedBy: "Admin"
    };

    const method = id ? "PUT" : "POST";
    const url = id ? `${API_BASE}/${id}?${$.param(data)}` : `${API_BASE}?${$.param(data)}`;

    $.ajax({
        url: url,
        type: method,
        success: function (res) {
            if (res.isSuccess) {
                $('#supplierModal').modal('hide');
                alert(id ? "Cập nhật thành công!" : "Thêm mới thành công!");
                loadSuppliers();
            } else {
                alert("Lỗi: " + (res.errorMessage || res.ErrorMessage));
            }
        },
        error: function (xhr) { showApiError(xhr, id ? "Lỗi cập nhật" : "Lỗi thêm mới"); }
    });
});

function checkGlobalError() {
    let hasEmptyField = false;
    $("#supplierForm input[required]").each(function () {
        if (!$(this).val().trim()) {
            hasEmptyField = true;
            return false;
        }
    });

    if (hasEmptyField) {
        $("#globalError").show();
    } else {
        $("#globalError").hide();
    }
}

function validateFormatFull() {
    let isValid = true;

    const emailInput = $("#email");
    const emailVal = emailInput.val().trim();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (emailVal && !emailRegex.test(emailVal)) {
        showInlineError(emailInput, "Email không đúng định dạng");
        isValid = false;
    }

    const phoneInput = $("#phone");
    const phoneVal = phoneInput.val().trim();
    const phoneRegex = /^[0-9]+$/;
    if (phoneVal && !phoneRegex.test(phoneVal)) {
        showInlineError(phoneInput, "Số điện thoại chỉ được chứa số");
        isValid = false;
    }

    return isValid;
}

function resetForm() {
    $("#supplierForm")[0].reset();
    $("#hiddenId").val("");
    $("#maNCC").val("");
    $(".field.error").removeClass("error");
    $(".validation-msg").remove();
    $("#globalError").hide();
}

function checkExistence(type, inputJQuery) {
    const value = inputJQuery.val().trim();
    const currentId = $("#hiddenId").val();
    const url = `${API_BASE}?${type}=${encodeURIComponent(value)}`;

    $.ajax({
        url: url,
        type: "GET",
        success: function (res) {
            if ((res.isSuccess || res.IsSuccess) && (res.data || res.Data) && (res.data || res.Data).length > 0) {
                const list = res.data || res.Data;
                const foundItem = list[0];
                if (currentId && (foundItem.id == currentId || foundItem.Id == currentId)) {
                    return;
                }
                showInlineError(inputJQuery, type === "Email" ? "Email này đã tồn tại" : "Số điện thoại này đã tồn tại");
            }
        },
        error: function (err) { console.error(err); }
    });
}

function showInlineError(inputElement, msg) {
    const fieldDiv = inputElement.closest('.field');
    fieldDiv.find('.validation-msg').remove();
    fieldDiv.addClass('error');
    fieldDiv.append(`<div class="validation-msg">${msg}</div>`);
}

function showApiError(xhr, defaultMsg) {
    if (xhr.responseJSON && (xhr.responseJSON.errorMessage || xhr.responseJSON.ErrorMessage)) {
        alert("⚠️ " + (xhr.responseJSON.errorMessage || xhr.responseJSON.ErrorMessage));
    } else {
        console.error(xhr);
        alert("❌ " + defaultMsg);
    }
}

function loadSuppliers() {
    const params = {
        Id: $("#searchId").val(),
        Name: $("#searchName").val(),
        Email: $("#searchEmail").val(),
        PhoneNumber: $("#searchPhone").val(),
        Address: $("#searchAddress").val()
    };

    $.ajax({
        url: API_BASE, type: "GET", data: params,
        success: function (res) {
            const tbody = $("#supplierTable tbody"); tbody.empty();
            if (res.isSuccess && res.data) {
                res.data.forEach(s => {
                    const tr = `<tr>
                        <td>${s.id || s.Id}</td>
                        <td style="font-weight:bold">${s.name || s.Name}</td>
                        <td>${s.phoneNumber || s.PhoneNumber || ''}</td>
                        <td>${s.email || s.Email || ''}</td>
                        <td>${s.address || s.Address || ''}</td>
                        <td>${s.description || s.Description || ''}</td>
                        
                        <td class="action-col">
                            <button class="ui blue mini button editBtn" data-id="${s.id || s.Id}">Sửa</button>
                            <button class="ui red mini button deleteBtn" data-id="${s.id || s.Id}">Xóa</button>
                        </td>
                    </tr>`;
                    tbody.append(tr);
                });
            }
        }
    });
}

$(document).on("click", ".editBtn", function () {
    const row = $(this).closest("tr");
    const id = $(this).data("id");
    resetForm();
    $("#hiddenId").val(id);
    $("#maNCC").val(id);
    $("#name").val(row.find("td:eq(1)").text());
    $("#phone").val(row.find("td:eq(2)").text());
    $("#email").val(row.find("td:eq(3)").text());
    $("#address").val(row.find("td:eq(4)").text());
    $("#description").val(row.find("td:eq(5)").text());
    $("#modalHeader").text("Cập nhật Nhà cung cấp");
    $('#supplierModal').modal('show');
});

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Xóa nhà cung cấp này?")) return;
    $.ajax({
        url: `${API_BASE}/${$(this).data("id")}?lastModifiedBy=Admin`,
        type: "DELETE",
        success: function (res) { if (res.isSuccess) loadSuppliers(); else alert(res.errorMessage); },
        error: function (xhr) { showApiError(xhr, "Lỗi xóa"); }
    });
});