% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse  % ensure all folders are added to path
rand('state',sum(100*clock));

% EVALUATION ROUTINE:
description='var-fixed';  % test fixed variance with different values
md = 5;
wd = 12;
rand_samples = true;
trials = [5 5];
T60=0.3;
SNR=0;
em_iterations=10;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init=[2 3];
var_fixed=true;
for i=1:length(var_init)
    for sources = 2:7
            random_sources_eval(description,sources,trials(i),md,wd,rand_samples,T60,SNR,em_iterations,em_conv_threshold,guess_randomly,reflect_order,var_init(i),var_fixed,'/HOMES/mainczyk/thesis/src/');
    end
end
