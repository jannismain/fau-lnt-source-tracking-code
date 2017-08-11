%
%    (c) Sultan Alzahrani, PhD Student, Arizona State University.
%    ssalzahr@asu.edu,  http://www.public.asu.edu/~ssalzahr/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


clear;
%file name
prompt = 'Please enter 1 for dataset1, 2 for dataset2, 3 for dataset3 ->>> ';
fileNumber = sscanf(input(prompt, 's'), '%d');
%init strategy
prompt = 'Select 1 for random intialization or 2 for KMEAN intialization for EM ->>> ';
intailization_strategy =  sscanf(input(prompt, 's'), '%d');
% r
prompt = 'Select r value ->>> ';
r =  sscanf(input(prompt, 's'), '%d');
%k
prompt = 'Select k value ->>> ';
k =  sscanf(input(prompt, 's'), '%d');

file_Name1 = 'dataset1.txt';
file_Name2 = 'dataset2.txt';
file_Name3 = 'dataset3.txt';
file_Name_test = 'dataset_test.txt';


if fileNumber == 1
    file_used = file_Name1;
elseif  fileNumber == 2
  file_used = file_Name2;
else
    file_used = file_Name3;
end







x = readTrainingData(file_used);

sizeX = size(x,1);

membership=0;
sses = []
vect = 0;
for i = 1:r
    % First do intialization
    r
    [means_init,converiances_init] = intialization_step(intailization_strategy,x,k,i,file_used);
    % run GaussianMixtureLearning update E and M step until convergence reached or max iteration reached...
    [means,converiances,P,log_p_self,liklihood] = GaussianMixtureLearning(x,means_init,converiances_init,k,i);
    means_init_tracker{i} = means_init;
    means_tracker{i} = means;
    converiances_tracker{i} = converiances;
    log_p_self_tracker{i}=log_p_self;
    vect(i) = log_p_self(end)
    P_tracker{i} = P;
    %determine point membership based on highest probab for each point
   
    
end
   
[maxLog,idx] = max(vect);
best_P =  P_tracker{idx};
disp('intialization means are as follows: (each row is a correspondance mean for a cluster)')
best_means_init = means_init_tracker{idx}

disp('Intial converiances are as follows: ')
best_converiances = converiances_tracker{idx};
converiances_init =best_converiances{1};
for i=1:k
    converiances_init{i}
end



best_log_p_self =  log_p_self_tracker{idx};
disp('Last updated means are as follows: (each row is a correspondance mean for a cluster)')
best_means = means_tracker{idx}

converiances =best_converiances{end};
disp('Last updated converiances are as follows: ')
for i=1:k
    converiances{i}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


membership(1:sizeX) = 0;
    for j=1:sizeX
        maxVal = max(best_P(j,:));
        membership(j) = find(best_P(j,:) == maxVal);
    end
membership = membership';
 %doPlot(x,membership,means,r,100)
doPlot_EM(x,membership,best_means_init,best_means,best_converiances{1},best_converiances{end},r,size(best_log_p_self,2),k);
figure(3);
plot(1:size(best_log_p_self,2),best_log_p_self);
        %DoIntailization(x,option,means,converiances)


% now plot the result




