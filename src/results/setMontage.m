% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function montage = setMontage(result)

  montage.background = {result.Output.montage.background};
  montage.orientation = result.Output.montage.orientation;
  montage.slices = result.Output.montage.slices;

end
