function main(eval, varargin)

clearvars('-except', 'eval', 'trials', 'varargin');

switch eval
    case 'base'
        description='base';  % use only single quotes, double quotes will raise error in mkdir()
        md = 5;
        wd = 12;
        rand_samples = true;
        T60=0.0;
        SNR=0;
        em_iterations=5;
        em_conv_threshold=-1;
        guess_randomly=false;
        reflect_order=3;
        for src_cfg = 2:7
            random_sources_eval(description,src_cfg,trials,md,wd,rand_samples,T60,SNR,em_iterations, em_conv_threshold, guess_randomly,reflect_order);
        end

    case 'schwartz2014'
        description='schwartz2014';
        md = 5;
        wd = 12;
        rand_samples = false;
        T60=[0.4, 0.7];
        SNR=30;
        em_iterations=10;
        em_conv_threshold=-1;
        reflect_order=-1;
        var_init = 1;
        var_fixed = false;
        prior = 'schwartz2014';
        n_sources = 2;
        src_cfg = 'schwartz2014';
        for t=1:length(T60)
            single_eval(description,n_sources,md,wd,rand_samples,T60(t),SNR,em_iterations, em_conv_threshold,reflect_order,var_init,var_fixed,false,prior,src_cfg);
        end
        
    case 'schwartz2014-variation'
        description='schwartz2014-variation';
        md = 5;
        wd = 12;
        rand_samples = false;
        T60=[0.4, 0.7];
        SNR=30;
        em_iterations=10;
        em_conv_threshold=-1;
        reflect_order=-1;
        var_init = 1;
        var_fixed = false;
%         prior=["equal", "rand","hh","hv","quart"];
        prior = [string('rand'), string('hv'), string('schwartz2014-unlucky'), string('equal')];
        src_cfg = [string('schwartz2014')];
        for t=1:length(T60)
            for scfg=1:length(src_cfg)
                for p=1:length(prior)
                    single_eval(description,2,md,wd,rand_samples,T60(t),SNR,em_iterations, em_conv_threshold,reflect_order,var_init,var_fixed,false,prior(p),src_cfg(scfg));
                end
            end
        end
    
    case 'schwartz2014-4sources'
        description='schwartz2014-4sources';
        md = 5;
        wd = 12;
        rand_samples = false;
        T60=[0.4, 0.7];
        SNR=30;
        em_iterations=10;
        em_conv_threshold=-1;
        reflect_order=-1;
        var_init = 1;
        var_fixed = false;
%         prior=["equal", "rand","hh","hv","quart"];
        prior = [string('rand'), string('quart'), string('quart-equal'), string('equal')];
        src_cfg = [string('quattro-good'), string('quattro-bad')];
        for t=1:length(T60)
            for scfg=1:length(src_cfg)
                for p=1:length(prior)
                    single_eval(description,2,md,wd,rand_samples,T60(t),SNR,em_iterations, em_conv_threshold,reflect_order,var_init,var_fixed,false,prior(p),src_cfg(scfg));
                end
            end
        end

    otherwise
        cprintf('*err', 'This evaluation is not yet defined! Please check the spelling of "%s" or define "%s" as new evaluation!\n', eval, eval);

end
