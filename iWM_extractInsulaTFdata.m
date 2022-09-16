function iWM_extractInsulaTFdata(patientCode)


%% 1. add Fieldtrip to the path and initialize it
if exist('ft_defaults.m', 'file') == 0
    iWM_setPath;
end


%% 2. define parameters
global dataPath;
if isempty(dataPath)
    dataPath = '/home/knight/IWM_SEEG/';
end


%% 3. load anatomical information and TFR data
load(sprintf('%s_analyses/allInsulaMNIcoord_12patients_FINAL.mat', dataPath), 'patientList', 'idxElecPat', 'elec_mni_frv');
load(sprintf('%s%s/%s_TFdecomposition.mat', dataPath, patientCode, patientCode), 'TFwavebl');


%% 4. extract insular channels
elecCoordLabels = elec_mni_frv.label(idxElecPat == find(ismember(patientList, patientCode)));
idxLabels = find(ismember(TFwavebl.label, elecCoordLabels));

cfg = [];
cfg.channel = TFwavebl.label(idxLabels);
TFwaveblIns = ft_selectdata(cfg, TFwavebl);


%% 5. save insular TF data
save(sprintf('%s_analyses/%s_TFwaveblIns.mat', dataPath, patientList{idxPat}), 'TFwaveblIns', '-v7.3');