function [ loc_est, est_err ] = estimation_error_min( S, loc_est_assorted )
%ESTIMATION_ERROR_MINIMUM Find the minimum estimation error across all possible
%assignments
if size(S,2)>2, S = S(:,1:2); end

all_perm = perms(1:size(S,1));
loc_err = zeros(size(all_perm,1), size(S,1));
est_err = zeros(size(S,1),1);
for i=1:size(all_perm, 1)
    for s=1:size(S,1)
        loc_err(i,s) = norm(S(s,:)-loc_est_assorted(all_perm(i,s),:));
    end
end
err_mean = mean(loc_err, 2);
[~, min_idx] = min(err_mean);
loc_est = loc_est_assorted(all_perm(min_idx,:),:);
for s=1:size(S,1)
    est_err(s) = norm(S(s,:)-loc_est(s,:));
end
end

