from pathlib import Path

from bids.modeling.statsmodels import BIDSStatsModelsGraph

graph = BIDSStatsModelsGraph(
    layout=Path("/home/remi/github/cpp-lln-lab/bidspm/demos/MoAE/inputs/raw"),
    model="/home/remi/github/cpp-lln-lab/bidspm/demos/openneuro/models/model-narps_desc-U26C_smdl.json",
)


graph.write_graph()
