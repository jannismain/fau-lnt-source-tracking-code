function loc_err = random_sources_eval(n_sources, trials, min_distance)

%% function argument handling
if nargin < 1
    n_sources = 2;
end
if nargin < 2
    trials = 10;
end
if nargin < 3
    min_distance = 0.5;
end

%% initialisation
cprintf('-comment', '                E V A L U A T I O N                \n');
loc_err = zeros(trials, n_sources);

%% trials
for trial=1:trials
    cprintf('*blue', '   [Trial %d/%d]: %d sources, %1.2f minimal distance\n', trial, trials, n_sources, min_distance/10);
    tic;
    log_cfg_update = evalc('config_update(n_sources, true, min_distance);');
    load('config.mat');
    for s=1:n_sources
        fprintf("%s Source Location #%d = [x=%0.2f, y=%0.2f]\n", FORMAT_PREFIX, s, S(s,1:2));
    end
    [log_simulate, x, fig] = evalc('simulate(ROOM, R, S);');
%     [x, fig] = simulate(ROOM, R, S);
    [log_stft, X, phi] = evalc('stft(x);');
    cfg = set_params_evaluate_Gauss();
    subplot_tight(2,2,[2 4], PLOT_BORDER);
    [log_loc_est, psi, est_error1, est_error2] = evalc('bren_estimate_location(cfg, phi);');
    if trials>1
        loc_err(trial, :) = [est_error1, est_error2];
    else
        loc_err = [est_error1, est_error2];
    end
    fprintf("%s Localisation Estimation Error = [%0.2f, %0.2f]\n", FORMAT_PREFIX, est_error1, est_error2)
end

%% results
cprintf('*err', '   [   RESULT]: Mean Localisation Error = %0.2f (Total Runtime = %s)\n', mean(mean(loc_err)), num2str(toc)');

end