% description='wd';  % use only single quotes, double quotes will raise error in mkdir()
% trials=50;
% md = 5;
% wd = 15;
% rand_samples = true;
% T60=0.0;
% SNR=0;
% em_iterations=5;
% em_conv_threshold=-1;
% guess_randomly=false;
% reflect_order=0;
% for sources = 2:7
%     random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
% end

description='var2';  % test fixed variance with different values
trials=30;
md = 5;
wd = 12;
rand_samples = true;
T60=0.3;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
variance=[0.1 0.5 1];
for i=3:3
    for sources = 7:7
        random_sources_eval(description,sources,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order,variance(i));
    end
end