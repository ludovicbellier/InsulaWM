function data = iWM_downsampleIEEG(patientCode)


%% 1. add Fieldtrip to the path and initialize it
iWM_setPath;

%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end
fsOut = 1000; % new sampling rate


%% 3. get patient information
cd(dataPath);
fprintf('Processing patient %s...\n', patientCode);
patientInfo = iWM_infoPatients(patientCode);
filenameList = patientInfo.filename;
nFiles = length(filenameList);


%% 4. load header and define channel batches
dataSave = cell(nFiles, 1);
for idxFile = 1:nFiles
    filename = filenameList{idxFile};
    switch filename(end-2:end)
        case {'edf', 'esa'}
            cfg = [];
            cfg.dataset = filename;
            data = ft_preprocessing(cfg);
            
            cfg = [];
            cfg.resamplefs = fsOut;
            data = ft_resampledata(cfg, data);
            
        case 'mat'
            data = load(filename);
            data = data.data;
            fsOrig = data.fsample;
            
            cfg = [];
            cfg.resamplefs = fsOut;
            data = ft_resampledata(cfg, data);
            
            try
                % update events - should be included in iWM_downsampleIEEG.m
                evtTMP = num2cell(ceil([data.event.sample].*(fsOut/fsOrig)));
                [data.event.sample] = evtTMP{:};
                evtTMP = num2cell(ceil([data.event.offset].*(fsOut/fsOrig)));
                [data.event.offset] = evtTMP{:};
            catch
            end
            
        otherwise
            addpath(genpath('/home/knight/lbellier/DataWorkspace/_tools/NLX2mat/'));
            filenameNLX = sprintf('%s_data/%s/macro/', dataPath, patientCode);
            
            cfg = [];
            cfg.dataset = filenameNLX;
            data = ft_preprocessing(cfg);
            
            cfg = [];
            cfg.resamplefs = fsOut;
            data = ft_resampledata(cfg, data);
    end
    dataSave{idxFile} = data;
end
if nFiles > 1
    data = ft_appenddata([], dataSave{:});
else
    data = dataSave{1};
end


%% 5. save downsampled data
save(sprintf('%s%s/%s_data_downsampled.mat', dataPath, patientCode, patientCode), 'data', '-v7.3');