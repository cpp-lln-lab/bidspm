% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow()

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
