function iWM_epochAndRerefIEEG(patientCode)


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
refMethod = 'bipolar';


%% 3. load preprocessed data and triggers
load(sprintf('%s%s/%s_data_cleaned.mat', dataPath, patientCode, patientCode), 'data');
load(sprintf('%s%s/%s_triggers.mat', dataPath, patientCode, patientCode), 'trl');


%% 4. get patient information
patientInfo = iWM_infoPatients(patientCode);
noisyChans = patientInfo.noisyChans;
epilepticChans = patientInfo.epilepticChans;
nChans = length(data.label);
noisyChansIdx = find(ismember(data.label, noisyChans));
goodChansDispIdx = find(~ismember(data.label, noisyChans));
goodChansIdx = find(~ismember(data.label, [epilepticChans noisyChans]));
if length(noisyChansIdx)+length(goodChansDispIdx) ~= nChans
    fprintf('/!\\ error in elec tagging: %i elecs ~= %i good + %i noisy /!\\\n', nChans, length(goodChansDispIdx), length(noisyChansIdx));
end


%% 4.5. visualize clean data with events
if flagFig > 0
    % create events structure
    nTrl = size(trl, 1);
    fieldNames = {'type', 'sample', 'value', 'offset', 'duration'};
    cellTMP = cell(length(fieldNames), nTrl);
    events = cell2struct(cellTMP, fieldNames);
    for idxTrl = 1:nTrl
        events(idxTrl).type = 'trial';
        events(idxTrl).sample = trl(idxTrl, 1);
        events(idxTrl).value = trl(idxTrl, 11);
        events(idxTrl).offset = 0;
        events(idxTrl).duration = 16;
    end
    
    % observe data
    data.cfg.previous = [];
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.preproc.demean = 'yes';
    cfg.blocksize = 30;
    cfg.channel = goodChansDispIdx;
    cfg.event = events;
    cfg.ylim = [-1 1].*400;
    ft_databrowser(cfg, data);
end


%% 5. epoch data
cfg = [];
cfg.trl = trl;
data = ft_redefinetrial(cfg, data);


%% 6. re-reference clean epochs
switch refMethod
    case 'CAR'
        cfg = [];
        cfg.reref = 'yes';
        cfg.refmethod = 'median';
        cfg.refchannel = goodChansIdx;
        data = ft_preprocessing(cfg, data);
        
    case {'bipo', 'bipolar'}
        cfg = [];
        cfg.reref = 'yes';
        cfg.refmethod = 'bipolar';
        data = ft_preprocessing(cfg, data);
        
        nChans = length(data.label);
        idxChanOk = true(nChans, 1);
        idxNoisy = false(nChans, 1);
        idxEpil = false(nChans, 1);
        for idx = 1:nChans
            labelTMP = split(data.label{idx}, '-');
            crit1 = strcmp(regexp(labelTMP{1}, '\D+', 'once', 'match'), regexp(labelTMP{2}, '\D+', 'once', 'match')); % same elec label
            crit2 = (str2double(regexp(labelTMP{2}, '\d+', 'once', 'match')) - str2double(regexp(labelTMP{1}, '\d+', 'match'))) == 1; % consecutive numbers
            idxChanOk(idx) = crit1 && crit2;
            idxNoisy(idx) = any(cellfun(@(x) ismember(x, noisyChans), labelTMP));
            idxEpil(idx) = any(cellfun(@(x) ismember(x, epilepticChans), labelTMP));
        end
        
        cfg = [];
        cfg.channel = find(idxChanOk);
        data = ft_selectdata(cfg, data);
        
        noisyChansIdx = find(idxNoisy(idxChanOk));
        epilepticChansIdx = find(idxEpil(idxChanOk));
        goodChansDispIdx = setdiff(1:length(data.label), noisyChansIdx)';
        goodChansIdx = setdiff(1:length(data.label), [epilepticChansIdx; noisyChansIdx])';
end


%% 6.5. visualize epochs for re-referenced data
if flagFig > 0
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.preproc.demean = 'yes';
    cfg.channel = goodChansIdx;
    cfg.ylim = [-1 1].*100;
    ft_databrowser(cfg, data);
end


%% 7. save data
patientInfo.noisyChansIdx = noisyChansIdx;
patientInfo.epilepticChansIdx = epilepticChansIdx;
patientInfo.goodChansDispIdx = goodChansDispIdx;
patientInfo.goodChansIdx = goodChansIdx;
patientInfo.labels = data.label;
save(sprintf('%s%s/%s_data_preprocessed.mat', dataPath, patientCode, patientCode), 'data', 'patientInfo', '-v7.3');