fprintf('------------------------- T E S T R U N -------------------------\n');
%% setting parameters
sources = 7;
md = 5;
wd = 12;
rand_sources = false;
rand_samples = false;
T60=0.6;
SNR=0;
em_iterations=10;
em_conv_threshold=0.0001;
guess_randomly=false;
reflect_order=3;
var_init=10;
var_fixed = false;
get_em_history = false;

%% init
tic;
fn_conf = config_update(sources,rand_sources, md,wd,rand_samples,T60,em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed);
load(fn_conf);

%% Simulate Environment
x = simulate(fn_cfg, ROOM, R, sources, false);
n_sources = size(x,2);

%% Overview
figure;
for s=1:n_sources
    xtemp = x(:,s,1,1);
    
    subplot(n_sources, 2, 2*s-1);
    plot(xtemp);
    xlabel('t')
    ylabel(sprintf("x(t)"))
    ylim([-0.5 0.5])
    
    subplot(n_sources,2,2*s);
    specgram(xtemp);
    xlabel('t')
    ylabel('k')
end

%% Save seperate plots
for s=1:n_sources
    xtemp = x(:,s,1,1);
    for i=1:2
        fig = figure; hold on;
        if i==1
            plot(xtemp, 'Color', [0.8000,0.2078,0.2196]);
            xlabel('t')
            ylabel(sprintf("x(t)"))
            ylim([-0.5 0.5])
            xticks(linspace(0,80000,6))
            xticklabels(linspace(0,5,6))
            fname = sprintf("s%d-time", s);
        else
            xtemp = xtemp + 0.01*(rand(size(xtemp))-0.5);
            specgram(xtemp,fft_bins,fs,fft_window,fft_overlap_samples);
            ylim([0 1])
            xlabel('t')
            ylabel('k')
            %TODO: give axis sensible tick labels
            fname = sprintf("s%d-stft", s);
        end
        matlab2tikz(char(strcat(fname, '.tikz')),...
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
        saveas(fig, char(strcat(fname, '.png')));
        close gcf; clear fig;
    end
end

%% Try to visualise sparseness
% x2 = x(:,2,1,1);
% x3 = x(:,3,1,1);
% x23 = sum(x(:,2:3,1,1),2);
% x46 = sum(x(:,4:6,1,1),2);
% p12 = abs(imag(specgram(x2)).*imag(specgram(x3)));
% figure;
% subplot(1,2,1)
% mesh(p12)
% view([0 0])
% title('X2*X3')
% colormap('jet')
% 
% p2346 = abs(imag(specgram(x23)).*imag(specgram(x46)));
% subplot(1,2,2)
% mesh(p2346)
% view([0 0])
% title('(X2+X3)*(X4+X5+X6)')
% colormap('jet')

delete(fn_cfg);