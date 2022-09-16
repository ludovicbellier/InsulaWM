function iWM_statsNFBenvelopes(flagTimeWin)

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
FOIlist = [4 8; 13 30; 70 150];
FOInames = {'THETA', 'BETA', 'HFB'};
sigThresh = .05; % p-value
consecThresh = .025; % in sec
switch flagTimeWin
    case 'whole'
        baseline = [-10 -9];
        timeWin = [-10 2];
    case 'probe'
        baseline = [-1 0];
        timeWin = [-1 2];
end


%% 3. loop over patients
nPat = length(patientList);
nFrq = length(FOInames);
statsCell = cell(nPat, nFrq);
tpCell = cell(nPat, nFrq);
for idxPat = 1:nPat
    fprintf('loading %s_TFwaveblIns.mat...\n', patientList{idxPat});
    load(sprintf('%s_analyses/%s_TFwaveblIns.mat', dataPath, patientList{idxPat}), 'TFwaveblIns');
    
    % only keep correct trials
    idxCorrectTrl = find(TFwaveblIns.trialinfo(:, 10) == 1);
    cfg = [];
    cfg.trials = idxCorrectTrl;
    TFwaveblIns = ft_selectdata(cfg, TFwaveblIns);
    
    fb = TFwaveblIns.freq;
    tb = TFwaveblIns.time;
    fs = round(1/diff(tb(1:2)));
    N = length(TFwaveblIns.label);
    T = size(TFwaveblIns.trialinfo, 1);
    L = length(tb);
    
    for idxF = 1:nFrq
        FOI = FOIlist(idxF, :);
        
        % extract Neural Frequency Band (TFR -> NFB)
        idxFOI = [find(fb > FOI(1), 1, 'first') find(fb < FOI(2), 1, 'last')];
        NFB = squeeze(mean(TFwaveblIns.powspctrm(:, :, idxFOI(1):idxFOI(2), :), 3));
        if N == 1
            NFB = reshape(NFB, T, 1, L);
        end
        
        % trim data to selected time window
        [~, idxTw] = min(abs(tb' - timeWin));
        NFB = NFB(:, :, idxTw(1):idxTw(2));
        tbTw = tb(idxTw(1):idxTw(2));
        LTw = length(tbTw);
        
        % baseline correction
        [~, idxBl] = min(abs(tbTw' - baseline));
        idxBl = idxBl(1):idxBl(2);
        NFB = NFB - mean(NFB(:, :, idxBl), 3);
        
        % get length of time window of interest
        LTOI = length(setdiff(1:LTw, idxBl));
        
        % perform ttest
        idxSig = false(N, 1);
        sigMat = zeros(N, LTw);
        for idx = 1:N
            sigSamp = ttest(squeeze(NFB(:, idx, :)), 0, 'alpha', sigThresh / LTOI); % Bonferroni-like correction
            sigSamp = consecutivityCorrection(sigSamp, consecThresh, fs);
            if any(sigSamp)
                idxSig(idx) = true;
                sigMat(idx, :) = sigSamp;
            end
        end
        
        % extract temporal profile / envelope
        NFB = squeeze(mean(NFB));
        if N == 1
            NFB = reshape(NFB, 1, LTw);
        end
        
        % store stat results
        statsCell{idxPat, idxF}.idxSig = idxSig;
        statsCell{idxPat, idxF}.sigMat = sigMat;
        
        % store resulting envelopes
        tpCell{idxPat, idxF} = NFB;
    end
end


%% 4. save stat results
save(sprintf('%s_analyses/statsNFBenvelopes_%s_%ipat.mat', dataPath, flagTimeWin, nPat), 'statsCell', 'tpCell', 'patientList', 'FOInames');