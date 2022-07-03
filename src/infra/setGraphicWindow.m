function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  % :type opt: structure
  %
  % :returns: - :interactiveWindow:
  %           - :graphWindow:
  %           - :cmdLine: (boolean)
  %
  % (C) Copyright 2019 CPP_SPM developers

  interactiveWindow = [];
  graphWindow = [];
  cmdLine = true;

  if ~opt.dryRun && ~spm('CmdLine') && ~isOctave

    try
      [interactiveWindow, graphWindow, cmdLine] = spm('FnUIsetup');
    catch
      msg = 'Could not open a graphic window. No figure will be created.';
      errorHandling(mfilename(), 'noGraphicWindow', msg, true, opt.verbosity);
    end

  else

    msg = ['Could not open a graphic window. Possible reasons:\n', ...
           ' - running in dry run mode,\n' ...
           ' - running SPM from the matlab command line only,\n' ...
           ' - running under octave.'];
    errorHandling(mfilename(), 'noGraphicWindow', msg, true, opt.verbosity);

  end

end
