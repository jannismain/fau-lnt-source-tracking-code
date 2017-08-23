
N = 4.0;
x=linspace(-N, N, 60);
y=x;
[X,Y]=meshgrid(x,y);


var=1; mid=2; prob=0.004;
z1=prob*(1000/sqrt(2*pi).*exp(-((X-mid).^2/var)-((Y-mid).^2/var)));

var=1; mid=-2; prob=0.0018;
z2=prob*(1000/sqrt(2*pi).*exp(-((X-mid).^2/var)-((Y-mid).^2/var)));

var=1; mid=-2; prob=0.0035;
z4=prob*(1000/sqrt(2*pi).*exp(-((X+mid).^2/var)-((Y-mid).^2/var)));

var=1; mid=-2; prob=0.0008;
z5=prob*(1000/sqrt(2*pi).*exp(-((X-mid).^2/var)-((Y+mid).^2/var)));

var=1; mid=0; prob=0.001;
z3=prob*(1000/sqrt(2*pi).*exp(-((X-mid).^2/var)-((Y-mid).^2/var)));

% var2 = 2;
% z2=5*0.001*(1000/sqrt(2*pi).*exp(-((X.^2/var2)+(Y.^2/var2))+3));
z=z1+z2+z3+z4+z5;

figure('Name','Gaussian Mixture Model',...
                  'NumberTitle','off',...
                  'Color','white');
hold on;
axis off;

surf(X,Y,z);
colormap('jet');
% shading interp
axis tight