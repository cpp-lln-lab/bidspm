import boutiques.creator as bc

from bidspm.parsers import common_parser

newDescriptor = bc.CreateDescriptor(common_parser(), execname="bidspm")

newDescriptor.save("my-new-descriptor.json")

# args = common_parser.parse_args()
# invoc = newDescriptor.createInvocation(args)

# # Then, if you want to save them to a file...
# import json
# with open('my-inputs.json', 'w') as fhandle:
#     fhandle.write(json.dumps(invoc, indent=4))
