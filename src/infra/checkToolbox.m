function status = checkToolbox(varargin)
  %
  % Checks that a given SPM toolbox is installed.
  % Possible to install it if necessary.
  %
  % USAGE::
  %
  %   status = checkToolbox(toolboxName, 'verbose', false, 'install', false)
  %
  % :param toolboxName: obligatory argument
  % :type toolboxName: string
  % :param verbose: parameter
  % :type verbose: boolean
  % :param install: parameter
  % :type install: boolean
  %
  % (C) Copyright 2021 CPP_SPM developers

  p = inputParser;

  defaultVerbose = false;
  defaultInstall = false;

  addRequired(p, 'toolboxName', @ischar);
  addParameter(p, 'verbose', defaultVerbose, @islogical);
  addParameter(p, 'install', defaultInstall, @islogical);

  parse(p, varargin{:});

  toolboxName = p.Results.toolboxName;
  verbose = p.Results.verbose;
  install = p.Results.install;

  knownToolboxes = {'ALI', 'MACS', 'mp2rage'};

  if ~ismember(toolboxName, knownToolboxes)
    msg = sprintf('Unknown toolbox: %s.\nKwnon toolboxes:\n%s\n\n', ...
                  toolboxName, ...
                  createUnorderedList(knownToolboxes));
    id = 'unknownToolbox';
    errorHandling(mfilename(), id, msg, true, verbose);
  end

  status = isdir(fullfile(spm('dir'), 'toolbox', toolboxName));
  if status
    return
  end

  switch lower(toolboxName)

    case 'macs'

      if ~status && install

        msg = sprintf('installing MACS toolbox in:\n%s.\n\n', ...
                      fullfile(spm('dir'), 'toolbox', 'MACS'));
        id = 'installingMacsToolbox';
        errorHandling(mfilename(), id, msg, true, verbose);

        copyfile(fullfile(returnRootDir(), 'lib', 'MACS'), ...
                 fullfile(spm('dir'), 'toolbox', 'MACS'));

        status = checkToolbox(toolboxName);

      end

    case 'mp2rage'

      msg = sprintf('The toolbox %s should be installed from:\n %s\n\n', ...
                    toolboxName, ...
                    'https://github.com/benoitberanger/mp2rage');
      errorHandling(mfilename(), 'missingToolbox', msg, true, verbose);

  end

  if ~status
    msg = sprintf('The toolbox %s could not be found or installed.\n\n', toolboxName);
    errorHandling(mfilename(), 'missingToolbox', msg, true, verbose);
  end

end
