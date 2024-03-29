function [ psi, loc_est, var_history, psi_history ] = rem_tracking( ang_dist, algorithm, var_init )
%REM_TRACKING Source Tracking Algorithm using recursive EM

%% Description
% Source Tracking Algorithm using recursive EM
%
%% Arguments
% * *ang_dist (mat)*: _angular distances computed in |<./rem_init.html rem_init.m>|_
% * *algorithm (str)*: _Name of algorithm to use (either |'CREM'| or |'TREM'|)_
% * *var_init (double)*: _initial value for variance (Overrides value set in |'config.mat'|)_

%% Return
% * *psi (mat)*: _matrix with weights of Gaussian components_
% * *loc_est (mat)*: _coordinates of location estimates for all time steps |em.T|_
% * *var_history (mat)*: _coordinates of location estimates for all time steps |em.T|_
% * *psi_history (mat)*: _matrix of Gaussian component weights for all time steps |em.T|_

%% Variables
% * *psi_old (mat)*: _|psi| of last iteration_
% * *mu (mat)*: _responsibility of Gaussian component for each position_

load('config.mat')
if nargin<2, error("Provide algorithm (either 'crem' or 'trem')"); end
if nargin>2, fprintf('WARN: Overwriting em.var with %1.2f (was %1.2f)', var_init, em.var); em.var = var_init; end

%% Create Variables
m = "EM-Iterations..."; counter = next_step(m, counter);

psi = ones(em.Ynet,em.Xnet,1) * (1 /(em.Xnet)*(em.Ynet));
psi_old = zeros(size(psi));
loc_est = zeros(n_sources, em.T, 2);
var_history = zeros(em.T+1, 1);
var_history(1) = em.var;
psi_history = zeros(em.T, size(psi, 1), size(psi, 2));

for iter = 1:em.T
    %% init iteration
    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f, \x03C3 = %1.4f (t = %2.4f)\n',norm(psi(:)-psi_old(:)), em.var, toc);  % \x0394\x03C8 = Delta Psi, \x03C3 = \sigma
    psi_old = psi;

    %% Compute Resposibility (Expectation)
    gaussian = (1 / (em.var * pi))*exp(-ang_dist(:,iter,:,:,:) / (em.var));
    pdf = bsxfun(@times,reshape(psi,1,1,em.Ynet,em.Xnet,1),prod(gaussian,5));
    
    mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,1,1,1));
    mu(isnan(mu)) = 0;
    
    %% Compute Component Weights (Maximization)
    psi = squeeze(sum(mu,1)/(em.K));
    psi(psi<=0) = eps;
    
    %% Estimate Variance (Maximization)
    if strcmpi(algorithm,'trem')
        sum_psi_old = sum(sum(psi_old));
        var_fact1 = 1/(em.K*sum_psi_old);
        var_fact2 = sum(sum(sum(mu.*((1/em.M)*sum(ang_dist(:,iter,:,:,:), 5)-em.var))));
        em.var = em.var + em.gamma*var_fact1*var_fact2;
    elseif strcmpi(algorithm,'crem')
        if iter==1, psi_old = psi; end
        psi_ratio = sum(sum(psi_old))/sum(sum(psi));
        var_fact2 = (sum(sum(sum(mu.*sum(ang_dist(:,iter,:,:,:), 5)))))/(em.K*em.M*sum(sum(psi)));
        em.var = em.var*psi_ratio + em.gamma*(var_fact2-em.var*psi_ratio);
    end
    psi = psi_old + em.gamma*(psi - psi_old);
    
    %% Delete outer margin (around microphones) to eliminate false peaks
    psi_computeMax = psi;
    b=2;
    if size(psi_computeMax, 3) == 1
        psi_computeMax(1:b,:) = 0;
        psi_computeMax(size(psi, 1)-b:size(psi, 1),:) = 0;
        psi_computeMax(:,1:b) = 0;
        psi_computeMax(:,size(psi, 2)-b:size(psi, 2)) = 0;
    end
    
    %% Save Values
    var_history(iter+1) = em.var;
    psi_history(iter, :, :) =  psi;

    %% Find Location Estimates
    evalc('loc_est(:,iter,:) = estimate_location(psi_computeMax,n_sources,1,5,room);');
end

end
