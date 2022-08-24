function patientInfo = iWM_infoPatients(patientCode)

% This is where we collect information about patients, to be read by the
% other scripts. One of the most important scripts, as it contains all of
% our observations.


%% 1. define directories where data is stored
dataPath = '/home/knight/ecog/DATA_FOLDER/';
dataPath2 = '/home/knight/IWM_SEEG/_data/';


%% 2. gather information on patients
% IR57
patients(1).code = 'IR57';
patients(1).implantationLaterality = 'b';
patients(1).fs = 5000;
patients(1).powerLineF0 = 60;
patients(1).trigDetectInfo = [2000 400 1:11 1020:1021]; % minPeakHeight, minPeakDist (ms), idx of detected triggers to be discarded (detection has to be made using the 1kHz downsampled photodiode channel)
patients(1).anatDir = [dataPath 'Irvine/IR57/3D_Images/Recon_Apr_2017/FT_Pipeline/'];
patients(1).filename{1} = [dataPath 'Irvine/IR57/Datafiles/2017032208/2017032208_0001.besa'];
patients(1).trigChan = 'DC02'; % photodiode
patients(1).refChan = 'XREF';
patients(1).otherChans = {'DC01','DC03','DC04','EKG','E','FPZ','CZ','OZ','C3','C4','Z','FP1','FP2','T3','T4','O1','O2','LUC','LLC','RUC','RLC'};
patients(1).depthChans = {'RSM','RAC','ROF','RIN','RTI','RAM','RHH','RTH','LSMA','LAC','LOF','LIN','LTI','LAM','LHH','LTH'};
patients(1).stripChans = {};
patients(1).gridChans = {};
patients(1).noisyChans = {};
patients(1).epilepticChans = {'RAM1','RAM2','RHH1','RHH2','RHH3','RHH4','RTH1','RTH2','LHH1','LHH2','LHH3','LHH4','LAM1','LAM5','LTH1','LTH2'};


% IR85
patients(2).code = 'IR85';
patients(2).implantationLaterality = 'b';
patients(2).powerLineF0 = 60;
patients(2).trigDetectInfo = [2000 300 1:15 683:688 1020:1021];
patients(2).anatDir = [dataPath 'Irvine/IR85/3D_Images/Recon_Apr_2019/FT_Pipeline/'];
patients(2).filename{1} = [dataPath 'Irvine/IR85/Datafiles/2019011416/2019011416_0019.besa'];
patients(2).filename{2} = [dataPath 'Irvine/IR85/Datafiles/2019011416/2019011416_0020.besa']; 
patients(2).trigChan = 'DC01';
patients(2).refChan = 'REF';
patients(2).otherChans = {'DC02','DC03','DC04','E','FZ','CZ','OZ','C3','C4','LUC','LLC','RUC','RLC','EKG'};
patients(2).depthChans = {'LAM','LHH','RAM','RHH','RAC','ROF','RPC','RIN','RTH','RMC','RIT','LTH'};
patients(2).stripChans = {};
patients(2).gridChans = {};
patients(2).noisyChans = {'ROF2','LAM8','RIT10'};
patients(2).epilepticChans = {};


% OS16
patients(3).code = 'OS16';
patients(3).implantationLaterality = 'r';
patients(3).powerLineF0 = 50;
patients(3).fs = 1000;
patients(3).anatDir = [dataPath 'Oslo/OS12/3D_Images/Recon_Jul_2016/FT_Pipeline/'];
patients(3).filename{1} = [dataPath2 'data_raw_OSL16_V2.mat'];
patients(3).filenameEvents = [dataPath2 'events_OSL16_V2.mat'];
patients(3).refChan = [];
patients(3).otherChans = {};
patients(3).depthChans = {'AR','BR','CR','FAR','FBAR','FBPR','FPR'};
patients(3).stripChans = {};
patients(3).gridChans = {};
patients(3).noisyChans = {'FAR7'};
patients(3).epilepticChans = {'AR1','AR2','AR7','BR1','BR2','CR1','CR2'};


