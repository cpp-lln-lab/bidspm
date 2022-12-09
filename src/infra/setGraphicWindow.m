function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % Open SPM graphic window.
  %
  % USAGE::
  %
  %   [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :returns: - :interactiveWindow:
  %           - :graphWindow:
  %           - :cmdLine: (boolean)
  %

  % (C) Copyright 2019 bidspm developers

  interactiveWindow = [];
  graphWindow = [];
  cmdLine = true;

  if ~opt.dryRun && ~spm('CmdLine') && ~isOctave

    try
      [interactiveWindow, graphWindow, cmdLine] = spm('FnUIsetup');
    catch
      msg = 'Could not open a graphic window. No figure will be created.';
      id = 'noGraphicWindow';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    end

  else

    msg = ['Could not open a graphic window. Possible reasons:\n', ...
           ' - running in dry run mode,\n' ...
           ' - running SPM from the matlab command line only,\n' ...
           ' - running under octave.\n' ...
           'To silence this warning, you can run ', ...
           '"warning(''off'', ''setGraphicWindow:noGraphicWindow'')".'];
    id = 'noGraphicWindow';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

  end

end
