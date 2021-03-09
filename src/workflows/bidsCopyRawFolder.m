% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsCopyRawFolder(opt, deleteZippedNii, modalitiesToCopy, unZip)
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
  % :param modalitiesToCopy: for example ``{'anat', 'func', 'fmap'}``
  % :type modalitiesToCopy: cell
  % :param unZip:
  % :type unZip: boolean
  %

  %% input variables default values

  if nargin < 4 || isempty(unZip)
    % Will only copy those modalities if they exist
    unZip = true();
  end

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

  printWorklowName('copy data');

  manageWorkersPool('open', opt);

  %% All tasks in this experiment
  % raw directory and derivatives directory
  opt = setDerivativesDir(opt);

  [rawDir, derivativesDir] = returnRawAndDerivativeDir(opt);

  createDerivativeDir(opt);

  copyTsvJson(rawDir, derivativesDir);

  %% Loop through the groups, subjects, sessions
  [BIDS, opt] = getData(opt, rawDir);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    subDir = returnSubjectDir(subLabel);

    fprintf('copying subject: %s \n', subDir);

    [~, ~, ~] =  mkdir(fullfile(derivativesDir, subDir));

    % copy scans.tsv files
    copyTsvJson( ...
                fullfile(rawDir, subDir), ...
                fullfile(derivativesDir, subDir));

    [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

    %% copy the whole subject's folder
    % use a call to system cp function to use the derefence option (-L)
    % to get the data 'out' of an eventual datalad dataset

    for iSes = 1:nbSessions

      sessionDir = returnSessionDir(sessions{iSes});

      fprintf(' copying session: %s \n', sessionDir);

      [~, ~, ~] =  mkdir(fullfile(derivativesDir, subDir, sessionDir));

      % copy scans.tsv files
      copyTsvJson( ...
                  fullfile(rawDir, subDir, sessionDir), ...
                  fullfile(derivativesDir, subDir, sessionDir));

      modalities = bids.query(BIDS, 'modalities', ...
                              'sub', subLabel, ...
                              'ses', sessions{iSes});
      modalities = intersect(modalities, modalitiesToCopy);

      copyModalities(BIDS, opt, modalities, subLabel, sessions{iSes});

    end
  end

  if unZip
    unzipFiles(derivativesDir, deleteZippedNii, opt);
  end

  manageWorkersPool('close', opt);

end

function [rawDir, derivativesDir] = returnRawAndDerivativeDir(opt)

  rawDir = opt.dataDir;
  derivativesDir = opt.derivativesDir;

end

function subDir = returnSubjectDir(subLabel)

  subDir = ['sub-', subLabel];

end

function sessionDir = returnSessionDir(session)

  sessionDir = [];
  if ~isempty(session)
    sessionDir = ['ses-' session];
  end

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

function copyModalities(BIDS, opt, modalities, subLabel, session)

  [rawDir, derivativesDir] = returnRawAndDerivativeDir(opt);

  subDir = returnSubjectDir(subLabel);

  sessionDir = returnSessionDir(session);

  for iModality = 1:numel(modalities)

    targetFolder = fullfile(derivativesDir, ...
                            subDir, ...
                            sessionDir);

    [~, ~, ~] = mkdir(fullfile(targetFolder, modalities{iModality}));

    srcFolder = fullfile(rawDir, ...
                         subDir, ...
                         sessionDir, ...
                         modalities{iModality});

    % for func we only copy the files of the task of interest
    if strcmp(modalities{iModality}, 'func')

      files = bids.query(BIDS, 'data', ...
                         'sub', subLabel, ...
                         'ses', session, ...
                         'task', opt.taskName);

      for iFile = 1:size(files, 1)
        copyToDerivative(files{iFile}, fullfile(targetFolder, 'func'));
        p = bids.internal.parse_filename(files{iFile});
        sidecar = strrep(p.filename, p.ext, '.json');
        if exist(fullfile(fileparts(files{iFile}), sidecar), 'file')
          copyToDerivative(fullfile(fileparts(files{iFile}), sidecar), ...
                           fullfile(targetFolder, 'func'));
        end
      end

    else
      copyToDerivative(srcFolder, targetFolder);

    end

  end

end

function copyToDerivative(src, targetFolder)

  command = 'cp -R -L -f';

  try
    status = system( ...
                    sprintf('%s %s %s', ...
                            command, ...
                            src, ...
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
    copyfile(src, targetFolder);
  end

end

function unzipFiles(derivativesDir, deleteZippedNii, opt)
  %% search for nifti files in a compressed nii.gz format

  zippedNiifiles = spm_select('FPListRec', derivativesDir, '^.*.gz$');

  parfor iFile = 1:size(zippedNiifiles, 1)

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
