% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsCopyRawFolder(opt, deleteZippedNii)
  % This function will copy the subject's folders from the "raw" folder to the
  % "derivatives" folder, and will copy the dataset description and task json files
  % to the derivatives directory.
  % Then it will search the derivatives directory for any zipped nii.gz image
  % and uncompress it to .nii images.
  %
  % INPUT:
  %
  % opt - options structure defined by the getOption function. If no inout is given
  % this function will attempt to load a opt.mat file in the same directory
  % to try to get some options
  %
  % deleteZippedNii - true or false and will delete original zipped files
  % after copying and unzipping

  %% input variables default values
  if nargin < 2            % if second argument isn't specified
    deleteZippedNii = 1;  % delete the original zipped nii.gz
  end

  % if input has no opt, load the opt.mat file
  if nargin < 1
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  % Will only copy those modalities if they exist
  modalitiesToCopy = {'anat', 'func'};

  %% All tasks in this experiment
  % raw directory and derivatives directory
  rawDir = opt.dataDir;
  opt = setDerivativesDir(opt);
  derivativesDir = opt.derivativesDir;

  % make derivatives folder if it doesnt exist
  if ~exist(derivativesDir, 'dir')
    mkdir(derivativesDir);
    fprintf('derivatives directory created: %s \n', derivativesDir);
  else
    fprintf('derivatives directory already exists. \n');
  end

  % copy TSV and JSON file from raw folder if it doesnt exist
  copyfile(fullfile(rawDir, '*.json'), derivativesDir);
  fprintf(' json files copied to derivatives directory \n');

  try
    copyfile(fullfile(rawDir, '*.tsv'), derivativesDir);
    fprintf(' tsv files copied to derivatives directory \n');
  catch
  end

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

        modalities = spm_BIDS(BIDS, 'modalities', ...
                              'sub', subID, ...
                              'ses', sessions{iSes}, ...
                              'task', opt.taskName);

        modalities = intersect(modalities, modalitiesToCopy);

        for iModality = 1:numel(modalities)

          try
            status = system( ...
                            sprintf('cp -R -L %s %s', ...
                                    fullfile(rawDir, ...
                                             subDir, ...
                                             sessionFolder, ...
                                             modalities{iModality}), ...
                                    fullfile(derivativesDir, ...
                                             subDir, ...
                                             sessionFolder, ...
                                             modalities{iModality})));

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
            copyfile(fullfile(rawDir, ...
                              subDir, ...
                              sessionFolder, ...
                              modalities{iModality}), ...
                     fullfile(derivativesDir, ...
                              subDir, ...
                              sessionFolder, ...
                              modalities{iModality}));
          end

        end

      end

      fprintf('folder copied: %s \n', subDir);

    end
  end

  %% search for nifti files in a compressed nii.gz format
  zippedNiifiles = spm_select('FPListRec', derivativesDir, '^.*.nii.gz$');

  for iFile = 1:size(zippedNiifiles, 1)

    file = deblank(zippedNiifiles(iFile, :));

    n = load_untouch_nii(file);  % load the nifti image
    save_untouch_nii(n, file(1:end - 4)); % Save the functional data as unzipped nii
    fprintf('unzipped: %s \n', file);

    if deleteZippedNii == 1
      delete(file);  % delete original zipped file
    end
  end

end
