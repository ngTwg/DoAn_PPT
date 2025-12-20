classdef TichPhanApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab 
    end

    methods (Access = private)
        
        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Tích Phân');
            
            pLeft = uipanel(app.Tab1, 'Title', 'Dữ liệu đầu vào', ...
                'Position', [10 10 280 500]);
            
            uilabel(pLeft, 'Text', '1. Dữ liệu bảng (X, Y):', 'FontWeight', 'bold', ...
                'Position', [10 450 200 20]);
            
            uilabel(pLeft, 'Text', 'Nhập X:', 'Position', [10 425 60 20]);
            xdata_field = uieditfield(pLeft, 'text', 'Position', [70 425 200 20], ...
                'Value', '', 'Placeholder', 'VD: 0, 1, 2, 3');
                
            uilabel(pLeft, 'Text', 'Nhập Y:', 'Position', [10 395 60 20]);
            ydata_field = uieditfield(pLeft, 'text', 'Position', [70 395 200 20], ...
                'Value', '', 'Placeholder', 'VD: 0, 1, 4, 9');
            
            uilabel(pLeft, 'Text', '--- HOẶC ---', 'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', 'FontSize', 14, 'Position', [10 350 260 30]);
            
            uilabel(pLeft, 'Text', '2. Hàm số f(x):', 'FontWeight', 'bold', ...
                'Position', [10 310 200 20]);
                
            uilabel(pLeft, 'Text', 'Hàm f(x):', 'Position', [10 285 60 20]);
            fx_field = uieditfield(pLeft, 'text', 'Position', [70 285 200 20], ...
                'Value', 'sin(x)', 'Placeholder', 'VD: x^2 + 1');
            
            uilabel(pLeft, 'Text', 'Cận a:', 'Position', [10 245 40 20]);
            a_field = uieditfield(pLeft, 'numeric', 'Position', [50 245 60 20], 'Value', 0);
            
            uilabel(pLeft, 'Text', 'Cận b:', 'Position', [130 245 40 20]);
            b_field = uieditfield(pLeft, 'numeric', 'Position', [170 245 60 20], 'Value', 3.1416);
            
            uilabel(pLeft, 'Text', 'Số khoảng chia N:', 'Position', [10 205 120 20]);
            n_field = uieditfield(pLeft, 'numeric', 'Position', [130 205 100 20], 'Value', 100);
            
            pRight = uipanel(app.Tab1, 'Title', 'Tính toán', ...
                'Position', [300 10 330 500]);
            
            uilabel(pRight, 'Text', 'Chọn phương pháp tích phân:', 'FontWeight', 'bold', ...
                'Position', [10 450 250 20]);
            method_dd = uidropdown(pRight, 'Items', {'Hình Thang', 'Simpson 1/3', 'Simpson 3/8'}, ...
                'Position', [10 425 300 20]);
            
            btnCalc = uibutton(pRight, 'push', 'Text', 'Tính Tích Phân', ...
                'Position', [10 370 300 40], 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.9 0.9]);
            
            uilabel(pRight, 'Text', 'KẾT QUẢ:', 'FontWeight', 'bold', ...
                'Position', [10 330 100 20]);
            res_label = uitextarea(pRight, 'Position', [10 20 310 300], ...
                'Editable', 'off', 'FontSize', 13);

            % Callback
            btnCalc.ButtonPushedFcn = @(src,evt) tinh_tichphan_cb(fx_field, xdata_field, ydata_field, a_field, b_field, n_field, method_dd, res_label);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Ứng Dụng Tích Phân', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app);
        end
    end

    methods (Access = public)
        function app = TichPhanApp
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
    end
end

