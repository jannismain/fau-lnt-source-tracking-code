function plot_variance(variance, legend_labels, c, archive, save_to)
%  PLOT_VARIANCE Plots variance with form A x E x T, where A is an index for the algorithm
%  used ('CREM', 'TREM'), E is an index for the Evaluation (var=0.1, var=0.5, ...) and T
%  are the actual variance values.
%
%  Example:
%      variance(1, E, :) = rem_tracking(...,'crem');
%      variance(2, E, :) = rem_tracking(...,'trem');
%      plot_variance(variance, {'CREM', 'TREM'});
    
% Parse input arguments, set default values if missing
    if nargin<2, legend_labels = {'CREM', 'TREM'}; end
    if nargin<3
        c.lmsred = [0.8000,0.2078,0.2196];
        c.darkgrey = [0.1, 0.1, 0.1];
    end
    if nargin<4, archive=false; end
    if nargin<5, save_to=[getuserdir filesep 'latex' filesep 'plots' filesep 'tracking' filesep 'variance' filesep]; [~,~]=mkdir(save_to);end
    %else, if ~strcmp(save_to(end), filesep), save_to = strcat(save_to, filesep); end; end
    
    E = size(variance, 2);
    T = size(variance, 3);
    xvalues = linspace(1,T,T);
    fig = figure('Name','Variance'); hold on; box on; grid on;
    for e=1:E  % plotting the different evaluations in a loop allows us to create a correct legend
        plot(xvalues, squeeze(variance(1,e,:))', 'Color', c.lmsred, 'LineWidth', 1);
        plot(xvalues, squeeze(variance(2,e,:))', 'Color', c.darkgray, 'LineWidth', 1);
    end

    xlabel('t') % x-axis label
    ylabel(sprintf("\\sigma^2")) % y-axis label
    xlim([0,T])
    legend(legend_labels{:},'Location','NorthEast')
    if archive
        matlab2tikz(char(strcat(save_to, 'variance-comparison.tikz')),...
                    'figurehandle', fig,...
                    'imagesAsPng', true,...
                    'checkForUpdates', false,...
                    'externalData', false,...
                    'height', '\figureheight',...
                    'width', '\figurewidth',...
                    'noSize', false,...
                    'showInfo', false,...
                    'interpretTickLabelsAsTex',true,...
                    'extraColors', {{'lms_red',c.lmsred}, {'darkgray',c.darkgray}});
    end
end
