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
%    - expand to run through multiple subjs ans groups
%      (https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files)
%    - generalize how to retrieve RT from sidecar json file
%    - saveMatlabBatch(matlabbatch, ['3Dto4D_dataType-' num2str(dataType) '_RT-' num2str(RT)], opt, subID);


% Set the folder where sequences folders exist
optSource.sourceDir = '/Users/barilari/Desktop/DICOM_UCL_leuven/renamed/sub-pilot001/ses-002/MRI';

% List the sequences that you want to skip (folder name)
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

% Set data format conversion (0 is reccomended)

% 0:  SAME
% 2:  UINT8   - unsigned char
% 4:  INT16   - signed short
% 8:  INT32   - signed int
% 16: FLOAT32 - single prec. float
% 64: FLOAT64 - double prec. float
optSource.dataType = 0;

% Get source folder content
sourceDataStruc = dir(optSource.sourceDir);

isDir = [sourceDataStruc(:).isdir];

optSource.sequenceList = {sourceDataStruc(isDir).name}';

%% Loop through the sequence folders

tic

for iSeq = 1:size(optSource.sequenceList, 1)

    % Skip 'non' foldera
    if length(char(optSource.sequenceList(iSeq))) > 2

        % Check if sequence to ignore or not
        if sum(strcmp(optSource.sequenceList(iSeq), optSource.sequenceToIgnore)) == 1

            newline;
            warning('IGNORING SEQUENCE: %s', optSource.sequenceToIgnore{strcmp(optSource.sequenceList(iSeq), optSource.sequenceToIgnore)})
            newline;

        else

            fprintf('\n\nCONVERTING SEQUENCE: %s \n\n', char(optSource.sequenceList(iSeq)))

            % Get sequence folder path
            sequencePath = char(fullfile(optSource.sourceDir, optSource.sequenceList(iSeq)));

            % Retrieve volume files info
            [volumesToConvert, volumesList] = parseNiiFiles(sequencePath, optSource);

            % Set output name, it takes the file name of the first volume and add subfix '_4D'
            outputName = char(volumesToConvert(1).name);

            dotPos = find(outputName == '.');

            outputName = outputName(1:dotPos(1)-1);

            optSource.outputName = [outputName '_4D.nii' ];

            % Retrieve sidecar json files info
            jsonList = parseJsonFiles(sequencePath);

            jsonFile = jsondecode(fileread(char(jsonList(1))));

            % % % % % % LIEGE  SPECIFIC % % % % % % %
            optSource.RT = jsonFile.acqpar.RepetitionTime/1000;
            % % % % % % % % % % % % % % % % % % % % %

            % Set and run spm batch
            matlabbatch = setBatch3Dto4D(optSource, volumesList);

            spm_jobman('run', matlabbatch);

            % Zip and delete the and the new 4D file
            fprintf(1, 'ZIP AND DELETE THE NEW 4D BRAIN \n\n');

            gzip([sequencePath filesep outputName])

            delete([sequencePath filesep outputName])

            % Save one sidecar json file, it takes the first volume one and add subfix '_4D'
            dotPos = find(char(jsonList(1)) == '.', 1, 'last');

            jsonCopy = char(jsonList(1));

            jsonCopy = jsonCopy(1:dotPos(1)-1);

            copyfile(char(jsonList(1)), [jsonCopy '_4D.json' ])

            % Delete all the single volumes .nii and .json files
            fprintf(1, 'EXTERMINATE SINGLE VOLUMES FILES \n\n');

            for iDel = 1:length(optSourcevolumesList)

                delete(char(optSourcevolumesList(iDel)))
                delete(char(jsonList(iDel)))

            end

        end

    end

end

newline;
toc

end

function [volumesToConvert, optSource] = parseNiiFiles(sequencePath, optSource)

volumesToConvert = dir(fullfile(sequencePath, '*.nii'));

optSource.volumesList = {};

for iVol = 1:size(volumesToConvert,1)

    optSource.volumesList{end+1} = [volumesToConvert(iVol).folder filesep volumesToConvert(iVol).name];

end

optSource.volumesList = optSource.volumesList';


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
