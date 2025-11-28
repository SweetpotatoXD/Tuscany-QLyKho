const API_BASE = "/api/Customer";

$(document).ready(function () {
    loadCustomers();

    $('.ui.dropdown').dropdown();

    $('#customerModal').modal({
        closable: false,
        onDeny: function () { return true; }
    });

    $("#customerForm input[required], #customerForm select[required]").on("blur", function () {
        const input = $(this);
        const val = input.val();
        const field = input.closest('.field');

        if (!val || (typeof val === 'string' && !val.trim())) {
            field.addClass('error');
            field.find('.validation-msg').remove();
        } else {
            if (field.find('.validation-msg').length === 0) {
                field.removeClass('error');
            }
        }
        checkGlobalError();
    });

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

    $("#customerForm input, #customerForm select").on("input change", function () {
        const field = $(this).closest('.field');
        field.removeClass('error');
        field.find('.validation-msg').remove();
        checkGlobalError();
    });

    $("#btnToggleFilter").click(function () { $("#filterArea").slideToggle(); });
    $("#btnSearch").click(function () { loadCustomers(); });
    $("#btnClearSearch").click(function () {
        $("#filterArea input").val("");
        $("#searchType").val("");
        loadCustomers();
    });

    $("#btnAdd").click(function () {
        resetForm();
        $("#modalHeader").text("Thêm khách hàng mới");
        $("#hiddenId").val("");
        $('#customerModal').modal('show');
    });

    $("#btnSaveModal").click(function () {
        $("#btnRealSubmit").click();
    });
});

$("#customerForm").on("submit", function (e) {
    e.preventDefault();

    let hasEmpty = false;
    $("#customerForm input[required], #customerForm select[required]").each(function () {
        const val = $(this).val();
        if (!val || (typeof val === 'string' && !val.trim())) {
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
        CustomerType: $("#customerType").val(),
        PhoneNumber: $("#phone").val().trim(),
        Email: $("#email").val().trim(),
        Address: $("#address").val().trim(),
        Debt: parseInt($("#debt").val()) || 0,
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
                $('#customerModal').modal('hide');
                alert(id ? "Cập nhật thành công!" : "Thêm mới thành công!");
                loadCustomers();
            } else {
                alert("Lỗi: " + (res.errorMessage || res.ErrorMessage));
            }
        },
        error: function (xhr) { showApiError(xhr, id ? "Lỗi cập nhật" : "Lỗi thêm mới"); }
    });
});

function checkGlobalError() {
    let hasEmptyField = false;
    $("#customerForm input[required], #customerForm select[required]").each(function () {
        const val = $(this).val();
        if (!val || (typeof val === 'string' && !val.trim())) {
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
    $("#customerForm")[0].reset();
    $("#hiddenId").val("");
    $("#maKH").val("");
    $("#debt").val(0);
    $('.ui.dropdown').dropdown('clear');
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

function loadCustomers() {
    const params = {
        Id: $("#searchId").val(),
        Name: $("#searchName").val(),
        CustomerType: $("#searchType").val(),
        Email: $("#searchEmail").val(),
        PhoneNumber: $("#searchPhone").val(),
        Address: $("#searchAddress").val()
    };

    $.ajax({
        url: API_BASE,
        type: "GET",
        data: params,
        success: function (res) {
            const tbody = $("#customerTable tbody"); tbody.empty();
            if (res.isSuccess && res.data) {
                res.data.forEach(c => {
                    const tr = `<tr>
                        <td>${c.id || c.Id}</td>
                        <td style="font-weight:bold">${c.name || c.Name}</td>
                        <td>${c.customerType || c.CustomerType}</td>
                        <td>${c.phoneNumber || c.PhoneNumber || ''}</td>
                        <td>${c.email || c.Email || ''}</td>
                        <td>${c.address || c.Address || ''}</td>
                        <td>${c.debt || c.Debt || 0}</td>
                        <td class="action-col">
                            <button class="ui blue mini button editBtn" data-id="${c.id || c.Id}">Sửa</button>
                            <button class="ui red mini button deleteBtn" data-id="${c.id || c.Id}">Xóa</button>
                        </td>
                    </tr>`;
                    tbody.append(tr);
                });
            } else {
                tbody.append(`<tr><td colspan="8" class="center aligned">Không tìm thấy dữ liệu</td></tr>`);
            }
        }
    });
}

$(document).on("click", ".editBtn", function () {
    const row = $(this).closest("tr");
    const id = $(this).data("id");
    resetForm();
    $("#hiddenId").val(id);
    $("#maKH").val(id);
    $("#name").val(row.find("td:eq(1)").text());
    $("#customerType").dropdown('set selected', row.find("td:eq(2)").text());
    $("#phone").val(row.find("td:eq(3)").text());
    $("#email").val(row.find("td:eq(4)").text());
    $("#address").val(row.find("td:eq(5)").text());
    $("#debt").val(row.find("td:eq(6)").text());
    $("#modalHeader").text("Cập nhật Khách hàng");
    $('#customerModal').modal('show');
});

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Xóa khách hàng này?")) return;
    $.ajax({
        url: `${API_BASE}/${$(this).data("id")}?lastModifiedBy=Admin`,
        type: "DELETE",
        success: function (res) { if (res.isSuccess) loadCustomers(); else alert(res.errorMessage); },
        error: function (xhr) { showApiError(xhr, "Lỗi xóa"); }
    });
});