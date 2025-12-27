classdef DoAn_PPT < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab
        Tab2                    matlab.ui.container.Tab
        Tab3                    matlab.ui.container.Tab
        Tab4                    matlab.ui.container.Tab
        Tab5                    matlab.ui.container.Tab
        Tab6                    matlab.ui.container.Tab
    end

    methods (Access = private)

        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Tìm Nghiệm');
            
            pLeft = uipanel(app.Tab1, 'Title', 'Nhập liệu', 'Position', [10 280 280 280]);
            
            uilabel(pLeft, 'Text', 'Hàm f(x):', 'Position', [10 230 60 20]);
            fx_field = uieditfield(pLeft, 'text', 'Position', [80 230 180 20], 'Value', 'x.^2 - 2*sin(x) + 0.5');
            
            uilabel(pLeft, 'Text', 'Khoảng [a, b]:', 'Position', [10 190 80 20]);
            a_field = uieditfield(pLeft, 'numeric', 'Position', [90 190 50 20], 'Value', -1);
            b_field = uieditfield(pLeft, 'numeric', 'Position', [150 190 50 20], 'Value', 2);
            
            uilabel(pLeft, 'Text', 'Sai số (eps):', 'Position', [10 150 80 20]);
            eps_field = uieditfield(pLeft, 'numeric', 'Position', [90 150 80 20], 'Value', 0.005);
            
            uilabel(pLeft, 'Text', 'Phương pháp:', 'Position', [10 110 80 20]);
            method_dd = uidropdown(pLeft, 'Items', {'Chia Đôi', 'Lặp Đơn', 'Newton'}, 'Position', [90 110 170 20]);
            
            btnCalc = uibutton(pLeft, 'push', 'Text', 'Tìm Nghiệm', 'Position', [80 30 120 40], 'FontWeight', 'bold');

            ax1 = uiaxes(app.Tab1, 'Position', [300 280 340 280]);
            title(ax1, 'Đồ thị hàm số');
            grid(ax1, 'on');

            pRes = uipanel(app.Tab1, 'Title', 'Kết quả', 'Position', [10 10 630 250]);
            
            uilabel(pRes, 'Text', 'Nghiệm tìm được:', 'Position', [20 200 120 20]);
            res_root = uieditfield(pRes, 'text', 'Position', [150 200 150 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Số lần lặp:', 'Position', [350 200 100 20]);
            res_iter = uieditfield(pRes, 'text', 'Position', [460 200 100 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Chi tiết:', 'Position', [20 170 100 20]);
            res_detail = uitextarea(pRes, 'Position', [20 10 590 160], 'Editable', 'off');

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_nghiem_cb(fx_field, a_field, b_field, eps_field, method_dd, ax1, res_root, res_iter, res_detail);
        end
        
        function setupTab2(app)
            app.Tab2 = uitab(app.TabGroup, 'Title', 'Nội Suy');
            
            pIn = uipanel(app.Tab2, 'Title', 'Dữ liệu đầu vào', 'Position', [10 350 280 210]);
            
            uilabel(pIn, 'Text', 'X (cách nhau dấu phẩy):', 'Position', [10 160 200 20]);
            x_field = uieditfield(pIn, 'text', 'Position', [10 140 250 20], 'Value', '0.1, 0.2, 0.3, 0.4');
            
            uilabel(pIn, 'Text', 'Y (cách nhau dấu phẩy):', 'Position', [10 110 200 20]);
            y_field = uieditfield(pIn, 'text', 'Position', [10 90 250 20], 'Value', '0.099, 0.198, 0.295, 0.389');
            
            uilabel(pIn, 'Text', 'Phương pháp:', 'Position', [10 50 80 20]);
            method_dd = uidropdown(pIn, 'Items', {'Lagrange', 'Newton'}, 'Position', [90 50 170 20]);
            
            pCalc = uipanel(app.Tab2, 'Title', 'Tính giá trị', 'Position', [10 200 280 140]);
            uilabel(pCalc, 'Text', 'Giá trị cần nội suy x*:', 'Position', [10 90 120 20]);
            xval_field = uieditfield(pCalc, 'numeric', 'Position', [140 90 100 20], 'Value', 0.14);
            
            btnCalc = uibutton(pCalc, 'push', 'Text', 'Tính Nội Suy', 'Position', [70 20 140 30], 'FontWeight', 'bold');

            ax2 = uiaxes(app.Tab2, 'Position', [300 200 340 360]);
            title(ax2, 'Đồ thị Nội suy');

            pRes = uipanel(app.Tab2, 'Title', 'Kết quả', 'Position', [10 10 630 180]);
            
            uilabel(pRes, 'Text', 'Đa thức nội suy:', 'Position', [10 130 120 20]);
            res_poly = uieditfield(pRes, 'text', 'Position', [130 130 480 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Kết quả tại x*:', 'Position', [10 90 120 20]);
            res_val = uieditfield(pRes, 'text', 'Position', [130 90 150 20], 'Editable', 'off');

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_noisuy_cb(x_field, y_field, xval_field, method_dd, ax2, res_poly, res_val);
        end
        
        function setupTab3(app)
            app.Tab3 = uitab(app.TabGroup, 'Title', 'Hồi Quy');
            
            pIn = uipanel(app.Tab3, 'Title', 'Dữ liệu mẫu', 'Position', [10 300 250 260]);
            
            uilabel(pIn, 'Text', 'Dữ liệu X:', 'Position', [10 210 100 20]);
            x_field = uieditfield(pIn, 'text', 'Position', [10 190 230 20], 'Value', '1, 2, 3, 4, 5');
            
            uilabel(pIn, 'Text', 'Dữ liệu Y:', 'Position', [10 160 100 20]);
            y_field = uieditfield(pIn, 'text', 'Position', [10 140 230 20], 'Value', '2.1, 4.0, 5.8, 8.1, 9.9');
            
            uilabel(pIn, 'Text', 'Dạng hồi quy:', 'Position', [10 100 100 20]);
            method_dd = uidropdown(pIn, 'Items', {'Tuyến Tính (ax+b)', 'Hàm Mũ (ae^bx)', 'Logarit (a+blnx)'}, 'Position', [10 80 230 20]);
                
            btnCalc = uibutton(pIn, 'push', 'Text', 'Tính Hồi Quy', 'Position', [60 20 120 30], 'FontWeight', 'bold');
                
            pPred = uipanel(app.Tab3, 'Title', 'Dự báo', 'Position', [10 150 250 140]);
            uilabel(pPred, 'Text', 'Nhập x cần dự báo:', 'Position', [10 90 120 20]);
            pred_x = uieditfield(pPred, 'numeric', 'Position', [140 90 80 20]);
            
            uilabel(pPred, 'Text', 'Kết quả dự báo y:', 'Position', [10 50 120 20]);
            pred_y = uieditfield(pPred, 'text', 'Position', [140 50 80 20], 'Editable', 'off');

            ax3 = uiaxes(app.Tab3, 'Position', [270 150 370 410]);
            title(ax3, 'Đồ thị Hồi quy');
            
            pRes = uipanel(app.Tab3, 'Title', 'Kết quả phương trình', 'Position', [10 10 630 130]);
            res_eq = uilabel(pRes, 'Text', 'Phương trình: ...', 'Position', [20 50 590 40], 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_hoiquy_cb(x_field, y_field, method_dd, pred_x, pred_y, ax3, res_eq);
        end
        
        function setupTab4(app)
            app.Tab4 = uitab(app.TabGroup, 'Title', 'Đạo Hàm');
            
            pLeft = uipanel(app.Tab4, 'Title', 'Dữ liệu đầu vào', 'Position', [10 10 280 500]);
            
            uilabel(pLeft, 'Text', '1. Dữ liệu bảng (X, Y):', 'FontWeight', 'bold', 'Position', [10 450 200 20]);
            uilabel(pLeft, 'Text', 'Nhập X:', 'Position', [10 425 60 20]);
            xdata_field = uieditfield(pLeft, 'text', 'Position', [70 425 200 20], 'Value', '0, 0.1, 0.2, 0.3');
            uilabel(pLeft, 'Text', 'Nhập Y:', 'Position', [10 395 60 20]);
            ydata_field = uieditfield(pLeft, 'text', 'Position', [70 395 200 20], 'Value', '0, 0.0998, 0.1986, 0.2955');
            
            uilabel(pLeft, 'Text', '--- HOẶC ---', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 14, 'Position', [10 350 260 30]);
            
            uilabel(pLeft, 'Text', '2. Hàm số f(x):', 'FontWeight', 'bold', 'Position', [10 310 200 20]);
            uilabel(pLeft, 'Text', 'Hàm f(x):', 'Position', [10 285 60 20]);
            fx_field = uieditfield(pLeft, 'text', 'Position', [70 285 200 20], 'Value', 'sin(x)');
            
            uilabel(pLeft, 'Text', 'Bước h:', 'Position', [10 245 60 20]);
            h_field = uieditfield(pLeft, 'numeric', 'Position', [70 245 80 20], 'Value', 0.01);
            uilabel(pLeft, 'Text', 'Sai số:', 'Position', [10 205 60 20]);
            err_dd = uidropdown(pLeft, 'Items', {'O(h)', 'O(h^2)'}, 'Position', [70 205 80 20]);
            
            pRight = uipanel(app.Tab4, 'Title', 'Tính toán', 'Position', [300 10 330 500]);
            
            uilabel(pRight, 'Text', 'Chọn phương pháp đạo hàm:', 'FontWeight', 'bold', 'Position', [10 450 250 20]);
            method_dd = uidropdown(pRight, 'Items', {'Xấp xỉ Tiến', 'Xấp xỉ Lùi', 'Xấp xỉ Trung Tâm'}, 'Position', [10 425 300 20]);
            
            uilabel(pRight, 'Text', 'Nhập giá trị x cần tính đạo hàm:', 'FontWeight', 'bold', 'Position', [10 380 250 20]);
            x_calc = uieditfield(pRight, 'numeric', 'Position', [10 355 150 20], 'Value', 0.5);
            
            btnCalc = uibutton(pRight, 'push', 'Text', 'Tính Đạo Hàm', 'Position', [10 300 300 40], 'FontWeight', 'bold');
            
            uilabel(pRight, 'Text', 'KẾT QUẢ:', 'FontWeight', 'bold', 'Position', [10 260 100 20]);
            res_label = uitextarea(pRight, 'Position', [10 20 310 240], 'Editable', 'off', 'FontSize', 13);

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_daoham_cb(fx_field, xdata_field, ydata_field, x_calc, h_field, method_dd, err_dd, res_label);
        end
        
        function setupTab5(app)
            app.Tab5 = uitab(app.TabGroup, 'Title', 'Tích Phân');
            
            pMode = uibuttongroup(app.Tab5, 'Position', [10 520 630 40], 'BorderType', 'none');
            mode_func = uiradiobutton(pMode, 'Text', 'Từ Hàm Số', 'Position', [10 10 100 20], 'Value', true);
            mode_data = uiradiobutton(pMode, 'Text', 'Từ Dữ Liệu (X,Y)', 'Position', [150 10 150 20]);
            
            pIn = uipanel(app.Tab5, 'Title', 'Thông số đầu vào', 'Position', [10 10 280 500]);
            
            uilabel(pIn, 'Text', '1. Dữ liệu bảng (X, Y):', 'FontWeight', 'bold', 'Position', [10 450 200 20]);
            uilabel(pIn, 'Text', 'Nhập X:', 'Position', [10 425 60 20]);
            xd_field = uieditfield(pIn, 'text', 'Position', [70 425 200 20]);
            uilabel(pIn, 'Text', 'Nhập Y:', 'Position', [10 395 60 20]);
            yd_field = uieditfield(pIn, 'text', 'Position', [70 395 200 20]);
            
            uilabel(pIn, 'Text', '--- HOẶC ---', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 14, 'Position', [10 350 260 30]);
            
            uilabel(pIn, 'Text', '2. Hàm số f(x):', 'FontWeight', 'bold', 'Position', [10 310 200 20]);
            uilabel(pIn, 'Text', 'Hàm f(x):', 'Position', [10 285 60 20]);
            fx_field = uieditfield(pIn, 'text', 'Position', [70 285 200 20], 'Value', 'sin(x)');
            
            uilabel(pIn, 'Text', 'Cận a:', 'Position', [10 245 40 20]);
            a_field = uieditfield(pIn, 'numeric', 'Position', [50 245 60 20], 'Value', 0);
            uilabel(pIn, 'Text', 'Cận b:', 'Position', [130 245 40 20]);
            b_field = uieditfield(pIn, 'numeric', 'Position', [170 245 60 20], 'Value', 3.1415);
            uilabel(pIn, 'Text', 'Số khoảng N:', 'Position', [10 205 100 20]);
            n_field = uieditfield(pIn, 'numeric', 'Position', [110 205 80 20], 'Value', 100);
            
            pRight = uipanel(app.Tab5, 'Title', 'Tính toán', 'Position', [300 10 330 500]);
            
            uilabel(pRight, 'Text', 'Chọn phương pháp:', 'FontWeight', 'bold', 'Position', [10 450 250 20]);
            method_dd = uidropdown(pRight, 'Items', {'Hình Thang', 'Simpson 1/3', 'Simpson 3/8'}, 'Position', [10 425 300 20]);
            
            btnCalc = uibutton(pRight, 'push', 'Text', 'Tính Tích Phân', 'Position', [10 370 300 40], 'FontWeight', 'bold');
            
            uilabel(pRight, 'Text', 'KẾT QUẢ:', 'FontWeight', 'bold', 'Position', [10 330 100 20]);
            res_label = uitextarea(pRight, 'Position', [10 20 310 300], 'Editable', 'off', 'FontSize', 13);

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_tichphan_cb(mode_func, fx_field, xd_field, yd_field, a_field, b_field, n_field, method_dd, res_label);
        end
        
        function setupTab6(app)
            app.Tab6 = uitab(app.TabGroup, 'Title', 'Giới Thiệu');
            
            uilabel(app.Tab6, 'Text', 'THÔNG TIN NHÓM THỰC HIỆN', 'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Position', [10 520 630 40]);
                
            info_str = ['Đề tài: Ứng dụng MATLAB trong Phương Pháp Tính' char(10) char(10) ...
                        'GVHD: [Tên Giảng Viên]' char(10) ...
                        'Lớp: [Tên Lớp]' char(10) char(10) ...
                        'Danh sách thành viên:' char(10) ...
                        '1. Lê Ngọc Tường - 23207124 (Trưởng nhóm)' char(10) ...
                        '2. Thành viên B - MSSV' char(10) ...
                        '3. Thành viên C - MSSV' char(10) char(10) ...
                        'Phân công nhiệm vụ:' char(10) ...
                        '- Thiết kế giao diện (UI): Tường' char(10) ...
                        '- Thuật toán tìm nghiệm & Tích phân: B' char(10) ...
                        '- Thuật toán Nội suy & Hồi quy: C'];
                        
            uitextarea(app.Tab6, 'Value', info_str, 'Position', [50 100 550 400], 'Editable', 'off', 'FontSize', 14);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Đồ Án Phương Pháp Tính', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app);
            setupTab2(app);
            setupTab3(app);
            setupTab4(app);
            setupTab5(app);
            setupTab6(app);
        end
    end

    methods (Access = public)
        function app = DoAn_PPT
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
    end
end

function tinh_nghiem_cb(fx_f, a_f, b_f, eps_f, method_d, ax, res_r, res_i, res_d)
    try
        fstr = fx_f.Value;
        f = str2func(['@(x)' fstr]);
        a = a_f.Value; b = b_f.Value; tol = eps_f.Value;
        method = method_d.Value;
        
        x = linspace(a - 1, b + 1, 100);
        y = f(x);
        cla(ax); hold(ax, 'on');
        plot(ax, x, y, 'b-', 'LineWidth', 1.5);
        yline(ax, 0, 'k--');
        grid(ax, 'on'); hold(ax, 'off');
        
        root = NaN; iter = 0; msg = '';
        
        switch method
            case 'Chia Đôi'
                [root, iter] = bisection_method(f, a, b, tol);
            case 'Newton'
                syms xs; 
                df_sym = diff(str2sym(fstr), xs);
                df = matlabFunction(df_sym);
                [root, iter] = newton_method(f, df, (a+b)/2, tol);
            case 'Lặp Đơn'
                g = @(x) sqrt(2*sin(x) - 0.5); 
                [root, iter] = fixed_point_method(g, (a+b)/2, tol);
                msg = '(Lưu ý: Phương pháp lặp cần hàm g(x) hội tụ)';
        end
        
        res_r.Value = sprintf('%.6f', root);
        res_i.Value = sprintf('%d', iter);
        res_d.Value = sprintf('Phương pháp: %s\nKhoảng phân ly: [%.2f, %.2f]\n%s', method, a, b, msg);
        
        hold(ax, 'on'); plot(ax, root, f(root), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); hold(ax, 'off');
        
    catch ME
        res_d.Value = ['Lỗi: ' ME.message];
    end
end

function tinh_noisuy_cb(x_f, y_f, xv_f, met_d, ax, res_p, res_v)
    try
        x = str2num(x_f.Value); 
        y = str2num(y_f.Value); 
        xp = xv_f.Value;
        method = met_d.Value;
        
        if length(x) ~= length(y)
            error('Số lượng phần tử X và Y phải bằng nhau.');
        end
        
        if strcmp(method, 'Lagrange')
             yp = lagrange_interp(x, y, xp);
             poly_str = 'P_n(x) = \Sigma (yi * Li(x)) [Lagrange]';
        else
             [yp, div_diff] = newton_interp(x, y, xp);
             poly_str = sprintf('P(x) = %.2f + %.2f(x-%.2f) + ... (Newton)', div_diff(1,1), div_diff(2,2), x(1));
        end
        
        res_p.Value = poly_str;
        res_v.Value = sprintf('%.6f', yp);
        
        xx = linspace(min(x), max(x), 100);
        if strcmp(method, 'Lagrange')
            yy = arrayfun(@(k) lagrange_interp(x, y, k), xx);
        else
            yy = arrayfun(@(k) newton_interp(x, y, k), xx);
        end
        
        cla(ax); hold(ax, 'on');
        plot(ax, x, y, 'ko', 'MarkerFaceColor', 'k');
        plot(ax, xx, yy, 'b-');
        plot(ax, xp, yp, 'r*', 'MarkerSize', 10);
        legend(ax, 'Dữ liệu', ['Nội suy ' method], 'Kết quả');
        grid(ax, 'on'); hold(ax, 'off');
        
    catch ME
        res_v.Value = 'Lỗi nhập liệu';
    end
end

function tinh_hoiquy_cb(xf, yf, md, px, py, ax, req)
    try
        x = str2num(xf.Value); 
        y = str2num(yf.Value); 
        method = md.Value;
        x_pred = px.Value;
        
        cla(ax); hold(ax, 'on');
        plot(ax, x, y, 'ro', 'MarkerSize', 6);
        
        xfit = linspace(min(x), max(x), 100);
        
        if contains(method, 'Tuyến Tính')
            p = polyfit(x, y, 1);
            yfit = polyval(p, xfit);
            y_pred = polyval(p, x_pred);
            req.Text = sprintf('y = %.4fx + %.4f', p(1), p(2));
        elseif contains(method, 'Hàm Mũ')
            p = polyfit(x, log(y), 1);
            a = exp(p(2)); b = p(1);
            yfit = a * exp(b * xfit);
            y_pred = a * exp(b * x_pred);
            req.Text = sprintf('y = %.4f * e^(%.4fx)', a, b);
        else
             p = polyfit(log(x), y, 1);
             yfit = polyval(p, log(xfit));
             y_pred = polyval(p, log(x_pred));
             req.Text = sprintf('y = %.4f + %.4f*ln(x)', p(2), p(1));
        end
        
        plot(ax, xfit, yfit, 'b-', 'LineWidth', 2);
        if ~isempty(x_pred)
            plot(ax, x_pred, y_pred, 'g*', 'MarkerSize', 10);
            py.Value = sprintf('%.4f', y_pred);
        end
        grid(ax, 'on'); hold(ax, 'off');
        
    catch ME
        req.Text = ['Lỗi: ' ME.message];
    end
end

function tinh_daoham_cb(fx_f, xd_f, yd_f, xc_f, h_f, met_d, err_d, res)
    try
        f_str = strtrim(fx_f.Value);
        x_val = xc_f.Value;
        h = h_f.Value;
        method = met_d.Value;
        result_text = '';
        val = NaN;
        
        if ~isempty(f_str) 
            f = str2func(['@(x)' f_str]);
            switch method
                case 'Xấp xỉ Tiến'
                    val = (f(x_val + h) - f(x_val)) / h;
                    formula = '(f(x+h) - f(x)) / h';
                case 'Xấp xỉ Lùi'
                    val = (f(x_val) - f(x_val - h)) / h;
                    formula = '(f(x) - f(x-h)) / h';
                case 'Xấp xỉ Trung Tâm'
                    val = (f(x_val + h) - f(x_val - h)) / (2*h);
                    formula = '(f(x+h) - f(x-h)) / 2h';
            end
            result_text = sprintf('Hàm: %s\nTại x=%.4f, h=%.4f\nPhương pháp: %s\nCông thức: %s\nKết quả: %.6f', f_str, x_val, h, method, formula, val);
        elseif ~isempty(xd_f.Value) && ~isempty(yd_f.Value)
            X = str2num(xd_f.Value);
            Y = str2num(yd_f.Value);
            [~, idx] = min(abs(X - x_val));
            try
                switch method
                    case 'Xấp xỉ Tiến'
                        val = (Y(idx+1) - Y(idx)) / (X(idx+1) - X(idx));
                    case 'Xấp xỉ Lùi'
                        val = (Y(idx) - Y(idx-1)) / (X(idx) - X(idx-1));
                    case 'Xấp xỉ Trung Tâm'
                        val = (Y(idx+1) - Y(idx-1)) / (X(idx+1) - X(idx-1));
                end
                result_text = sprintf('Dữ liệu bảng\nTại x gần %.4f\nPhương pháp: %s\nKết quả: %.6f', X(idx), method, val);
            catch
                 result_text = 'Lỗi: Không đủ điểm dữ liệu lân cận để tính.';
            end
        else
            result_text = 'Vui lòng nhập Hàm số hoặc Dữ liệu bảng.';
        end
        res.Value = result_text;
    catch ME
        res.Value = ['Lỗi: ', ME.message];
    end
end

function tinh_tichphan_cb(mode_func, fx_f, xd_f, yd_f, a_f, b_f, n_f, met_d, res)
    try
        method = met_d.Value;
        val = 0;
        if mode_func.Value == true 
            f_str = fx_f.Value;
            if isempty(f_str), error('Vui lòng nhập hàm f(x)'); end
            f = str2func(['@(x)' f_str]);
            a = a_f.Value; b = b_f.Value; n = n_f.Value;
            if contains(method, 'Simpson 1/3') && mod(n, 2) ~= 0, n = n+1; end
            if contains(method, 'Simpson 3/8') && mod(n, 3) ~= 0, n = n + (3-mod(n,3)); end
            h = (b-a)/n;
            y = f(a:h:b);
            val = calculate_integral(y, h, method);
            msg = sprintf('Kết quả (Hàm): %.6f\n(N=%d, h=%.4f)', val, n, h);
        else
            if isempty(xd_f.Value) || isempty(yd_f.Value), error('Vui lòng nhập dữ liệu X, Y'); end
            X = str2num(xd_f.Value); Y = str2num(yd_f.Value);
            h = X(2) - X(1);
            val = calculate_integral(Y, h, method);
            msg = sprintf('Kết quả (Dữ liệu): %.6f\n(N=%d, h=%.4f)', val, length(X)-1, h);
        end
        res.Text = msg;
    catch ME
        res.Text = ['Lỗi: ' ME.message];
    end
end

function [c, k] = bisection_method(f, a, b, tol)
    k = 0; c = a;
    if f(a)*f(b) >= 0, return; end
    while (b-a)/2 > tol
        k = k+1; c = (a+b)/2;
        if f(c) == 0, break; end
        if f(a)*f(c) < 0, b = c; else, a = c; end
    end
end

function [x1, k] = newton_method(f, df, x0, tol)
    k = 0; x1 = x0;
    while k < 1000
        fx = f(x1);
        if abs(fx) < tol, break; end
        x1 = x1 - fx/df(x1); k = k + 1;
    end
end

function [x1, k] = fixed_point_method(g, x0, tol)
    k = 0; x1 = x0;
    while k < 1000
        x_new = g(x1);
        if abs(x_new - x1) < tol, break; end
        x1 = x_new; k = k + 1;
    end
end

function y = lagrange_interp(X, Y, x)
    n = length(X); y = 0;
    for i = 1:n
        L = 1;
        for j = 1:n
            if i ~= j, L = L * (x - X(j)) / (X(i) - X(j)); end
        end
        y = y + Y(i) * L;
    end
end

function [y_val, D] = newton_interp(X, Y, x_query)
    n = length(X);
    D = zeros(n, n);
    D(:,1) = Y(:);
    for j = 2:n
        for i = j:n
            D(i,j) = (D(i,j-1) - D(i-1,j-1)) / (X(i) - X(i-j+1));
        end
    end
    y_val = D(1,1);
    x_term = 1;
    for k = 2:n
        x_term = x_term * (x_query - X(k-1));
        y_val = y_val + D(k,k) * x_term;
    end
end

function val = calculate_integral(Y, h, method)
    if contains(method, 'Hình Thang')
        val = h * (0.5*Y(1) + sum(Y(2:end-1)) + 0.5*Y(end));
    elseif contains(method, 'Simpson 1/3')
        val = (h/3) * (Y(1) + 4*sum(Y(2:2:end-1)) + 2*sum(Y(3:2:end-2)) + Y(end));
    elseif contains(method, 'Simpson 3/8')
        sum1 = sum(Y(2:3:end-1));
        sum2 = sum(Y(3:3:end-1));
        sum3 = sum(Y(4:3:end-2));
        val = (3*h/8) * (Y(1) + 3*(sum1 + sum2) + 2*sum3 + Y(end));
    else
        val = 0;
    end
end