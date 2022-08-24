function iWM_cleanIEEG(patientCode)

% This is the machinery to preprocess the data (from raw to clean data)
% all required information is read from iWM_infoPatients.m


%% 1. add Fieldtrip to the path and initialize it
if exist('ft_defaults.m', 'file') == 0
    iWM_setPath;
end


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
flagFig = 0; % flag to create figures in the process
HPcutoff = 1; % high-pass filter cutoff
LPcutoff = 250; % low-pass filter cutoff
pos1 = [1 45 1144 1200]; % to resize ft_databrowser
pos2 = [1145 45 1144 1200];


%% 3. get patient information
patientInfo = iWM_infoPatients(patientCode);
powerLineF0 = patientInfo.powerLineF0;
filenameList = patientInfo.filename;
trigChan = patientInfo.trigChan;
refChan = patientInfo.refChan;
otherChans = patientInfo.otherChans;
noisyChans = patientInfo.noisyChans;
nFiles = length(filenameList);
filename = filenameList{1};


%% 4. load iEEG data
if ~exist(sprintf('%s%s', dataPath, patientCode), 'dir')
    mkdir(sprintf('%s%s', dataPath, patientCode));
end
fnameDs = sprintf('%s%s/%s_data_downsampled.mat', dataPath, patientCode, patientCode);
if exist(fnameDs, 'file') == 2
    load(fnameDs, 'data');
