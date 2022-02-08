function imgNb = copyGraphWindownOutput(opt, subID, action, imgNb)
  %
  % Looks into the current directory for an ``spm_.*imgNb.png`` file and moves it into
  % the output directory ``sub-label/figures``.
  % The output name of the file is
  % ``yyyymmddHHMM_sub-label_task-label_action.png``
  %
  % USAGE::
  %
  %   imgNb = copyGraphWindownOutput(opt, subID, [action = '',] [imgNb = 1])
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subID: Subject label (for example `'01'`).
  % :type subID: string
  % :param action: Name to be given to the figure.
  % :type action: string
  % :param imgNb: Image numbers to look for. SPM increments them automatically when
  %               adding a new figure a folder.
  % :type imgNb: vector of integer
  %
  % :returns: :imgNb: (integer) number of the next image to get.
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 4 || isempty(imgNb)
    imgNb = 1;
  end

  if nargin < 3 || isempty(action)
    action = '';
  end

  figureDir = fullfile(opt.derivativesDir, strcat('sub-', subID), 'figures');
  if ~exist(figureDir, 'dir')
    mkdir(figureDir);
  end

  for iFile = imgNb

    % Using validationInputFile might be too agressive as it throws an error if
    % it can't find a file. Let's use a work around and stick to warnings for now

    %     file = validationInputFile(pwd, sprintf('spm_.*%i.png', iFile));
    file = spm_select('FPList', pwd, sprintf('^spm_.*%i.png$', iFile));

    if isempty(file)

      warning( ...
              'copyGraphWindownOutput:noFile', ...
              'No figure file to copy');

    elseif size(file, 1) > 1

      warning( ...
              'copyGraphWindownOutput:tooManyFiles', ...
              sprintf('\n %s\n %s\n %s', ...
                      'Too many figure files to copy.', ...
                      'Not sure what to do.', ...
                      'Will skip this step.'));
      disp(file);

    else

      targetFile = sprintf( ...
                           '%s_%i_sub-%s_task-%s_%s.png', ...
                           datestr(now, 'yyyymmddHHMM'), ...
                           iFile, ...
                           subID, ...
                           opt.taskName, ...
                           action);

      movefile( ...
               file, ...
               fullfile(figureDir, targetFile));

      fprintf(1, '\n%s\nwas moved to\n%s\n', ...
              file, ...
              fullfile(figureDir, targetFile));

    end

  end

  imgNb = imgNb(end) + 1;

end
