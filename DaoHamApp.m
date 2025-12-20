classdef DaoHamApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab 
    end

    methods (Access = private)
        
        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Đạo Hàm');
            
            pLeft = uipanel(app.Tab1, 'Title', 'Dữ liệu đầu vào', ...
                'Position', [10 10 280 500]);
            
            uilabel(pLeft, 'Text', '1. Dữ liệu bảng (X, Y):', 'FontWeight', 'bold', ...
                'Position', [10 450 200 20]);
            
            uilabel(pLeft, 'Text', 'Nhập X:', 'Position', [10 425 60 20]);
            xdata_field = uieditfield(pLeft, 'text', 'Position', [70 425 200 20], ...
                'Value', '0, 0.1, 0.2, 0.3', 'Placeholder', 'VD: 1, 2, 3');
                
            uilabel(pLeft, 'Text', 'Nhập Y:', 'Position', [10 395 60 20]);
            ydata_field = uieditfield(pLeft, 'text', 'Position', [70 395 200 20], ...
                'Value', '0, 0.0998, 0.1986, 0.2955', 'Placeholder', 'VD: 2, 4, 6');
            
            uilabel(pLeft, 'Text', '--- HOẶC ---', 'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', 'FontSize', 14, 'Position', [10 350 260 30]);
            
            uilabel(pLeft, 'Text', '2. Hàm số f(x):', 'FontWeight', 'bold', ...
                'Position', [10 310 200 20]);
                
            uilabel(pLeft, 'Text', 'Hàm f(x):', 'Position', [10 285 60 20]);
            fx_field = uieditfield(pLeft, 'text', 'Position', [70 285 200 20], ...
                'Value', 'sin(x)', 'Placeholder', 'VD: x^2 + 1');
            
            uilabel(pLeft, 'Text', 'Bước h:', 'Position', [10 245 60 20]);
            h_field = uieditfield(pLeft, 'numeric', 'Position', [70 245 80 20], ...
                'Value', 0.01);
                
            uilabel(pLeft, 'Text', 'Sai số:', 'Position', [10 205 60 20]);
            err_dd = uidropdown(pLeft, 'Items', {'O(h)', 'O(h^2)'}, ...
                'Position', [70 205 80 20]);
            
            pRight = uipanel(app.Tab1, 'Title', 'Tính toán', ...
                'Position', [300 10 330 500]);
            
            uilabel(pRight, 'Text', 'Chọn phương pháp đạo hàm:', 'FontWeight', 'bold', ...
                'Position', [10 450 250 20]);
            method_dd = uidropdown(pRight, 'Items', {'Xấp xỉ Tiến', 'Xấp xỉ Lùi', 'Xấp xỉ Trung Tâm'}, ...
                'Position', [10 425 300 20]);
            
            uilabel(pRight, 'Text', 'Nhập giá trị x cần tính đạo hàm:', 'FontWeight', 'bold', ...
                'Position', [10 380 250 20]);
            x_calc = uieditfield(pRight, 'numeric', 'Position', [10 355 150 20], ...
                'Value', 0.5);
            
            btnCalc = uibutton(pRight, 'push', 'Text', 'Tính Đạo Hàm', ...
                'Position', [10 300 300 40], 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.9 0.9]);
            
            uilabel(pRight, 'Text', 'KẾT QUẢ:', 'FontWeight', 'bold', ...
                'Position', [10 260 100 20]);
            res_label = uitextarea(pRight, 'Position', [10 20 310 240], ...
                'Editable', 'off', 'FontSize', 13);

            % Callback
            btnCalc.ButtonPushedFcn = @(src,evt) tinh_daoham_cb(fx_field, xdata_field, ydata_field, x_calc, h_field, method_dd, err_dd, res_label);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Ứng Dụng Đạo Hàm', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app);
        end
    end

    methods (Access = public)
        function app = DaoHamApp
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
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
            
            result_text = sprintf(['KẾT QUẢ TÍNH TOÁN (TỪ HÀM SỐ):\n' ...
                                   '--------------------------------\n' ...
                                   'Hàm số: f(x) = %s\n' ...
                                   'Tại điểm x = %.4f\n' ...
                                   'Bước h = %.4f\n' ...
                                   'Phương pháp: %s\n\n' ...
                                   'Công thức: %s\n' ...
                                   'Giá trị đạo hàm ≈ %.6f'], ...
                                   f_str, x_val, h, method, formula, val);
                                   
        elseif ~isempty(xd_f.Value) && ~isempty(yd_f.Value)
            X = str2num(xd_f.Value); 
            Y = str2num(yd_f.Value); 
            
            if length(X) ~= length(Y)
                error('Số lượng phần tử X và Y không bằng nhau.');
            end
            [min_val, idx] = min(abs(X - x_val));
            
            warn_msg = '';
            if min_val > 1e-6
                 warn_msg = 'Cảnh báo: Điểm x cần tính không trùng khớp với dữ liệu X trong bảng. Kết quả được tính tại điểm gần nhất.';
            end
            
            try
                switch method
                    case 'Xấp xỉ Tiến'
                        if idx < length(X)
                            val = (Y(idx+1) - Y(idx)) / (X(idx+1) - X(idx));
                        else
                            error('Không thể dùng xấp xỉ Tiến tại điểm cuối cùng của dữ liệu.');
                        end
                    case 'Xấp xỉ Lùi'
                        if idx > 1
                            val = (Y(idx) - Y(idx-1)) / (X(idx) - X(idx-1));
                        else
                            error('Không thể dùng xấp xỉ Lùi tại điểm đầu tiên của dữ liệu.');
                        end
                    case 'Xấp xỉ Trung Tâm'
                        if idx > 1 && idx < length(X)
                            val = (Y(idx+1) - Y(idx-1)) / (X(idx+1) - X(idx-1));
                        else
                            error('Cần ít nhất một điểm bên trái và một điểm bên phải để dùng Trung tâm.');
                        end
                end
                
                result_text = sprintf(['KẾT QUẢ TÍNH TOÁN (TỪ DỮ LIỆU):\n' ...
                                       '--------------------------------\n' ...
                                       'Dữ liệu bảng X, Y\n' ...
                                       'Tại điểm x ≈ %.4f (index %d)\n' ...
                                       'Phương pháp: %s\n\n' ...
                                       'Giá trị đạo hàm ≈ %.6f\n\n%s'], ...
                                       X(idx), idx, method, val, warn_msg);
            catch err
                 result_text = ['Lỗi tính toán trên dữ liệu: ' err.message];
            end
            
        else
            result_text = 'Vui lòng nhập Hàm số HOẶC Dữ liệu bảng (X, Y).';
        end
        
        res.Value = result_text;
        
    catch ME
        res.Value = ['Lỗi: ', ME.message];
    end
end