function factorialDesign = setBatchFactorialDesignGlobalCalcAndNorm(factorialDesign)
  %
  % USAGE::
  %
  %   factorialDesign = setBatchFactorialDesignGlobalCalcAndNorm(factorialDesign)
  %
  %

  % (C) Copyright 2022 bidspm developers

  factorialDesign.globalc.g_omit = 1;
  factorialDesign.globalm.gmsca.gmsca_no = 1;
  factorialDesign.globalm.glonorm = 1;
end
