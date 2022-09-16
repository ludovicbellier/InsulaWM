function iWM_plotNFBenvelopes(flagTimeWin)

% flagTimeWin = 'whole' or 'probe'


%% 1. add functions to the path
iWM_setPath;


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
patientList = {'IR57', 'IR85', 'OS21', 'OS27', 'OS29', 'OS32', ...
               'OS34', 'OS36', 'OS38', 'OS40', 'OS43', 'OS51'};
switch flagTimeWin
    case 'whole'
        timeWin = [-10 2];
    case 'probe'
        timeWin = [-1 2];
end
TOI = [0 2];


%% 3. load data
nPat = length(patientList);
load(sprintf('%s_analyses/statsNFBenvelopes_%s_%ipat.mat', dataPath, flagTimeWin, nPat), 'statsCell', 'tpCell', 'FOInames');
load(sprintf('%s_analyses/allInsulaMNIcoord_12patients_FINAL.mat', dataPath), 'elec_mni_frv', 'anatLabels');


%% 4. concatenate envelopes and stats, and extract elec laterality
nFrq = length(FOInames);
N = length(anatLabels);
L = size(tpCell{1}, 2);
tpMat = zeros(nFrq, N, L);
idxSigMat = zeros(nFrq, N);
sigMatMat = zeros(nFrq, N, L);
for idxF = 1:nFrq
    tpMat(idxF, :, :) = cat(1, tpCell{:, idxF});
    idxSigMat(idxF, :) = cell2mat(cellfun(@(x) x.idxSig, statsCell(:, idxF), 'un', 0));
    sigMatMat(idxF, :, :) = cell2mat(cellfun(@(x) x.sigMat, statsCell(:, idxF), 'un', 0));
end

idxElecLat = (elec_mni_frv.elecpos(:, 1) > 0) + 1;
clear tpCell idxSigCell elec_mni_frv

fs = 200;
colorList = [.4 .4 .4; 0 .4392 .7529; .5725 .8157 .3137];

colorSigBar = flipud(hot(8));
colorSigBar = colorSigBar(4:end, :);

