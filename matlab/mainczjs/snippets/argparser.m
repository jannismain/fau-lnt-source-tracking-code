function argparser(args)
    for i=1:2:length(args)
        switch args(i)
            case 'md'
                md = args(i+1);
            case 'wd'
                wd = args(i+1);
            case 'guess'
                guess_randomly = args(i+1);
            case 'em-iterations'
                em_iterations = args(i+1);
            case 'em-conv-threshold'
                em_conv_threshold = args(i+1);
            case 'T60'
                T60 = args(i+1);
            case 'sources'
                sources = args(i+1);
        end
    end
end