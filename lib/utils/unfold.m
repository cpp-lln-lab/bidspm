function unfold(input, varargin)
    %
    % Displays the content of a variable.
    %
    % USAGE::
    %
    %   unfold(SC, name, show, file_id)
    %
    %
    % :param SC: variable to show the content of.
    % :type SC: structure or cell
    %
    % If SC is a structure it recursively shows the name of SC and
    % the fieldnames of SC and their contents.
    %
    % If SC is a cell array the contents of each cell are displayed.
    %
    % It uses the caller's workspace variable name as the name of SC.
    %
    % :param name: can be used instead of the name of SC.
    % :type name: string
    %
    % :param show: if ``false`` only the fieldnames and their size_es are  shown,
    %              if ``true`` the contents are shown also.
    % :type show: boolean
    %
    % (C) Copyright 2022 Remi Gau
    % (C) Copyright 2005-2006 R.F. Tap

    % R.F. Tap
    % 15-6-2005, 7-12-2005, 5-1-2006, 3-4-2006

    % taken and adapted from shorturl.at/dqwN7

    % check input
    switch nargin
        case 1
            name = inputname(1);
            show = true;
            file_id = 1;
        case 2
            if islogical(varargin{1})
                name = inputname(1);
                show = varargin{1};
                file_id = 1;
            elseif ischar(varargin{1})
                name = varargin{1};
                show = true;
                file_id = 1;
            else
                error('Second input argument must be a string or a logical');
            end
        case 3
            if ischar(varargin{1})
                if islogical(varargin{2})
                    name = varargin{1};
                    show = varargin{2};
                    file_id = 1;
                else
                    error('Third input argument must be a logical');
                end
            else
                error('Second input argument must be a string');
            end

        case 4
            if ischar(varargin{1})
                if islogical(varargin{2})
                    name = varargin{1};
                    show = varargin{2};
                    file_id = varargin{3};
                else
                    error('Third input argument must be a logical');
                end
            else
                error('Second input argument must be a string');
            end
        otherwise
            error('Invalid number of input arguments');
    end

    if isstruct(input)

        input = orderfields(input);
        % number of elements to be displayed
        NS = numel(input);
        if show
            hmax = NS;
        else
            hmax = min(1, NS);
        end

        % recursively display structure including fieldnames
        for h = 1:hmax
            F = fieldnames(input(h));
            NF = length(F);
            for i = 1:NF

                if NS > 1
                    size_ = size(input);
                    if show
                        name_i = [name '(' indToStr(size_, h) ').' F{i}];
                    else
                        name_i = [name '(' indToStr(size_, NS) ').'  F{i}];
                    end
                else
                    name_i = [name '.' F{i}];
                end

                if isstruct(input(h).(F{i}))
                    unfold(input(h).(F{i}), name_i, show, file_id);
                else

                    if iscell(input(h).(F{i}))
                        if numel(input(h).(F{i})) == 0
                            printKeyToScreen(name_i, file_id);
                            fprintf(file_id, ' =\t{};');
                        else
                            size_ = size(input(h).(F{i}));
                            NC = numel(input(h).(F{i}));
                            if show
                                jmax = NC;
                            else
                                jmax = 1;
                            end
                            for j = 1:jmax
                                if show
                                    name_j = [name_i '{' indToStr(size_, j) '}'];
                                else
                                    name_j = [name_i '{' indToStr(size_, NC) '}'];
                                end
                                printKeyToScreen(name_j, file_id);
                                if show
                                    printValueToScreen(input(h).(F{i}){j}, file_id);
                                end
                            end
                        end

                    else
                        printKeyToScreen(name_i, file_id);
                        if show
                            printValueToScreen(input(h).(F{i}), file_id);
                        end
                    end

                end
            end
        end

    elseif iscell(input)

        if numel(input) == 0
            fprintf(file_id, ' =\t{};');
        else
            % recursively display cell
            size_ = size(input);
            for i = 1:numel(input)
                name_i = [name '{' indToStr(size_, i) '}'];
                unfold(input{i}, name_i, show, file_id);
            end
        end

    else

        printKeyToScreen(name);
        if show
            printValueToScreen(input, file_id);
        end

    end

    callStack = dbstack();
    if numel(callStack) > 1 && ~strcmp(callStack(2).name, mfilename())
        fprintf(file_id, '\n');
    elseif numel(callStack) == 1 && strcmp(callStack(1).name, mfilename())
        fprintf(file_id, '\n');
    end

end

function printKeyToScreen(input, file_id)
    fprintf(file_id, sprintf('\n%s', input));
end

function printValueToScreen(input, file_id)

    base_string = ' =\t';
    msg = '';
    if ischar(input)
        msg = sprintf('%s''%s''  ', base_string, input);
    elseif isinteger(input) || islogical(input)
        if isempty(input)
            msg = ' =\t[]  ';
        else
            pattern = repmat('%i, ', 1, numel(input));
            msg = sprintf(['%s' pattern], base_string, input);
        end
    elseif isnumeric(input)
        if isempty(input)
            msg = ' =\t[]  ';
        else
            pattern = repmat('%0.3f, ', 1, numel(input));
            msg = sprintf(['%s' pattern], base_string, input);
        end
    end
    fprintf(file_id, msg);
    fprintf(file_id, '\b\b;');
end

% local functions
% --------------------------------------------------------------------------
function str = indToStr(size_, ndx)

    n = length(size_);
    % treat vectors and scalars correctly
    if n == 2
        if size_(1) == 1
            size_ = size_(2);
            n = 1;
        elseif size_(2) == 1
            size_ = size_(1);
            n = 1;
        end
    end
    k = [1 cumprod(size_(1:end - 1))];
    ndx = ndx - 1;
    str = '';
    for i = n:-1:1
        v = floor(ndx / k(i)) + 1;
        if i == n
            str = num2str(v);
        else
            str = [num2str(v) ',' str];
        end
        ndx = rem(ndx, k(i));
    end

end
