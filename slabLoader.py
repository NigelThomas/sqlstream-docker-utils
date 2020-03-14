## Use python to turn a SLAB file into a piece of JSON that can be submitted to Rose to load the SLAB project
# p1 = slab filename
# leaves the required file in /tmp/slab.json

import json
import os
import sys

filename=sys.argv[1]
base = os.path.basename(filename)
basename = os.path.splitext(base)[0]


with open(filename) as slab_file:
    json_data = json.load(slab_file)
    project_model = json_data['projectModel']
    title = project_model['title']
    schema = project_model['projectSchema']

    # add the adjustments element
    adjustments = { "newName":basename, "newTitle":title, "newSchema":schema, "setProtect": "false"}
    json_data["adjustments"] = adjustments

    # stringfy the json
    json_string = json.dumps(json_data)

    # and embed it in the call structure
    submit_dict = { "username": 'user', "json": json_string}

    # write out as json to be submitted by curl

    with open('/tmp/slab.json', 'w') as out_fp:
        json.dump(submit_dict, out_fp)



