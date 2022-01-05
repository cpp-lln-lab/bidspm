function [t_vaso, t_bold] = resample_events_tsv(tsvFile)

  close all;

  % load the event file
  t = spm_load(tsvFile);

  event_onsets = t.onset;
  event_durations = t.duration;

  %% parameters

  plot_figure = 0;

  samp_rate = 1000; % in Hz

  vaso_tr = 1.6;

  bold_tr = 2.25;

  tot_tr = vaso_tr + bold_tr;

  %% start

  % add 1000 seconds padding
  run_duration = round(max(event_onsets + event_durations) + 1000);

  % we start with vaso at t=0
  vaso_triggers = 0:(tot_tr):run_duration;
  bold_triggers = vaso_tr:(tot_tr):run_duration;

  % convert values to a higher temporal resolution
  run_duration = temp_upsamp(run_duration, samp_rate);

  offsets = temp_upsamp(event_onsets + event_durations, samp_rate);
  onsets = temp_upsamp(event_onsets, samp_rate);

  vaso_triggers = temp_upsamp(vaso_triggers, samp_rate);
  bold_triggers = temp_upsamp(bold_triggers, samp_rate);

  %% create artifical time courses
  template = zeros(run_duration, 1);

  time_course = template;
  time_course(1 + round(onsets)) = 1;
  time_course(1 + round(offsets)) = -1;

  vaso_time_course = template;
  vaso_time_course(round(1 + vaso_triggers)) = 1;

  bold_time_course = template;
  bold_time_course(round(1 + bold_triggers)) = 1;

  if plot_figure
    figure('name', 'time course');
    hold on;
    plot(time_course * 2, 'b');
    plot(vaso_time_course, 'g');
    plot(bold_time_course, 'r');
  end

  %% epoch time courses using vaso and bold triggers

  vaso_triggers = find(vaso_time_course);
  bold_triggers = find(bold_time_course);

  vaso_epochs = [];
  bold_epochs = [];

  for i = 1:length(vaso_triggers)

    % we break out if we are beyond the end of the last block
    if bold_triggers(i) > max(offsets + 10000)
      break
    end

    time_points_to_sample = vaso_triggers(i):bold_triggers(i);
    vaso_epochs(:, i) = time_course(time_points_to_sample); %#ok<*AGROW,*SAGROW>

    time_points_to_sample = bold_triggers(i):vaso_triggers(i + 1);
    bold_epochs(:, i) = time_course(time_points_to_sample);

  end

  % this resampling changes the offset and onset values
  % to something else than -1 and 1.
  % It also adds some near zero values that we get rid off by rounding.

  % we stretch the vaso epochs
  resampled_vaso = resample(vaso_epochs, ...
                            temp_upsamp(bold_tr, samp_rate), ...
                            temp_upsamp(vaso_tr, samp_rate));

  % we compress the bold epochs
  resampled_bold = resample(bold_epochs, ...
                            temp_upsamp(vaso_tr, samp_rate), ...
                            temp_upsamp(bold_tr, samp_rate));

  if plot_figure
    figure('name', 'bold epochs');

    subplot(211);
    plot(bold_epochs(:));
    ylabel('original');

    subplot(212);
    plot(resampled_bold);
    ylabel('time compressed');
    xlabel('time points');

    figure('name', 'vaso epochs');

    subplot(211);
    plot(vaso_epochs);
    ylabel('original');

    subplot(212);
    plot(resampled_vaso);
    ylabel('time compressed');
    xlabel('time points');
  end

  time_course_for_vaso = cat(1, vaso_epochs, resampled_bold);
  time_course_for_vaso = time_course_for_vaso(:);

  time_course_for_bold = cat(1, resampled_vaso, bold_epochs);
  time_course_for_bold = time_course_for_bold(:);

  % fprintf(1, 'VASO:\n');
  % fprintf(1, ' Onsets\n');
  onsets_vaso = find_peaks(time_course_for_vaso, onsets, samp_rate, plot_figure);
  % fprintf(1, '\n Offsets\n');
  offsets_vaso = find_peaks(-time_course_for_vaso, offsets, samp_rate, plot_figure);
  durations_vaso = offsets_vaso - onsets_vaso;

  % fprintf(1, '\nBOLD:\n');
  % fprintf(1, ' Onsets\n');
  onsets_bold = find_peaks(time_course_for_bold, onsets, samp_rate, plot_figure);
  % fprintf(1, '\n Offsets\n');
  offsets_bold = find_peaks(-time_course_for_bold, offsets, samp_rate, plot_figure);
  durations_bold = offsets_bold - onsets_bold;

  % fprintf(1, '\n');

  % write two different event files for vaso and bold

  t_vaso = t;

  t_vaso.onset = onsets_vaso;

  t_vaso.duration = durations_vaso;

  t_bold = t;

  t_bold.onset = onsets_bold;

  t_bold.duration = durations_bold;

end

function trigger = find_peaks(time_course, events, samp_rate, make_fig)

  if make_fig
    figure;
    findpeaks(time_course, ...
              'MinPeakHeight', 0.4, ...
              'Annotate', 'peaks');

    %                                 'NPeaks', numel(events), ...
  end
  [~, trigger] = findpeaks(time_course, ...
                           'MinPeakHeight', .4, ...
                           'NPeaks', numel(events));

  trigger = trigger / samp_rate;

  %     fprintf(1, '  Original\n');
  %     fprintf(1, '   %f.2\t', events / samp_rate);
  %     fprintf(1, '  \n  New\n');
  %     fprintf(1, '   %f.2\t', trigger);

end

function impulse_times = temp_upsamp(impulse_times, samp_rate)
  impulse_times = impulse_times * samp_rate;
end
