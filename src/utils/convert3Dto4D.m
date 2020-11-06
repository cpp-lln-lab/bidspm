% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function convert3Dto4D
%
% Short description of what the function does goes here.
%
% USAGE::
%
%   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
%
% :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
%                consectetur adipiscing elit. Ut congue nec est ac lacinia.
% :type argin1: type
% :param argin2: optional argument and its default value. And some of the
%               options can be shown in litteral like ``this`` or ``that``.
% :type argin2: string
% :param argin3: (dimension) optional argument
%
% :returns: - :argout1: (type) (dimension)
%           - :argout2: (type) (dimension)
%
% .. todo:
%
%    - item 1
%    - item 2

% https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files

optSource.sourceDir = '/Users/barilari/Desktop/DICOM_UCL_leuven/renamed/sub-pilot001/ses-002/MRI';

optSource.sequenceToIgnore = {'001-AAHead_Scout_32ch-head-coil', ...
    '002-AAHead_Scout_32ch-head-coil_MPR_sag' ,...
    '003-AAHead_Scout_32ch-head-coil_MPR_cor', ...
    '004-AAHead_Scout_32ch-head-coil_MPR_tra', ...
    '005-b1map_sag_p2', ...
    '006-b1map_sag_p2', ...
    '007-t1_mprage_sag_p2_0.70mm', ...
    '011-gre_field_mapping_2mm_eufind', ...
    '012-gre_field_mapping_2mm_eufind', ...
    '016-gre_field_mapping_2mm_eufind', ...
    '017-gre_field_mapping_2mm_eufind', ...
    '021-gre_field_mapping_2mm_eufind', ...
    '022-gre_field_mapping_2mm_eufind', ...
    '026-gre_field_mapping_2mm_eufind', ...
    '027-gre_field_mapping_2mm_eufind', ...
    '035-gre_field_mapping_2mm_eufind', ...
    '036-gre_field_mapping_2mm_eufind', ...
    '044-gre_field_mapping_2mm_eufind', ...
    '045-gre_field_mapping_2mm_eufind'};

% 0:  SAME
% 2:  UINT8   - unsigned char
% 4:  INT16   - signed short
% 8:  INT32   - signed int
% 16: FLOAT32 - single prec. float
% 64: FLOAT64 - double prec. float
dataType = 0;

sourceDataStruc = dir(optSource.sourceDir);

isDir = [sourceDataStruc(:).isdir]; 

sequenceList = {sourceDataStruc(isDir).name}';

%% Loop through the sequence folders

tic

for iSeq = 1:length(sequenceList)
    
    if length(char(sequenceList(iSeq))) > 2
        
        if sum(strcmp(sequenceList(iSeq), optSource.sequenceToIgnore)) == 1
            
            newline;
            warning('IGNORING SEQUENCE: %s', optSource.sequenceToIgnore{strcmp(sequenceList(iSeq), optSource.sequenceToIgnore)})
            newline;
            
        else
            
            fprintf('\n\nCONVERTING SEQUENCE: %s \n\n', char(sequenceList(iSeq)))
            
            sequencePath = char(fullfile(optSource.sourceDir, sequenceList(iSeq)));
            
            [volumesToConvert, volumesList] = parseNiiFiles(sequencePath);
            
            outputName = char(volumesToConvert(1).name);
            
            dotPos = find(outputName == '.');
            
            outputName = outputName(1:dotPos(1)-1);
            
            outputName = [outputName '_4D.nii' ]; %#ok<AGROW>
            
            jsonList = parseJsonFiles(sequencePath);
            
            jsonFile = jsondecode(fileread(char(jsonList(1))));
            
            RT = jsonFile.acqpar.RepetitionTime/1000;
            
            matlabbatch = setBatch3Dto4D(volumesList, outputName, dataType, RT);
            
            % saveMatlabBatch(matlabbatch, ['3Dto4D_dataType-' num2str(dataType) '_RT-' num2str(RT)], opt, subID);
            
            spm_jobman('run', matlabbatch);
            
            fprintf(1, 'ZIPPING THE 4D BRAIN \n\n');

            gzip([sequencePath filesep outputName])
            
            delete([sequencePath filesep outputName])
            
            dotPos = find(char(jsonList(1)) == '.', 1, 'last');
            
            jsonCopy = char(jsonList(1));
            
            jsonCopy = jsonCopy(1:dotPos(1)-1);
            
            copyfile(char(jsonList(1)), [jsonCopy '_4D.json' ])
            
            fprintf(1, 'EXTERMINATE SINGLE VOLUMES FILES \n\n');
            
            for iDel = 1:length(volumesList)
                
                delete(char(volumesList(iDel)))
                delete(char(jsonList(iDel)))
                
            end
            
        end
        
    end
    
end

newline;
toc

end

function [volumesToConvert, volumesList] = parseNiiFiles(sequencePath)

volumesToConvert = dir(fullfile(sequencePath, '*.nii'));

volumesList = {};

for iVol = 1:size(volumesToConvert,1)
    
    volumesList{end+1} = [volumesToConvert(iVol).folder filesep volumesToConvert(iVol).name];  %#ok<AGROW>
    
end

volumesList = volumesList';


end

function [jsonList] = parseJsonFiles(sequencePath)

jsonToConvert = dir(fullfile(sequencePath, '*.json'));

if size(jsonToConvert, 1) > 0
    
    jsonList = {};
    
    for iJson = 1:size(jsonToConvert, 1)
        
        jsonList{end+1} = [jsonToConvert(iJson).folder filesep jsonToConvert(iJson).name];  %#ok<AGROW>
        
    end
    
    jsonList = jsonList';
    
end

end
