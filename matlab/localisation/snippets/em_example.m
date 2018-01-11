% Script to simulate EM algorithm for estimation of parameters of a mixture
% of two multivariate normal distributions. See the related pdf-document
% for the model definitions etc.

% The script is targeted at teaching/educational purposes, and therefore,
% the performance of the code is not optimized but made more comprehensible
% (there are some unnecessary for-loops etc.). The script is divided into
% cells (search help: "What are code cells?") as follows:
% 1. Simulation parameters (define model and algorithm parameters)
% 2. Generate observation data (Generate samples from the specified model)
% 3. Algorithm (Run the EM algorithm)
% 4. Figures (plot figures, see explanations therein)
%
% E.g., you can navigate between code cells with "ctrl+Arrow up/down" and
% evaluate the cell (i.e., run the code inside the cell) with ctrl+Enter.
%
% For simplicity reasons, the code does not include any convergence
% criterion to stop the iteration loop, although the likelihood maximum
% would be practically reached (if needed, add this functionality in the
% code by yourself). Also, some extreme covariance matrices might result to
% errors, especially with small number of samples (i.e., N is small). This
% can be avoided by checking whether the covariance matrix is
% positive-semidefinite or not (use, e.g., Cholesky factorization for this
% (see help for "chol")).
%
% Please report and give feedback on any typos etc. in the code.
%
% Made by Jukka Talvitie, December 4th 2013
% jukka.talvitie@tut.fi
% Department of Electronics and Communications Engineering
% Tampere University of Technology

clear all; clc; close all
%% 1. Simulation Parameters:
%---------------------------------------------------------------------------

% Selection of the seed for the random number generator:
% E.g., fix the seed and select different initial guesses for the
% algorithm. For some observation sets, this leads to different results and
% final likelihood values)
seed_num = sum(round(1000*clock)); % random seed based on the current time
% seed_num = 211245;

% For newer Matlab versions:
%rng(seed_num)

% For older Matlab versions:
stream = RandStream('mt19937ar','seed',seed_num);
RandStream.setGlobalStream(stream);


% Number os observations/samples taken
N = 50;

%Number of iterations (no convergence criterion applied):
N_iter = 40; %first iteration is the initialization

%Initialization (choose the first guess values):
tau_est = [0.5 0.5]; %here starting with fifty-fifty
mu_est = [0 -5;0 5]; %mean value initial guess
C_est={diag(10*[1 1]) diag(10*[1 1])}; %covariance value initial guess
% If you are not satisfied with the end result of the algorithm, try
% different initial values and compare the final likelihood values. Does
% the final estimate (and/or final likelihood) change?



% ANIMATION THROUGH ITERATIONS
% (define 'true' if you want to see the animation, otherwise 'false'):
animate_iterations = true; % (press ctrl+c to stop the animation)
% What you see in the animation (at each iteration step):
%-different colors represent different distributions and their observations
%-numbers show what is the likelihood for the observation to belong into
% the most likely distribution (i.e. value is always between 0.5...1)
%-black cross on top of observation indicates that the observation is
% mapped into incrorrect distribution (i.e., hard estimate of the
% originated distribution of this observation is wrong))


