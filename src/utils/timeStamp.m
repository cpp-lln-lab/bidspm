function output = timeStamp()
  %
  % Returns the current time in a BIDS (ish) valid format: 'yyyy-mm-ddTHH-MM'
  %
  % USAGE::
  %
  %   output = timeStamp()
  %
  % (C) Copyright 2022 CPP_SPM developers

  output = datestr(now, 'yyyy-mm-ddTHH-MM');

end
