function mancoreg(varargin)
  %
  % This function displays 2 SPM ortho-views of a ``targetimage`` and
  % a ``sourceimage`` image that can be manually coregistered.
  %
  % USAGE::
  %
  %   mancoreg('targetimage', [], 'sourceimage', [], 'stepsize', 0.01)
  %
  % :param targetimage: Filename or fullpath of the target image. If none is provided
  %                     you will be asked by SPM to select one.
  % :type targetimage: string
  % :param sourceimage: Filename or fullpath of the source image. If none is provided
  %                     you will be asked by SPM to select one.
  % :type sourceimage: string
  % :param stepsize: step size for each rotation and translation
  % :type stepsize: positive float
  %
  % Manual coregistration tool
  %
  % The source image (bottom graph) can be manually
  % rotated and translated with 6 slider controls. In the source
  % graph the source image can be exchanged with the target image
  % using a radio button toggle. This is helpful for visual fine control
  % of the coregistration. The transformation matrix can be applied
  % to a selected set of volumes with the ``apply transformation`` button.
  % If the transformation is to be applied to the original source file
  % that file will also need to be selected. If the sourceimage or
  % targetimage are not passed the user will be prompted with a file browser.
  %
  % The code is loosely based on ``spm_image()`` and ``spm_orthoviews()``
  % It requires the m-file with the callback functions for the user
  % controls (``mancoregCallbacks()``).
  %
  % (C) Copyright 2004-2009 JH
  % (C) Copyright 2009_2012 DSS
  % (C) Copyright 2012_2019 Remi Gau
  % (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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
  % Added: Plot of transformation matrix, values are shown next to sliders
  % and "reset transformation" button (12.1.2004, JH)
  %
  % Version 1.0.3
  % Added: Made compatible with SPM5 and corrected "Yawn" (altho I like it)

  global st mancoregvar

  p = inputParser;
  
  is_file = @(x) exist(x, 'file')==2;

  default_sliderStep = '0.01';
  default_file = [];

  addParameter(p, 'targetimage', default_file, is_file);
  addParameter(p, 'sourceimage', default_file, is_file);
  addParameter(p, 'sliderStep', default_sliderStep, @isnumeric);

  parse(p, varargin{:});


  %% Options
  
  opt.smallFontSize = 8;
  opt.largeFontSize = 10;

  opt.smallFontBoxHeight = 15;
  opt.largeFontBoxHeight = 19;

  opt.smallFontBoxWidth = 40;
  opt.largeFontBoxWidth = 60;

  opt.translationSliderMin = -500;
  opt.translationSliderMax = 500;

  opt.rotationSliderMin = -pi;
  opt.rotationSliderMax = pi;

  opt.sliderStep = [p.Results.sliderStep p.Results.sliderStep];

  %% Make sure we have both image filenames and map images
  targetimage = p.Results.targetimage;
  sourceimage = p.Results.sourceimage;
  
  if isempty(targetimage)
    targetimage = spm_select(1, 'image', 'Please select target image');
  end

  if isempty(sourceimage)
    sourceimage = spm_select(1, 'image', 'Please select source image');
  end

  targetvol = spm_vol(targetimage);
  sourcevol = spm_vol(sourceimage);

  %% Init graphics window

  fg = spm_figure('Findwin', 'Graphics');
  if isempty(fg)
    fg = spm_figure('Create', 'Graphics');
    if isempty(fg)
      error('Cant create graphics window');
    end
  else
    spm_figure('Clear', 'Graphics');
  end
  opt.windowScale = spm('WinScale');

  htargetstim = spm_orthviews('Image', targetvol, [0.1 0.55 0.45 0.48]);
  spm_orthviews('space');
  spm_orthviews('AddContext', htargetstim);

  hsourcestim = spm_orthviews('Image', sourcevol, [0.1 0.08 0.45 0.48]);
  spm_orthviews('AddContext', hsourcestim);

  spm_orthviews('maxbb');

  mancoregvar.targetimage = st.vols{1};
  mancoregvar.sourceimage = st.vols{2};

  %% Define and initialise all user controls

  initTitleAndBoxes(opt, fg, targetimage, sourceimage);
  mancoregvar = initTransMat(mancoregvar, opt, fg);
  mancoregvar = initRotationSlider(mancoregvar, opt, fg);
  mancoregvar = initTranslationSlider(mancoregvar, opt, fg);

  % Source/target display toggle

  mancoregvar.htoggle_off = uicontrol(fg, ...
                                      'style', 'radiobutton', ...
                                      'position', ...
                                      [470 100 opt.smallFontBoxWidth * ...
                                       2 opt.largeFontBoxHeight] .* opt.windowScale, ...
                                      'Value', 1, ...
                                      'Callback', 'mancoregCallbacks(''toggle_off'')', ...
                                      'string', 'OFF');

  mancoregvar.htoggle_on = uicontrol(fg, ...
                                     'style', 'radiobutton', ...
                                     'position', ...
                                     [530 100 opt.largeFontBoxWidth opt.largeFontBoxHeight] .* ...
                                     opt.windowScale, ...
                                     'Value', 0, ...
                                     'Callback', 'mancoregCallbacks(''toggle_on'')', ...
                                     'string', 'ON');

  % "Reset transformation" pushbutton

  mancoregvar.hreset = uicontrol(fg, ...
                                 'style', 'pushbutton', ...
                                 'position', [370 75 220 opt.largeFontBoxHeight] .* ...
                                 opt.windowScale, ...
                                 'String', 'Reset transformation', ...
                                 'Callback', 'mancoregCallbacks(''reset'')');

  % "Apply transformation" pushbutton

  mancoregvar.hwrite = uicontrol(fg, 'style', 'pushbutton', ...
                                 'position', [370 50 220 opt.largeFontBoxHeight] .* ...
                                 opt.windowScale, ...
                                 'String', 'Apply transformation', ...
                                 'Callback', 'mancoregCallbacks(''apply'')');

  %% Fill in "transf." fields

  mancoregCallbacks('plotmat');

  return

end

function initTitleAndBoxes(opt, fg, targetimage, sourceimage)

  windowScale = opt.windowScale;
  fontSize = opt.largeFontSize;
  height = opt.largeFontBoxHeight;

  uicontrol(fg, ...
            'style', 'text', ...
            'string', 'Manual coregistration tool', ...
            'position', [200 825 300 30] .* windowScale, ...
            'Fontsize', 16, 'backgroundcolor', [1 1 1]);

  uicontrol(fg, ...
            'style', 'frame', ...
            'position', [360 550 240 250] .* windowScale);
  uicontrol(fg, 'style', 'frame', ...
            'position', [360 40 240 410] .* windowScale);

  addTextToUI( ...
              fg, 'TARGET IMAGE', ...
              [370 760 100 height], opt, fontSize);
  addTextToUI( ...
              fg, targetimage, ...
              [370 700 220 height * 3], opt, fontSize);

  addTextToUI( ...
              fg, 'SOURCE IMAGE', ...
              [370 415 100 height], opt, fontSize);
  addTextToUI( ...
              fg, sourceimage, ...
              [370 395 220 height], opt, fontSize);

end

function mancoregvar = initTransMat(mancoregvar, opt, fg)

  fontSize = opt.smallFontSize;

  width = opt.smallFontBoxWidth;
  height = opt.smallFontBoxHeight;

  colPosition = 415:45:550;
  rowPosition = 360:-20:300;

  addTextToUI( ...
              fg, 'transf.', ...
              [370 360 width height], opt, opt.largeFontSize);

  for iRow = 1:numel(rowPosition)

    for iCol = 1:numel(colPosition)

      xPos = colPosition(iCol);
      yPos = rowPosition(iRow);
      fieldName = sprintf('hmat_%i_%i', iRow, iCol);

      stringToUse = '0.00';
      if iRow == iCol
        stringToUse = '1.00';
      end

      mancoregvar = addTextToUI( ...
                                fg, stringToUse, ...
                                [xPos yPos width height], opt, fontSize, ...
                                mancoregvar, fieldName);

    end
  end

end

function mancoregvar = initRotationSlider(mancoregvar, opt, fg)

  windowScale = opt.windowScale;
  fontSize = opt.largeFontSize;
  height = opt.largeFontBoxHeight;
  width = opt.largeFontBoxWidth;

  sliderMin = opt.rotationSliderMin;
  sliderMax = opt.rotationSliderMax;

  sliderStep = opt.sliderStep;

  % set sliders
  mancoregvar.hpitch = uicontrol(fg, 'style', 'slider', ...
                                 'position', [430 250 100 height] .* windowScale, ...
                                 'Value', 0, ...
                                 'min', sliderMin, ...
                                 'max', sliderMax, ...
                                 'sliderstep', sliderStep, ...
                                 'Callback', 'mancoregCallbacks(''move'')');
  mancoregvar.hroll = uicontrol(fg, 'style', 'slider', ...
                                'position', [430 225 100 height] .* windowScale, ...
                                'Value', 0, ...
                                'min', sliderMin, ...
                                'max', sliderMax, ...
                                'sliderstep', sliderStep, ...
                                'Callback', 'mancoregCallbacks(''move'')');
  mancoregvar.hyaw = uicontrol(fg, 'style', 'slider', ...
                               'position', [430 200 100 height] .* windowScale, ...
                               'Value', 0, ...
                               'min', sliderMin, ...
                               'max', sliderMax, ...
                               'sliderstep', sliderStep, ...
                               'Callback', 'mancoregCallbacks(''move'')');

  % display text
  xPos = 370;

  addTextToUI( ...
              fg, 'PITCH', ...
              [xPos 250 width height], opt, fontSize);
  addTextToUI( ...
              fg, 'ROLL', ...
              [xPos 225 width height], opt, fontSize);
  addTextToUI( ...
              fg, 'YAW', ...
              [xPos 200 width height], opt, fontSize);

  % display value
  xPos = 530;

  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 250 width height], opt, fontSize, ...
                            mancoregvar, 'hpitch_val');
  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 225 width height], opt, fontSize, ...
                            mancoregvar, 'hroll_val');
  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 200 width height], opt, fontSize, ...
                            mancoregvar, 'hyaw_val');

