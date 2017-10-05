function [ clabels ] = get_column_names_result( n_sources )
%GET_COLUMN_NAMES_RESULT Summary of this function goes here
%   Detailed explanation goes here
    
    numbers = linspace(1,n_sources,n_sources);
    clabels = "";
    
    % generate x/y pairs
    for s=1:n_sources
        clabels = strcat(clabels, sprintf("$x_%d$,$y_%d$,", numbers(s), numbers(s)));
    end
    
    % generate x_hat/y_hat pairs
    for s=1:n_sources
        clabels = strcat(clabels, sprintf("$\\hat x_%d$,$\\hat y_%d$,", numbers(s), numbers(s)));
    end
    
    % generate error labels
    for s=1:n_sources
        if s==n_sources % omit last seperator
            clabels = strcat(clabels, sprintf("err\\textsubscript{%d}", numbers(s)));
        else
            clabels = strcat(clabels, sprintf("err\\textsubscript{%d},", numbers(s)));
        end
    end
    clabels = strsplit(clabels, ',');
    return
    

end

