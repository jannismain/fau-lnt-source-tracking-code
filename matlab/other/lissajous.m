function lissajous
%LISSAJOUS - a simple example of 2D line plot in Matlab, and creating a GUI
% without GUIDE.
%
% In mathematics, a Lissajous curve (Lissajous figure or Bowditch curve) is
% the graph of a system of parametric equations:
%     x=Asin(at+d)
%     y=Bsin(bt)
% which describe complex harmonic motion. This family of curves was
% investigated by Nathaniel Bowditch in 1815, and later in more detail
% by Jules Antoine Lissajous in 1857.
% For more inforamtion visit:
% http://en.wikipedia.org/wiki/Lissajous_curve
%
% Author: Grzegorz Knor
% email: gknor at ippt.gov.pl

% create figure
figure('Color',[.8 .8 .8],'Units','Normalized','Position',...
    [0.2805 0.3463 0.4375 0.5250],'menu','no','Name','Lissajous curve');

% title
uicontrol('Style', 'Text', 'String', 'Lissajous curve',...
    'BackgroundColor',[.8 .8 .8],'FontWeight','bold',...
    'Units','Normalized','Position', [.4 .94 .2 .05]);

% main axes
ax = axes('Position',[.06 .17 .7 .76]);

% uicontrols
h1 = uicontrol('Style', 'Edit', 'String', 'A',...
    'Units','Normalized','Position', [.828 .83 .15 .1]);
uicontrol('Style', 'Text', 'String', 'A =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .80 .05 .1]);
h2 = uicontrol('Style', 'Edit', 'String', 'a',...
    'Units','Normalized','Position', [.828 .72 .15 .1]);
uicontrol('Style', 'Text', 'String', 'a =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .69 .05 .1]);
h3 = uicontrol('Style', 'Edit', 'String', 'delta',...
    'Units','Normalized','Position', [.828 .61 .15 .1]);
uicontrol('Style', 'Text', 'String', 'd =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .58 .05 .1]);
h4 = uicontrol('Style', 'Edit', 'String', 'B',...
    'Units','Normalized','Position', [.828 .50 .15 .1]);
uicontrol('Style', 'Text', 'String', 'B =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .47 .05 .1]);
h5 = uicontrol('Style', 'Edit', 'String', 'b',...
    'Units','Normalized','Position', [.828 .39 .15 .1]);
uicontrol('Style', 'Text', 'String', 'b =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .36 .05 .1]);
h6 = uicontrol('Style', 'Edit', 'String', 't',...
    'Units','Normalized','Position', [.828 .28 .15 .1]);
uicontrol('Style', 'Text', 'String', 't =','BackgroundColor',[.8 .8 .8],...
    'Units','Normalized','Position', [.77 .25 .05 .1]);

% start button
uicontrol('Style', 'pushbutton', 'String', 'Start',...
    'Units','Normalized','Position', [.828 .17 .15 .1], 'Callback', @mycallback);

% display equation
axes('Position',[.15 .02 .7 .1]);
text(0,0.5,'x(t) = A{\cdot}sin(a{\cdot}t + \delta), y(t) = B{\cdot}sin(b{\cdot}t)','FontWeight','bold',...
    'FontSize',15)
axis off

% Executes on button press in START
    function mycallback(src,evnt) %#ok<INUSD>
        % parameters value
        A = str2double(get(h1,'String'));
        a = str2double(get(h2,'String'));
        delta = str2double(get(h3,'String'));
        B = str2double(get(h4,'String'));
        b = str2double(get(h5,'String'));
        t = str2double(get(h6,'String'));
        % checking paramters values
        if isnan(A)
            A = 1;
        end
        if isnan(a)
            a = sqrt(2);
        end
        if isnan(delta)
            delta = sqrt(3);
        end
        if isnan(B)
            B = 1.1;
        end
        if isnan(b)
            b = sqrt(7);
        end
        if isnan(t)
            t = 50;
        end
        
        % set strings for edit uicontrols
        set(h1,'String',num2str(A))
        set(h2,'String',num2str(a))
        set(h3,'String',num2str(delta))
        set(h4,'String',num2str(B))
        set(h5,'String',num2str(b))
        set(h6,'String',num2str(t))
        
        % main equation
        T = 0:.01:t*pi;
        x = A*sin(a*T + delta);
        y = B*sin(b*T);
        
        %plot Lissajous curve
        comet(ax,x,y,0.2);
    end % mycallback
end % function lissajous

% EOF :~