end

function mancoregvar = initTranslationSlider(mancoregvar, opt, fg)

  windowScale = opt.windowScale;
  fontSize = opt.largeFontSize;
  height = opt.largeFontBoxHeight;
  width = opt.largeFontBoxWidth;

  sliderMin = opt.translationSliderMin;
  sliderMax = opt.translationSliderMax;

  sliderStep = opt.sliderStep;

  % add sliders
  xPos = 430;

  mancoregvar.hx = uicontrol(fg, ...
                             'style', 'slider', ...
                             'position', [xPos 175 100 height] .* windowScale, ...
                             'Value', 0, ...
                             'min', sliderMin, ...
                             'max', sliderMax, ...
                             'sliderstep', sliderStep, ...
                             'Callback', 'mancoregCallbacks(''move'')');
  mancoregvar.hy = uicontrol(fg, ...
                             'style', 'slider', ...
                             'position', [xPos 150 100 height] .* windowScale, ...
                             'Value', 0, ...
                             'min', sliderMin, ...
                             'max', sliderMax, ...
                             'sliderstep', sliderStep, ...
                             'Callback', 'mancoregCallbacks(''move'')');
  mancoregvar.hz = uicontrol(fg, ...
                             'style', 'slider', ...
                             'position', [xPos 125 100 height] .* windowScale, ...
                             'Value', 0, ...
                             'min', sliderMin, ...
                             'max', sliderMax, ...
                             'sliderstep', sliderStep, ...
                             'Callback', 'mancoregCallbacks(''move'')');

  % display text
  xPos = 370;

  addTextToUI( ...
              fg, 'X', ...
              [xPos 175 width height], opt, fontSize);
  addTextToUI( ...
              fg, 'Y', ...
              [xPos 150 width height], opt, fontSize);
  addTextToUI( ...
              fg, 'Z', ...
              [xPos 125 width height], opt, fontSize);

  % display value
  xPos = 530;

  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 175 width height], opt, fontSize, ...
                            mancoregvar, 'hx_val');
  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 150 width height], opt, fontSize, ...
                            mancoregvar, 'hy_val');
  mancoregvar = addTextToUI( ...
                            fg, '0', ...
                            [xPos 125 width height], opt, fontSize, ...
                            mancoregvar, 'hz_val');

end

function mancoregvar = addTextToUI(varargin)

  if numel(varargin) == 7
    [fg, textString, position, opt, fontSize, mancoregvar, fieldName] = deal(varargin{:});
  elseif numel(varargin) == 5
    [fg, textString, position, opt, fontSize] = deal(varargin{:});
    fieldName = [];
  end

  handle = uicontrol(fg, ...
                     'style', 'text', ...
                     'string', textString, ...
                     'position', position .* opt.windowScale, ...
                     'Fontsize', fontSize);

  if ~isempty(fieldName)
    mancoregvar.(fieldName) = handle;
  end

end
