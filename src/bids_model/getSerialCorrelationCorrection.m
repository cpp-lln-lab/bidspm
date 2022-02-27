function autoCorCorrection = getSerialCorrelationCorrection(modelFile, nodeType)
  %
  % returns the HRF derivatives of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  autoCorCorrection =  'FAST';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  bm = bids.Model('file', modelFile);
  node = bm.get_nodes('Level', nodeType);

  try
    autoCorCorrection = node.Model.Software.SPM.SerialCorrelation;
  catch
    isempty(node.Model.Options.HighPassFilterCutoffHz);
    msg = sprintf('No HRF derivatives mentioned for node %s in BIDS model file\%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'noHRFderivatives', msg, true, true);
  end

end
