function [ loc_est, est_err ] = estimation_error_rad( S, loc_est_assorted )
%ESTIMATION_ERROR Calculates the estimation error based on the true source positions

%% Description
% Find assignment with the minimal estimation error on a per-source basis. First, the
% |threshold| is initialised to 0. Then the algorithm looks at each source successively and
% determines, if an estimate is within a circle with the radius |threshold| around a source.
% If true, this estimate is assigned to its original source location. If false, the |threshold|
% is increased. This procedure repeats until all estimates have been assigned.

%% Arguments
% * *S (mat):* _|2xN| matrix that holds source location coordinates (e.g. |[2.4, 2.7; 4.8, 1.0]|)_
% * *loc_est_assorted (mat):* _|2xN| matrix that holds source location estimates (e.g. |[4.2, 1.1; 2.4, 2.5]|)_

%% Returns
% * *loc_est (mat):* _|2xN| matrix that holds assigned source location estimates (e.g. |[2.4, 2.5; 4.2, 1.1]|)_
% * *est_err (mat):* _|1xN| matrix that holds the estimation error per source (e.g. |[0.20; 0.61]|, in metre)_

%% Notes
% * assigned or sorted means, that the order of the estimates corresponds to the order of
% the sources _S_.
% * unassigned or assorted means, that the order of estimates does _NOT_ correspond to the
% order of sources _S_.
% * If an estimate is equidistant to two or more source locations,
% |<estimation_error_min.html estimation_error_min>| is used as a fallback!
% * This error calculation routine is a replacement of the *deprecated* function |<estimation_error.html estimation_error>|

fprintf('\n<%s.m>', mfilename); fprintf(' (t = %2.4f)\n', toc);
if nargin<2, error('Both input arguments "S" and "loc_est" are required!'); end
if size(S, 1)==1, loc_est_assorted = loc_est_assorted; end
if size(S, 1) ~= size(loc_est_assorted, 1), error('dimensions of input arguments mismatch! (S is %dx%d, loc_est is %dx%d)', size(S), size(loc_est_assorted)); end

%% Initialisation
% Initialise all variables used in the procedure below
est_err = ones(size(loc_est_assorted, 1), 1)*inf;
loc_est = zeros(size(loc_est_assorted));

all_assigned = false;
threshold = 0;
increment = 0.01;

%% Compute Error
% Compute localisation error with increasing thresholds. Stop, when all estimates have
% been assigned!
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
    %% More than 1 new assignment with current threshold found
    % If multiple assignments are found for a certain threshold value, it could be the
    % case, that either a original source location or a location estimate was assigned
    % multiple times. The |else|-block handles this by falling back to the minimal
    % assignment strategy, while the |if|-block identifies a valid assignment, where two
    % distinct estimates have been assigned to two distinct source locations at the same
    % time.
    if found>1
        % very complicated way of checking, if there are duplicate values in either column
        % (--> multiple assignments of one estimate or source position)
        if length(unique(pair_idx(:,1)))==length(pair_idx(:,1)) && length(unique(pair_idx(:,2)))==length(pair_idx(:,2))
            for i=1:size(pair_idx, 1)
                est_err(pair_idx(i,2)) = found_diff(i);
                loc_est(pair_idx(i,2), 1:2) = loc_est_assorted(pair_idx(i,1), 1:2);
                loc_est_assorted(pair_idx(i,1), 1:2) = inf;  % remove assigned estimate
                S(pair_idx(i,2), 1:2) = inf;  % remove assigned source
            end
        else  % multiply assigned estimates or actual source positions!
            % find "minimum error assignment" for remaining estimates
            [est_min, err_min] = estimation_error_min(S(S(:,1)~=inf,:), loc_est_assorted(loc_est_assorted(:,1)~=inf,:));
            [~,S_est_remaining_idx] = ismember(est_min, loc_est_assorted, 'rows');
            [~,S_remaining_idx] = ismember(S(S(:,1)~=inf,:),S, 'rows');
            % apply minimum error assignment to remaining estimates
            for i=1:length(S_remaining_idx)
                loc_est(S_remaining_idx(i),:) = loc_est_assorted(S_est_remaining_idx(i),:);
                est_err(S_remaining_idx(i),:) = err_min(i);
                loc_est_assorted(S_est_remaining_idx(i), 1:2) = inf;  % remove assigned estimate
                S(S_remaining_idx(i), 1:2) = inf;  % remove assigned source
            end
            fprintf("WARN: Closest estimate assignment not conclusive! Will fall back to minimum error assignment for remaining estimates!")
            all_assigned=true;
        end
    %% Only 1 new assignment with current threshold found
    % If only 1 new assignment is identified for a certain threshold, this is the next,
    % most optimal assignment in the context of this assignment strategy.
    elseif found==1 
        est_err(pair_idx(2)) = found_diff;
        loc_est(pair_idx(2), 1:2) = loc_est_assorted(pair_idx(1), 1:2);
        loc_est_assorted(pair_idx(1), 1:2) = inf;  % remove assigned estimate
        S(pair_idx(2), 1:2) = inf;  % remove assigned source
    else
        if min(loc_est_assorted)==inf
            all_assigned=true;
        else
            threshold = threshold+increment;
        end
    end
end

%% Finalise
est_err(est_err<0.01)=0;  % removes errors due to floating point arithmetic

end