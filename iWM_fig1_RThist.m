function iWM_fig1_RThist


%% 1. load RT data
dataPath = '/home/knight/IWM_SEEG/';
patientList = {'IR57', 'IR85', 'OS21', 'OS27', 'OS29', 'OS32', ...
               'OS34', 'OS36', 'OS38', 'OS40', 'OS43', 'OS51'};
nPat = length(patientList);
load(sprintf('%s_analyses/probeClusterAnalysisData_12pat.mat', dataPath), 'RTCell');


%% 2. prepare RT data
allRT = cat(1, RTCell{:});
nRTperPat = cellfun(@length, RTCell);
g = repelem(1:nPat, nRTperPat);
colors = jet(nPat);


%% 3. plot RT data
figure('Position', [6 690 1145 606], 'Color', [1 1 1], 'DefaultAxesFontSize', 5);
line([0 nPat+1], [1000 1000], 'color', [1 1 1]*.2, 'linestyle', ':'); hold on;
h = boxplot(allRT, g, 'OutlierSize', 2, 'Symbol', 'o', 'colors', colors);
box off; set(h(1:4, :), 'color', 'k'); set(h(6, :), 'color', 'r'); grid;
ylim([0 2000]); xlim([0 nPat+1]);
ylabel('response time (ms)'); xlabel('patient index');
colors2 = flipud(colors);
h2 = findobj(gca,'Tag','Box');
for j = 1:nPat
    patch(get(h2(j), 'XData'), get(h2(j), 'YData'), colors2(j, :), 'FaceAlpha', .2, 'LineStyle', 'none');
end


%% 4. save figure
fnameOut = sprintf('%s_figures/insula/Fig1_RThist.svg', dataPath);
h = findall(gcf,'-property','FontName');
set(h,'FontName','San Serif');
print(gcf, '-dsvg', fnameOut);