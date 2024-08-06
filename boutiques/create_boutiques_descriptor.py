import json

import boutiques.creator as bc
from bidspm.parsers import sub_command_parser

newDescriptor = bc.CreateDescriptor(sub_command_parser(), execname="bidspm")

newDescriptor.save("bidspm.json")

cmd = (
    "./demos/openneuro/inputs/ds000114-fmriprep "
    "./demos/openneuro/outputs/ds000114/derivatives "
    "subject smooth "
    "--participant_label 01 02 "
    "--fwhm 6 "
    "--task overtverbgeneration overtwordrepetition covertverbgeneration "
    "--space MNI152NLin2009cAsym"
)

parser = sub_command_parser()
args = parser.parse_args(cmd.split(" "))
invoc = newDescriptor.createInvocation(args)

with open("my-inputs.json", "w") as fhandle:
    fhandle.write(json.dumps(invoc, indent=4))
