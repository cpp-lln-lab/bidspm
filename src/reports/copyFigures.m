function copyFigures(BIDS, opt, subID)

  imgNb = copyGraphWindownOutput(opt, subID, 'realign');
  
  % loop through the figures outputed for unwarp: one per run
  if  opt.realign.useUnwarp
    runs = spm_BIDS(BIDS, 'runs', ...
      'sub', subID, ...
      'task', opt.taskName, ...
      'type', 'bold');
    imgNb = copyGraphWindownOutput(opt, subID, 'unwarp', imgNb : (imgNb + size(runs, 2) - 1 ));
  end
  
  imgNb = copyGraphWindownOutput(opt, subID, 'func2anatCoreg', imgNb); %#ok<NASGU>
  
end