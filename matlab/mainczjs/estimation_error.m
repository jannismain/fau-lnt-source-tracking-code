function [ loc_est, est_err ] = estimation_error( S, loc_est_assorted )
%ESTIMATION_ERROR Calculates the estimation error based on the true source positions
%   bla bla

fprintf('\n<%s.m>', mfilename); fprintf(' (t = %2.4f)\n', toc);
if nargin<2, error('Both input arguments "S" and "loc_est" are required!'); end
if size(S, 1)==1, loc_est_assorted = loc_est_assorted; end
if size(S, 1) ~= size(loc_est_assorted, 1), error('dimensions of input arguments mismatch! (S is %dx%d, loc_est is %dx%d)', size(S), size(loc_est_assorted)); end

% Assign estimation to appropiate source (min error for existing position and estimation)

diff = inf;
est_err = ones(size(loc_est_assorted, 1), 1)*inf;
loc_est = zeros(size(loc_est_assorted));

%% assign perfect matches
for s=1:size(S, 1)
    for s2=1:size(loc_est_assorted, 1)
        if s2<s, continue; end  % check each pair only once
        diff = norm(S(s2,1:2)-loc_est_assorted(s,1:2));
        if diff < 0.01
            est_err(s2) = 0;
            loc_est(s2, 1:2) = loc_est_assorted(s, 1:2);
            loc_est_assorted(s, 1:2) = inf;  % remove perfect match from estimates
            S(s2, 1:2) = inf;  % remove perfect match from sources
            break;
        end
    end 
end

%% assign remaining estimates
idx_loc_est_assorted = -1;
for s=1:size(S, 1)  % go through all real source positions
    if S(s, 1) == inf, continue; end  % skip, if S(s) has already been assigned
    for s_est=1:size(loc_est_assorted, 1)  % go through all estimated source positions
        if loc_est_assorted(s_est, 1) == inf, continue; end  % skip, if S_est(s) has already been assigned
        diff = norm(S(s,1:2)-loc_est_assorted(s_est,1:2));
        if diff < est_err(s)
            est_err(s) = diff;
            loc_est(s, 1:2) = loc_est_assorted(s_est, 1:2);
            idx_loc_est_assorted = s_est;
        end
    end
    if idx_loc_est_assorted > -1
        loc_est_assorted(idx_loc_est_assorted, 1:2) = inf;  % 'remove' assigned estimates from sources
    end
end

%% final steps
est_err(est_err<0.01)=0;  % removes errors due to floating point arithmetic
% TODO: Refactor to reliably allow for more/less estimates than real sources!

end

