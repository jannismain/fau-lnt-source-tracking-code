function analyse_pdf(phi)

if nargin==0
    try
        phi = evalin('base','phi');
    catch
        try
            load('analysis.mat')
            if ~exist('phi')>1, error("provide phi"); end
        catch
            error('provide phi');
        end
    end
end

scr_size = get(0,'ScreenSize');
fig_size = [scr_size(3)-100 scr_size(4)-100];  % width x height
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
% for t=1:37:296
%     figure('Name',sprintf('PDF for all frequency bins at time bin %d', t),'Position',[fig_xpos fig_ypos fig_size(1) fig_size(2)],'MenuBar','none');
%     for i=1:9
%         for j=0:2
%             if i+j*9<=26
%                 subplot_tight(3,9,i+j*9)
%                 surf(squeeze(phi(i+j*9,t,:,:)))
%                 title(sprintf("K=%d", i+j*9))
%             end
%         end
%     end
% end

fig2 = figure('Name','PDF for some time bins',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)],...
              'Visible','off',...
              'MenuBar','none');
for i=1:9
    for j=0:2
        if i+j*9<=26
            subplot_tight(3,9,i+j*9)
            surf(squeeze(phi(i+j*9,1,:,:)))
            title(sprintf("K=%d", i+j*9))
        end
    end
end
end