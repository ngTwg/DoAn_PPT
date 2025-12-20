classdef NoiSuyApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab 
    end

    methods (Access = private)
        
        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Nội Suy');
            
            pIn = uipanel(app.Tab1, 'Title', 'Dữ liệu đầu vào', 'Position', [10 350 280 210]);
            
            uilabel(pIn, 'Text', 'X (cách nhau dấu phẩy):', 'Position', [10 160 200 20]);
            x_field = uieditfield(pIn, 'text', 'Position', [10 140 250 20], 'Value', '0.1, 0.2, 0.3, 0.4');
            
            uilabel(pIn, 'Text', 'Y (cách nhau dấu phẩy):', 'Position', [10 110 200 20]);
            y_field = uieditfield(pIn, 'text', 'Position', [10 90 250 20], 'Value', '0.099, 0.198, 0.295, 0.389');
            
            uilabel(pIn, 'Text', 'Phương pháp:', 'Position', [10 50 80 20]);
            method_dd = uidropdown(pIn, 'Items', {'Lagrange', 'Newton'}, ...
                'Position', [90 50 170 20]);
            
            pCalc = uipanel(app.Tab1, 'Title', 'Tính giá trị', 'Position', [10 200 280 140]);
            uilabel(pCalc, 'Text', 'Giá trị cần nội suy x*:', 'Position', [10 90 120 20]);
            xval_field = uieditfield(pCalc, 'numeric', 'Position', [140 90 100 20], 'Value', 0.14);
            
            btnCalc = uibutton(pCalc, 'push', 'Text', 'Tính Nội Suy', ...
                'Position', [70 20 140 30], 'FontWeight', 'bold');

            ax2 = uiaxes(app.Tab1, 'Position', [300 200 340 360]);
            title(ax2, 'Đồ thị Nội suy');

            pRes = uipanel(app.Tab1, 'Title', 'Kết quả', 'Position', [10 10 630 180]);
            
            uilabel(pRes, 'Text', 'Đa thức nội suy:', 'Position', [10 130 120 20]);
            res_poly = uieditfield(pRes, 'text', 'Position', [130 130 480 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Kết quả tại x*:', 'Position', [10 90 120 20]);
            res_val = uieditfield(pRes, 'text', 'Position', [130 90 150 20], 'Editable', 'off');

            % Gán Callback
            btnCalc.ButtonPushedFcn = @(src,evt) tinh_noisuy_cb(x_field, y_field, xval_field, method_dd, ax2, res_poly, res_val);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Ứng Dụng Nội Suy', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app);
        end
    end

    methods (Access = public)
        function app = NoiSuyApp
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
    end
end


function tinh_noisuy_cb(x_f, y_f, xv_f, met_d, ax, res_p, res_v)
    try
        
        x = str2num(x_f.Value); 
        y = str2num(y_f.Value); 
        xp = xv_f.Value;
        method = met_d.Value;
        
        if length(x) ~= length(y)
            error('Số lượng phần tử X và Y không bằng nhau.');
        end
        
        if strcmp(method, 'Lagrange')
             yp = lagrange_interp(x, y, xp);
             poly_str = 'P_n(x) = L_0(x)y_0 + ... + L_n(x)y_n';
        else
             yp = lagrange_interp(x, y, xp); 
             poly_str = 'P_n(x) (Newton - chưa cài đặt chi tiết, dùng tạm Lagrange)';
        end
        
        res_p.Value = poly_str;
        res_v.Value = sprintf('%.6f', yp);
        
        xx = linspace(min(x), max(x), 100);
        yy = arrayfun(@(k) lagrange_interp(x, y, k), xx);
        
        cla(ax); hold(ax, 'on');
       
        plot(ax, x, y, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
       
        plot(ax, xx, yy, 'b-', 'LineWidth', 1.5);

        plot(ax, xp, yp, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
        
        legend(ax, 'Dữ liệu mẫu', 'Đường nội suy', 'Điểm cần tính');
        grid(ax, 'on'); hold(ax, 'off');
        
    catch ME
        res_v.Value = 'Lỗi nhập liệu';
        uialert(ancestor(ax, 'figure'), ME.message, 'Lỗi Tính Toán');
    end
end


function y = lagrange_interp(X, Y, x)
    % Hàm tính nội suy Lagrange tại điểm x
    n = length(X);
    y = 0;
    for i = 1:n
        L = 1;
        for j = 1:n
            if i ~= j
                L = L * (x - X(j)) / (X(i) - X(j));
            end
        end
        y = y + Y(i) * L;
    end
end