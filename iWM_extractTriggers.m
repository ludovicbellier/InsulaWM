function iWM_extractTriggers(patientCode)

% This is the machinery to extract triggers from the photodiode channel
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
preStim = 12; % prestimulus period to probe (in sec)
postStim = 4; % poststimulus period from probe (in sec)
behavFilename = '/home/knight/IWM_SEEG/Behav/Behav_addedScript2020.xlsx';
behavCols = [13 15 28]; % columns of the behavioral results spreadsheet to be extracted
behavCode = {'HRN', 'HRP', 'LRN', 'LRP'; 30 40 60 50}';


%% 3. get patient information
patientInfo = iWM_infoPatients(patientCode);
filenameList = patientInfo.filename;
nFiles = length(filenameList);


%% 4. load trigger data
switch filenameList{1}(end-2:end)
    case {'edf', 'esa'}
        trigDetectInfo = patientInfo.trigDetectInfo;
        trigChan = patientInfo.trigChan;
        
        dataSave = cell(nFiles, 1);
        for idxFile = 1:nFiles
            filename = filenameList{idxFile};
            hdr = ft_read_header(filename);
            
            cfg = [];
            cfg.dataset = filename;
            cfg.channel = find(contains(hdr.label, trigChan));
            dataTrig = ft_preprocessing(cfg);
            fsOrig = dataTrig.fsample;
            if fsOrig > 1000
                cfg = [];
                cfg.resamplefs = 1000;
                dataTrig = ft_resampledata(cfg, dataTrig);
            end
            
            dataSave{idxFile} = dataTrig;
        end
        if nFiles > 1
            try
                dataTrig = ft_appenddata([], dataSave{:});
            catch
                dataSave{1}.label = dataSave{2}.label;
                dataTrig = ft_appenddata([], dataSave{:});
            end
            dataTrig.time{2} = dataTrig.time{2} + dataTrig.time{1}(end);
            dataTrig.trial = {[dataTrig.trial{1}, dataTrig.trial{2}]};
            dataTrig.time = {[dataTrig.time{1}, dataTrig.time{2}]};
        else
            dataTrig = dataSave{1};
        end
        fs = dataTrig.fsample;
        
        if any(strcmp(patientCode, {'OS21', 'OS24', 'OS27', 'OS29', 'OS36'}))
            dataTrig.trial{1}(1,:) = sum(dataTrig.trial{1}(1:2, :));
            cfg = [];
            cfg.channel = 1;
            dataTrig = ft_selectdata(cfg, dataTrig);
        end
        
        % 5. extract triggers
        % automatically detect steps in photodiode signal
        minPeakHeight = trigDetectInfo(1);
        minPeakDistance = trigDetectInfo(2) * fs/1000;
        X = dataTrig.trial{1};
        tb = dataTrig.time{1};
        [~, loc] = findpeaks(abs(diff(X)), 'MinPeakHeight', minPeakHeight, 'Minpeakdistance', minPeakDistance);
        if flagFig > 0
            figure('DefaultAxesFontSize', 5); plot(tb, X); hold on; plot(tb(loc), mean([min(X) max(X)]), 'r*');
            text(tb(loc), ones(length(loc), 1) .* mean([min(X) max(X)]) * 1.1, strsplit(num2str(1:length(loc))), 'HorizontalAlignment', 'center', 'FontSize', 5);
            if length(trigDetectInfo) < 3
                idxRmLoc = input('Enter index of triggers to be discarded:\n'); %#ok
            end
        end
        if length(trigDetectInfo) > 2
            idxRmLoc = trigDetectInfo(3:end);
        else
            idxRmLoc = [];
        end
        loc(idxRmLoc) = [];
        nTrials = length(loc) / 7;
        if rem(nTrials, 1) ~= 0
            fprintf('/!\\ incomplete triggers /!\\\n');
            if strcmp(patientCode, 'IR85')
                locCanon = reshape(loc([3:667 670:end]), 7, floor(nTrials));
                locCanon = round(mean(locCanon-locCanon(6,:), 2))';
                idxMissingProbes = [668 1]; % must be in descending order
                for idxTMP = 1:length(idxMissingProbes)
                    idxProbe = idxMissingProbes(idxTMP);
                    if idxProbe == 1
                        loc = [loc(1)+locCanon(1:5) loc];
                    else
                        loc = [loc(1:idxProbe-1) loc(idxProbe)+locCanon(1:5) loc(idxProbe:end)];
                    end
                end
            end
            nTrials = length(loc) / 7;
        end
        if nTrials ~= 144
            fprintf('/!\\ missing trials /!\\\n');
        end
        
    case 'mat'
        fsOrig = patientInfo.fs;
        fs = 1000;
        if ~isempty(patientInfo.filenameEvents)
            load(patientInfo.filenameEvents, 'events', 'indEvents');
            eventsMat = [round(indEvents.*(fs/fsOrig))' events'];
        else
            try
                fnameDs = sprintf('%s%s/%s_data_downsampled.mat', dataPath, patientCode, patientCode);
                load(fnameDs, 'data');
                events = data.event;
                fs = data.fsample;
                clear data
                eventsMat = [events(:).sample; events(:).value]';
            catch
                eventSave = cell(nFiles, 1);
                for idxFile = 1:nFiles
                    dataTMP = load(filenameList{idxFile});
                    if idxFile == 1
                        L = length(dataTMP.data.time{1});
                        eventSave{idxFile} = dataTMP.eventsMat;
                    else
                        eventSave{idxFile} = dataTMP.eventsMat + [L 0];
                    end
                    clear dataTMP
                end
                eventsMat = [eventSave{1}; eventSave{2}];
                eventsMat(:, 1) = round(eventsMat(:, 1).*(fs/fsOrig));
                clear eventSave
            end
        end
        
        if any(strcmp(patientCode, {'OS32', 'OS34', 'OS38', 'OS40', 'OS43'}))
            idxProbes = find(eventsMat(:, 2) == 2);
            idxZeros = find(eventsMat(:, 2) == 0);
            idxZerosToRemove = idxZeros(~ismember(idxZeros, idxProbes+1)); % keep only the 0 after the 2
            eventsMat(idxZerosToRemove, :) = [];
            
            idxFirstProbe = find(eventsMat(:, 2) == 2, 1);
            idxLastMarker = find(eventsMat(:, 2) == 16, 1, 'last');
            eventsMat([1:idxFirstProbe-6 idxLastMarker:end], :) = []; % remove triggers after or before the actual task and the practice
            
            eventsMat(eventsMat(:, 2) == 4, :) = []; % remove the breaks
            eventsMat(eventsMat(:, 2) == 16, :) = []; % remove the breaks
            
            % check number of reponses
            nTrials = sum(eventsMat(:, 2) == 2);
            nRT = sum(eventsMat(:, 2) == 0);
            nLetters = sum(eventsMat(:, 2) == 1);
            if nTrials ~= 144 || nRT ~= 144 || nLetters ~= 720
                fprintf('WARNING: there are %i probes, %i zeros and %i letters.\n', nTrials, nRT, nLetters);
            end
            
            loc = eventsMat(:, 1)';
            
        elseif strcmp(patientCode, 'OS51')
            eventsMat(1:34, :) = []; % remove triggers from practice
            eventsMatTMP = [eventsMat(83,1)-round(0.879*fs) 248]; % missing PROBE trigger, with RT of 879ms
            eventsMat = [eventsMat(1:82, :); eventsMatTMP; eventsMat(83:end, :)];
            missingLettersIdx = [137 4; 214 5; 337 3; 687 4; 720 3; 826 5]; % 6 missing letter triggers (current idx, position in letter sequence)
            for idx = 1:size(missingLettersIdx)
                eventsMat = [eventsMat(1:missingLettersIdx(idx, 1)-1, :); [-1 1]; eventsMat(missingLettersIdx(idx, 1):end, :)];
                missingLettersIdx(:, 1) = missingLettersIdx(:, 1) + 1;
            end
            locCanon = reshape(eventsMat(:, 1), 7, 144);
            locCanon(:, any(locCanon==-1)) = [];
            locCanon = round(mean(locCanon-locCanon(6,:), 2))';
            
            locMissingLetters = find(eventsMat(:, 1) == -1);
            for idx = 1:length(locMissingLetters)
                idxToProbe = missingLettersIdx(idx, 2);
                locTMP = eventsMat(locMissingLetters(idx)+6-idxToProbe, 1) + locCanon(idxToProbe);
                eventsMat(locMissingLetters(idx), 1) = locTMP;
           end
            
            idxProbesRT = find(eventsMat(:, 2) == 248);
            idxProbes = idxProbesRT(1:2:end);
            idxRT = idxProbesRT(2:2:end);
           
            % check number of reponses
            nTrials = size(idxProbes, 1);
            nRT = size(idxRT, 1);
            nLetters = sum(eventsMat(:, 2) == 1);
            if nTrials ~= 144 || nRT ~= 144 || nLetters ~= 720
                fprintf('WARNING: there are %i probes, %i zeros and %i letters.\n', nTrials , nRT, nLetters);
            end
            
            loc = eventsMat(:, 1)';
            
        else
            
            eventsMat(564,2) = 7; % weird label
            eventsMat(991,2) = 7;
            eventsMat(924,2) = 121; % instead of 41
            eventsMat(925,2) = 1; % instead of 41
            
            eventsMat([132 133 565 674 675 992 1705 1706 1766 1767],:) = []; % weird double triggers, need to be removed
            
            idxProbes = find(ismember(eventsMat(:,2),[61, 81, 101, 121]));
            idxOnes = find(eventsMat(:, 2) == 1);
            idxOnesToRemove = idxOnes(~ismember(idxOnes, idxProbes+1)); % keep only the 0 after the 2
            eventsMat(idxOnesToRemove, :) = [];
            % one probe trigger did not work so only 143 probes and RT even if 144 trials
            
            idxFirstProbe = find(eventsMat(:, 2) == 1, 1);
            idxLastMarker = find(eventsMat(:, 2) == 255, 1, 'last');
            eventsMat([1:idxFirstProbe-7 idxLastMarker:end], :) = []; % remove triggers after or before the actual task and the practice
            
            eventsMat(eventsMat(:, 2) == 255, :) = []; % remove the breaks
            eventsMat(eventsMat(:, 2) == 253, :) = []; % remove the breaks
            
            % check number of reponses
            nTrials = sum(eventsMat(:, 2) == 1);
            nRT = sum(eventsMat(:, 2) == 1);
            nLetters = sum(ismember(eventsMat(:, 2), [3, 5, 7, 9, 11])); %720
            
            if nTrials ~= 144 || nRT ~= 144 || nLetters ~= 720
                fprintf('WARNING: there are %i probes, %i zeros and %i letters.\n', nTrials, nRT, nLetters);
            end
            
            loc = eventsMat(:, 1)';
            
        end
        
    otherwise
        trigDetectInfo = patientInfo.trigDetectInfo;
        
        addpath(genpath('/home/knight/lbellier/DataWorkspace/_tools/NLX2mat/'));
        filenameNLX = sprintf('%s_data/%s/aux/', dataPath, patientCode');
        cfg = [];
        cfg.dataset = filenameNLX;
        dataTrig = ft_preprocessing(cfg);
        fsOrig = dataTrig.fsample;
        cfg = [];
        cfg.resamplefs = 1000;
        dataTrig = ft_resampledata(cfg, dataTrig);
        fs = dataTrig.fsample;
        
        % 5. extract triggers
        % automatically detect steps in photodiode signal
        minPeakHeight = trigDetectInfo(1);
        minPeakDistance = trigDetectInfo(2) * fs/1000;
        X = dataTrig.trial{1};
        tb = dataTrig.time{1};
        [~, loc] = findpeaks(abs(diff(X)), 'MinPeakHeight', minPeakHeight, 'Minpeakdistance', minPeakDistance);
        if flagFig > 0
            figure; plot(tb, X); hold on; plot(tb(loc), mean([min(X) max(X)]), 'r*');
            text(tb(loc), ones(length(loc), 1) .* mean([min(X) max(X)]) * 1.1, strsplit(num2str(1:length(loc))), 'HorizontalAlignment', 'center');
            if length(trigDetectInfo) < 3
                idxRmLoc = input('Enter index of triggers to be discarded:\n'); %#ok
            end
        end
        if length(trigDetectInfo) > 2
            idxRmLoc = trigDetectInfo(3:end);
        else
            idxRmLoc = [];
        end
        loc(idxRmLoc) = [];
        nTrials = length(loc) / 7;
        if rem(nTrials, 1) ~= 0
            fprintf('/!\\ incomplete triggers /!\\\n');
        end
        if nTrials ~= 144
            fprintf('/!\\ missing trials /!\\\n');
        end
end


%% 5. add behavioral data
[~,~,behavData] = xlsread(behavFilename);
if strcmp(patientCode(1:2), 'OS')
    patientCode2 = ['OSL' patientCode(3:end)];
else
    patientCode2 = patientCode;
end
behavData = behavData(ismember(behavData(:,2), patientCode2), behavCols);
idxCode = cellfun(@(x) find(strcmp(behavCode(:, 1), x)), behavData(:, 1));
behavData(:, 1) = behavCode(idxCode, 2);
behavData = cell2mat(behavData);
if nTrials < 144
    nTrials = floor(nTrials);
    missedTrlIdx = patientInfo.missedTrlIdx;
    behavData(missedTrlIdx, :) = [];
end


%% 6. create the trl matrix
idxProbe = 6:7:nTrials*7; % probe index for each trial
trl = zeros(nTrials, 13);
for idxTrial = 1:nTrials
    locsTrialTMP = loc((-5:1)+idxProbe(idxTrial));
    locProbeTMP = locsTrialTMP(6);
    trl(idxTrial,:) = [locProbeTMP-preStim*fs, locProbeTMP+postStim*fs, 0, abs(locProbeTMP-locsTrialTMP), behavData(idxTrial, :)];
end


%% 7. save triggers
save(sprintf('%s%s/%s_triggers.mat', dataPath, patientCode, patientCode), 'trl');