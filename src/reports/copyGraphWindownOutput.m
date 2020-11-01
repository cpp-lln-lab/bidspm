% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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
  % :param opt: options
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param action:
  % :type action: string
  % :param imgNb: image number to look for. SPM increments them automatically.
  % :type imgNb: integer
  %
  % :returns: - :imgNb: (integer) number of the next image to get.
  %
  % assumes that no file was generated if SPM is running in command line mode

  if nargin < 4 || isempty(imgNb)
    imgNb = 1;
  end

  if nargin < 3 || isempty(action)
    action = '';
  end

  if ~spm('CmdLine') && ~isOctave

    figureDir = fullfile(opt.derivativesDir, ['sub-' subID], 'figures');
    if ~exist(figureDir, 'dir')
      mkdir(figureDir);
    end

    file = spm_select('FPList', pwd, sprintf('^spm_.*%i.png$', imgNb));

    if ~isempty(file)

      targetFile = [datestr(now, 'yyyymmddHHMM') ...
                    '_sub-', subID, ...
                    '_task-',   opt.taskName, ...
                    '_' action '.png'];

      movefile( ...
               file, ...
               fullfile(figureDir, targetFile));

      imgNb = imgNb + 1;

    end

  end

end
