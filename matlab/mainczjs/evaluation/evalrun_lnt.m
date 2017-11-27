% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse  % ensure all folders are added to path
rand('state',sum(100*clock));

% EVALUATION ROUTINE:
description='min-distance';
trials=[25 25 50];
md = [3 5 10];
wd = 12;
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init = 0.1;
var_fixed = false;
for sources = 2:7
    for i=1:length(md)
        random_sources_eval(description,sources,trials(i),md(i),wd,rand_samples,T60,SNR,em_iterations,em_conv_threshold,guess_randomly,reflect_order,var_init,var_fixed,'/HOMES/mainczyk/thesis/src/');
    end
end
