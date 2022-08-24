%{
This script performs all preprocessing and analysis steps underlying our
Insula Working Memory study.
I. Preprocessing:
- preprocess the song stimulus (waveform -> auditory spectrogram);
- for each patient:
    - preprocess ECoG data (estimation of HFA);
    - detect artifacts (noisy time samples);
    - process anatomical data (MNI electrode coordinates and atlas labels);
II. Encoding models:
- launch all encoding models (STRFs);
- collect STRF metrics and identify significant electrodes
- Fig. 1 - plot example data
- Fig. 2 - analyze STRF prediction accuracies
- Fig. 3 - perform an ICA on STRF coefficients
- Fig. 4 - perform a sliding correlation between ICA components and
           the song spectrogram
III. Decoding models:
- launch linear decoding models for all significant electrodes, and after
  ablating anatomical and functional sets of electrodes
- Fig. 5 - analyze decoding accuracies in the ablation analysis
- launch linear decoding models by bootstrapping the number of electrodes
  used as predictors and the dataset duration
- launch linear and nonlinear reconstruction of the song spectrogram from
  all significant electrodes
- Fig. 6 - analyze output of the bootstrap analysis and of the linear and
           nonlinear song reconstruction
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

% plot recon to identify and validate insular contacts
IWM_plotRecon(patientCode);

IWM_extractInsulaElecCoord;
% from this point, anatomical data (coordinates + anatomical labels) are
% included with each output, to ensure matching between func and anat chans

for idx = 1:14
    IWM_extractInsulaTFdata(idx);
end

IWM_matchFuncAnatElecs; % also, output index of functional channels to match with elec coordinates

IWM_prepareInsulaAnatData;

%% script to be used in the paper
IWM_statsNFBenvelopes('whole');
IWM_statsNFBenvelopes('probe');

IWM_plotNFBenvelopes('whole');
IWM_plotNFBenvelopes('probe');

IWM_probeClusterAnalysis;

%% output figures
IWM_fig1_RThist;
IWM_fig2_coverage;
IWM_fig3_tempProfilesProbe;
IWM_fig4_clusterAnalysis;
IWM_fig5_tempProfilesWhole;