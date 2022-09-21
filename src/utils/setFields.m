function structure = setFields(structure, fieldsToSet, overwrite)
  %
  % Recursively loop through the fields of a target ``structure`` and sets the values
  % as defined in the structure ``fieldsToSet`` if they don't exist.
  %
  % Content of the target structure can be overwritten by setting the
  % ``overwrite```to ``true``.
  %
  % USAGE::
  %
  %   structure = setFields(structure, fieldsToSet, overwrite = false)
  %
  % :param structure:
  % :type structure:
  %
  % :param fieldsToSet:
  % :type fieldsToSet: char
  %
  % :param overwrite:
  % :type overwrite: boolean
  %
  % :returns: - :structure: (structure)
  %
  %

  % (C) Copyright 2020 bidspm developers

  if isempty(fieldsToSet) || ~isstruct(fieldsToSet)
    return
  end

  if nargin < 3 || isempty(overwrite)
    overwrite = false;
  end

  names = fieldnames(fieldsToSet);

  for j = 1:numel(structure)

    for i = 1:numel(names)

      thisField = fieldsToSet.(names{i});

      if isfield(structure(j), names{i}) && isstruct(structure(j).(names{i}))

        structure(j).(names{i}) = ...
            setFields(structure(j).(names{i}), fieldsToSet.(names{i}), overwrite);

      else

        if ~overwrite
          structure = setFieldToIfNotPresent( ...
                                             structure, ...
                                             names{i}, ...
                                             thisField);
        else
          structure.(names{i}) = thisField;

        end

      end

    end

    structure = orderfields(structure);

  end

end

function structure = setFieldToIfNotPresent(structure, fieldName, value)
  if ~isfield(structure, fieldName)
    for i = 1:numel(structure)
      structure(i).(fieldName) = value;
    end
  end
end
