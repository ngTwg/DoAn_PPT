classdef HoiQuyApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab 
    end

    methods (Access = private)
        
        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Hồi Quy');
            
            pIn = uipanel(app.Tab1, 'Title', 'Dữ liệu mẫu', 'Position', [10 300 250 260]);
            
            uilabel(pIn, 'Text', 'Dữ liệu X:', 'Position', [10 210 100 20]);
            x_field = uieditfield(pIn, 'text', 'Position', [10 190 230 20], ...
                'Value', '1, 2, 3, 4, 5', 'Placeholder', 'Ví dụ: 1, 2, 3');
            
            uilabel(pIn, 'Text', 'Dữ liệu Y:', 'Position', [10 160 100 20]);
            y_field = uieditfield(pIn, 'text', 'Position', [10 140 230 20], ...
                'Value', '2.1, 4.0, 5.8, 8.1, 9.9', 'Placeholder', 'Ví dụ: 2, 4, 6');
            
            uilabel(pIn, 'Text', 'Dạng hồi quy:', 'Position', [10 100 100 20]);
            method_dd = uidropdown(pIn, 'Items', {'Tuyến Tính (ax+b)', 'Hàm Mũ (ae^bx)', 'Logarit (a+blnx)'}, ...
                'Position', [10 80 230 20]);
                
            btnCalc = uibutton(pIn, 'push', 'Text', 'Tính Hồi Quy', ...
                'Position', [60 20 120 30], 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.9 0.9]);
                
            pPred = uipanel(app.Tab1, 'Title', 'Dự báo', 'Position', [10 150 250 140]);
            uilabel(pPred, 'Text', 'Nhập x cần dự báo:', 'Position', [10 90 120 20]);
            pred_x = uieditfield(pPred, 'numeric', 'Position', [140 90 80 20]);
            
            uilabel(pPred, 'Text', 'Kết quả dự báo y:', 'Position', [10 50 120 20]);
            pred_y = uieditfield(pPred, 'text', 'Position', [140 50 80 20], 'Editable', 'off');

            ax3 = uiaxes(app.Tab1, 'Position', [270 150 370 410]);
            title(ax3, 'Đồ thị Hồi quy');
            grid(ax3, 'on');
            
            pRes = uipanel(app.Tab1, 'Title', 'Kết quả phương trình', 'Position', [10 10 630 130]);
            res_eq = uilabel(pRes, 'Text', 'Phương trình: ...', ...
                'Position', [20 50 590 40], 'FontSize', 14, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'FontColor', 'b');

            % Gán Callback
            btnCalc.ButtonPushedFcn = @(src,evt) tinh_hoiquy_cb(x_field, y_field, method_dd, pred_x, pred_y, ax3, res_eq);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Ứng Dụng Hồi Quy', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app);
        end
    end

    methods (Access = public)
        function app = HoiQuyApp
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
    end
end

function tinh_hoiquy_cb(xf, yf, md, px, py, ax, req)
    try
        x = str2num(xf.Value); 
        y = str2num(yf.Value); 
        method = md.Value;
        x_pred = px.Value;
        
        if isempty(x) || isempty(y)
            error('Vui lòng nhập đầy đủ dữ liệu X và Y');
        end
        if length(x) ~= length(y)
            error('Độ dài vector X và Y phải bằng nhau');
        end
        
        cla(ax); hold(ax, 'on');
        plot(ax, x, y, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
        
        xfit = linspace(min(x), max(x), 100);
        yfit = [];
        y_pred = NaN;
        
        if contains(method, 'Tuyến Tính')
            
            p = polyfit(x, y, 1);
            a = p(1); b = p(2);
            
            yfit = polyval(p, xfit);
            if ~isempty(x_pred), y_pred = polyval(p, x_pred); end
            
            req.Text = sprintf('Phương trình: y = %.4fx + %.4f', a, b);
            
        elseif contains(method, 'Hàm Mũ')
           
            if any(y <= 0)
                error('Hồi quy hàm mũ yêu cầu tất cả giá trị Y > 0');
            end
            
            p = polyfit(x, log(y), 1);
            b = p(1);
            A = p(2);
            a = exp(A);
            
            yfit = a * exp(b * xfit);
            if ~isempty(x_pred), y_pred = a * exp(b * x_pred); end
            
            req.Text = sprintf('Phương trình: y = %.4f * e^(%.4fx)', a, b);
            
        else 
            if any(x <= 0)
                error('Hồi quy Logarit yêu cầu tất cả giá trị X > 0');
            end
            
            p = polyfit(log(x), y, 1);
            b = p(1); 
            a = p(2); 
            
            yfit = polyval(p, log(xfit));
            if ~isempty(x_pred)
                if x_pred <= 0
                    y_pred = NaN; 
                    uialert(ancestor(ax,'figure'), 'Giá trị dự báo X phải > 0', 'Lỗi');
                else
                    y_pred = polyval(p, log(x_pred)); 
                end
            end
            
            req.Text = sprintf('Phương trình: y = %.4f + %.4f * ln(x)', a, b);
        end
        
        plot(ax, xfit, yfit, 'b-', 'LineWidth', 2);
        
        if ~isempty(x_pred) && ~isnan(y_pred)
            plot(ax, x_pred, y_pred, 'g*', 'MarkerSize', 12, 'LineWidth', 2);
            py.Value = sprintf('%.4f', y_pred);
            legend(ax, 'Dữ liệu thực', 'Đường hồi quy', 'Điểm dự báo');
        else
            py.Value = '';
            legend(ax, 'Dữ liệu thực', 'Đường hồi quy');
        end
        
        grid(ax, 'on'); hold(ax, 'off');
        
    catch ME
        req.Text = ['Lỗi: ' ME.message];
        uialert(ancestor(ax,'figure'), ME.message, 'Lỗi Tính Toán');
    end
end