function tinh_tichphan_cb(fx_f, xd_f, yd_f, a_f, b_f, n_f, met_d, res)
    try
        f_str = strtrim(fx_f.Value);
        method = met_d.Value;
        result_text = '';
        val = NaN;
        
        if ~isempty(f_str)
            f = str2func(['@(x)' f_str]);
            a = a_f.Value;
            b = b_f.Value;
            n = n_f.Value;
            
            if contains(method, 'Simpson 1/3') && mod(n, 2) ~= 0
                n = n + 1; 
                warning_msg = '(Đã tự động chỉnh N thành số chẵn để phù hợp Simpson 1/3)';
            elseif contains(method, 'Simpson 3/8') && mod(n, 3) ~= 0
                n = n + (3 - mod(n,3)); 
                warning_msg = '(Đã tự động chỉnh N chia hết cho 3 để phù hợp Simpson 3/8)';
            else
                warning_msg = '';
            end
            
            h = (b - a) / n;
            x = linspace(a, b, n+1);
            y = f(x);
            
            switch method
                case 'Hình Thang'
                    val = h * (0.5*y(1) + sum(y(2:end-1)) + 0.5*y(end));
                    formula_name = 'Công thức Hình Thang';
                case 'Simpson 1/3'
                    val = (h/3) * (y(1) + 4*sum(y(2:2:end-1)) + 2*sum(y(3:2:end-2)) + y(end));
                    formula_name = 'Công thức Simpson 1/3';
                case 'Simpson 3/8'
                    val = (3*h/8) * (y(1) + 3*sum(y(2:end-1)) - sum(y(4:3:end-1)) + y(end)); 
                    sum1 = sum(y(2:3:end-1)); 
                    sum2 = sum(y(3:3:end-1)); 
                    sum3 = sum(y(4:3:end-2)); 
                    val = (3*h/8) * (y(1) + 3*(sum1 + sum2) + 2*sum3 + y(end));
                    
                    formula_name = 'Công thức Simpson 3/8';
            end
            
            result_text = sprintf(['KẾT QUẢ TÍNH TỪ HÀM SỐ:\n' ...
                                   '------------------------\n' ...
                                   'Hàm số: f(x) = %s\n' ...
                                   'Cận: [%.4f, %.4f]\n' ...
                                   'Số khoảng N = %d %s\n' ...
                                   'Bước h = %.6f\n' ...
                                   'Phương pháp: %s\n\n' ...
                                   'Giá trị Tích phân ≈ %.8f'], ...
                                   f_str, a, b, n, warning_msg, h, method, val);
                                   
        elseif ~isempty(xd_f.Value) && ~isempty(yd_f.Value)
            X = str2num(xd_f.Value); 
            Y = str2num(yd_f.Value); 
            n = length(X) - 1;
            
            if length(X) ~= length(Y)
                error('Độ dài vector X và Y không bằng nhau.');
            end
            
            h_vec = diff(X);
            if max(abs(h_vec - h_vec(1))) > 1e-9
                error('Dữ liệu X phải cách đều nhau (bước h không đổi) để dùng các công thức này.');
            end
            h = h_vec(1);
            
            switch method
                case 'Hình Thang'
                    val = h * (0.5*Y(1) + sum(Y(2:end-1)) + 0.5*Y(end));
                    
                case 'Simpson 1/3'
                    if mod(n, 2) ~= 0
                        error('Dữ liệu bảng có số khoảng chia lẻ (N=%d), không thể dùng Simpson 1/3. Hãy dùng Hình Thang.', n);
                    end
                    val = (h/3) * (Y(1) + 4*sum(Y(2:2:end-1)) + 2*sum(Y(3:2:end-2)) + Y(end));
                    
                case 'Simpson 3/8'
                    if mod(n, 3) ~= 0
                        error('Dữ liệu bảng có số khoảng chia không chia hết cho 3 (N=%d), không thể dùng Simpson 3/8.', n);
                    end
                    sum1 = sum(Y(2:3:end-1)); 
                    sum2 = sum(Y(3:3:end-1)); 
                    sum3 = sum(Y(4:3:end-2)); 
                    val = (3*h/8) * (Y(1) + 3*(sum1 + sum2) + 2*sum3 + Y(end));
            end
            
            result_text = sprintf(['KẾT QUẢ TÍNH TỪ DỮ LIỆU BẢNG:\n' ...
                                   '-----------------------------\n' ...
                                   'Dữ liệu đầu vào: %d điểm (N=%d)\n' ...
                                   'Bước h = %.6f\n' ...
                                   'Phương pháp: %s\n\n' ...
                                   'Giá trị Tích phân ≈ %.8f'], ...
                                   length(X), n, h, method, val);
        else
            result_text = 'Vui lòng nhập Hàm số hoặc Dữ liệu bảng (X, Y).';
        end
        
        res.Value = result_text;
        
    catch ME
        res.Value = ['Lỗi: ' ME.message];
    end
end