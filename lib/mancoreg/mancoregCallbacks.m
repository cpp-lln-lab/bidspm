% (C) Copyright 2004-2009 JH
% (C) Copyright 2009_2012 DSS
% (C) Copyright 2012_2019 Remi Gau
% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function mancoregCallbacks(operation)
    %
    % Callback routines for ``mancoreg()``: defines the different actions for the
    % different buttons.
    %
    % USAGE::
    %
    %   mancoreg_callbacks(operation)
    %
    % :param operation: Can be any of the following: ``move``, ``toggle_off``, ``toggle_on``,
    %                   ``reset``, ``apply``, ``plotmat``
    % :type operation: string
    %

    % Change LOG
    %
    % Version 1.0.1
    % Radio button cannot be turned off on matlab for linux (6.5.0). Changed to
    % two radio buttons for toggle on/off (12.1.2004, JH)
    %
    % Version 1.0.2
    % Added:    Plot of transformation matrix, values are shown next to sliders
    %           and "reset transformation" button (12.1.2004, JH)
    %

    switch operation

        case 'move'
            % Update the position of the bottom (source) image according to user settings
            moveImage();

            % Toggles between source and target display in bottom window
        case 'toggle_off'
            toggleOff();

        case 'toggle_on'
            toggleOn();

        case 'reset'
            resetTransformationMatrix();

        case 'apply'

            applyTransformationMatrix();

        case 'plotmat'
            % Plot matrix notation of transformation

            plotMat;

        otherwise
            % None of the op strings matches

            fprintf('WARNING: mancoreg_callbacks.m called with unspecified operation!\n');

    end

end

function moveImage()

    global st mancoregvar;

    angl_pitch = get(mancoregvar.hpitch, 'Value');
    angl_roll = get(mancoregvar.hroll, 'Value');
    angl_yaw = get(mancoregvar.hyaw, 'Value');

    dist_x = get(mancoregvar.hx, 'Value');
    dist_y = get(mancoregvar.hy, 'Value');
    dist_z = get(mancoregvar.hz, 'Value');

    set(mancoregvar.hpitch_val, 'string', num2str(angl_pitch));
    set(mancoregvar.hroll_val, 'string', num2str(angl_roll));
    set(mancoregvar.hyaw_val, 'string', num2str(angl_yaw));

    set(mancoregvar.hx_val, 'string', num2str(dist_x));
    set(mancoregvar.hy_val, 'string', num2str(dist_y));
    set(mancoregvar.hz_val, 'string', num2str(dist_z));

    mancoregvar.sourceimage.premul = ...
        spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);
    if get(mancoregvar.htoggle_on, 'value') == 0  % source is currently displayed
        st.vols{2}.premul = ...
            spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);
    end

    plotMat;
    spm_orthviews('redraw');

end

function toggleOff()

    global st mancoregvar;

    if get(mancoregvar.htoggle_off, 'value') == 0 % Source is to be displayed

        set(mancoregvar.htoggle_off, 'value', 1);

    else

        set(mancoregvar.htoggle_on, 'value', 0);
        st.vols{2} = mancoregvar.sourceimage;
        spm_orthviews('redraw');

    end

end

function toggleOn()

    global st mancoregvar;

    if get(mancoregvar.htoggle_on, 'value') == 0 % Source is to be displayed

        set(mancoregvar.htoggle_on, 'value', 1);

    else
        set(mancoregvar.htoggle_off, 'value', 0);
        mancoregvar.sourceimage = st.vols{2}; % Backup current state
        st.vols{2} = st.vols{1};
        st.vols{2}.ax = mancoregvar.sourceimage.ax; % These have to stay the same
        st.vols{2}.window = mancoregvar.sourceimage.window;
        st.vols{2}.area = mancoregvar.sourceimage.area;
        spm_orthviews('redraw');

    end

end

