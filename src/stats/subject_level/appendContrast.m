function [contrasts, counter] = appendContrast(contrasts, C, counter, type)
  %
  %
  %
  % USAGE::
  %
  %   [contrasts, counter] = appendContrast(contrasts, C, counter, type)
  %
  % :param contrasts:
  % :type  contrasts: struct
  %
  % :param C:
  % :type  C: struct
  %
  % :param counter:
  % :type  counter: integer
  %
  % :param type:
  % :type  type: char?
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2022 bidspm developers

  counter = counter + 1;
  contrasts(counter).type = type;
  contrasts(counter).C = C.C;
  contrasts(counter).name = C.name;

  validateContrasts(contrasts);

end
