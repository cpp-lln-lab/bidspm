from pathlib import Path

from bids.modeling.statsmodels import BIDSStatsModelsGraph

root_dir = Path("/home/remi/github/cpp-lln-lab/bidspm")

graph = BIDSStatsModelsGraph(
    layout=root_dir / "demos/MoAE/inputs/raw",
    model=root_dir / "demos/openneuro/models/model-narps_desc-U26C_smdl.json",
)


graph.write_graph()
