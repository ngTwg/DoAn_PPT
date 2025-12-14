classdef TimNghiemApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        Tab1                    matlab.ui.container.Tab 
    end

    methods (Access = private)
        
        function setupTab1(app)
            app.Tab1 = uitab(app.TabGroup, 'Title', 'Tìm Nghiệm');
            
            pLeft = uipanel(app.Tab1, 'Title', 'Nhập liệu', ...
                'Position', [10 280 280 280]);
                
            uilabel(pLeft, 'Text', 'Hàm f(x):', 'Position', [10 230 60 20]);
            fx_field = uieditfield(pLeft, 'text', 'Position', [80 230 180 20], 'Value', 'x.^2 - 2*sin(x) + 0.5');
            
            uilabel(pLeft, 'Text', 'Khoảng [a, b]:', 'Position', [10 190 80 20]);
            a_field = uieditfield(pLeft, 'numeric', 'Position', [90 190 50 20], 'Value', -1);
            b_field = uieditfield(pLeft, 'numeric', 'Position', [150 190 50 20], 'Value', 2);
            
            uilabel(pLeft, 'Text', 'Sai số (eps):', 'Position', [10 150 80 20]);
            eps_field = uieditfield(pLeft, 'numeric', 'Position', [90 150 80 20], 'Value', 0.005);
            
            uilabel(pLeft, 'Text', 'Phương pháp:', 'Position', [10 110 80 20]);
            
            method_dd = uidropdown(pLeft, 'Items', {'Chia Đôi', 'Lặp Đơn', 'Newton'}, ...
                'Position', [90 110 170 20]);
            
            btnCalc = uibutton(pLeft, 'push', 'Text', 'Tìm Nghiệm', ...
                'Position', [80 30 120 40], 'FontWeight', 'bold');

            ax1 = uiaxes(app.Tab1, 'Position', [300 280 340 280]);
            title(ax1, 'Đồ thị hàm số');
            grid(ax1, 'on');

            pRes = uipanel(app.Tab1, 'Title', 'Kết quả', ...
                'Position', [10 10 630 250]);
            
            uilabel(pRes, 'Text', 'Nghiệm tìm được:', 'Position', [20 200 120 20]);
            res_root = uieditfield(pRes, 'text', 'Position', [150 200 150 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Số lần lặp:', 'Position', [350 200 100 20]);
            res_iter = uieditfield(pRes, 'text', 'Position', [460 200 100 20], 'Editable', 'off');
            
            uilabel(pRes, 'Text', 'Chi tiết:', 'Position', [20 170 100 20]);
            res_detail = uitextarea(pRes, 'Position', [20 10 590 160], 'Editable', 'off');

            btnCalc.ButtonPushedFcn = @(src,evt) tinh_nghiem_cb(fx_field, a_field, b_field, eps_field, method_dd, ax1, res_root, res_iter, res_detail);
        end
        
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Ứng Dụng Tìm Nghiệm', 'Position', [100 100 650 600]);
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [1 1 650 600]);
            
            setupTab1(app); 
        end
    end

    methods (Access = public)
        function app = TimNghiemApp
            createComponents(app);
            movegui(app.UIFigure, 'center');
        end
    end
end
%Logic 

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
                % Tính đạo hàm tự động cho Newton
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
        res_d.Value = sprintf('Phương pháp: %s\nKhoảng phân ly: [%.2f, %.2f]\nSai số cho phép: %g\n%s', method, a, b, tol, msg);
        
        hold(ax, 'on'); 
        plot(ax, root, f(root), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); 
        hold(ax, 'off');
        
    catch ME
        res_d.Value = ['Lỗi: ' ME.message];
    end
end


function [c, k] = bisection_method(f, a, b, tol)
    % Phương pháp chia đôi
    k = 0; c = a;
    if f(a)*f(b) >= 0
        error('Khoảng phân ly không chứa nghiệm hoặc chứa nghiệm kép (f(a)*f(b) >= 0).'); 
    end
    while (b-a)/2 > tol
        k = k+1;
        c = (a+b)/2;
        if f(c) == 0, break; end
        if f(a)*f(c) < 0, b = c; else, a = c; end
    end
end

function [x1, k] = newton_method(f, df, x0, tol)
    % Phương pháp Newton (Tiếp tuyến)
    k = 0; x1 = x0;
    while k < 1000 
        fx = f(x1);
        if abs(fx) < tol, break; end
        
        dfx = df(x1);
        if dfx == 0, error('Đạo hàm bằng 0, không thể dùng Newton.'); end
        
        x1 = x1 - fx/dfx;
        k = k + 1;
    end
end

function [x1, k] = fixed_point_method(g, x0, tol)
    % Phương pháp Lặp đơn
    k = 0; x1 = x0;
    while k < 1000
        x_new = g(x1);
        if abs(x_new - x1) < tol, break; end
        x1 = x_new;
        k = k + 1;
    end
end