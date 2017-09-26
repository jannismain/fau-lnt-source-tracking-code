function [ fig ] = plot_results( psi, loc_est, room)
%PLOT_RESULTS Plots location estimation results
%   Detailed explanation goes here

    scr_size = get(0,'ScreenSize');
    fig_size = [2*scr_size(3)/3 scr_size(4)/2];  % width x height
    fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
    fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
    fig = figure('Name','Location Estimate Result',...
                  'NumberTitle','off',...
                  'Color','white',...
                  'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);
    subplot_tight(1,2,1);
    imagesc(room.grid_x,room.grid_y,psi)
    set(gca,'Ydir','Normal')
    set(gca, 'box', 'off')
    hold on
    
    plot(room.R(:, 1), room.R(:, 2),'x','MarkerSize', 12, 'Linewidth',2,'Color','g');    
    plot(room.S(:, 1), room.S(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
    plot(loc_est(:, 1), loc_est(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');

    axis([0,room.dimensions(1),0,room.dimensions(2)]);
    % colorbar('East', 'AxisLocation', 'out', 'Ticks', [0.01 0.02 0.03]);
    % colormap(flipud(gray));  % apply inverted b/w colormap
    % title(sprintf('Location Estimate\n(Est. Err.: %1.2fm, %1.2fm, T60=%1.2fs)', est_error1,est_error2,cfg.synth_room.t60));
    subplot_tight(1,2,2);
    surf(room.grid_x,room.grid_y,psi)
    view([-65 25]);
    shading interp
    pause(0.1)

end