% OS21
patients(4).code = 'OS21';
patients(4).implantationLaterality = 'r';
patients(4).powerLineF0 = 50;
patients(4).trigDetectInfo = [1000 200 1:30 451:455 463:467];
patients(4).missedTrlIdx = [61 63:67];
patients(4).anatDir = [dataPath 'Oslo/OS21/3D_Images/Recon_May_2017/FT_Pipeline/'];
patients(4).filename{1} = [dataPath2 'OSL21_IWMnew.edf'];
patients(4).trigChan = {'NpsykPC','NpsykPC2'};
patients(4).refChan = 'RP9';
patients(4).otherChans = {'NpsykPC3','NpsykPC4','REF'};
patients(4).depthChans = {'RF','RG','RP','RA','RC','RB','RS','RT'};
patients(4).stripChans = {};
patients(4).gridChans = {};
patients(4).noisyChans = {};
patients(4).epilepticChans = {'RP1','RP2','RP3','RA1','RA2','RA3','RA4','RC1','RC2','RC3','RC4','RB1','RB2'};


% OS24
patients(5).code = 'OS24';
patients(5).implantationLaterality = 'r';
patients(5).powerLineF0 = 50;
patients(5).fs = 512;
patients(5).trigDetectInfo = [1000 200 1:528 1537:1855];
patients(5).anatDir = [dataPath 'Oslo/OS24/3D_Images/Recon_Jun_2017/FT_Pipeline/'];
patients(5).filename{1} = [dataPath 'Oslo/OS24/Datafiles/OSL24_sEEG_notfiltered/OSL24_MAV_IWM.edf'];
patients(5).refChan = [];
patients(5).trigChan = {'NpsykPC', 'NpsykPC2'};
patients(5).otherChans = {'NpsykPC3', 'NpsykPC4'};
patients(5).depthChans = {'RF', 'RG', 'RH', 'RI', 'RL', 'RM', 'RN', 'RO', 'RT', 'RU', 'RV', 'RW', 'RX', 'RY'};
patients(5).stripChans = {};
patients(5).gridChans = {};
patients(5).noisyChans = {'RF8'};
patients(5).epilepticChans = {'RT2', 'RH6' ,'RH7', 'RH8', 'RI7', 'RI8'};


% OS27
patients(6).code = 'OS27';
patients(6).implantationLaterality = 'r';
patients(6).powerLineF0 = 50;
patients(6).fs = 512;
patients(6).trigDetectInfo = [1000 200 1:34 364:392 1065:1066];
patients(6).missedTrlIdx = 48;
patients(6).anatDir = [dataPath 'Oslo/OS27/3D_Images/Recon_Jun_2017/FT_Pipeline/'];
patients(6).filename{1} = [dataPath 'Oslo/OS27/Datafiles/OSL27_sEEG_notfiltered/OSL27_IWM.edf'];
patients(6).filename{2} = [dataPath 'Oslo/OS27/Datafiles/OS27_Anesthesia.edf'];
patients(6).refChan = [];
patients(6).trigChan = {'NpsykPC', 'NpsykPC2'};
patients(6).otherChans = {'NpsykPC3', 'NpsykPC4'};
patients(6).depthChans = {'RF', 'RG', 'RH', 'RI', 'RJ', 'RK', 'RP', 'RQ', 'RR', 'RS', 'RT', 'RU', 'RV', 'RW'};
patients(6).stripChans = {};
patients(6).gridChans = {};
patients(6).noisyChans = {'RV15', 'RH10'};
patients(6).epilepticChans = {'RV12', 'RV13', 'RV14', 'RR1', 'RR2', 'RK1', 'RK2', 'RJ5', 'RW2', 'RW3'};


