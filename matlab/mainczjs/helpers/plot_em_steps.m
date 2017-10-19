function plot_em_steps(psi, n_sources, md, room, S)
%PLOT_EM_STEPS A helper to visualise the incremental changes in between em iterations
%
%   PARAMETERS:
%   psi: a history of estimates psi-matrices size(psi) = (trials x n_sources x coordinate)
%        Example: size(psi)=7x5x2 for 7 trials with 5 sources (and 2 coordinates)

if size(psi, 3) == 1, err("psi needs to be in the following shape: psi(trial, source, coordinate)"); end

em_iterations = size(psi, 1);
% x_vals = linspace(0,em_iterations,em_iterations+1);
loc_est_sorted = zeros(em_iterations, n_sources, 2);
est_err = zeros(em_iterations, n_sources);

for i=1:size(psi, 1)
    loc_est = estimate_location(squeeze(psi(i, :, :)), n_sources, 0, md, room);
    [loc_est_sorted(i,:,:), est_err(i,:)] = estimation_error(S, loc_est);
    % plot
    for s=1:n_sources+1
        subplot_tight(1,n_sources+1,s)
        if s~=n_sources+1
            plot(est_err(:, s), 'LineWidth',2,'Color',[0.4 0.4 0.4]);
            title(sprintf("S%d Estimation Error", s));
        else  % last iteration, plot mean
            plot(mean(est_err, 2), 'LineWidth',2,'Color',[204/255 53/255 56/255]);
            title("Average Estimation Error");
        end
%         xticks(x_vals);
        ylim([-0.1 3.0])
        yticks(linspace(0, 3, 16))
        grid on
    end
end
    
end