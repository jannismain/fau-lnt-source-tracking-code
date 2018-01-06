%% setting parameters
PATH_LATEX_TRIAL = [getuserdir filesep 'latex' filesep 'plots' filesep 'tracking' filesep 'variance' filesep];
PATH_MATLAB = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'tracking' filesep 'evaluation' filesep 'results' filesep 'variance' filesep];
[~,~]=mkdir(PATH_LATEX_TRIAL); [~,~]=mkdir(PATH_MATLAB);

% static parameters
T60=0.4;
SNR=30;
samples=500;
source_length = 5; % seconds
freq_range=[];
method='fastISM';

% variable parameters
src_config = [string('parallel'), string('crossing'), string('arc')];
init_vars = [.1, .5, 1, 2, 5];
algorithmus = [string('CREM'), string('TREM')];

for s=1:length(src_config)
    %% INIT TRIAL
    cd(PATH_MATLAB);
    tic;
    config_update_tracking(src_config(s),T60,-1,SNR,samples,source_length,freq_range,method);
    load('config.mat');

    %% SIMULATE
    [x, sources.sdata] = simulate_tracking();
    [X, phi] = stft('config.mat', x);
    ang_dist = rem_init(phi);

    %% SOURCE TRACKING
    
    var_hist = zeros(length(algorithmus),length(init_vars),em.T+1);
    for alg=1:length(algorithmus)
        for var=1:length(init_vars)
            [psi, loc_est, var_hist(alg,var,:), psi_history] = rem_tracking(ang_dist, algorithmus(alg), init_vars(var));
        end
    end

    %% PLOTTING
    plot_variance(var_hist, {algorithmus(1),algorithmus(2)}, c, true, strcat(PATH_LATEX_TRIAL, src_config(s), '-'));

end