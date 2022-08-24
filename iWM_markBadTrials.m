function iWM_markBadTrials(patientCode)


%% 1. add Fieldtrip to the path and initialize it
if exist('ft_defaults.m', 'file') == 0
    IWM_setPath;
end


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end


%% 3. load data
fnameGoodTrials = sprintf('%s%s/%s_data_goodTrials.mat', dataPath, patientCode, patientCode);
flagProceed = true;
if exist(fnameGoodTrials, 'file') == 2
    tmp = input(sprintf('%s already exists. Do you want to redo bad trial marking? [0 for no / 1 for yes]\n', fnameGoodTrials));
    if tmp == 0
        flagProceed = false;
    end
end


%% 4. perform trial rejection
if flagProceed
    load(sprintf('%s%s/%s_data_preprocessed.mat', dataPath, patientCode, patientCode), 'data', 'patientInfo');
    epilepticChans = patientInfo.epilepticChans;
    noisyChans = patientInfo.noisyChans;
    
    nChans = length(data.label);
    idxNoisy = false(nChans, 1);
    idxEpil = false(nChans, 1);
    for idx = 1:nChans
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
    
    cfg = [];
    cfg.channel = setdiff(1:length(data.label), [noisyChansIdx; epilepticChansIdx]);
    dataTMP = ft_preprocessing(cfg, data); % select good channels before visual rejection
    
    cfg = [];
    cfg.method = 'summary';
    dataTMP = ft_rejectvisual(cfg, dataTMP);
    badTrialIdx = find(ismember(data.sampleinfo(:, 1), dataTMP.cfg.artfctdef.summary.artifact(:, 1)));
    goodTrialIdx = setdiff(1:length(data.trial), badTrialIdx);
    save(fnameGoodTrials, 'goodTrialIdx');
end