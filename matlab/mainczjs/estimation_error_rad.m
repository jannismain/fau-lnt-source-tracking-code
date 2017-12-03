function [ loc_est, est_err ] = estimation_error_rad( S, loc_est_assorted )
%ESTIMATION_ERROR Calculates the estimation error based on the true source positions
%   bla bla

fprintf('\n<%s.m>', mfilename); fprintf(' (t = %2.4f)\n', toc);
if nargin<2, error('Both input arguments "S" and "loc_est" are required!'); end
if size(S, 1)==1, loc_est_assorted = loc_est_assorted; end
if size(S, 1) ~= size(loc_est_assorted, 1), error('dimensions of input arguments mismatch! (S is %dx%d, loc_est is %dx%d)', size(S), size(loc_est_assorted)); end

% Assign estimation to appropiate source (min error for existing position and estimation)

est_err = ones(size(loc_est_assorted, 1), 1)*inf;
loc_est = zeros(size(loc_est_assorted));

all_assigned = false;
threshold = 0;
increment = 0.01;
while ~all_assigned
    found=0;
    found_diff=[];
    pair_idx = [];
    for s=1:size(S, 1)
        for s2=1:size(loc_est_assorted, 1)
%             if s2<s || S(s2)==inf || loc_est_assorted(s)==inf, continue; end  % skip
            diff = norm(S(s2,1:2)-loc_est_assorted(s,1:2));
            if diff <= threshold
                found = found+1;
                found_diff = [found_diff diff];
                pair_idx = [pair_idx; s s2];
                continue;
            end
        end 
    end
    if found>1 % more than one assignment found with this threshold
        % very complicated way of checking, if there are duplicate values in either column
        % (--> multiple assignments of one estimate or source position)
        if length(unique(pair_idx(:,1)))==length(pair_idx(:,1)) && length(unique(pair_idx(:,2)))==length(pair_idx(:,2))
            for i=1:size(pair_idx, 1)
                est_err(pair_idx(i,2)) = found_diff(i);
                loc_est(pair_idx(i,2), 1:2) = loc_est_assorted(pair_idx(i,1), 1:2);
                loc_est_assorted(pair_idx(i,1), 1:2) = inf;  % remove perfect match from estimates
                S(pair_idx(i,2), 1:2) = inf;  % remove perfect match from sources
            end
        else  % multiple assigned positions!
            % find "minimum error assignment" for remaining estimates
            [est_min, err_min] = estimation_error_min(S(S(:,1)~=inf,:), loc_est_assorted(loc_est_assorted(:,1)~=inf,:))
            [~,S_est_remaining_idx] = ismember(est_min, loc_est_assorted, 'rows');
            [~,S_remaining_idx] = ismember(S(S(:,1)~=inf,:),S, 'rows');
            % apply minimum error assignment to remaining estimates
            for i=1:length(S_remaining_idx)
                loc_est(S_remaining_idx(i),:) = loc_est_assorted(S_est_remaining_idx(i),:);
                est_err(S_remaining_idx(i),:) = err_min(i);
                loc_est_assorted(S_est_remaining_idx(i), 1:2) = inf;  % remove perfect match from estimates
                S(S_remaining_idx(i), 1:2) = inf;  % remove perfect match from sources
            end
            fprintf("WARN: Closest estimate assignment not conclusive! Will fall back to minimum error assignment for remaining estimates!")
            all_assigned=true;
        end
    elseif found==1 % only one assignment found with this threshold
        est_err(pair_idx(2)) = found_diff;
        loc_est(pair_idx(2), 1:2) = loc_est_assorted(pair_idx(1), 1:2);
        loc_est_assorted(pair_idx(1), 1:2) = inf;  % remove perfect match from estimates
        S(pair_idx(2), 1:2) = inf;  % remove perfect match from sources
    else
        if min(loc_est_assorted)==inf
            all_assigned=true;
        else
            threshold = threshold+increment;
        end
    end
end

%% final steps
est_err(est_err<0.01)=0;  % removes errors due to floating point arithmetic
% TODO: Refactor to reliably allow for more/less estimates than real sources!

end