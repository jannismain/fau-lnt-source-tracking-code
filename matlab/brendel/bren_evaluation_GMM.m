clear all

tic;
rng('default')

num_trials = 1;
error1 = zeros(num_trials,1);
error2 = zeros(num_trials,1);
error1_fP = zeros(num_trials,1);
error2_fP = zeros(num_trials,1);
num_maxima = zeros(num_trials,1);

for idx_trial = 1:num_trials
    %% Config Update
    disp('----------------------------------------------------------------')
    disp(['trial ',num2str(idx_trial)])
    disp('----------------------------------------------------------------')
    
    fprintf('Setting simulation parameters...');
    cfg = set_params_evaluate_Gauss();
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    
    %% Simulate
    fprintf('Creating microphone signals...\n');
    try
        load('x_brendel.mat');
    catch err
        x = createMicSignals_ASN_vonMises(cfg);
        save('x_brendel.mat', 'x');
    end
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    fprintf("    -> size(x) = %dx%dx%d\n", size(x, 1), size(x, 2), size(x, 3));
    
    %% STFT
    cfg.T = floor((size(x,1)-cfg.winpts)/cfg.steppts)+1;
    phi = bren_stft(cfg, x);
    
    clear x;
    clear X1;
    clear X2;
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    
    [est_error1, est_error2] = bren_estimate_location(cfg, phi);
    
    error1(idx_trial) = est_error1;
    error2(idx_trial) = est_error2;
    
end

fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
save('brendel_cfg.mat', 'cfg');