% OS29
patients(7).code = 'OS29';
patients(7).implantationLaterality = 'b';
patients(7).powerLineF0 = 50;
patients(7).fs = 512;
patients(7).trigDetectInfo = [1000 200 1:25];
patients(7).anatDir = [dataPath 'Oslo/OS29/3D_Images/Recon_Jun_2017/FT_Pipeline/'];
patients(7).filename{1} = [dataPath 'Oslo/OS29/Datafiles/OSL29_sEEG_notfiltered/OSL29_IWM.edf'];
patients(7).taskWindow = [2100 5200];
patients(7).refChan = [];
patients(7).trigChan = {'NpsykPC', 'NpsykPC2'};
patients(7).otherChans = {'NpsykPC3', 'NpsykPC4', 'Sync1', 'Sync2'};
patients(7).depthChans = {'LX', 'LY', 'RF', 'RG', 'RH', 'RP', 'RQ', 'RS', 'RU'};
patients(7).stripChans = {};
patients(7).gridChans = {};
patients(7).noisyChans = {};
patients(7).epilepticChans = {'RP3', 'RP7', 'RP8', 'RQ1', 'RQ2', 'RQ6', 'RQ8', 'RQ9', 'RG11', 'RG12','RG13', 'RF13'};


% OS32
patients(8).code = 'OS32';
patients(8).implantationLaterality = 'b';
patients(8).fs = 2000;
patients(8).powerLineF0 = 50;
patients(8).anatDir = [dataPath 'Oslo/OS32/3D_Images/Recon_Nov_2017/FT_Pipeline/'];
patients(8).filename{1} = [dataPath2 'data_raw_OSL32.mat'];
patients(8).filenameEvents = [dataPath2 'events_OSL32.mat'];
patients(8).depthChans = {'D','E','F','K','L','M','O','Q','S','A','B','C'};
patients(8).stripChans = {};
patients(8).gridChans = {};
patients(8).refChan = 'S11';
patients(8).otherChans = {};
patients(8).noisyChans = {'C12'};
patients(8).epilepticChans = {'D2','K7','A1','B1','B2','C2'};


% OS34
patients(9).code = 'OS34';
patients(9).implantationLaterality = 'r';
patients(9).fs = 2000;
patients(9).powerLineF0 = 50;
patients(9).anatDir = [dataPath 'Oslo/OS34/3D_Images/Recon_Feb_2018/FT_Pipeline/'];
patients(9).filename{1} = [dataPath2 'data_raw_OSL34.mat'];
patients(9).filenameEvents = [dataPath2 'events_OSL34.mat'];
patients(9).refChan = [];
patients(9).otherChans = {};
patients(9).depthChans = {'A','B','C','E','F','G','M','N','O','P','T'};
patients(9).stripChans = {};
patients(9).gridChans = {};
patients(9).noisyChans = {'M7','P12'};
patients(9).epilepticChans = {'A8','A9','A10','A11','A12','A13','A14','C1','C4','C9','C10','C11','C12','C13','C14','C15',...
'E7','E8','E9','E10','E11','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','F13',...
'G1','G2','G3','G4','G5','G8','G9','G10','G11','G12'};


% OS36
patients(10).code = 'OS36';
patients(10).implantationLaterality = 'r';
patients(10).powerLineF0 = 50;
patients(10).trigDetectInfo = [1000 200 1:25 369:372];
patients(10).missedTrlIdx = [49 50 52];
patients(10).anatDir = [dataPath 'Oslo/OS36/3D_Images/Recon_Feb_2018/FT_Pipeline/'];
patients(10).filename{1} = [dataPath2 'OSL36_IWMnew.edf'];
patients(10).trigChan = {'NpsykPC','NpsykPC2'};
patients(10).refChan = [];
patients(10).otherChans = {'NpsykPC3','NpsykPC4','REF'};
patients(10).depthChans = {'RF','RB','RC','RE','RA','RG','RR','RO','RP','RX'};
patients(10).stripChans = {};
patients(10).gridChans = {};
patients(10).noisyChans = {'RA14','RO14','RX16'};
patients(10).epilepticChans = {'RA15','RB1','RB2','RB3','RC1','RC2','RC3','RC4'};


