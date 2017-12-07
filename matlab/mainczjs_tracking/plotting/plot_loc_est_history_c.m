function [fig] = plot_loc_est_history_c(loc_est_history, sources, alg)

T = size(loc_est_history, 2);
traj = zeros(sources.n, T,3);
for s=1:sources.n
    if strcmp(sources.cfg, 'arc')
        traj(s,:,:) = get_trajectory_arc(squeeze(sources.p(s,:)), squeeze(sources.p(s,:)+sources.movement(s,:)),1,T,false);
    else
        traj(s,:,:) = get_trajectory_from_source(squeeze(sources.p(s,:)),squeeze(sources.movement(s,:)), T);
    end
end

for i=1:2
    fig = figure; hold on;
    fdir = [getuserdir filesep 'latex' filesep 'plots' filesep 'tracking' filesep char(sources.cfg) filesep];
    fname = ['results-' alg];
    if i==1  % Plot X-Axis
        plot(squeeze(loc_est_history(:,:,1))', 'x', 'Color', [204/255, 53/255, 56/255])
        plot(traj(:,:,1)', '--');
        fname = [fname '-x'];
        ylabel('\\bm p_x')
    else  % Plot Y-Axis
        plot(squeeze(loc_est_history(:,:,2))', 'x', 'Color', [204/255, 53/255, 56/255])
        plot(traj(:,:,2)', '--');
        fname = [fname '-y'];
        ylabel('\\bm p_y')
    end
    xlabel('t'); % x-axis label
    xlim([0,T]);
    xticks(linspace(0,T,6));
    xticklabels(linspace(0,5,6));
    matlab2tikz(char(strcat(fdir, fname, '.tikz')),...
                    'figurehandle', fig,...
                    'imagesAsPng', true,...
                    'checkForUpdates', false,...
                    'externalData', false,...
                    'height', '\figureheight',...
                    'width', '\figurewidth',...
                    'noSize', false,...
                    'showInfo', false,...
                    'interpretTickLabelsAsTex',true,...
                    'extraColors', {{'lms_red',[0.8000,0.2078,0.2196]}});
    saveas(fig, char(strcat(fdir, fname, '.png')));
    close gcf; clear fig;
end