else
    switch filename(end-2:end)
        case {'edf', 'esa'}
            hdr = ft_read_header(filename);
            fsOrig = hdr.Fs;
            if fsOrig > 1000
                data = iWM_downsampleIEEG(patientCode);
            else
                cfg = [];
                cfg.dataset = filename;
                data = ft_preprocessing(cfg);
            end
        case 'mat'
            dataTMP = load(filename);
            data = dataTMP.data;
            fsOrig = data.fsample;
            clear dataTMP
            if fsOrig > 1000
                data = iWM_downsampleIEEG(patientCode);
            end
        otherwise
            addpath(genpath('/home/knight/lbellier/DataWorkspace/_tools/NLX2mat/'));
            trigName = split(trigChan, {'_', '.'});
            trigPrefix = trigName{1};
            if length(trigName) < 3
                trigSuffix = '';
            else
                trigSuffix = ['_' trigName{2}];
            end
            
            if ~exist(sprintf('%s_data/%s', dataPath, patientCode), 'dir')
                mkdir(sprintf('%s_data/%s', dataPath, patientCode));
                mkdir(sprintf('%s_data/%s/macro/', dataPath, patientCode));
                mkdir(sprintf('%s_data/%s/aux/', dataPath, patientCode));
                system(sprintf('cp %sEvents%s.nev %s_data/%s/aux/', filename, trigSuffix, dataPath, patientCode));
                system(sprintf('cp %s%s%s.ncs %s_data/%s/aux/', filename, trigPrefix, trigSuffix, dataPath, patientCode));
                system(sprintf('cp %s[[:upper:]][[:upper:]]*%s.ncs %s_data/%s/macro/', filename, trigSuffix, dataPath, patientCode));
            end
            filenameNLX = sprintf('%s_data/%s/macro/', dataPath, patientCode');
            cfg = [];
            cfg.dataset = filenameNLX;
            data = ft_preprocessing(cfg);
            fsOrig = data.fsample;
            if fsOrig > 1000
                data = iWM_downsampleIEEG(patientCode);
            end
    end
end

% take care of cases where more than one datafile
if nFiles > 1
    if strcmp(patientCode, 'OS27')
        dataSave = cell(nFiles, 1);
        for idxFile = 1:nFiles
            cfg = [];
            cfg.dataset = filenameList{idxFile};
            data = ft_preprocessing(cfg);
            dataSave{idxFile} = data;
        end
        
        dataSave{2}.label(1:end-4) = cellfun(@(x) x(5:end-4), dataSave{2}.label(1:end-4), 'un', 0);
        dataSave{2}.label(end-3:end) = cellfun(@(x) x(4:end-4), dataSave{2}.label(end-3:end), 'un', 0);
        dataSave{2}.label = regexprep(dataSave{2}.label, '_', '');
        dataSave{2}.label(1:end-4) = cellfun(@(x) [regexp(x, '\D+', 'match', 'once') num2str(str2double(regexp(x, '\d+', 'match', 'once')))], dataSave{2}.label(1:end-4), 'un', 0);
        
        dataSave{1}.label = dataSave{2}.label;
        
        data = ft_appenddata([], dataSave{:});
    end
    
    data.time{2} = data.time{2} + data.time{1}(end);
    data.trial = {[data.trial{1}, data.trial{2}]};
    data.time = {[data.time{1}, data.time{2}]};
    if isfield(data, 'sampleinfo')
        data.sampleinfo = [1 length(data.time{1})];
    end
end

% correct labels as needed
if any(strcmp(patientCode, {'OS21', 'OS36'}))
    data.label(1:end-5) = cellfun(@(x) x(5:end-4), data.label(1:end-5), 'un', 0);
    data.label(end-4:end-1) = cellfun(@(x) x(4:end), data.label(end-4:end-1), 'un', 0);
    data.label = regexprep(data.label, '_', '');
    data.label(1:end-5) = cellfun(@(x) [regexp(x, '\D+', 'match', 'once') num2str(str2double(regexp(x, '\d+', 'match', 'once')))], data.label(1:end-5), 'un', 0);
end
if any(strcmp(patientCode, {'OS24', 'OS29'}))
    data.label(1:end-4) = cellfun(@(x) x(5:end-4), data.label(1:end-4), 'un', 0);
    data.label(end-3:end) = cellfun(@(x) x(4:end), data.label(end-3:end), 'un', 0);
    data.label = regexprep(data.label, '_', '');
    data.label(1:end-4) = cellfun(@(x) [regexp(x, '\D+', 'match', 'once') num2str(str2double(regexp(x, '\d+', 'match', 'once')))], data.label(1:end-4), 'un', 0);
end
if strcmp(patientCode, 'OS51')
    data.label = cellfun(@(x) [regexp(x, '\D+', 'match', 'once') num2str(str2double(regexp(x, '\d+', 'match', 'once')))], data.label, 'un', 0)';    
end
if any(strcmp(patientCode, {'OS16', 'OS32', 'OS34', 'OS38', 'OS40', 'OS43'}))
    elecNames = cellfun(@(x) x(regexp(x, '\D')), data.label, 'un', 0);
    uniqElecNames = unique(elecNames, 'stable');
    nElecNames = length(uniqElecNames);
    idxReorg = 1:nElecNames;
    for idx = 1:nElecNames
        elecNameTMP = uniqElecNames(idx);
        idxElecInLabels = find(ismember(elecNames, elecNameTMP));
        labelsTMP = data.label(idxElecInLabels);
        elecNumber = cellfun(@(x) str2double(x(regexp(x, '\d'))), labelsTMP);
        [~, idxElecNumber] = sort(elecNumber);
        idxReorg(idxElecInLabels) = idxElecInLabels(idxElecNumber);
    end
    data.label = data.label(idxReorg);
    if size(data.label, 1) < size(data.label, 2)
        data.label = data.label';
    end
    data.trial{1} = data.trial{1}(idxReorg, :);
end
if strcmp(patientCode, 'OS43')
    data = rmfield(data, {'nCh', 'event'});
end


%% 4.5 visualize raw data
if flagFig > 0
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.preproc.demean = 'yes';
    cfg.blocksize = 10;
    cfg.position = pos1;
    cfg.ylim = [-1 1].*200;
    ft_databrowser(cfg, data);
end


%% 5. parse data
if ~isempty([refChan trigChan otherChans])
    cfg = [];
    cfg.channel = find(~ismember(data.label, [refChan trigChan otherChans]));
    data = ft_selectdata(cfg, data);
end
goodChansDispIdx = find(~ismember(data.label, noisyChans));


%% 5.5 visualize iEEG-chans-only raw data
if flagFig > 0
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.preproc.demean = 'yes';
    cfg.blocksize = 10;
    cfg.channel = goodChansDispIdx;
    cfg.position = pos1;
    cfg.ylim = [-1 1].*400;
    ft_databrowser(cfg, data);
end


%% 6. filter out power line noise and detrend
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = (powerLineF0 * (1:round((LPcutoff+powerLineF0)/powerLineF0)) + [-1; 1])';
if data.fsample <= 512
    cfg.bsfreq = cfg.bsfreq(1:5, :);
end
cfg.bsfiltord = 3;
cfg.hpfilter = 'yes';
cfg.hpfreq = HPcutoff;
cfg.hpfiltord = 3;
cfg.lpfilter = 'yes';
cfg.lpfreq = LPcutoff;
data = ft_preprocessing(cfg, data);


%% 6.5 visualize clean data - useful to optimally detect epileptic channels
if flagFig > 0
    cfg = [];
    cfg.viewmode = 'vertical';
    cfg.preproc.demean = 'yes';
    cfg.blocksize = 10;
    cfg.channel = goodChansDispIdx;
    cfg.position = pos2;
    cfg.ylim = [-1 1].*200;
    ft_databrowser(cfg, data);
end


%% 7. save preprocessed data
save(sprintf('%s%s/%s_data_cleaned.mat', dataPath, patientCode, patientCode), 'data', '-v7.3');