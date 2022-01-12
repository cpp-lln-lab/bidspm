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

  default_verbose = false;
  default_install = false;

  addRequired(p, 'toolboxName', @ischar);
  addParameter(p, 'verbose', default_verbose, @islogical);
  addParameter(p, 'install', default_install, @islogical);

  parse(p, varargin{:});

  toolboxName = p.Results.toolboxName;
  verbose = p.Results.verbose;
  install = p.Results.install;
  
  
  status = false;
  
  knownToolboxes = {'ALI', 'MACS'};
  
  switch lower(toolboxName)
    
    case 'ali'
      
      % ALI toolbox
      if exist(fullfile(spm('dir'), 'toolbox', 'ALI'), 'dir')
        status =  true;
        return
      end
      
    case 'macs'
      
      % MACS toolbox
      if exist(fullfile(spm('dir'), 'toolbox', 'MACS'), 'dir')
        status =  true;
        return
      end
      
      if ~status && install
        
         msg = sprintf('installing MACS toolbox in:\n%s.\n\n', ...
           fullfile(spm('dir'), 'toolbox', 'MACS'));
         id = 'installingMacsToolbox';
         errorHandling(mfilename(), id, msg, true, verbose)
        
         copyfile(fullfile(returnRootDir(), 'lib', 'MACS'), ...
                 fullfile(spm('dir'), 'toolbox', 'MACS'))
               

         status = checkToolbox(toolboxName);

      end
      
    otherwise
      
      msg = sprintf('Unknown toolbox: %s.\nKwnon toolboxes:\n%s\n\n', ...
        toolboxName, ...
        createUnorderedList(knownToolboxes));
      id = 'unknownToolbox';
      errorHandling(mfilename(), id, msg, true, verbose)

  end
  
  if ~status
    msg = sprintf('The toolbox %s could not be found or installed.\n\n', toolboxName);
    errorHandling(mfilename(), 'missingToolbox', msg, true, verbose);
  end
  
end
