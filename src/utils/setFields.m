% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function structure = setFields(structure, fieldsToSet)
  %
  % Recursively loop through the fields of a ``structure`` and sets the values
  % as defined in the structure ``fieldsToSet`` if they don't exist.
  %
  % USAGE::
  %
  %   structure = setFields(structure, fieldsToSet)
  %
  % :param structure:
  % :type structure:
  % :param fieldsToSet:
  % :type fieldsToSet: string
  %
  % :returns: - :structure: (structure)
  %
  %

  if isempty(fieldsToSet)
    return
  end

  names = fieldnames(fieldsToSet);

  for j = 1:numel(structure)

    for i = 1:numel(names)

      thisField = fieldsToSet.(names{i});

      if isfield(structure(j), names{i}) && isstruct(structure(j).(names{i}))

        structure(j).(names{i}) = ...
            setFields(structure(j).(names{i}), fieldsToSet.(names{i}));

      else

        structure = setFieldToIfNotPresent( ...
                                           structure, ...
                                           names{i}, ...
                                           thisField);
      end

    end

    structure = orderfields(structure);

  end

end

function structure = setFieldToIfNotPresent(structure, fieldName, value)
  if ~isfield(structure, fieldName)
    structure.(fieldName) = value;
  end
end