% OS38
patients(11).code = 'OS38';
patients(11).implantationLaterality = 'l';
patients(11).fs = 2000;
patients(11).powerLineF0 = 50;
patients(11).anatDir = [dataPath 'Oslo/OS38/3D_Images/Recon_Jun_2018/FT_Pipeline/'];
patients(11).filename{1} = [dataPath2 'data_raw_OSL38.mat'];
patients(11).filenameEvents = [dataPath2 'events_OSL38.mat'];
patients(11).refChan = [];
patients(11).otherChans = {};
patients(11).depthChans = {'A','B','C','E','F','H','L','M','P','Q','R','S','T','X'};
patients(11).stripChans = {};
patients(11).gridChans = {};
patients(11).noisyChans = {'A12','B12'};
patients(11).epilepticChans = {'H5','H6','H7','H8','E3','E4','E5','E6','E7','X2','X5','X6','X7','06','P7','C1','C2','C3'};


% OS40
patients(12).code = 'OS40';
patients(12).implantationLaterality = 'l';
patients(12).powerLineF0 = 50;
patients(12).fs = 2000;
patients(12).anatDir = [dataPath 'Oslo/OS40/3D_Images/Recon_Jun_2018/FT_Pipeline/'];
patients(12).filename{1} = [dataPath2 'data_raw_OSL40.mat'];
patients(12).filenameEvents = [dataPath2 'events_OSL40.mat'];
patients(12).refChan = [];
patients(12).otherChans = {};
patients(12).depthChans = {'A','B','C','E','F','G','H','K','P','T','X','Y'};
patients(12).stripChans = {};
patients(12).gridChans = {};
patients(12).noisyChans = {'A14','Y17'};
patients(12).epilepticChans = {'B1','B2','B3','B4','B5','C1','C2','C3','C4''C9','C13','E1','E2','E3','G1','G2','G3','G4','G13','K7','P1','P2','P3','P5','P7','P8','P9','X1'};


% OS43
patients(13).code = 'OS43';
patients(13).implantationLaterality = 'l';
patients(13).powerLineF0 = 50;
patients(13).fs = 1000;
patients(13).anatDir = [dataPath 'Oslo/OS43/3D_Images/Recon_Feb_2019/FT_Pipeline/'];
patients(13).filename{1} = '/home/knight/anais/Desktop/IWM_Parietofrontal/WM/IWM-Post/raw_data/OSL43/data_raw_OSL43.mat'; % 180 chans, fs=1kHz
patients(13).filenameEvents = '/home/knight/anais/Desktop/IWM_Parietofrontal/WM/IWM-Post/raw_data/OSL43/events_OSL43.mat';
patients(13).refChan = [];
patients(13).otherChans = {};
patients(13).depthChans = {'B', 'F', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'W'};
patients(13).stripChans = {};
patients(13).gridChans = {};
patients(13).noisyChans = {'O6', 'P6'};
patients(13).epilepticChans = {'B4', 'B5', 'Q11', 'Q12', 'Q13', 'R7', 'R10', 'R11', 'R12', 'W2'};


% OS51
patients(14).code = 'OS51';
patients(14).implantationLaterality = 'r';
patients(14).powerLineF0 = 50;
patients(14).fs = 1024;
patients(14).anatDir = [dataPath 'Oslo/OS51/3D_Images/Recon_Mar_2020/FT_Pipeline/'];
patients(14).filename{1} = [dataPath2 'OSL51_1.mat'];
patients(14).filename{2} = [dataPath2 'OSL51_2.mat'];
patients(14).refChan = [];
patients(14).otherChans = {'MKR1','MKR2','MKR3','MKR4'}; 
patients(14).depthChans = {'B','W','S','C','R','L','T','A','P','M','N','O','Q','G','F'};
patients(14).stripChans = {};
patients(14).gridChans = {};
patients(14).noisyChans = {'A15','P11','M10','N17','O9','Q8','Q10','Q16','Q17'};
patients(14).epilepticChans = {'A1'};


%% 3. select patient data
if nargin < 1
    patientInfo = patients;
else
    patientInfo = patients(strcmp({patients.code}, patientCode));
end