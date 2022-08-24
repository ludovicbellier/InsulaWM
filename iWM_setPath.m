function iWM_setPath

ftDir = '/home/knight/lbellier/DataWorkspace/_tools/git/fieldtrip/';
if exist('ft_defaults.m', 'file') == 0
    addpath(ftDir); ft_defaults;
end
addpath('/home/knight/lbellier/DataWorkspace/_tools');