% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse  % ensure all folders are added to path
rand('state',sum(100*clock));

% EVALUATION ROUTINE:
description='T60';  % test fixed variance with different values
md = 5;
wd = 12;
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=[1 2 3 5 10 20];
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
trials=[50 50 50 25 25 50];
var_init = 0.1;
var_fixed = false;
for i=1:length(em_iterations)
    for sources = 2:7
        random_sources_eval(description,sources,trials(i),md,wd,rand_samples,T60,SNR,em_iterations(i), em_conv_threshold, guess_randomly,reflect_order,var_init,var_fixed, '/HOMES/mainczyk/thesis/src/');
    end
end
