function iWM_probeClusterAnalysis


%% 1. add Fieldtrip to the path and initialize it
if exist('ft_defaults.m', 'file') == 0
    iWM_setPath;
end


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
patientList = {'IR57', 'IR85', 'OS21', 'OS27', 'OS29', 'OS32', ...
               'OS34', 'OS36', 'OS38', 'OS40', 'OS43', 'OS51'};
FOIlist = [4 8; 13 30; 70 150];
FOInames = {'THETA', 'BETA', 'HFB'};
baseline = [-1 0];
timeWin = [-1 2];
TOIclustering = [0 2];
G = 10; % number of trial groups
Kinit = 10; % max number of clusters for exploration


%% 3. load stat results
nPat = length(patientList);
nFrq = length(FOInames);
load(sprintf('%s_analyses/statsNFBenvelopes_probe_%ipat.mat', dataPath, nPat), 'statsCell');


%% 4. loop over patients
fnameHFBg = sprintf('%s_analyses/probeClusterAnalysisData_%ipat.mat', dataPath, nPat);
if exist(fnameHFBg, 'file') == 0
    RTCell = cell(nPat, 1);
    NFBgCell = cell(nPat, nFrq);
    RTgCell = cell(nPat, nFrq);
    for idxPat = 1:nPat
        fprintf('loading %s_TFwaveblIns.mat...\n', patientList{idxPat});
        load(sprintf('%s_analyses/%s_TFwaveblIns.mat', dataPath, patientList{idxPat}), 'TFwaveblIns');
        
        % only keep correct trials
        idxCorrectTrl = find(TFwaveblIns.trialinfo(:, 10) == 1);
        cfg = [];
        cfg.trials = idxCorrectTrl;
        TFwaveblIns = ft_selectdata(cfg, TFwaveblIns);
        
        trialRT = TFwaveblIns.trialinfo(:, 9);
        RTCell{idxPat} = trialRT;
        
        fb = TFwaveblIns.freq;
        tb = TFwaveblIns.time;
        T = size(TFwaveblIns.trialinfo, 1);
        L = length(tb);
        
        for idxF = 1:nFrq
            FOI = FOIlist(idxF, :);
            
            % extract Neural Frequency Band (TFR -> NFB)
            idxFOI = [find(fb > FOI(1), 1, 'first') find(fb < FOI(2), 1, 'last')];
            idxSig = statsCell{idxPat, idxF}.idxSig;
            N = sum(idxSig);
            NFB = reshape(mean(TFwaveblIns.powspctrm(:, idxSig, idxFOI(1):idxFOI(2), :), 3), T, N, L);
            
            % trim data to selected time window
            [~, idxTw] = min(abs(tb' - timeWin));
            NFB = NFB(:, :, idxTw(1):idxTw(2));
            tbTw = tb(idxTw(1):idxTw(2));
            LTw = length(tbTw);
            
            % baseline correction
            [~, idxBl] = min(abs(tbTw' - baseline));
            idxBl = idxBl(1):idxBl(2);
            NFB = NFB - mean(NFB(:, :, idxBl), 3);
            
            [~, idxSortRT] = sort(trialRT);
            
            % "downsample" trials into N groups
            idxFirstTrl = zeros(2, G);
            idxFirstTrl(1, :) = round(1:T/G:T);
            idxFirstTrl(2, :) = [idxFirstTrl(1, 2:end)-1 T];
            NFBg = zeros(G, N, LTw);
            trialRTg = zeros(G, 1);
            for idxG = 1:G
                idxTMP = idxSortRT(idxFirstTrl(1, idxG):idxFirstTrl(2, idxG));
                NFBg(idxG, :, :) = mean(NFB(idxTMP, :, :), 1);
                trialRTg(idxG) = mean(trialRT(idxTMP));
            end
            
            % store resulting matrices
            NFBgCell{idxPat, idxF} = NFBg;
            RTgCell{idxPat, idxF} = trialRTg;
        end
    end
    save(fnameHFBg, 'NFBgCell', 'RTgCell', 'RTCell');
else
    load(fnameHFBg, 'NFBgCell', 'RTgCell');
end


%% Kmeans
for idxF = 1:nFrq
    NFBg = cat(2, NFBgCell{:, idxF});
    NFBg = permute(NFBg, [2 1 3]);
    
    [N, G, L] = size(NFBg);
    tb = linspace(timeWin(1), timeWin(2), L);
    
    % trim to TOI
    [~, idxTOI] = min(abs(tb' - TOIclustering));
    NFBg = NFBg(:, :, idxTOI(1):idxTOI(2));
    tb = tb(idxTOI(1):idxTOI(2));

    [~, ~, L] = size(NFBg);
    NFBg = reshape(NFBg, N, G*L);

    % nb of cluster
    idxClustAll = zeros(N, Kinit);
    CCell = cell(Kinit, 1);
    for idxK = 1:Kinit
        [idxClustAll(:, idxK), CCell{idxK}] = kmeans(NFBg, idxK, 'Replicates', 500);
    end
    va = evalclusters(NFBg, idxClustAll, 'CalinskiHarabasz');
    nK = va.OptimalK;
    
    idxClust = idxClustAll(:, nK);
    C = CCell{nK};
 
    RTmean = mean(cat(2, RTgCell{:, idxF}), 2);
    
    latPeak = zeros(nK, 1);
    for idxK = 1:nK
        [~, latPeak(idxK)] = max(mean(reshape(C(idxK, :), G, L)));
    end
    latPeak = tb(latPeak);
    
    switch idxF
        case 1
            if latPeak(1) < latPeak(2)
                idxClust = floor(1./idxClust) + 1;
                C = C([2 1], :);
            end
        case 2
            if latPeak(1) < latPeak(2)
                idxClust = floor(1./idxClust) + 1;
                C = C([2 1], :);
            end
        case 3
            if latPeak(2) < latPeak(1)
                idxClust = floor(1./idxClust) + 1;
                C = C([2 1], :);
            end
    end
    
    figure('Position', [6 744 1371 552], 'Color', [1 1 1], 'DefaultAxesFontSize', 5);
    for idxK = 1:nK
        compTMP = reshape(C(idxK, :), G, L);
        subplot(1,nK,idxK); imagesc(tb, 1:G, reshape(C(idxK, :), G, L));
        hold on; plot(RTmean/1000, 1:G, '.k', 'MarkerSize', 15); hold off;
        if idxK == 1
            xlabel('time (s)'); ylabel('trial sub-averages');
        end
        
        latMat = zeros(G, 2);
        for idxG = 1:G
            [~, latMat(idxG, 1)] = max(compTMP(idxG, :));
            [~, latMat(idxG, 2)] = min(compTMP(idxG, :));
        end
        [rM, pM] = corr(latMat(:, 1), RTmean);
        [rm, pm] = corr(latMat(:, 2), RTmean);
        title(sprintf('r_max = %.3g - p_max = %.4g\nr_min = %.3g - p_min = %.4g', rM, pM, rm, pm), 'Interpreter', 'none');
    end
    colormap jet;
    
    elecSize = 15; 
    faceAlpha = 1;
    
    idxSig = cell2mat(cellfun(@(x) x.idxSig, statsCell(:, idxF), 'un', 0));

    params = [];
    params.values = zeros(length(idxSig), 1);
    params.values(find(idxSig)) = idxClust;
    params.space = 'MNI';
    params.lateralFilter = 'lh';
    params.extLatInfo = 0;
    params.faceAlpha = faceAlpha;
    params.elecSize = elecSize;
    params.titleStr = 'initialization';
    params.valRange = [0 nK];
    params.centered = 0;
    params.cmap = [0 0 0; 255 135 250; 0 255 190]./255;
    params.figOutTrig = 0;
    params.mask = [];
    params.flagWholeBrain = 0;
    params.XOffset = 2;
    iWM_plotValOnAnat(patientList, params);
    params.lateralFilter = 'rh';
    iWM_plotValOnAnat(patientList, params);
end