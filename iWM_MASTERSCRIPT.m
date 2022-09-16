%{
This script performs all preprocessing and analysis steps underlying our
Insula Working Memory study.
I. Preprocessing of iEEG data:
- for each patient:
    - import and clean iEEG data;
    - extract triggers;
    - epoch and re-reference data;
    - mark bad trials;
    - compute Time-Frequency Representation;
II. Preprocessing of anatomical data:
- for each patient:
    - identify and label insular electrodes (files provided)
    - extract TF data for insular channels
III. Analyses and figures:
- for each patient:
    - statistical tests for emergence from baseline
- across all patients:
    - k-means clustering
    - create all figures
%}


%% Initialization
% add FieldTrip and other important functions to the path
iWM_setPath;

% set working directory
global dataPath;
dataPath = '/home/knight/IWM_SEEG/';

% define patient list
patientList = {'IR57', 'IR85', 'OS16', 'OS21', 'OS24', 'OS27', 'OS29', ...
               'OS32', 'OS34', 'OS36', 'OS38', 'OS40', 'OS43', 'OS51'};


%% I. Preprocessing of iEEG data
% open the script below to store information on patient datasets
edit iWM_infoPatients.m

% loop over patients
P = length(patientList);
for idxP = 1:P
    patientCode = patientList{idxP};
    
    % 1. Import and clean iEEG data (bad channel detection, notch filter)
    iWM_cleanIEEG(patientCode);
    
    % 2. Extract triggers
    iWM_extractTriggers(patientCode);
    
    % 3. Epoch and re-reference iEEG data
    iWM_epochAndRerefIEEG(patientCode);
    
    % 4. Reject bad trials
    iWM_markBadTrials(patientCode);
    
    % 5. Compute Time-Frequency Representations
    iWM_computeTFR(patientCode);
end


%% II. Preprocessing of anatomical data
% after identifying contacts in the insula, two patients with epileptic
% activity on all of their insular contacts were removed

% anatomical information is contained in
% allInsulaMNIcoord_12patients_FINAL.mat and anatDataInsula_FINAL.mat

% redefine patient list
patientList = {'IR57', 'IR85', 'OS21', 'OS27', 'OS29', 'OS32', ...
               'OS34', 'OS36', 'OS38', 'OS40', 'OS43', 'OS51'};

% loop over patients
P = length(patientList);
for idxP = 1:P
    % only keep TFR from insular channels
    iWM_extractInsulaTFdata(patientList{idxP});
end


%% III. Analyses and figures
% compute statistical tests on the whole or probe-only time window,
% returning indices of time samples significantly emerging from baseline
iWM_statsNFBenvelopes('whole');
iWM_statsNFBenvelopes('probe');

% sort trials by RT, compute 10 subaverages and perform k-means clustering
iWM_probeClusterAnalysis;

% create all figures
iWM_fig1_RThist;
iWM_fig2_coverage;
iWM_fig3_tempProfilesProbe;
iWM_fig4_clusterAnalysis;
iWM_fig5_tempProfilesWhole;
