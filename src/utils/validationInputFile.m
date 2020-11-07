% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function files = validationInputFile(dir, fileName, prefix)
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
  % file = validationInputFile(dir, fileName, prefix)
  %
  % Checks if files exist. A prefix can be added. The prefix allows for the
  % use of regular expression.
  %
  % TPMs = validationInputFile(anatDataDir, anatImage, 'c[12]');
  %
  % If the filet(s) exist(s), it returns a char array containing list of fullpath.

  if nargin < 3
    prefix = '';
  end

  files = spm_select('FPList', dir, ['^' prefix fileName '$']);

  if isempty(files)

    errorStruct.identifier = 'validationInputFile:nonExistentFile';
    errorStruct.message = sprintf( ...
                                  'This file does not exist: %s', ...
                                  fullfile(dir, [prefix fileName '[.gz]']));
    error(errorStruct);

  end

end
