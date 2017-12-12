%% setting parameters
PATH_LATEX = [getuserdir filesep 'latex' filesep 'plots' filesep 'tracking' filesep];
PATH_MATLAB = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'mainczjs_tracking' filesep 'evaluation' filesep 'results' filesep];

% static parameters
SNR=30;
samples=500;
source_length = 5; % seconds
freq_range=[];
method='fastISM';
gamma = 0.1;

% variable parameters
% src_config = [string('parallel'), string('crossing'), string('arc')];
src_config = [string('parallel')];
T60_list=[0.7];

for t=1:length(T60_list)
for scfg=1:length(src_config)
    %% INIT TRIAL
    PATH_LATEX_TRIAL = char([PATH_LATEX char(src_config(scfg)) filesep]); [~,~] = mkdir(PATH_LATEX_TRIAL);
    PATH_MATLAB_TRIAL = char(strcat(PATH_MATLAB, src_config(scfg), filesep)); [~,~] = mkdir(PATH_MATLAB_TRIAL);
    cd(PATH_MATLAB_TRIAL);

    tic;
    config_update_tracking(src_config(scfg),T60_list(t),-1,SNR,samples,source_length,freq_range,method, gamma);
    load('config.mat');

    %% SIMULATE
    [x, sources.sdata] = simulate_tracking();
    [X, phi] = stft('config.mat', x);
    ang_dist = rem_init(phi);

    %% SOURCE TRACKING
    init_vars = [1];
    var_hist = zeros(2,length(init_vars),em.T+1);
    for v=1:length(init_vars)
        [psi_crem, loc_est_crem, var_hist(1,v,:), psi_history_crem] = rem_tracking(ang_dist, 'crem', init_vars(v));
        [psi_trem, loc_est_trem, var_hist(2,v,:), psi_history_trem] = rem_tracking(ang_dist, 'trem', init_vars(v));
    end

    % analyse_em_steps_tracking(psi_history, var_history, room, sources);

    %% PLOTTING
%     plot_variance(var_hist, {'CREM','TREM'}, c, true, strcat(PATH_LATEX_TRIAL, sprintf('results-T60=%0.1f-crem-', T60_list(t))));

%     scr_size = get(0,'ScreenSize');  % [1, 1, 2560, 1440] on 2k resolution screen
%     offset = 100;
%     fig_size = [(scr_size(3)-2*offset)/4 scr_size(4)-2*offset];  % width x height
%     fig_xpos = ceil(scr_size(3)/4);
%     fig_ypos = ceil((scr_size(4)-2*offset-fig_size(2))/2); % center the figure on the screen vertically
    % 'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);
    % 
%     fig_crem = figure('Name', 'Estimated Coordinates over Time (CREM)', 'Position', [offset,offset,fig_size(1),fig_size(2)]);
%     fig_trem = figure('Name', 'Estimated Coordinates over Time (TREM)', 'Position', [fig_xpos+offset,offset,fig_size(1), fig_size(2)]);
    
%     plot_loc_est_history_c(loc_est_crem, sources, char(sprintf('T60=%0.1f-crem-TEST', T60_list(t))))
%     plot_loc_est_history_c(loc_est_trem, sources, char(sprintf('T60=%0.1f-trem-TEST', T60_list(t))))
    % 
    plot_results_tracking(loc_est_crem, sources, room, true, char(sprintf('T60=%0.1f-crem-room-K=%d-T=%d-gamma=%d-', T60_list(t), em.K, em.T, gamma*10)));
    plot_results_tracking(loc_est_trem, sources, room, true, char(sprintf('T60=%0.1f-trem-room-K=%d-T=%d-gamma=%d-', T60_list(t), em.K, em.T, gamma*10)))
    
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');

end
end