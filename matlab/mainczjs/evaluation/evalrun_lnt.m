% REMOTE SERVER MATLAB CONFIG - DO NOT TOUCH
cd('../../.')
addpath_recurse

% EVALUATION ROUTINE:
description='var';  % test fixed variance with different values
trials=100;
md = 5;
wd = 12;
rand_samples = true;
T60=0.6;
SNR=0;
em_iterations=10;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=-1;
variance=0.1;
for sources = 3:7
    random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,variance);
end
