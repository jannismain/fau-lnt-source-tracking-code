function f = gaussian_plot()
N = 4.0;
x=linspace(-N, N, 60);
y=x;
[X,Y]=meshgrid(x,y);


for mid=-2:2

    var=1; prob=0.004;
    z=prob*(1000/sqrt(2*pi).*exp(-((X).^2/var)-((Y-mid).^2/var)));
    figure('Name','Gaussian Mixture Model',...
                      'NumberTitle','off',...
                      'Color','white');
    hold on;
    axis off;

    surf(X,Y,z);
    axis tight;
    colormap('jet');
    % shading interp
    view([-45 45])

end

end