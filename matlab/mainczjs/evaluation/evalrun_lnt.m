% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse

% EVALUATION ROUTINE:
description='var-fixed';  % test fixed variance with different values
trials=50;
md = 5;
wd = 12;
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=10;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init = [0.1 0.5 2];
var_fixed = true;
for i=1:length(var_init)
    for sources = 2:7
        random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,var_init(i),var_fixed);
    end
end
