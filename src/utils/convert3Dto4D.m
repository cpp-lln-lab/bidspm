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
  
  % Add folder where some functions live
  initEnv()

  % Set the folder where sequences folders exist
  optSource.sourceDir = '/Users/barilari/Desktop/DICOM_UCL_leuven/renamed/sub-pilot001/ses-002/MRI';

  % List of the sequences that you want to skip (folder name pattern)
  optSource.sequenceToIgnore = {'AAHead_Scout', ...
                                'b1map', ...
                                't1', ...
                                'gre_field'};

  % Number of volumes to discard ad dummies, (0 is default)
  optSource.nbDummies = 5;

  % List of the sequences where you want to remove dummies (folder name pattern)
  optSource.sequenceRmDummies = {'cmrr_mbep2d_p3_mb2_1.6iso_AABrain', ...
                                 'cmrr_mbep2d_p4_mb2_750um_AAbrain'};

  % Set data format conversion (0 is default)

  % 0:  SAME
  % 2:  UINT8   - unsigned char
  % 4:  INT16   - signed short
  % 8:  INT32   - signed int
  % 16: FLOAT32 - single prec. float
  % 64: FLOAT64 - double prec. float

  optSource.dataType = 0;

  % Boolean to enable gzip of the new 4D file (0 is default)
  optSource.zip = 0;

  % Check the options provided
  optSource = checkOptionsSource(optSource);

  % Get source folder content
  sourceDataStruc = dir(optSource.sourceDir);

  isDir = [sourceDataStruc(:).isdir];

  optSource.sequenceList = {sourceDataStruc(isDir).name}';

  % Loop through the sequence folders

  tic;

  for iSeq = 1:size(optSource.sequenceList, 1)

    % Skip 'non' folders
    if length(optSource.sequenceList{iSeq}) > 2

      % Check if sequence to ignore or not
      if contains(optSource.sequenceList(iSeq), optSource.sequenceToIgnore)

        warning('\nIGNORING SEQUENCE: %s\n', string(optSource.sequenceList(iSeq)));

      else

        fprintf('\n\nCONVERTING SEQUENCE: %s \n', char(optSource.sequenceList(iSeq)));

        % Set whether to remove dummies or not

        nbDummies = 0;

        if contains(optSource.sequenceList(iSeq), optSource.sequenceRmDummies)

          nbDummies = optSource.nbDummies;

          fprintf('\n\nREMOVING %s DUMMIES\n\n', num2str(nbDummies));

        end

        % Get sequence folder path
        sequencePath = fullfile(optSource.sourceDir, optSource.sequenceList{iSeq});

        % Retrieve volume files info
        [volumesList, outputNameImage] = parseFiles('nii', sequencePath, nbDummies);

        % Set output name, it takes the file name of the 1st volume of the 4D file and add subfix
        outputNameImage = strrep(outputNameImage, '.nii', '_4D.nii');

        % Retrieve sidecar json files info
        [jsonList, outputNameJson] = parseFiles('json', sequencePath, nbDummies);

        jsonFile = spm_jsonread(jsonList{1});

        % % % % % % LIEGE  SPECIFIC % % % % % % %
        RT = jsonFile.acqpar.RepetitionTime / 1000;
        % % % % % % % % % % % % % % % % % % % % %

        % Set and run spm batch, input all the volumes minus the dummies if > 0
        matlabbatch = setBatch3Dto4D(volumesList(nbDummies + 1:end, :), ...
                                     outputNameImage, ...
                                     optSource.dataType, ...
                                     RT);

        spm_jobman('run', matlabbatch);

        if optSource.zip

          % Zip and delete the and the new 4D file
          fprintf(1, 'ZIP AND DELETE THE NEW 4D BRAIN \n\n');

          gzip([sequencePath filesep outputNameImage]);

          delete([sequencePath filesep outputNameImage]);

        end

        % Save one sidecar json file, it takes the file name of the 1st volume of the 4D file and
        % add subfix
        if ~isempty(jsonList)
% TODO: cover the MoCo use case
% - if the sequence is MoCo (motion corrected when the "scanner" reconstructs the images - an option on can tick
% on Siemens scanner and that output an additional MoCo file with the regular sequence) then each JSON file of 
% each volume contains the motion correction information for that volume.
% So only taking the JSON of the first volume means we "lose" the realignment parameters that could be useful later.
          copyfile(jsonList{1}, [sequencePath filesep strrep(outputNameJson, '.json', '_4D.json')]);

        end

        % Delete all the single volumes .nii and .json files
        fprintf(1, 'EXTERMINATE SINGLE VOLUMES FILES \n\n');

        for iDel = 1:length(volumesList)

          delete(volumesList{iDel});
          delete(jsonList{iDel});

        end

      end

    end

  end

  toc;

end

function [fileList, outputName] = parseFiles(fileExtention, sequencePath, nbDummies)

  fileList = spm_select('list', sequencePath, fileExstention);

  if size(fileList, 1) > 0

    outputName = fileList(nbDummies + 1, :);

    fileList = strcat(sequencePath, filesep, cellstr(fileList));

  else

    fileList = {};

    outputName = [];

    warning('\nI have found 0 files with extension ''.%s'' \n', fileExstention);

  end

end

function initEnv()

    pth = fileparts(mfilename('fullpath'));
    addpath(fullfile(pth, '..', 'defaults'));
    addpath(fullfile(pth, '..', 'batches'));

end
