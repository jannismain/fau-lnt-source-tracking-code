a = magic(10000);
b = magic(10000);
tic;
for i=1:1
%     c = a-b;
    c = bsxfun(@minus,a,b);
end
fprintf('execution time = %s\n', num2str(toc)');