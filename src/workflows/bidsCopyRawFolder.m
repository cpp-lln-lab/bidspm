% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsCopyRawFolder(opt, deleteZippedNii, modalitiesToCopy)
  %
  % This function will copy the subject's folders from the ``raw`` folder to the
  % ``derivatives`` folder, and will copy the dataset description and task json files
  % to the derivatives directory.
  % Then it will search the derivatives directory for any zipped nii.gz image
  % and uncompress it to .nii images.
  %
  % USAGE::
  %
  %   bidsCopyRawFolder([opt,] ...
  %                     [deleteZippedNii = true,] ...
  %                     [modalitiesToCopy = {'anat', 'func', 'fmap'}])
  %
  % :param opt:
  % :type opt: type
  % :param deleteZippedNii:
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

  %% All tasks in this experiment
  % raw directory and derivatives directory
  rawDir = opt.dataDir;
  opt = setDerivativesDir(opt);
  derivativesDir = opt.derivativesDir;

  createDerivativeDir(derivativesDir);

  copyTsvJson(rawDir, derivativesDir);

  %% Loop through the groups, subjects, sessions
  [group, opt, BIDS] = getData(opt, rawDir);

  for iGroup = 1:length(group)

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      % the folder containing the subjects data
      subDir = ['sub-', subID];

      mkdir(fullfile(derivativesDir, subDir));

      [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

      %% copy the whole subject's folder
      % use a call to system cp function to use the derefence option (-L)
      % to get the data 'out' of an eventual datalad dataset

      for iSes = 1:nbSessions

        sessionFolder = [];
        if ~isempty(sessions{iSes})
          sessionFolder = ['ses-' sessions{iSes}];
        end

        mkdir(fullfile(derivativesDir, subDir, sessionFolder));

        modalities = bids.query(BIDS, 'modalities', ...
                                'sub', subID, ...
                                'ses', sessions{iSes}, ...
                                'task', opt.taskName);
        modalities = intersect(modalities, modalitiesToCopy);

        for iModality = 1:numel(modalities)

          mkdir(fullfile(derivativesDir, subDir, sessionFolder, modalities{iModality}));

          srcFolder = fullfile(rawDir, ...
                               subDir, ...
                               sessionFolder, ...
                               modalities{iModality});
          targetFolder = fullfile(derivativesDir, ...
                                  subDir, ...
                                  sessionFolder, ...
                                  modalities{iModality});

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

        fprintf('folder copied: %s \n', subDir);

      end
    end

  end

  unzipFiles(derivativesDir, deleteZippedNii);

end

function  createDerivativeDir(derivativesDir)
  % make derivatives folder if it doesnt exist

  if ~exist(derivativesDir, 'dir')
    mkdir(derivativesDir);
    fprintf('derivatives directory created: %s \n', derivativesDir);
  else
    fprintf('derivatives directory already exists. \n');
  end

end

function copyTsvJson(rawDir, derivativesDir)
  % copy TSV and JSON file from raw folder

  copyfile(fullfile(rawDir, '*.json'), derivativesDir);
  fprintf(' json files copied to derivatives directory \n');

  try
    copyfile(fullfile(rawDir, '*.tsv'), derivativesDir);
    fprintf(' tsv files copied to derivatives directory \n');
  catch
  end

end

function unzipFiles(derivativesDir, deleteZippedNii)
  %% search for nifti files in a compressed nii.gz format
  zippedNiifiles = spm_select('FPListRec', derivativesDir, '^.*.nii.gz$');

  for iFile = 1:size(zippedNiifiles, 1)

    file = deblank(zippedNiifiles(iFile, :));

    n = load_untouch_nii(file);  % load the nifti image
    save_untouch_nii(n, file(1:end - 4)); % Save the functional data as unzipped nii
    fprintf('unzipped: %s \n', file);

    if deleteZippedNii
      delete(file);  % delete original zipped file
    end

  end

end
