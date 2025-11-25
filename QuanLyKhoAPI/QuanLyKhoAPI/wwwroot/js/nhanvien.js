const API_BASE = "/api/Employee/Employee";

$(document).ready(function () {
    loadEmployees();

    $("#btnToggleFilter").click(function () {
        $("#filterArea").slideToggle();

        const btn = $(this);
        if (btn.text().includes("Mở")) {
            btn.html('<i class="angle up icon"></i> Đóng bộ lọc');
        } else {
            btn.html('<i class="filter icon"></i> Mở bộ lọc tìm kiếm');
        }
    });

    $("#btnSearch").click(function () {
        loadEmployees();
    });

    $("#btnClearSearch").click(function () {
        $("#filterArea input").val("");
        loadEmployees();
    });
});

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
        url: url,
        type: "GET",
        success: function (res) {
            if (res.isSuccess || res.IsSuccess) {
                renderTable(res.data || res.Data);
            } else {
                console.error(res.errorMessage);
                renderTable([]);
            }
        },
        error: function (err) {
            console.error(err);
        }
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
            </tr>
        `;
        tbody.append(tr);
    });
}

$("#employeeForm").on("submit", function (e) {
    e.preventDefault();

    const id = $("#hiddenId").val();

    const formData = {
        Name: $("#hoTen").val(),
        Role: $("#chucVu").val(),
        PhoneNumber: $("#soDT").val(),
        Email: $("#email").val(),
        Address: $("#diaChi").val(),
        CreatedBy: "Admin",
        LastModifiedBy: "Admin"
    };

    if (id) {
        const queryString = $.param(formData);
        const url = `${API_BASE}/${id}?${queryString}`;

        $.ajax({
            url: url,
            type: "PUT",
            success: function (res) {
                if (res.isSuccess || res.IsSuccess) {
                    alert("Cập nhật thành công!");
                    resetForm();
                    loadEmployees();
                } else {
                    alert("Lỗi: " + (res.errorMessage || res.ErrorMessage));
                }
            },
            error: function () { alert("Lỗi khi gọi API Cập nhật"); }
        });

    } else {
        const queryString = $.param(formData);
        const url = `${API_BASE}?${queryString}`;

        $.ajax({
            url: url,
            type: "POST",
            success: function (res) {
                if (res.isSuccess || res.IsSuccess) {
                    alert("Thêm mới thành công!");
                    resetForm();
                    loadEmployees();
                } else {
                    alert("Lỗi: " + (res.errorMessage || res.ErrorMessage));
                }
            },
            error: function (xhr) {
                console.error(xhr);
                alert("Lỗi khi gọi API Thêm mới");
            }
        });
    }
});

$(document).on("click", ".editBtn", function () {
    const row = $(this).closest("tr");
    const id = row.data("id");

    $("#hiddenId").val(id);
    $("#maNV").val(id);
    $("#hoTen").val(row.find("td:eq(1)").text());
    $("#chucVu").val(row.find("td:eq(2)").text());
    $("#soDT").val(row.find("td:eq(3)").text());
    $("#email").val(row.find("td:eq(4)").text());
    $("#diaChi").val(row.find("td:eq(5)").text());

    $("button[type='submit']").text("Lưu thay đổi");

    $('html, body').animate({
        scrollTop: $("#employeeForm").offset().top - 100
    }, 500);
});

$(document).on("click", ".deleteBtn", function () {
    if (!confirm("Bạn có chắc chắn muốn xóa?")) return;

    const row = $(this).closest("tr");
    const id = row.data("id");

    $.ajax({
        url: `${API_BASE}/${id}?lastModifiedBy=Admin`,
        type: "DELETE",
        success: function (res) {
            if (res.isSuccess || res.IsSuccess) {
                alert("Đã xóa!");
                loadEmployees();
            } else {
                alert("Lỗi xóa: " + (res.errorMessage || res.ErrorMessage));
            }
        },
        error: function () { alert("Lỗi khi gọi API Xóa"); }
    });
});

$("#resetForm").on("click", resetForm);

function resetForm() {
    $("#employeeForm")[0].reset();
    $("#hiddenId").val("");
    $("#maNV").val("");
    $("button[type='submit']").text("Lưu thông tin");
}