%--The following constructs the distributions and generates the
%observations
% (i.e. these are parameters that we want to estimate, so we "don't know
% them" in the process) Try different type of distributions and see how the
% algorithm works!

% Probability of the sample to be taken from the 1st distributions and 2nd
% distribution:
tau = [1/3 2/3]; %NB!!! always: sum(tau)=1

% Mean of the distributions (in column vectors)
%(here randomly chosing some values between -5...5 )
mu = 10*rand(2,2)-5;

% Covariance matrix C (has to be symmetric positive-semidefinite): First
% we randomly generate standard deviations for "x" and "y" dimensions (i.e.
% square root of C's diagonal elements. Here distributions are separated by
% columns):
std_values = 1+4*rand(2,2); %values vary between 1 and 5

corr_term = 2*rand(1,2)-1; % xy-correlation term (varies between -1...1)

%Finally building the covariance matrices C1 and C2:
C1 = diag(std_values(:,1).^2);
C1(1,2)=corr_term(1)*prod(std_values(:,1));
C1(2,1)=C1(1,2);

C2 = diag(std_values(:,2).^2);
C2(1,2)=corr_term(2)*prod(std_values(:,2));
C2(2,1)=C2(1,2);

C={C1 C2}; % concatenate separate covariance matrices into 1x2 cell


% End of simulation Parameters--------------------------------------------

%% 2. Generate observation data:

%hidden variable z determining from which distribution the sample is taken
%(this is based on the probability given in tau)
z = (rand(N,1)<=tau(2))+1;
%z is either 1 or 2 whether sampled from 1st or 2nd distribution

% observations X (Nx2 matrix, where each row indicates one observation)
X = NaN(N,2); 
for dist_ind=1:2
    X(z==dist_ind,:) = mvnrnd(...
        mu(:,dist_ind)',C{dist_ind},sum(z==dist_ind));
end


%% 3. The algorithm

%Initialize the loop parameters

% P(z|x,current parameter estimates), see the pdf-file
T = NaN(N,2);

% Memorize values at each iteration (not necessarily needed in practice):
tau_iter_mem = cell(1,N_iter);
mu_iter_mem = cell(1,N_iter);
C_iter_mem = cell(1,N_iter);
T_iter_mem = cell(1,N_iter);
likelihoodValue = zeros(1,N_iter);

% The 1st iteration is here the initialization phase
tau_iter_mem{1} = tau_est;
mu_iter_mem{1} = mu_est;
C_iter_mem{1} = C_est;
T_iter_mem{1} = T; % =NaNs, i.e., not available in the initialization
likelihoodValue(1)=NaN; %i.e., not available in the initialization
for iter_ind = 2:N_iter %Go through the iteration loop
    
    %E-step----------------------------------------------------------------
    %calculate "P(z|x,current parameter estimates)"
    T_sum=0;
    for dist_ind=1:2
        T(:,dist_ind) = tau_est(dist_ind)*mvnpdf(X,mu_est(:,dist_ind)',C_est{dist_ind});
        T_sum = T_sum + T(:,dist_ind);
    end
    T = T./repmat(T_sum,1,2);
    
    
    % Here we calculate the overall value of the likelihood. Here it's used
    % only for the plotting purposes, so in practice it is not necessarily
    % needed. The likelihood function, or more precisely, the expectation
    % of the likelihood with respect to the hidden parameter z, given the
    % observations and the current parameter estimates can be written as
    % (i.e., this is the function in the E-step):
    % Q(parameter|parameter_estimates)=
    for meas_ind = 1:N
        for dist_ind=1:2
        Xmu = X(meas_ind,:)-mu_est(:,dist_ind)';
        likelihoodValue(iter_ind) = likelihoodValue(iter_ind) + ...
            T(meas_ind,dist_ind).*(log(tau(dist_ind))...
            -0.5*log(det(C_est{dist_ind}))...
            -0.5*(Xmu*(C_est{dist_ind}\Xmu'))-log(2*pi));
        end
    end
    % NB! Since this function reveals the overall likelihood of the
    % estimated parameters, it can be used to find the global peak by
    % comparing the converged likelihoods between different initial guesses
    % of the parameters.
    
    %M-step----------------------------------------------------------------
    
    %Update the parameter estimates:
    for dist_ind=1:2
        
        % tau overall sampling probability
        tau_est(dist_ind) = sum(T(:,dist_ind))/N; 
        
        % distribution means
        mu_est(:,dist_ind) = ...
            sum(repmat(T(:,dist_ind),1,2).*X)'/sum(T(:,dist_ind));
        
        % distribution covariances
        for meas_ind=1:N
            C_est{dist_ind} = C_est{dist_ind} + T(meas_ind,dist_ind).*...
                (X(meas_ind,:)-mu_est(:,dist_ind)')'*...
                (X(meas_ind,:)-mu_est(:,dist_ind)');
        end
        C_est{dist_ind} = C_est{dist_ind}/sum(T(:,dist_ind));
        
    end
    
    % Memorize values for each iteration (only for plotting purposes)
    tau_iter_mem{iter_ind} = tau_est;
    mu_iter_mem{iter_ind} = mu_est;
    C_iter_mem{iter_ind} = C_est;
    T_iter_mem{iter_ind} = T;
end



%% 4. Figures:

% figure #1 ---------------------------------------------------------------
% Plot the observations and the distribution contours along with the
% estimated ones:
% - Colored contours are the two modeled distributions 
% - Colored circles are observations from the two distributions
% - Black contours are the estimated distributions

figure
%create x-y grid for the contour
hold on
min_val = min(X(:)); %create grid limits for the contours
max_val = max(X(:)); %create grid limits for the contours
[Xg Yg] = meshgrid(min_val:0.1:max_val); %create grid for the contours
Zg = NaN(size(Xg)); %contour initialization
colors='rb'; %colors for the distributions
for dist_ind=1:2
    
    %True distributions
    plot(X(z==dist_ind,1),X(z==dist_ind,2),'ko',...
        'MarkerFaceColor',colors(dist_ind))
    Zg(:) = mvnpdf([Xg(:) Yg(:)],mu(:,dist_ind)',C{dist_ind});
    contour(Xg,Yg,Zg,colors(dist_ind),'LineWidth',2)
    
    %Estimated distributions
    f = mvnpdf([Xg(:) Yg(:)],mu_est(:,dist_ind)',C_est{dist_ind});
    Zg(:) = f;
    contour(Xg,Yg,Zg,'k','LineWidth',2)%,colors(dist_ind))
    
end
hold off
v_ax = axis; %memorize the axis
%--------------------------------------------------------------------------


% figure #2 ---------------------------------------------------------------
% Likelihood curve as a function of iteration steps:
% (notice that numerical accuracy might affect this result a little bit...)
figure
plot(1:N_iter,likelihoodValue)
xlabel('Iteration index')
ylabel('Log-likelihood')
title(['Likelihood function as function of iterations '...
    '(where to stop iterations?)'])
grid on
%--------------------------------------------------------------------------


% Figure #3 (if animate_iterations==true)----------------------------------
% Animate iterations one-by-one
% Observations from the two distributions are shown with colored circles
% (as in the figure#1). The estimated contours are plotted with black color
% step-by-step at each iteration round. Here the numbers next to
% observations indicate the expectation that the observation is from the
% specified distribution (~0 means unlikely, ~1 means likely, the numerical
% accuracy is 3 numbers: 0.9999 appears as 1). If there's a black cross on
% top of the observation, it indicates that the observation is mapped into
% incorrect distribution (i.e. the likelihood is lower for the correct
% distribution).

if animate_iterations 
    
    % NB! If needed, this can be done done much more efficiently using
    % axis/line/figure object handles
    figure
    for iter=1:N_iter-1
        
        clf
        hold on
        for dist_ind=1:2
            
            % Plot the estimated distributions for this iteration
            f = mvnpdf([Xg(:) Yg(:)],mu_iter_mem{1,iter}(:,dist_ind)'...
                ,C_iter_mem{1,iter}{dist_ind});
            Zg(:) = f;
            contour(Xg,Yg,Zg,'k')
            
            %Plot observations colored based on their original distribution
            plot(X(z==dist_ind,1),X(z==dist_ind,2),'ko',...
                'MarkerFaceColor',colors(dist_ind),'MarkerSize',10)
            
            
            if iter>1 %Iteration 1 is only the initialization phase
                
                % "Hard estimates" for the distribution origin of the
                % observations
                z_hard = (T_iter_mem{iter}(:,2)>T_iter_mem{iter}(:,1))+1;
                % "Soft estimates" for the distribution origin of the
                % observations
                z_prob = diag(T_iter_mem{iter+1}(:,z_hard));

                %Flip distributions, if our estimate of the distribution #1
                %estimates actually the distribution #2 and vice versa:
                if ~(mean(z_hard==z)>0.5)
                    z_hard = -z_hard+3; 
                end
                
                %plot cross-markers if the hard estimate is incorrect
                plot(X(z_hard~=z,1),X(z_hard~=z,2),'kx','MarkerSize',14,...
                    'LineWidth',2.5)
                %include likelihood numbers in the plot
                text(X(z_hard==dist_ind,1)+0.15,X(z_hard==dist_ind,2),...
                    num2str(z_prob(z_hard==dist_ind),3))

            end

            
        end
        axis(v_ax) %fix the axis
        title(['Iteration #' num2str(iter) ', Likelihood='...
            num2str(likelihoodValue(iter))])%update the title
        drawnow %force to draw immeadiately
        pause(1/10) %pause time (modify to fit your preferences)
        
    end
    %Title after all iterations:
    title(['All iterations (N_{iter}=' num2str(N_iter)...
        ') performed (likelihood=' num2str(likelihoodValue(end)) ').'])
end