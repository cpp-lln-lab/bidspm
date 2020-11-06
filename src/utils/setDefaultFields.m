% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function structure = setDefaultFields(structure, fieldsToSet)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % structure = setDefaultFields(structure, fieldsToSet)
  %
  % recursively loop through the fields of a structure and sets a value if they don't exist
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
            setDefaultFields(structure(j).(names{i}), fieldsToSet.(names{i}));

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