function resetTransformationMatrix()

    global st mancoregvar;

    set(mancoregvar.hpitch, 'Value', 0);
    set(mancoregvar.hroll, 'Value', 0);
    set(mancoregvar.hyaw, 'Value', 0);

    set(mancoregvar.hx, 'Value', 0);
    set(mancoregvar.hy, 'Value', 0);
    set(mancoregvar.hz, 'Value', 0);

    set(mancoregvar.hpitch_val, 'string', '0');
    set(mancoregvar.hroll_val, 'string', '0');
    set(mancoregvar.hyaw_val, 'string', '0');

    set(mancoregvar.hx_val, 'string', '0');
    set(mancoregvar.hy_val, 'string', '0');
    set(mancoregvar.hz_val, 'string', '0');

    mancoregvar.sourceimage.premul = spm_matrix([0 0 0 0 0 0 1 1 1 0 0 0]);
    if get(mancoregvar.htoggle_on, 'value') == 0  % source is currently displayed
        st.vols{2}.premul = spm_matrix([0 0 0 0 0 0 1 1 1 0 0 0]);
    end

    plotMat;
    spm_orthviews('redraw');

end

function applyTransformationMatrix()

    global st mancoregvar;

    angl_pitch = get(mancoregvar.hpitch, 'Value');
    angl_roll = get(mancoregvar.hroll, 'Value');
    angl_yaw = get(mancoregvar.hyaw, 'Value');

    dist_x = get(mancoregvar.hx, 'Value');
    dist_y = get(mancoregvar.hy, 'Value');
    dist_z = get(mancoregvar.hz, 'Value');
    spm_defaults;
    reorientationMatrix = ...
        spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);

    % The following is copied from spm_image.m
    if det(reorientationMatrix) <= 0
        spm('alert!', 'This will flip the images', mfilename, 0, 1);
    end
    imagesToReorient = spm_select(Inf, 'image', 'Images to reorient');

    saveReorientationMatrix(imagesToReorient, reorientationMatrix);

    matricesToChange = zeros(4, 4, size(imagesToReorient, 1));

    for i = 1:size(imagesToReorient, 1)
        tmp = ...
            sprintf('Reading current orientations... %.0f%%.\n', i / ...
                    size(imagesToReorient, 1) * 100);
        fprintf('%s', tmp);

        matricesToChange(:, :, i) = spm_get_space(imagesToReorient(i, :));
        spm_progress_bar('Set', i);

        fprintf('%s', char(sign(tmp) * 8));
    end

    for i = 1:size(imagesToReorient, 1)
        tmp = ...
            sprintf('Reorienting images... %.0f%%.\n', i / size(imagesToReorient, 1) * 100);
        fprintf('%s', tmp);

        spm_get_space(imagesToReorient(i, :), reorientationMatrix * matricesToChange(:, :, i));

        fprintf('%s', char(sign(tmp) * 8));
    end

    tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
    if sum((tmp(:) - st.vols{1}.mat(:)).^2) > 1e-8
        spm_image('init', st.vols{1}.fname);
    end
end

function plotMat

    global mancoregvar;

    angl_pitch = get(mancoregvar.hpitch, 'Value');
    angl_roll = get(mancoregvar.hroll, 'Value');
    angl_yaw = get(mancoregvar.hyaw, 'Value');

    dist_x = get(mancoregvar.hx, 'Value');
    dist_y = get(mancoregvar.hy, 'Value');
    dist_z = get(mancoregvar.hz, 'Value');

    premul = spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);

    for iRow = 1:4

        for iCol = 1:4

            fieldName = sprintf('hmat_%i_%i', iRow, iCol);
            stringToUse = sprintf('%2.4g', premul(iRow, iCol));

            set(mancoregvar.(fieldName), 'string', stringToUse);

        end
    end

end

function saveReorientationMatrix(imagesToReorient, reorientationMatrix)

    dateFormat = 'yyyymmdd_HHMM';

    filename = fullfile(pwd, strcat('reorientMatrix_', datestr(now, dateFormat)));

    fprintf(['Saving reorient matrice to ' [filename '.mat/json'] '.\n']);

    save([filename '.mat'], 'reorientationMatrix', 'imagesToReorient', '-v7');

    json.reorientationMatrix = reorientationMatrix;
    json.imagesToReorient = imagesToReorient;

    opts.indent = '    ';

    spm_jsonwrite([filename '.json'], json, opts);

end
