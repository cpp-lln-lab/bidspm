function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % Open SPM graphic window.
  %
  % USAGE::
  %
  %   [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type opt:  structure
  %
  % :return: interactiveWindow, graphWindow, cmdLine
  %

  % (C) Copyright 2019 bidspm developers

  interactiveWindow = [];
  graphWindow = [];
  cmdLine = true;

  if ~opt.dryRun && ~spm('CmdLine') && ~bids.internal.is_octave()

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
