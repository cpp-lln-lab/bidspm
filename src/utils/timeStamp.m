function output = timeStamp()
  %
  % Returns the current time in a BIDS (ish) valid format: 'yyyy-mm-ddTHH-MM'
  %
  % USAGE::
  %
  %   output = timeStamp()
  %
  % (C) Copyright 2022 bidspm developers

  output = datestr(now, 'yyyy-mm-ddTHH-MM');

end
