% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function convert3Dto4D(optSource)
  %
  % It converts single volumes of a sequence in a 4D file, remove the dummies (optional), zip the
  % 4D file (optional) and delete the converted files. Recursevly loops through a folder in which a
  % not-yet-BIDS dataset live and the nii files are sorted in each sequence folder.
  %
  % USAGE::
  %
  %   convert3Dto4D(optSource)
  %
  % :param optSource: Obligatory argument. The structure that contains the options set by the user
  %                   to run the batch workflow for source processing
  %
  % .. todo:
  %
  %    - expand to run through multiple subjs ans groups
  %      (https://stackoverflow.com/questions/8748976/
  %      list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files)
  %    - generalize how to retrieve RT from sidecar json file
  %    - saveMatlabBatch(matlabbatch, ...
  %      ['3Dto4D_dataType-' num2str(dataType) '_RT-' num2str(RT)], opt, subID);
  %    - Cover the MoCo use case: if the sequence is MoCo (motion corrected when the "scanner"
  %      reconstructs the images - an option on can tick on Siemens scanner and that output an
  %      additional MoCo file with the regular sequence) then each JSON file of each volume contains
  %      the motion correction information for that volume. So only taking the JSON of the first
  %      volume means we "lose" the realignment parameters that could be useful later.

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
                                     RT, ...
                                     outputNameImage, ...
                                     optSource.dataType);

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

  fileList = spm_select('list', sequencePath, fileExtention);

  if size(fileList, 1) > 0

    outputName = fileList(nbDummies + 1, :);

    fileList = strcat(sequencePath, filesep, cellstr(fileList));

  else

    fileList = {};

    outputName = [];

    warning('\nI have found 0 files with extension ''.%s'' \n', fileExtention);

  end

end
