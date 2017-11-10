description='wd-em-convergence';  % perfect conditions, increased wd, trying to get 100% success rate!
md = 5;
trials = 100;
wd = [12, 13, 15];
rand_samples = true;
T60=0.0;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=0;
for i=1:length(wd)
    for sources = 2:7
        random_sources_eval(description,sources,trials,md,wd(i),rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
    end
end
    