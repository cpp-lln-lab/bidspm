function imgNb = copyGraphWindownOutput(opt, subLabel, action, imgNb)
  %
  % Looks into the current directory for an ``spm_.*imgNb.png`` file and moves it into
  % the output directory ``sub-label/figures``.
  %
  % The output name of the file is
  %
  % ``yyyymmddHHMM_sub-label_task-label_action.png``
  %
  % USAGE::
  %
  %   imgNb = copyGraphWindownOutput(opt, subLabel, [action = '',] [imgNb = 1])
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param subLabel: Subject label (for example `'01'`).
  % :type subLabel: char
  %
  % :param action: Name to be given to the figure.
  % :type action: char
  %
  % :param imgNb: Image numbers to look for. SPM increments them automatically when
  %               adding a new figure a folder.
  % :type imgNb: vector of integer
  %
  % :returns: :imgNb: (integer) number of the next image to get.
  %

  % (C) Copyright 2019 bidspm developers

  if nargin < 4 || isempty(imgNb)
    imgNb = 1;
  end

  if nargin < 3 || isempty(action)
    action = '';
  end

  figureDir = fullfile(opt.dir.preproc, strcat('sub-', subLabel), 'figures');
  if ~exist(figureDir, 'dir')
    mkdir(figureDir);
  end

  for iFile = imgNb

    % Using validationInputFile might be too aggressive as it throws an error if
    % it can't find a file. Let's use a work around and stick to warnings for now

    %     file = validationInputFile(pwd, sprintf('spm_.*%i.png', iFile));
    file = spm_select('FPList', pwd, sprintf('^spm_.*%i.png$', iFile));

    if isempty(file)

      id = 'noFile';
      msg = 'No figure file to copy';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    elseif size(file, 1) > 1

      msg = sprintf('\n %s\n %s\n %s', ...
                    'Too many figure files to copy.', ...
                    'Not sure what to do.', ...
                    'Will skip this step.');
      id = 'tooManyFiles';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

      msg = sprintf('%s\n', strjoin(pathToPrint(cellstr(file)), '\n'));
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

    else

      targetFile = sprintf('%s_%i_sub-%s_task-%s_%s.png', ...
                           datestr(now, 'yyyymmddHHMM'), ...
                           iFile, ...
                           subLabel, ...
                           strjoin(opt.taskName, ''), ...
                           action);

      movefile(file, ...
               fullfile(figureDir, targetFile));

      msg = sprintf('\n%s\nwas moved to\n%s\n', ...
                    pathToPrint(file), ...
                    pathToPrint(fullfile(figureDir, targetFile)));
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

    end

  end

  imgNb = imgNb(end) + 1;

end
