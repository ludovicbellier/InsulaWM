function iWM_fig3_tempProfilesProbe

iWM_plotNFBenvelopes('probe');

figure(1);
set(gcf, 'Position', [6 216 1766 1080]);

% save figure
dataPath = '/home/knight/IWM_SEEG/';
fnameOut = sprintf('%s_figures/insula/Fig3_temporalProfilesProbe.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut);

figure(2);
fnameOut = sprintf('%s_figures/insula/Fig3_colorbar.svg', dataPath);
print(gcf, '-dsvg', fnameOut);
