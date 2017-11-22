tic;
for i=1:100
    reshape(psi,em.S,1,1,em.Ynet,em.Xnet,1);
end
toc;

tic;
for i=1:100
    permute(psi,[1,4,5,2,3,6]);
end
toc;