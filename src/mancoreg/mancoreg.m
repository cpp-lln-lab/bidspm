function mancoreg(targetimage, sourceimage)
    %
    % Manual coregistration tool
    %
    % FORMAT mancoreg(targetimage,sourceimage);
    %
    % ----------------------------------------------------------------------------
    % This function displays 2 ortho views of a TARGET and
    % a SOURCE image that can be manually coregistered.
    %
    % The source image (bottom graph) can be manually
    % rotated and translated with 6 slider controls. In the source
    % graph the source image can be exchanged with the target image
    % using a radio button toggle. This is helpful for visual fine control
    % of the coregistration. The transformation matrix can be applied
    % to a selected set of volumes with the "apply transformation" button.
    % If the transformation is to be applied to the original source file
    % that file will also need to be selected. If the sourceimage or
    % targetimage are not passed the user will be prompted with a file browser.
    %
    % The code is loosely based on spm_image.m and spm_orthoviews.m
    % It requires the m-file with the callback functions for the user
    % controls (mancoreg_callbacks.m).
    % ----------------------------------------------------------------------------
    % JH 10.01.2004
    % modified DSS 10/02/2009
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
    % Version 1.0.3
    % Added:    Made compatible with SPM5 and corrected "Yawn" (altho I like it)

    global st mancoregvar

    %% Make sure we have both image filenames and map images
    % ----------------------------------------------------------------------------

    if ~exist('targetimage')
        targetimage = spm_select(1, 'image', 'Please select target image');
    end

    if ~exist('sourceimage')
        sourceimage = spm_select(1, 'image', 'Please select source image');
    end

    targetvol = spm_vol(targetimage);
    sourcevol = spm_vol(sourceimage);

    %% Init graphics window
    % ----------------------------------------------------------------------------

    fg = spm_figure('Findwin', 'Graphics');
    if isempty(fg)
        fg = spm_figure('Create', 'Graphics');
        if isempty(fg)
            error('Cant create graphics window');
        end
    else
        spm_figure('Clear', 'Graphics');
    end
    WS = spm('WinScale');

    htargetstim = spm_orthviews('Image', targetvol, [0.1 0.55 0.45 0.48]);
    spm_orthviews('space');
    spm_orthviews('AddContext', htargetstim);

    hsourcestim = spm_orthviews('Image', sourcevol, [0.1 0.08 0.45 0.48]);
    spm_orthviews('AddContext', hsourcestim);

    spm_orthviews('maxbb');

    mancoregvar.targetimage = st.vols{1};
    mancoregvar.sourceimage = st.vols{2};

    %% Define and initialise all user controls
    % ----------------------------------------------------------------------------

    % 1.a Titles and boxes

    uicontrol(fg, 'style', 'text', 'string', 'Manual coregistration tool', 'position', [200 825 200 30] .* WS, 'Fontsize', 16, 'backgroundcolor', [1 1 1]);

    uicontrol(fg, 'style', 'frame', 'position', [360 750 240 60] .* WS);
    uicontrol(fg, 'style', 'frame', 'position', [360 40 240 410] .* WS);

    uicontrol(fg, 'style', 'text', 'string', 'TARGET IMAGE', 'position', [370 780 80 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', targetimage, 'position', [370 760 220 019] .* WS, 'Fontsize', 10);

    uicontrol(fg, 'style', 'text', 'string', 'SOURCE IMAGE', 'position', [370 415 80 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', sourceimage, 'position', [370 395 220 019] .* WS, 'Fontsize', 10);

    % 1.b Transformation matrix

    uicontrol(fg, 'style', 'text', 'string', 'transf.', 'position', [370 360 40 015] .* WS, 'Fontsize', 10);
    mancoregvar.hmat_1_1 = uicontrol(fg, 'style', 'text', 'string', '1.00', 'position', [415 360 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_1_2 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [460 360 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_1_3 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [505 360 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_1_4 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [550 360 40 015] .* WS, 'Fontsize', 8);

    mancoregvar.hmat_2_1 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [415 340 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_2_2 = uicontrol(fg, 'style', 'text', 'string', '1.00', 'position', [460 340 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_2_3 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [505 340 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_2_4 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [550 340 40 015] .* WS, 'Fontsize', 8);

    mancoregvar.hmat_3_1 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [415 320 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_3_2 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [460 320 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_3_3 = uicontrol(fg, 'style', 'text', 'string', '1.00', 'position', [505 320 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_3_4 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [550 320 40 015] .* WS, 'Fontsize', 8);

    mancoregvar.hmat_4_1 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [415 300 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_4_2 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [460 300 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_4_3 = uicontrol(fg, 'style', 'text', 'string', '0.00', 'position', [505 300 40 015] .* WS, 'Fontsize', 8);
    mancoregvar.hmat_4_4 = uicontrol(fg, 'style', 'text', 'string', '1.00', 'position', [550 300 40 015] .* WS, 'Fontsize', 8);

    %% 2. Rotation sliders

    mancoregvar.hpitch =    uicontrol(fg, 'style', 'slider', 'position', [430 250 100 019] .* WS, 'Value', 0, ...
        'min', -pi, 'max', pi, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');
    mancoregvar.hroll  =    uicontrol(fg, 'style', 'slider', 'position', [430 225 100 019] .* WS, 'Value', 0, ...
        'min', -pi, 'max', pi, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');
    mancoregvar.hyaw   =    uicontrol(fg, 'style', 'slider', 'position', [430 200 100 019] .* WS, 'Value', 0, ...
        'min', -pi, 'max', pi, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');

    uicontrol(fg, 'style', 'text', 'string', 'PITCH', 'position', [370 250 60 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', 'ROLL', 'position', [370 225 60 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', 'YAW', 'position', [370 200 60 019] .* WS, 'Fontsize', 10);

    mancoregvar.hpitch_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 250 60 019] .* WS, 'Fontsize', 10);
    mancoregvar.hroll_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 225 60 019] .* WS, 'Fontsize', 10);
    mancoregvar.hyaw_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 200 60 019] .* WS, 'Fontsize', 10);

    %% 3. Translation sliders

    mancoregvar.hx =    uicontrol(fg, 'style', 'slider', 'position', [430 175 100 019] .* WS, 'Value', 0, ...
        'min', -500, 'max', 500, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');
    mancoregvar.hy =    uicontrol(fg, 'style', 'slider', 'position', [430 150 100 019] .* WS, 'Value', 0, ...
        'min', -500, 'max', 500, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');
    mancoregvar.hz =    uicontrol(fg, 'style', 'slider', 'position', [430 125 100 019] .* WS, 'Value', 0, ...
        'min', -500, 'max', 500, 'sliderstep', [0.01 0.01], 'Callback', 'mancoreg_callbacks(''move'')');

    uicontrol(fg, 'style', 'text', 'string', 'X', 'position', [370 175 60 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', 'Y', 'position', [370 150 60 019] .* WS, 'Fontsize', 10);
    uicontrol(fg, 'style', 'text', 'string', 'Z', 'position', [370 125 60 019] .* WS, 'Fontsize', 10);

    mancoregvar.hx_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 175 60 019] .* WS, 'Fontsize', 10);
    mancoregvar.hy_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 150 60 019] .* WS, 'Fontsize', 10);
    mancoregvar.hz_val = uicontrol(fg, 'style', 'text', 'string', '0', 'position', [530 125 60 019] .* WS, 'Fontsize', 10);

    %% 4. Source/target display toggle

    mancoregvar.htoggle_off =    uicontrol(fg, 'style', 'radiobutton', 'position', [470 100 040 019] .* WS, 'Value', 1, ...
        'Callback', 'mancoreg_callbacks(''toggle_off'')', 'string', 'OFF');
    mancoregvar.htoggle_on  =    uicontrol(fg, 'style', 'radiobutton', 'position', [530 100 060 019] .* WS, 'Value', 0, ...
        'Callback', 'mancoreg_callbacks(''toggle_on'')', 'string', 'ON');

    %% 5. "Reset transformation" pushbutton

    mancoregvar.hreset =    uicontrol(fg, 'style', 'pushbutton', 'position', [370 75 220 019] .* WS, 'String', 'Reset transformation', ...
        'Callback', 'mancoreg_callbacks(''reset'')');

    %% 6. "Apply transformation" pushbutton

    mancoregvar.hwrite =    uicontrol(fg, 'style', 'pushbutton', 'position', [370 50 220 019] .* WS, 'String', 'Apply transformation', ...
        'Callback', 'mancoreg_callbacks(''apply'')');

    %% Fill in "transf." fields

    mancoreg_callbacks('plotmat');

    return
