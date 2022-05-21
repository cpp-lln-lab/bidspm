function printAvailableContrasts(SPM, opt)
  %
  % (C) Copyright 2019 CPP_SPM developers
  printToScreen('List of contrast in this SPM file\n', opt);
  printToScreen(createUnorderedList({SPM.xCon.name}), opt);
  printToScreen('\n', opt);
end
