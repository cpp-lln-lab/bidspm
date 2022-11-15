function C = newContrast(SPM, conName, type, conditionList)
  %
  %
  %
  % USAGE::
  %
  %   C = newContrast(SPM, conName, type, conditionList)
  %
  % :param SPM:
  % :type  SPM: struct
  %
  % :param conName:
  % :type  conName: struct
  %
  % :param type:
  % :type  type:
  %
  % :param conditionList:
  % :type  conditionList:
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2022 bidspm developers

  switch type
    case 't'
      C.C = zeros(1, size(SPM.xX.X, 2));
    case 'F'
      C.C = zeros(numel(conditionList), size(SPM.xX.X, 2));
  end
  C.name = conName;
end
