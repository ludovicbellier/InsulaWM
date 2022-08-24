function iWM_computeTFR(patientCode)


%% 1. add Fieldtrip to the path and initialize it
if exist('ft_defaults.m', 'file') == 0
    iWM_setPath;
end


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
flagFig = 0;
nFreqSteps = 32; % number of steps for spectral resolution
freqRange = [4 150];
widthRange = [4 30];
timeStep = .005; % sec
baseline = [2 3]; % sec (tb from 0 to 16, prestim = 12, therefore tb from -12 to 4s and baseline from -10 to -9)
prestim = 12;
padding = 2;


%% 3. load data
load(sprintf('%s%s/%s_data_preprocessed.mat', dataPath, patientCode, patientCode), 'data', 'patientInfo');
load(sprintf('%s%s/%s_data_goodTrials.mat', dataPath, patientCode, patientCode), 'goodTrialIdx');


%% 4. clean data (remove channels tagged as noisy and epi and only keep good trials)
N = length(data.label);
epilepticChans = patientInfo.epilepticChans;
noisyChans = patientInfo.noisyChans;
idxNoisy = false(N, 1);
idxEpil = false(N, 1);
for idx = 1:N
    labelTMP = split(data.label{idx}, '-');
    idxNoisy(idx) = any(cellfun(@(x) ismember(x, noisyChans), labelTMP));
    idxEpil(idx) = any(cellfun(@(x) ismember(x, epilepticChans), labelTMP));
end

noisyChansIdx = find(idxNoisy);
if size(noisyChansIdx, 1) == 1
    noisyChansIdx = noisyChansIdx';
end

epilepticChansIdx = find(idxEpil);
if size(epilepticChansIdx, 1) == 1
    epilepticChansIdx = epilepticChansIdx';
end

goodChanIdx = setdiff(1:length(data.label), [noisyChansIdx; epilepticChansIdx]);

cfg = [];
cfg.trials = goodTrialIdx;
cfg.channel = goodChanIdx;
data = ft_preprocessing(cfg, data);
N = length(data.label);


%% 5. enforce similar 1kHz sampling rate across datasets
if data.fsample ~= 1000
    cfg = [];
    cfg.resample = 'yes';
    cfg.resamplefs = 1000;
    data = ft_resampledata(cfg, data);
end


%% 6. perform time-frequency decomposition
cfg = [];
cfg.output = 'pow';
cfg.method = 'wavelet';
cfg.keeptrials = 'yes';
cfg.foi = logspace(log10(freqRange(1)), log10(freqRange(2)), nFreqSteps);
cfg.width = logspace(log10(widthRange(1)), log10(widthRange(2)), nFreqSteps);
cfg.toi = data.time{1}(1):timeStep:data.time{1}(end);
cfg.pad = 'nextpow2';
TFwave = ft_freqanalysis(cfg, data);


%% 7. perform baseline correction for each trial
cfg = [];
cfg.baseline = baseline;
cfg.keeptrials = 'yes';
cfg.baselinetype = 'db';
TFwavebl = ft_freqbaseline(cfg, TFwave);


%% 8. remove data padding
% TW of interest: from -10 (baseline from -10 to -9)
paddingIdx = zeros(2, 1);
[~, paddingIdx(1)] = min(abs(TFwavebl.time-(TFwave.time(1)+padding)));
[~, paddingIdx(2)] = min(abs(TFwavebl.time-(TFwave.time(end)-padding)));
TFwavebl.time = TFwavebl.time(paddingIdx(1):paddingIdx(2)) - prestim;
TFwavebl.powspctrm = TFwavebl.powspctrm(:,:,:,paddingIdx(1):paddingIdx(2));


%% 8.5. plot TFR
if flagFig > 0
    tb = TFwave.time - prestim;
    tbbl = TFwavebl.time;
    fb = TFwave.freq;
    figure;
    for idx = 1:N
        subplot(211);
        imagesc(tb, 1:nFreqSteps, squeeze(mean(TFwave.powspctrm(:,idx,:,:))));
        axis xy; set(gca, 'XTick', tb(1):tb(end));
        set(gca, 'YTick', 1:4:length(fb), 'YTickLabel', round(fb(1:4:end)*10)/10);
        title(sprintf('elec %.3i/%.3i - no baseline correction', idx, N));
        
        subplot(212);
        imagesc(tbbl, 1:nFreqSteps, squeeze(mean(TFwavebl.powspctrm(:,idx,:,:))));
        axis xy; set(gca, 'XTick', tbbl(1):tbbl(end));
        set(gca, 'YTick', 1:4:length(fb), 'YTickLabel', round(fb(1:4:end)*10)/10);
        xlim(tbbl([1 end]));
        title('baseline-corrected');
        
        input('');
    end
	
    figure;
    cfg = [];
    cfg.layout = 'ordered';
    cfg.showlabels = 'yes';
    ft_multiplotTFR(cfg, TFwavebl);
end


%% 9. save TFR
save(sprintf('%s%s/%s_TFdecomposition.mat', dataPath, patientCode, patientCode), 'TFwavebl', '-v7.3');