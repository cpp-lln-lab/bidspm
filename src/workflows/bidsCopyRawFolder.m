% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsCopyRawFolder(opt, deleteZippedNii, modalitiesToCopy)
  %
  % Copies the folders from the ``raw`` folder to the
  % ``derivatives`` folder, and will copy the dataset description and task json files
  % to the derivatives directory.
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files for the task of interest.
  %
  % USAGE::
  %
  %   bidsCopyRawFolder([opt,] ...
  %                     [deleteZippedNii = true,] ...
  %                     [modalitiesToCopy = {'anat', 'func', 'fmap'}])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param deleteZippedNii: will delete the original zipped ``.gz`` if set to ``true``
  % :type deleteZippedNii: boolean
  % :param modalitiesToCopy:
  % :type modalitiesToCopy: cell
  %

  %% input variables default values

  if nargin < 3 || isempty(modalitiesToCopy)
    % Will only copy those modalities if they exist
    modalitiesToCopy = {'anat', 'func', 'fmap'};
  end

  if nargin < 2 || isempty(deleteZippedNii)
    % delete the original zipped nii.gz
    deleteZippedNii = true;
  end

  % if input has no opt, load the opt.mat file
  if nargin < 1 || isempty(opt)
    opt = [];
  end
  opt = loadAndCheckOptions(opt);
  
  cleanCrash();
  
  printWorklowName('copy data')

  %% All tasks in this experiment
  % raw directory and derivatives directory
  opt = setDerivativesDir(opt);
  rawDir = opt.dataDir;
  derivativesDir = opt.derivativesDir;

  createDerivativeDir(opt);

  copyTsvJson(rawDir, derivativesDir);

  %% Loop through the groups, subjects, sessions
  [group, opt, BIDS] = getData(opt, rawDir);

  for iGroup = 1:length(group)

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      % the folder containing the subjects data
      subDir = ['sub-', subID];

      mkdir(fullfile(derivativesDir, subDir));
      
      % copy scans.tsv files
      copyTsvJson(...
        fullfile(rawDir, subDir), ...
        fullfile(derivativesDir, subDir))

      [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

      %% copy the whole subject's folder
      % use a call to system cp function to use the derefence option (-L)
      % to get the data 'out' of an eventual datalad dataset

      for iSes = 1:nbSessions

        sessionDir = [];
        if ~isempty(sessions{iSes})
          sessionDir = ['ses-' sessions{iSes}];
        end

        mkdir(fullfile(derivativesDir, subDir, sessionDir));
        
        % copy scans.tsv files
        copyTsvJson(...
          fullfile(rawDir, subDir, sessionDir), ...
          fullfile(derivativesDir, subDir, sessionDir))

        modalities = bids.query(BIDS, 'modalities', ...
                                'sub', subID, ...
                                'ses', sessions{iSes}, ...
                                'task', opt.taskName);
        modalities = intersect(modalities, modalitiesToCopy);

        for iModality = 1:numel(modalities)

          mkdir(fullfile(derivativesDir, subDir, sessionDir, modalities{iModality}));

          srcFolder = fullfile(rawDir, ...
                               subDir, ...
                               sessionDir, ...
                               modalities{iModality});
          targetFolder = fullfile(derivativesDir, ...
                                  subDir, ...
                                  sessionDir);

          copyModalityDir(srcFolder, targetFolder);

        end

        fprintf('folder copied: %s \n', subDir);

      end
    end

  end

  unzipFiles(derivativesDir, deleteZippedNii, opt);

end

function copyTsvJson(srcDir, targetDir)
  % copy TSV and JSON file from raw folder
  
  ext = {'tsv', 'json'};
  
  for i = 1:numel(ext)
  
    if ~isempty(spm_select('List', srcDir, ['^.*.' ext{i} '$']))

      copyfile(fullfile(srcDir, ['*.' ext{i}]), targetDir);
      fprintf(1, ' %s files copied\n', ext{i});

    end
  
  end

end

function copyModalityDir(srcFolder, targetFolder)

  try
    status = system( ...
                    sprintf('cp -R -L -f %s %s', ...
                            srcFolder, ...
                            targetFolder));

    if status > 0
      message = [ ...
                 'Copying data with system command failed: ' ...
                 'Are you running Windows?\n', ...
                 'Will use matlab/octave copyfile command instead.\n', ...
                 'Maybe your data set contains symbolic links' ...
                 '(e.g. if you use datalad or git-annex.'];
      error(message);
    end

  catch
    fprintf(1, 'Using octave/matlab to copy files.');
    copyfile(srcFolder, targetFolder);
  end

end

function unzipFiles(derivativesDir, deleteZippedNii, opt)
  %% search for nifti files in a compressed nii.gz format

  zippedNiifiles = spm_select('FPListRec', derivativesDir, '^.*.gz$');

  for iFile = 1:size(zippedNiifiles, 1)

    file = deblank(zippedNiifiles(iFile, :));
    
    fragments = bids.internal.parse_filename(file);
    
    % for bold, physio and stim files, we only unzip the files of the task of
    % interest
    if any(strcmp(fragments.type, {'bold', 'stim', 'physio'})) && ...
        isfield(fragments, 'task') && strcmp(fragments.task, opt.taskName)

      % load the nifti image and saves the functional data as unzipped nii
      n = load_untouch_nii(file); 
      save_untouch_nii(n, file(1:end - 4));
      fprintf('unzipped: %s \n', file);

      % delete original zipped file
      if deleteZippedNii
        delete(file); 
      end
    
    end

  end

end
