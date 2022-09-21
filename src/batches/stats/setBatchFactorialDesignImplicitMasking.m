function factorialDesign = setBatchFactorialDesignImplicitMasking(factorialDesign)
  %
  % USAGE::
  %
  %   factorialDesign = setBatchFactorialDesignImplicitMasking(factorialDesign)
  %
  %

  % (C) Copyright 2022 bidspm developers

  factorialDesign.masking.tm.tm_none = 1;
  factorialDesign.masking.im = 1;
end
