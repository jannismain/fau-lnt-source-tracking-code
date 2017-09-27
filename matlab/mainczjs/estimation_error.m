function [ loc_est, est_err ] = assign_estimates( S, loc_est_assorted )
%ESTIMATION_ERROR Calculates the estimation error based on the true source positions
%   bla bla

cprintf('*blue', '\n<%s.m>', mfilename); fprintf(' (t = %2.4f)\n', toc);
if nargin<2, error('Both input arguments "S" and "loc_est" are required!'); end
if size(S, 1) ~= size(loc_est_assorted, 1), error('dimensions of input arguments mismatch! (%s is %dx%d, %s is %dx%d)', inputname(1), size(S), inputname(2), size(loc_est_assorted)); end

% Assign estimation to appropiate source (min error for existing position and estimation)

diff = inf;
est_err = ones(size(loc_est_assorted, 1), 1)*inf;
loc_est = zeros(size(loc_est_assorted));
for s=1:size(S, 1)
    for s_est=1:size(loc_est_assorted, 1)
        diff = norm(S(s,1:2)-loc_est_assorted(s_est,1:2));
        if diff < est_err(s)
            est_err(s) = diff;
            loc_est(s, 1:2) = loc_est_assorted(s_est, 1:2);
            idx_loc_est_assorted = s_est;
        end
    end
    loc_est_assorted(idx_loc_est_assorted, 1:2) = inf;  % 'remove' assigned estimates
end

try
    [S(:,1:2) loc_est est_err]
catch
    error('TODO: Refactor to reliably allow for more/less estimates than real sources!')
end
        
            

% diff1 = ;
% diff2 = norm(cfg.synth_room.sloc(2,1:2)-loc_est1);
% [est_error1_complete,idx_est_error_1] = min([diff1,diff2]);
% est_error2_complete = norm(cfg.synth_room.sloc(3-idx_est_error_1,1:2)-loc_est2);
% fprintf('%s Estimation errors: %1.2f m   %1.2f m\n', FORMAT_PREFIX, est_error1_complete,est_error2_complete);
% 
% diff1_rev = norm(cfg.synth_room.sloc(1,1:2)-loc_est2);
% diff2_rev = norm(cfg.synth_room.sloc(2,1:2)-loc_est2);
% [est_error2_complete_rev,idx_est_error_2_rev] = min([diff1_rev,diff2_rev]);
% est_error1_complete_rev = norm(cfg.synth_room.sloc(3-idx_est_error_2_rev,1:2)-loc_est1);
% fprintf('%s Estimation errors: %1.2f m   %1.2f m\n', FORMAT_PREFIX, est_error1_complete_rev,est_error2_complete_rev);
% 
% [~,idx_error] = min([est_error1_complete,est_error2_complete,est_error1_complete_rev,est_error2_complete_rev]);
% if(idx_error<=2)
%     est_error1 = est_error1_complete;
%     est_error2 = est_error2_complete;
% else
%     est_error1 = est_error1_complete_rev;
%     est_error2 = est_error2_complete_rev;
% end

end

