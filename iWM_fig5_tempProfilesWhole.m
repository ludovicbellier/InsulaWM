function iWM_fig5_tempProfilesWhole

iWM_plotNFBenvelopes('whole');

figure(1);
set(gcf, 'Position', [6 486 1766 810]);

% save figure
dataPath = '/home/knight/IWM_SEEG/';
fnameOut = sprintf('%s_figures/insula/Fig5_temporalProfilesWhole.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut, '-painters');

figure(2);
fnameOut = sprintf('%s_figures/insula/Fig5_colorbar.svg', dataPath);
print(gcf, '-dsvg', fnameOut);
