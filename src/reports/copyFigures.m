function copyFigures(BIDS, opt, subID)

  imgNb = copyGraphWindownOutput(opt, subID, 'realign');
  
  % loop through the figures outputed for unwarp: one per run
  if  opt.realign.useUnwarp
    
    runs = bids.query(BIDS, 'runs', ...
      'sub', subID, ...
      'task', opt.taskName, ...
      'type', 'bold');
    
    nbRuns = size(runs, 2);
    if nbRuns == 0
      nbRuns = 1;
    end
    
    imgNb = copyGraphWindownOutput(opt, subID, 'unwarp', imgNb : (imgNb + nbRuns - 1 ));
    
  end
  
  imgNb = copyGraphWindownOutput(opt, subID, 'func2anatCoreg', imgNb); %#ok<NASGU>
  
end