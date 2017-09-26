function [ est_error1, est_error2, loc_est1, loc_est2, fig ] = bren_estimate_location( cfg, loc_est)

load('config.mat');
loc_est1 = loc_est(1, :);
loc_est2 = loc_est(2, :);
%% Error Calculation
    % Assign estimation to appropiate source (min error for existing
    % position and estimation)
    % 
    diff1 = norm(cfg.synth_room.sloc(1,1:2)-loc_est1);
    diff2 = norm(cfg.synth_room.sloc(2,1:2)-loc_est1);
    [est_error1_complete,idx_est_error_1] = min([diff1,diff2]);
    est_error2_complete = norm(cfg.synth_room.sloc(3-idx_est_error_1,1:2)-loc_est2);
    fprintf('%s Estimation errors: %1.2f m   %1.2f m\n', FORMAT_PREFIX, est_error1_complete,est_error2_complete);
    
    diff1_rev = norm(cfg.synth_room.sloc(1,1:2)-loc_est2);
    diff2_rev = norm(cfg.synth_room.sloc(2,1:2)-loc_est2);
    [est_error2_complete_rev,idx_est_error_2_rev] = min([diff1_rev,diff2_rev]);
    est_error1_complete_rev = norm(cfg.synth_room.sloc(3-idx_est_error_2_rev,1:2)-loc_est1);
    fprintf('%s Estimation errors: %1.2f m   %1.2f m\n', FORMAT_PREFIX, est_error1_complete_rev,est_error2_complete_rev);
    
    [~,idx_error] = min([est_error1_complete,est_error2_complete,est_error1_complete_rev,est_error2_complete_rev]);
    if(idx_error<=2)
        est_error1 = est_error1_complete;
        est_error2 = est_error2_complete;
    else
        est_error1 = est_error1_complete_rev;
        est_error2 = est_error2_complete_rev;
    end

end

