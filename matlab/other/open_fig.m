function open_fig
init_dir = pwd;
FigToOpen = cellstr(uigetfile('*.fig','Select the Figures to open...', init_dir, 'MultiSelect','on') );
for ind = 1 : length(FigToOpen)
    openfig(FigToOpen{ind},'new','visible')
end

