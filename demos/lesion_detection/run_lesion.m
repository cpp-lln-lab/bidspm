% (C) Copyright 2021 CPP_SPM developers

clear;
clc;

% This script will download the CVI dataset and will run 1) lesion segmentation,
% 2)lesion abnormalities detection and 3)lesion overlapmap adapted from the ALI
% toolbox (SPM.)

% URL of the data set to download
% URL = https://gin.g-node.org/mwmaclean/CVI-Datalad/src/master/data


%downloadData = false;

% run ../../initCppSpm.m;


%% Set options
 
%% Run batches
% reportBIDS(opt);

% deleteZippedNii = true;
% bidsCopyRawFolder(opt, deleteZippedNii, {'anat'});

% Step 1: segmentation
% bidsLesionSegmentation(opt);

% get the anat  file for step 1:
spm_select('FPListRec', pwd, '^sub.*T1w.nii$')

% the output file from the segmentation will be called the same with a
% prefix for segmentation (something like c6 is probably what we need, to
% check):
spm_select('FPListRec', pwd, '^c6sub-.*T1w.nii$')


% acquire_tsv;
%   % Identify if it's a patient or not, create the files accordingly, save in segmented directory and then pull from the lesion
% % abnormality section
% % isPatient = [0 0 0 0 0 1]
% isPatient = participants.group=='blind'; % link to tsv file
% 
% destdir = 'C:\Users\michm\Data\myphdproject\MRI\CVI-DataLad\processed_data\';
% 
%     if ~exist([destdir, 'segmentedPatientData'])
%         mkdir([destdir, 'segmentedPatientData']);
%     end
%     if ~exist([destdir, 'segmentedControlData'])
%         mkdir([destdir, 'segmentedControlData']);
%     end
%     
% for p_i=1:length(isPatient)
%     
% if isPatient(p_i) == 1
%     % assuming that the output is a file
% %     copyfile(fullnames, [destdir, 'segmentedPatientData']);  % store segmented patient output file in directory 1
%        
% else 
% %     copyfile(fullnames, [destdir, 'segmentedControlData']);  %store segmented control output file in directory 2
% end
% 
%     
% end

      

% % Step 2: lesion abnormalities
 bidsLesionAbnormalitiesDetection(opt)
% 
% % Step 3: overlap map
% bidsLesionOverlapMap(opt)


%% % Get data


%To do. add function data download