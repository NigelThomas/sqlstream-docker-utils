## Use python to extract one or more dashboards from a SLAB file 
# p1 = slab filename (without slab extension)

import json
import os
import sys
import re

basename=sys.argv[1]
base = basename+'.slab'
filename = base


with open(filename) as slab_file:
    json_data = json.load(slab_file)
    dashboards = json_data['dashboards']
    print 'extracting dashboards:'

    for i in range(0, len(dashboards)):
        if (i == 0):
            try:
                os.mkdir('dashboards');
            except OSError as error:
                # ignore error (eg directory already present
                errCount = 0
            
        dashboard = dashboards[i]
        
        dash = dashboard['dash']

        dashModel = dashboard['dashModel']
        print '... '+dash

        with open('./dashboards/'+dash + '.json', 'w') as fp:
            json.dump(dashModel, fp)




