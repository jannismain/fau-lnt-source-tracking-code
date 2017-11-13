% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse  % ensure all folders are added to path
rand('state',sum(100*clock));

% EVALUATION ROUTINE:
description='em-iterations';  % test fixed variance with different values
md = 5;
wd = [13,15];
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
trials=[25 25];
var_init = 0.1;
var_fixed = false;
for i=1:length(wd)
    for sources = 2:7
        random_sources_eval(description,sources,trials(i),md,wd(i),rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,var_init,var_fixed, '/HOMES/mainczyk/thesis/src/');
    end
end
