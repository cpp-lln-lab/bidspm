function str = renameStructField(str, oldFieldName, newFieldName)
%RENAMESTRUCTFIELD renames oldFieldName to newFieldName in struct str
%
%   STR = RENAMESTRUCTFIELD(STR, OLDFIELDNAME, NEWFIELDNAME)
%   STR is the struct in which to rename the field
%   OLDFIELDNAME is the name of the field to rename
%   NEWFIELDNAME is the name to rename OLDFIELDNAME to
%

%   Copyright 2013-2014 The MathWorks, Inc.
if ~strcmp(oldFieldName, newFieldName)
    allNames = fieldnames(str);
    % Is the user renaming one field to be the name of another field?
    % Remember this.
    isOverwriting = ~isempty(find(strcmp(allNames, newFieldName), 1));
    matchingIndex = find(strcmp(allNames, oldFieldName));
    if ~isempty(matchingIndex)
        allNames{matchingIndex(1)} = newFieldName;
        str.(newFieldName) = str.(oldFieldName);
        str = rmfield(str, oldFieldName);
        if (~isOverwriting)
            % Do not attempt to reorder if we've reduced the number
            % of fields.  Bad things will result.  Let it go.
            str = orderfields(str, allNames);
        end
    end
end
