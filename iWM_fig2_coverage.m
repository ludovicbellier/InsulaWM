function iWM_fig2_coverage


%% 1. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
faceAlpha = 1;

load(sprintf('%s_analyses/anatDataInsula_FINAL.mat', dataPath), 'mesh_LI', 'mesh_RI', 'face_colors_LI', 'face_colors_RI', 'elec_mni_frv_LI', 'elec_mni_frv_RI', 'insula_SR_index_LI', 'insula_SR_index_RI', 'insula_sub_regions');


%% 2. anatomical view
figure('Color', [1 1 1]); ft_plot_mesh(mesh_LI, 'edgealpha', 0, 'facecolor', face_colors_LI, 'facealpha', faceAlpha);
view([-120 -30]); material dull; lighting gouraud; camlight;
view([-90 0]);
ft_plot_sens(elec_mni_frv_LI, 'elecshape', 'sphere', 'elecsize', 1.5, 'facecolor', [1 0 0]);

fnameOut = sprintf('%s_figures/insula/Fig2_coverageAnatL.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut);

figure('Color', [1 1 1]); ft_plot_mesh(mesh_RI, 'edgealpha', 0, 'facecolor', face_colors_RI, 'facealpha', faceAlpha);
view([80 -30]); material dull; lighting gouraud; camlight;
view([90 0]);
ft_plot_sens(elec_mni_frv_RI, 'elecshape', 'sphere', 'elecsize', 1.5, 'facecolor', [1 0 0]);

fnameOut = sprintf('%s_figures/insula/Fig2_coverageAnatR.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut);


%% 3. bar plot
countL = sum(insula_SR_index_LI,1);
countR = sum(insula_SR_index_RI,1);
nL = size(insula_SR_index_LI, 1);
nR = size(insula_SR_index_RI, 1);
N = nL + nR;

percL = countL/N*100;
percR = countR/N*100;
figure('Position', [67 602 1269 614], 'Color', [1 1 1], 'DefaultAxesFontSize', 5);
h = bar([percL; percR]'); % global percentage
set(gca, 'XTickLabel', insula_sub_regions, 'YGrid', 'on');
ylabel('percentage insula subregions');
xlabel ('Left vs Right');
box off
colorList = [0 32 96; 0 112 192; 0 176 240; 237 125 49; 0 146 66; 146 208 80]./255;
h(1).FaceColor = 'flat';
h(1).CData = colorList;
h(2).FaceColor = 'flat';
h(2).CData = colorList .* .8;

% save figure
fnameOut = sprintf('%s_figures/insula/Fig2_coverageBarPlot.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut);
