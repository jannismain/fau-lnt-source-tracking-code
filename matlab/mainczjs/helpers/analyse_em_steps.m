function analyse_em_steps(psi, n_sources, md, room)
%PLOT_EM_STEPS A helper to visualise the incremental changes in between em iterations
%
%   PARAMETERS:
%   psi: a history of estimates psi-matrices size(psi) = (trials x n_sources x coordinate)
%        Example: size(psi)=7x5x2 for 7 trials with 5 sources (and 2 coordinates)

if size(psi, 3) == 1, err("psi needs to be in the following shape: psi(trial, source, coordinate)"); end

em_iterations = size(psi, 1);
% x_vals = linspace(0,em_iterations,em_iterations+1);
loc_est_sorted = zeros(em_iterations, n_sources, 2);
est_err = zeros(em_iterations, n_sources);

scr_size = get(0,'ScreenSize');
fig_size = [5*scr_size(3)/6 scr_size(4)/2];  % width x height
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
fig1 = figure('Name','EM Iterations Overview',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos scr_size(4)-fig_size(2)/1.5-50 fig_size(1) fig_size(2)/1.5],...
              'Visible','off',...
              'MenuBar','none');
fig2 = figure('Name','Progression of psi',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos scr_size(4)-fig_size(2)-scr_size(4)/2 fig_size(1) fig_size(2)],...
              'Visible','off',...
              'MenuBar','none');

for i=1:em_iterations
    loc_est = estimate_location(squeeze(psi(i, :, :)), n_sources, 0, md, room);
    [loc_est_sorted(i,:,:), est_err(i,:)] = estimation_error(room.S, loc_est);
    % plot
    for s=1:n_sources+1
        figure(fig1);
        subplot_tight(1,n_sources+1,s)
        if s~=n_sources+1
            plot(est_err(:, s), 'LineWidth',2,'Color',[0.4 0.4 0.4], 'Marker', 'x', 'MarkerSize', 12);
            title(sprintf("S%d Estimation Error", s));
        else  % last iteration, plot mean
            plot(mean(est_err, 2), 'LineWidth',2,'Color',[204/255 53/255 56/255], 'Marker', 'x', 'MarkerSize', 12);
            title("Average Estimation Error");
        end
        ylim([-0.1 4.0])
        yticks(linspace(0, 4, 21))
        grid on
    end
    figure(fig2);
    subplot_tight(2,em_iterations,i)
    
    psi_plot = zeros(room.Y,room.X);
    psi_plot((room.N_margin+1):(room.Y-room.N_margin),(room.N_margin+1):(room.X-room.N_margin)) = squeeze(psi(i,:,:));
    
    imagesc(room.grid_x,room.grid_y,psi_plot)
    set(gca,'Ydir','Normal')
    set(gca, 'box', 'off')
    hold on

    plot(room.R(:, 1), room.R(:, 2),'x','MarkerSize', 12, 'Linewidth',2,'Color','g');    
    plot(room.S(:, 1), room.S(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
    plot(loc_est(:, 1), loc_est(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');

    axis([0,room.dimensions(1),0,room.dimensions(2)]);
    subplot_tight(2,em_iterations,i+em_iterations)
    surf(room.grid_x,room.grid_y,psi_plot)
    view([-65 25]);
    shading interp
    
end
    
end