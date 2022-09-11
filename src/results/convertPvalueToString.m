function p = convertPvalueToString(p)
  %
  % convert p value
  %
  % (C) Copyright 2019 bidspm developers

  p = sprintf('0pt%.3f', p);
  p = strrep(p, '0.', '');

end
