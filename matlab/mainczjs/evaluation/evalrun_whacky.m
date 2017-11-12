% description='wd-em-convergence';  % perfect conditions, increased wd, trying to get 100% success rate!
% md = 5;
% trials = 100;
% wd = [12, 13, 15];
% rand_samples = true;
% T60=0.0;
% SNR=0;
% em_iterations=5;
% em_conv_threshold=-1;
% guess_randomly=false;
% reflect_order=0;
% for i=1:length(wd)
%     for sources = 2:7
%         random_sources_eval(description,sources,trials,md,wd(i),rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
%     end
% end

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
var_init = [1 2 5];
var_fixed = false;
for i=1:length(var_init)
    for sources = 2:7
        random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,var_init(i),var_fixed);
    end
end
    