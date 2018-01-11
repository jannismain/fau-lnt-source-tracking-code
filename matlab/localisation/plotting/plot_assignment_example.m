fdir = [getuserdir filesep 'latex' filesep 'data' filesep 'plots' filesep 'reference' filesep];


[~, ] = evalc('plot_simulation_environment;');
EXPORT = true; % this is here, because plot_sim... resets EXPORT to false
hold on;


% fname = 'assignment-clear';
% E = [2.5 3;
%      3.5 3.2];

fname = 'assignment-debatable';
E = [1.3 4.2;
     2.8 3];


% fname = 'assignment-ambiguous';
% E = [3.0 1.7;
%      3.0 4.0];

fpath = strcat(fdir, fname);
[~, ~, est_err] = evalc('estimation_error(S,E);');
[~, ~, est_err_min] = evalc('estimation_error_min(S,E);');
[~, ~, est_err_rad] = evalc('estimation_error_rad(S,E);');
fprintf("\nestimate-error result:     est-err1=%0.1f, est-err2=%0.1f, mean-err=%0.2f\n", est_err(1), est_err(2), mean(est_err));
fprintf("estimate-error-min result: est-err1=%0.1f, est-err2=%0.1f, mean-err=%0.2f\n", est_err_min(1), est_err_min(2), mean(est_err_min));
fprintf("estimate-error-rad result: est-err1=%0.1f, est-err2=%0.1f, mean-err=%0.2f\n", est_err_rad(1), est_err_rad(2), mean(est_err_rad));
fprintf("First Possibility:         est-err1=%0.1f, est-err2=%0.1f, mean-err=%0.2f\n", norm(S(1,1:2)-E(1,:)), norm(S(2,1:2)-E(2,:)), (norm(S(1,1:2)-E(1,:))+norm(S(2,1:2)-E(2,:)))/2); 
fprintf("Second Possibility:        est-err1=%0.1f, est-err2=%0.1f, mean-err=%0.2f\n", norm(S(2,1:2)-E(1,:)), norm(S(1,1:2)-E(2,:)), (norm(S(2,1:2)-E(1,:))+norm(S(1,1:2)-E(2,:)))/2);

ax_est = plot(squeeze(E(:,1)), squeeze(E(:,2)), 'yx', 'MarkerSize', 12, 'Linewidth',1);

if EXPORT
    % export to tikz
    matlab2tikz([fpath '.tex'],...
               'figurehandle', fig,...
               'imagesAsPng', true,...
               'checkForUpdates', false,...
               'externalData', false,...
               'relativeDataPath', 'data/plots/setup/tikz-data/',...
               'dataPath', strcat(fdir, 'tikz-data', filesep),...
               'noSize', false,...
               'width', '\figurewidth',...
               'height', '\figureheight',...
               'showInfo', false);

    % resize elements for non-tikz output
    for i=1:length(axd1)
        axd1(i).MarkerSize = 1;
    end
    for i=1:length(axd2)
        axd2(i).MarkerSize = 1;
    end
    for i=1:length(ax_s)
        ax_s(i).MarkerSize = 6;
    end
    for i=1:length(ax_r)
        ax_r(i).MarkerSize = 3;
    end
    for i=1:length(ax_est)
        ax_est(i).MarkerSize = 6;
    end

    % export as pdf
    print(fig, '-dpdf', [fpath '.pdf'], '-bestfit');
    %export as png/jpeg
%     print(fig, '-dpng', [fpath '_PRINT.png']);
%     saveas(fig, [fpath '_SAVEAS.png']);
    saveas(fig, [fpath '.png']);
    saveas(fig, [fpath '.jpg']);
end
