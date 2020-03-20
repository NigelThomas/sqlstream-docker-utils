## Use python to extract one or more SQL scripts from a SLAB file 
# p1 = slab filename (without slab extension)
# p2, ... = name of script eg main, start, stop
# leaves the required file in /tmp/slab.json

import json
import os
import sys
import re

basename=sys.argv[1]
base = basename+'.slab'
filename = base


with open(filename) as slab_file:
    json_data = json.load(slab_file)
    project_model = json_data['projectModel']
    
    print 'extracting SQL scripts:'
    
    for i in range(2, len(sys.argv)):
        sname = sys.argv[i]
        script = re.sub('\n!','\n-- ',project_model[sname+'Script'])

        print '... '+sname

        with open(basename+'.'+sname+'.sql', 'w') as fp:
            fp.write(script.encode('utf-8'));