tb = linspace(timeWin(1), timeWin(2), L);
[~, idxTOI] = min(abs(tb' - TOI));

switch flagTimeWin
    case 'whole'
        timePeriods = [-10 -9; -9 -4; -4 0; 0 2];
        timePeriodsNames = {'baseline'; 'encoding'; 'maintenance'; 'probe'};
        figure('Color', [1 1 1], 'DefaultAxesFontSize', 5);
        for idxF = 1:nFrq
            idxSig = find(idxSigMat(idxF, :));
            sigMat = squeeze(sigMatMat(idxF, idxSig, :));
            NTMP = length(idxSig);
            
            tpMatTMP = squeeze(tpMat(idxF, idxSig, :));
            idxElecLatTMP = idxElecLat(idxSig);
            anatLabelsTMP = anatLabels(idxSig);
            
            idxL = find(idxElecLatTMP == 1);
            idxR = find(idxElecLatTMP == 2);
            idxA = find(contains(anatLabelsTMP, {'ASG', 'MSG', 'PSG', 'AIC'}));
            idxP = setdiff(1:NTMP, idxA);
            
            idxAL = intersect(idxA, idxL);
            idxAR = intersect(idxA, idxR);
            idxPL = intersect(idxP, idxL);
            idxPR = intersect(idxP, idxR);
            
            idxCell = {idxL, idxR, idxAL, idxAR, idxPL, idxPR};
            
            for idxLat = 1:2
                idxSubplot = idxLat+(idxF-1)*2;
                
                yLimMat = zeros(3, 2);
                
                subplot(3, 2, idxSubplot);
                yLimMat(1, :) = plotX(tpMatTMP(idxCell{idxLat+2}, :), 'mean', fs, colorList(2, :), 10); hold on;
                yLimMat(2, :) = plotX(tpMatTMP(idxCell{idxLat+4}, :), 'mean', fs, colorList(3, :), 10); hold on;
                yLimMat(3, :) = plotX(tpMatTMP(idxCell{idxLat}, :), 'sem', fs, colorList(ceil(idxLat/2), :), 10); box off;
                line(timePeriods([1 1], 2), [-5 5], 'Color', [.5 .5 .5]);
                line(timePeriods([2 2], 2), [-5 5], 'Color', [.5 .5 .5]);
                
                yLim = [min(yLimMat(:, 1)) max(yLimMat(:, 2))];
                
                text(tb(end), yLim(1), sprintf('Ne=%i', length(idxCell{idxLat})), 'FontSize', 4, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
                
                sumSig = sum(sigMat(idxCell{idxLat}, :));
                if ~isempty(idxSig)
                    hold on;
                    for idxNbSig = 2:5 % don't plot when only one sig electrode
                        idxSigSamp = sumSig == idxNbSig;
                        if idxNbSig == 5
                            idxSigSamp = sumSig >= idxNbSig;
                        end
                        if any(idxSigSamp)
                            plot(tb(idxSigSamp), ones(sum(idxSigSamp), 1).*yLim(2), '.', 'MarkerSize', 3, 'Color', colorSigBar(idxNbSig, :));
                        end
                    end
                end
                
                if idxSubplot < 5
                    set(gca, 'XTickLabel', []);
                end
                if idxSubplot == 5
                    xlabel('time (s)'); ylabel('amplitude (A.U.)');
                end
                if ismember(idxSubplot, [1 2])
                    for idxTimePer = 1:4
                        text(mean(timePeriods(idxTimePer, :)), yLim(2)+diff(yLim)*0.1, timePeriodsNames{idxTimePer}, 'HorizontalAlignment', 'center', 'fontSize', 5);
                    end
                end
                ylim(yLim);
            end
        end
        axes(gcf, 'visible', 'off');
        text(.495, .88, 'theta', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        text(.495, .5, 'beta', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        text(.495, .13, 'HFA', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        text(.215, 1.06, 'left', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        text(.785, 1.06, 'right', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        
    case 'probe'
        figure('Color', [1 1 1], 'DefaultAxesFontSize', 5);
        for idxF = 1:nFrq
            idxSig = find(idxSigMat(idxF, :));
            sigMat = squeeze(sigMatMat(idxF, idxSig, :));
            NTMP = length(idxSig);
            
            tpMatTMP = squeeze(tpMat(idxF, idxSig, :));
            idxElecLatTMP = idxElecLat(idxSig);
            anatLabelsTMP = anatLabels(idxSig);
            
            idxL = find(idxElecLatTMP == 1);
            idxR = find(idxElecLatTMP == 2);
            idxA = find(contains(anatLabelsTMP, {'ASG', 'MSG', 'PSG', 'AIC'}));
            idxP = setdiff(1:NTMP, idxA);
            
            idxAL = intersect(idxA, idxL);
            idxAR = intersect(idxA, idxR);
            idxPL = intersect(idxP, idxL);
            idxPR = intersect(idxP, idxR);
            
            idxCell = {idxL, idxR, idxAL, idxAR, idxPL, idxPR};
            
            for idxLat = 1:2
                idxSubplot = idxF + (idxLat - 1) * 3;
                
                yLimMat = zeros(3, 2);
                sumSigMat = zeros(3, L);
                nElecMat = zeros(3, 1);
                for idxSet = 1:3
                    idxSubplot2 = idxSubplot + (idxSet - 1) * 6;
                    subplot(4, 6, idxSubplot2);
                    yLimMat(idxSet, :) = plotX(tpMatTMP(idxCell{idxLat+(idxSet-1)*2}, :), 'sem', fs, colorList(idxSet, :), 1);
                    box off;
                    sumSigMat(idxSet, :) = sum(sigMat(idxCell{idxLat+(idxSet-1)*2}, :));
                    nElecMat(idxSet) = length(idxCell{idxLat+(idxSet-1)*2});
                end
                yLim = [min(yLimMat(:, 1)) max(yLimMat(:, 2))];
                
                for idxSet = 1:3
                    idxSubplot2 = idxSubplot + (idxSet - 1) * 6;
                    subplot(4, 6, idxSubplot2);
                    ylim(yLim);
                    if ~isempty(idxSig)
                        hold on;
                        for idxNbSig = 2:5 % don't plot when only one sig electrode
                            idxSigSamp = sumSigMat(idxSet, :) == idxNbSig;
                            if idxNbSig == 5
                                idxSigSamp = sumSigMat(idxSet, :) >= idxNbSig;
                            end
                            if any(idxSigSamp)
                                plot(tb(idxSigSamp), ones(sum(idxSigSamp), 1).*yLim(2), '.', 'MarkerSize', 3, 'Color', colorSigBar(idxNbSig, :));
                            end
                        end
                    end
                    text(tb(end), yLim(1), sprintf('Ne=%i', nElecMat(idxSet)), 'FontSize', 4, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
                    hold off;
                    if idxSubplot2 < 13
                        set(gca, 'XTickLabel', []);
                    end
                    if idxSubplot2 == 13
                        xlabel('time (s)'); ylabel('amplitude (A.U.)');
                    end
                    if idxSet == 1
                        title(FOInames{idxF});
                    end
                end
                
                idx50Cell = cell(2, 1);
                for idxSet = 2:3
                    subplot(4, 6, idxSubplot2 + 6);
                    tpTMP = tpMatTMP(idxCell{idxLat+(idxSet-1)*2}, idxTOI(1):idxTOI(2));
                    
                    [tpTMPmat, idx50Cell{idxSet-1}] = getCumAUC(tpTMP);
                    
                    plotX(tpTMPmat, 'sem', fs, colorList(idxSet, :), 0, 0);
                    hold on;
                end
                xLim = get(gca, 'XLim');
                line([xLim(1) xLim(2)], [50 50], 'linestyle', ':', 'color', 'k');
                ylim([0 100]);
                hold off
                box off;
                p = ranksum(idx50Cell{1}, idx50Cell{2});
                text(tb(end), 0, sprintf('p=%.3g', p), 'FontSize', 4, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
                if idxSubplot2 == 13
                    xlabel('time (s)'); ylabel('normalized AUC');
                end
            end
        end
        axes(gcf, 'visible', 'off');
        text(.215, 1.06, 'left', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
        text(.785, 1.06, 'right', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'fontSize', 5);
end

% plot the color scale
figure('Color', [1 1 1], 'DefaultAxesFontSize', 5); imagesc(1:5); colormap(colorSigBar); colorbar;
xlim([1.5 5.5]);