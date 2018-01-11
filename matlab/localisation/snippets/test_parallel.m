% tic
% n = 100;
% A = 500;
% a = zeros(n);
% for i = 1:n
%     a(i) = max(abs(eig(rand(A))));
% end
% toc
% 
% tic
% n = 100;
% A = 500;
% a = zeros(n);
% parfor i = 1:n
%     a(i) = max(abs(eig(rand(A))));
% end
% toc


% Test GPU Devices
for ii = 1:gpuDeviceCount
    g = gpuDevice(ii);
    fprintf(1,'Device %i has ComputeCapability %s \n', ...
            g.Index,g.ComputeCapability)
end