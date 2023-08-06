function C = newContrast(SPM, conName, type, conditionList)
  %
  % Create a new contrast structure with a zero vector.
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
  % :param type: Contrast type. Can be ``'t'`` or ``'F'``.
  % :type  type: char
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
    otherwise
      msg = sprintf('Contrast type must be "t" or "F". Got: "%s"', type);
      logger('ERROR', msg, ...
             'filename', mfilename, ...
             'id', 'unknownTestType');
  end
  C.name = conName;
end
