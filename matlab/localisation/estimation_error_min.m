function [ loc_est, est_err ] = estimation_error_min( S, loc_est_assorted )
% ESTIMATION_ERROR_MIN Find assignment with the minimal estimation error across all possible assignments

%% Description
% Find assignment with the minimal estimation error across all possible assignments. This
% is done by computing the estimation error across _all_ possible assignments and then
% simply chosing the assignment with the smallest error.
%% Arguments
% * *S (mat):* _|2xN| matrix that holds source location coordinates (e.g. |[2.4, 2.7; 4.8, 1.0]|)_
% * *loc_est_assorted (mat):* _|2xN| matrix that holds source location estimates (e.g. |[4.2, 1.1; 2.4, 2.5]|)_

%% Returns
% * *loc_est (mat):* _|2xN| matrix that holds assigned source location estimates (e.g. |[2.4, 2.5; 4.2, 1.1]|)_
% * *est_err (mat):* _|1xN| matrix that holds the estimation error per source (e.g. |[0.20; 0.61]|, in metre)_

%% Variables
% * *all_perm (mat):* _Indices of all possible permutations of |loc_est_assorted|_
% * *loc_err (mat):* _Estimation error of all sources for all possible permutations_
% * *est_err (mat):* _Estimation error of assigned estimates_
% * *err_mean (mat):* _Mean localisation error across all sources for all possible permutations_
% * *min_idx (int):* _Index of permutation with minimal mean localisation error_

%% Notes
% * assigned or sorted means, that the order of the estimates corresponds to the order of
% the sources _S_.
% * unassigned or assorted means, that the order of estimates does _NOT_ correspond to the
% order of sources _S_.

%% Truncate S
% Truncate _S_ to only hold |[x y]| coordinates.
if size(S,2)>2, S = S(:,1:2); end

%% Initialisation
% Compute indices of all possible permutations of _|loc_est_assorted|_ and initialise empty matrices for |loc_err| and
% |est_err|.
all_perm = perms(1:size(loc_est_assorted,1));
loc_err = zeros(size(all_perm,1), size(S,1));
est_err = zeros(size(S,1),1);

%% Compute Localisation Error
% Compute localisation error for all possible permutations and calculate mean error
for i=1:size(all_perm, 1)
    for s=1:size(S,1)
        loc_err(i,s) = norm(S(s,:)-loc_est_assorted(all_perm(i,s),:));
    end
end
err_mean = mean(loc_err, 2);

%% Assignment
% Find assignment with minimal mean localisation error
[~, min_idx] = min(err_mean);
loc_est = loc_est_assorted(all_perm(min_idx,:),:);
for s=1:size(S,1)
    est_err(s) = norm(S(s,:)-loc_est(s,:));
end
end

