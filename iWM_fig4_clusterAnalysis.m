iWM_probeClusterAnalysis;

dataPath = '/home/knight/IWM_SEEG/';
FOInames = {'THETA', 'BETA', 'HFA'};

for idxF = 1:3
    offset = (idxF-1)*3;
    figure(1 + offset);
    
    % save figures
    fnameOut = sprintf('%s_figures/insula/Fig4_clusters_%s.svg', dataPath, FOInames{idxF});
    h = findall(gcf,'-property','FontName');
    set(h,'FontName','San Serif');
    print(gcf, '-dsvg', fnameOut);
    
    figure(2 + offset);
    fnameOut = sprintf('%s_figures/insula/Fig4_clusterAnatL_%s.svg', dataPath, FOInames{idxF});
    print(gcf, '-dsvg', fnameOut);
    
    figure(3 + offset);
    fnameOut = sprintf('%s_figures/insula/Fig4_clusterAnatR_%s.svg', dataPath, FOInames{idxF});
    print(gcf, '-dsvg', fnameOut);
end

% statistical test - Fisher's exact test
% anterior - posterior
x = [6 7; 3 5]; % theta [C1a C1p; C2a C2p]
x = [9 3; 2 5]; % beta
x = [15 2; 4 18]; % HFA
x = table(x(:, 1), x(:, 2), 'VariableNames', {'ant.', 'post.'}, 'RowNames', {'C1', 'C2'});
[h, p, stats] = fishertest(x);

% left - right
x = [3 10; 7 1]; % theta [C1l C1r; C2l C2r]
x = [3 9; 4 3]; % beta
x = [7 10; 11 11]; % HFA
x = table(x(:, 1), x(:, 2), 'VariableNames', {'left', 'right'}, 'RowNames', {'C1', 'C2'});
[h, p, stats] = fishertest(x);