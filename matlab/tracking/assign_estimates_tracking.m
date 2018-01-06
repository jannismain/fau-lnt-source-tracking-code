function [ loc_est, est_err ] = assign_estimates_tracking( sources, all_loc_est_assorted )
%ESTIMATION_ERROR Calculates the estimation error based on the true source positions
%   bla bla

fprintf('\n<%s.m>', mfilename); fprintf(' (t = %2.4f)\n', toc);

% recalculate trajectory with em.T samples
T = size(all_loc_est_assorted, 2);
trajs = zeros(sources.n, T, 3);
for s=1:sources.n
    trajs(s, :, :) = get_trajectory_from_source(squeeze(sources.p(s,:)),squeeze(sources.movement(s,:)), T);
end

est_err = ones(sources.n, T)*inf;
loc_est = zeros(size(all_loc_est_assorted));

for t=1:T
    S = round(squeeze(trajs(:,t,:)),1);
    loc_est_assorted = squeeze(all_loc_est_assorted(:,t,:));
    diff = inf;

    %% assign perfect matches
    for s=1:size(S, 1)
        for s2=1:size(loc_est_assorted, 1)
            if s2<s, continue; end  % check each pair only once
            diff = norm(S(s2,1:2)-loc_est_assorted(s,1:2));
            if diff < 0.01
                est_err(s2,t) = 0;
                loc_est(s2,t,1:2) = loc_est_assorted(s, 1:2);
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
            if diff < est_err(s,t)
                est_err(s,t) = diff;
                loc_est(s,t,1:2) = loc_est_assorted(s_est, 1:2);
                idx_loc_est_assorted = s_est;
            end
        end
        if idx_loc_est_assorted > -1
            loc_est_assorted(idx_loc_est_assorted, 1:2) = inf;  % 'remove' assigned estimates from sources
        end
    end

    %% final steps
    est_err(est_err(:,t)<0.01,t)=0;  % removes errors due to floating point arithmetic
    % TODO: Refactor to reliably allow for more/less estimates than real sources!

end
end
