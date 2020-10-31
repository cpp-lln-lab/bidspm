% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function [interactiveWindow, graphWindow, cmdLine] = setGraphicWindow()
  [interactiveWindow, graphWindow, cmdLine] = spm('FnUIsetup');
end
