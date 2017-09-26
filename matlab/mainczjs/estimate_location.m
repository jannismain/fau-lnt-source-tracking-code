function [ loc_est ] = estimate_location( psi, n_sources, elimination_radius, min_distance)
%ESTIMATE_LOCATION Finds the n_sources most probable locations of audio sources
%   Input Arguments:
%   - psi: output of prior EM-Iterations
%   - [n_sources]: number of locations to be found

load('config.mat');

if nargin<1, error('input argument "psi" is required!'); end
if nargin<2, n_sources=2; end
if nargin<3, elimination_radius=2; end
if nargin<4, min_distance=5; end

    for n=1:n_sources
        % determine maximum
        [~,idx_Xmax] = max(max(psi,[],1));  % ~ = max. value of psi at identified index
        [~,idx_Ymax] = max(max(psi,[],2));
        loc_est(n, :) = [room.grid_x(idx_Xmax),room.grid_y(idx_Ymax)] + room.N_margin*room.grid_resolution;
        fprintf('Estimate #%d at x=%0.2f, y=%0.2f\n', n, loc_est(n, :));
        
        if n>1  % is this is not the first estimate, make comparison to other estimates
            for m=1:n-1
                % eliminate identified location too close to another identified location
                if(norm(loc_est(n, :)-loc_est(m, :)) < min_distance/10)
                    n=n-1;  % this is not a valid source, will be overwritten on next loop
                    % if(sum(sum(psi)) == 0)
                    %     break
                    % end
                    fprintf('Estimate #%d is within %0.2fm of #%d. Will skip this one!\n', n, min_distance/10, m);
                end
            end
        end
        % eliminate maximum from psi (square with length cfg.erase_threshold)
        d = elimination_radius;
        err = true;
        while err
            try
                psi(idx_Ymax-d:idx_Ymax+d,idx_Xmax-d:idx_Xmax+d) = 0;
                err = false;
            catch
                d = d-1;
                fprintf('Eliminating area around found maximum failed! (x=%d, y=%d, psi=%dx%d, d=%d)\n', idx_Xmax, idx_Ymax, size(psi, 1), size(psi, 2), d)
            end
        end
        
    end

end

