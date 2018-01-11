function [ clabels ] = get_column_names_result( n_sources )
%% GET_COLUMN_NAMES_RESULT Generate column names of final results data table
%   This is useful when the raw data table is to be displayed in LaTeX without much hassle
    
numbers = linspace(1,n_sources,n_sources);
clabels = "";

%% generate x/y pairs
% $$ x_1, y_1, x_2, y_2, ..., x_N, y_N $$

for s=1:n_sources
    clabels = strcat(clabels, sprintf("$x_%d$,$y_%d$,", numbers(s), numbers(s)));
end

%% generate x_hat/y_hat pairs
% $$ \hat x_1, \hat y_1, \hat x_2, \hat y_2, ..., \hat x_N, \hat y_N $$

for s=1:n_sources
    clabels = strcat(clabels, sprintf("$\\hat x_%d$,$\\hat y_%d$,", numbers(s), numbers(s)));
end

%% generate error labels
% $$ err_{1}, err_{2}, ..., err_{N} $$

for s=1:n_sources
    if s==n_sources % omit last seperator
        clabels = strcat(clabels, sprintf("err\\textsubscript{%d}", numbers(s)));
    else
        clabels = strcat(clabels, sprintf("err\\textsubscript{%d},", numbers(s)));
    end
end

%% concat all labels
% $$ \hat x_1, \hat y_1, ..., \hat x_1, \hat y_1, ..., err_{1}, err_{2}, ... $$
clabels = strsplit(clabels, ',');
end

