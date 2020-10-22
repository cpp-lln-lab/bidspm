% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function structure = setDefaultFields(structure, fieldsToSet)
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
