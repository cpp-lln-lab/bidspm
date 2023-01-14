function plotEvents(eventsFile, modelFile)
  %
  % See bids.util.plot_events
  %

  % (C) Copyright 2020 bidspm developers

  if nargin < 2
    modelFile = '';
  end

  deprecated(mfilename());

  plot_events(eventsFile, 'model_file', modelFile);
end
