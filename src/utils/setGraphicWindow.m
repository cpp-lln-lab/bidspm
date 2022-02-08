function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow()
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
  % (C) Copyright 2019 CPP_SPM developers

  interactiveWindow = [];
  graphWindow = [];
  cmdLine = true;

  if ~spm('CmdLine') && ~isOctave

    try
      [interactiveWindow, graphWindow, cmdLine] = spm('FnUIsetup');
    catch
      warning('Could not open a graphic window. No figure will be created.');
    end

  end

end
