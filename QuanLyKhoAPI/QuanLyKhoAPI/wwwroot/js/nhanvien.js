const API_BASE = "/api/Employee/Employee";

$(document).ready(function () {
    loadEmployees();

    $('#employeeModal').modal({
        closable: false,
        onDeny: function () { return true; }
    });

    $("#employeeForm input[required]").on("blur", function () {
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

    $("#soDT").on("blur", function () {
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

    $("#employeeForm input").on("input", function () {
        const field = $(this).closest('.field');
        field.removeClass('error');
        field.find('.validation-msg').remove();
        checkGlobalError();
    });

    $("#btnToggleFilter").click(function () { $("#filterArea").slideToggle(); });
    $("#btnSearch").click(function () { loadEmployees(); });
    $("#btnClearSearch").click(function () {
        $("#filterArea input").val("");
        $("#searchCreatedDateEnd, #searchCreatedDateStart, #searchModifiedDateEnd, #searchModifiedDateStart").removeAttr("min max");
        loadEmployees();
    });

    $("#btnAdd").click(function () {
        resetForm();
        $("#modalHeader").text("Thêm nhân viên mới");
        $("#hiddenId").val("");
        $('#employeeModal').modal('show');
    });

    $("#btnSaveModal").click(function () {
        $("#btnRealSubmit").click();
    });

    setupDateConstraints("#searchCreatedDateStart", "#searchCreatedDateEnd");
    setupDateConstraints("#searchModifiedDateStart", "#searchModifiedDateEnd");
});

$("#employeeForm").on("submit", function (e) {
    e.preventDefault();

    let hasEmpty = false;
    $("#employeeForm input[required]").each(function () {
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
    const formData = {
        Name: $("#hoTen").val().trim(),
        Role: $("#chucVu").val().trim(),
        PhoneNumber: $("#soDT").val().trim(),
        Email: $("#email").val().trim(),
        Address: $("#diaChi").val().trim(),
        CreatedBy: "Admin",
        LastModifiedBy: "Admin"
    };

    const method = id ? "PUT" : "POST";
    const url = id ? `${API_BASE}/${id}?${$.param(formData)}` : `${API_BASE}?${$.param(formData)}`;

    $.ajax({
        url: url,
        type: method,
        success: function (res) {
            if (res.isSuccess || res.IsSuccess) {
                $('#employeeModal').modal('hide');
                alert(id ? "Cập nhật thành công!" : "Thêm mới thành công!");
                loadEmployees();
            } else {
                alert("Lỗi: " + (res.errorMessage || res.ErrorMessage));
            }
        },
        error: function (xhr) { showApiError(xhr, id ? "Lỗi cập nhật" : "Lỗi thêm mới"); }
    });
});

function checkGlobalError() {
    let hasEmptyField = false;

    $("#employeeForm input[required]").each(function () {
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

    const phoneInput = $("#soDT");
    const phoneVal = phoneInput.val().trim();
    const phoneRegex = /^[0-9]+$/;
    if (phoneVal && !phoneRegex.test(phoneVal)) {
        showInlineError(phoneInput, "Số điện thoại chỉ được chứa số");
        isValid = false;
    }

    return isValid;
}

function resetForm() {
    $("#employeeForm")[0].reset();
    $("#hiddenId").val("");
    $("#maNV").val("");
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

function loadEmployees() {
    const searchParams = {};
    const sId = $("#searchId").val()?.trim();
    const sName = $("#searchName").val()?.trim();
    const sRole = $("#searchRole").val()?.trim();
    const sPhone = $("#searchPhone").val()?.trim();
    const sEmail = $("#searchEmail").val()?.trim();
    const sAddress = $("#searchAddress").val()?.trim();
    const sCreatedBy = $("#searchCreatedBy").val()?.trim();
    const sCreatedStart = $("#searchCreatedDateStart").val();
    const sCreatedEnd = $("#searchCreatedDateEnd").val();
    const sModBy = $("#searchLastModifiedBy").val()?.trim();
    const sModStart = $("#searchModifiedDateStart").val();
    const sModEnd = $("#searchModifiedDateEnd").val();

    if (sId) searchParams.Id = sId;
    if (sName) searchParams.Name = sName;
    if (sRole) searchParams.Role = sRole;
    if (sPhone) searchParams.PhoneNumber = sPhone;
    if (sEmail) searchParams.Email = sEmail;
    if (sAddress) searchParams.Address = sAddress;
    if (sCreatedBy) searchParams.CreatedBy = sCreatedBy;
    if (sCreatedStart) searchParams.CreatedDateStart = sCreatedStart;
    if (sCreatedEnd) searchParams.CreatedDateEnd = sCreatedEnd;
    if (sModBy) searchParams.LastModifiedBy = sModBy;
    if (sModStart) searchParams.LastModifiedDateStart = sModStart;
    if (sModEnd) searchParams.LastModifiedDateEnd = sModEnd;

    const queryString = $.param(searchParams);
    const url = queryString ? `${API_BASE}?${queryString}` : API_BASE;

    $.ajax({
        url: url, type: "GET",
        success: function (res) {
            if (res.isSuccess || res.IsSuccess) { renderTable(res.data || res.Data); }
            else { console.error(res.errorMessage); renderTable([]); }
        },
        error: function (err) { console.error(err); }
    });
}

function renderTable(data) {
    const tbody = $("#employeeTable tbody");
    tbody.empty();
    if (!data || data.length === 0) {
        tbody.append("<tr><td colspan='7' class='center aligned'>Không tìm thấy dữ liệu</td></tr>");
        return;
    }
    data.forEach(emp => {
        const id = emp.id || emp.Id;
        const name = emp.name || emp.Name;
        const role = emp.role || emp.Role || "";
        const phone = emp.phoneNumber || emp.PhoneNumber || "";
        const email = emp.email || emp.Email || "";
        const address = emp.address || emp.Address || "";
        const tr = `
            <tr data-id="${id}">
                <td>${id}</td>
                <td>${name}</td>
                <td>${role}</td>
                <td>${phone}</td>
                <td>${email}</td>
                <td>${address}</td>
                <td>
                    <button class="ui blue button editBtn">Sửa</button>
                    <button class="ui red button deleteBtn">Xóa</button>
                </td>
            </tr>`;
        tbody.append(tr);
    });
}

$(document).on("click", ".editBtn", function () {
    const row = $(this).closest("tr");
    const id = row.data("id");
    resetForm();
    $("#hiddenId").val(id);
    $("#maNV").val(id);
    $("#hoTen").val(row.find("td:eq(1)").text());
    $("#chucVu").val(row.find("td:eq(2)").text());
    $("#soDT").val(row.find("td:eq(3)").text());
    $("#email").val(row.find("td:eq(4)").text());
    $("#diaChi").val(row.find("td:eq(5)").text());
    $("#modalHeader").text("Cập nhật thông tin");
    $('#employeeModal').modal('show');
});

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Bạn có chắc chắn muốn xóa?")) return;
    const id = $(this).closest("tr").data("id");
    $.ajax({
        url: `${API_BASE}/${id}?lastModifiedBy=Admin`,
        type: "DELETE",
        success: function (res) {
            if (res.isSuccess || res.IsSuccess) { loadEmployees(); }
            else { alert("Lỗi xóa: " + (res.errorMessage || res.ErrorMessage)); }
        },
        error: function (xhr) { showApiError(xhr, "Lỗi xóa"); }
    });
});

function setupDateConstraints(startId, endId) {
    $(startId).on("change", function () { $(endId).attr("min", $(this).val()); });
    $(endId).on("change", function () { $(startId).attr("max", $(this).val()); });
}