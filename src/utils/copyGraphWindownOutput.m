% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function copyGraphWindownOutput(outputDir, action)
    % copyGraphWindownOutput(outputDir, action)
    %
    % looks into the current directory for an spm_*.ps file and moves it into
    % the output directory and adds the 'action' in the name of the file
    %
    % assumes that no file was generated if SPM is running in command line mode

    if ~spm('CmdLine')

        if nargin < 1
            outputDir = pwd;
        end

        if nargin < 1
            action = [];
        end

        file = spm_select('FPList', pwd, '^spm_.*.ps$');

        if ~isempty(file)

            [~, filename, ext] = spm_fileparts(file);

            targetFile = [strrep(filename, 'spm_', ['spm_' action '_']) ext];

            movefile( ...
                     file, ...
                     fullfile(outputDir, targetFile));

        end

    end

end
