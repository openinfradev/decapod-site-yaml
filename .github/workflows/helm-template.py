#!/usr/bin/python3
import sys,yaml

with open(sys.argv[1], 'r') as stream:
    try:
        parsed = yaml.safe_load(stream)
        with open('{}.vo'.format(sys.argv[1]), 'w') as outfile:
            yaml.dump(parsed['spec']['values'], outfile, default_flow_style=False)
            print ('echo "=======================>', parsed['spec']['chart']['name'],'"')
            print ('helm repo add temp ', parsed['spec']['chart']['repository'])
            print ('helm template {0} temp/{1} --version {2} -f {3}'.format(
                parsed['spec']['chart']['name'], 
                parsed['spec']['chart']['name'], 
                parsed['spec']['chart']['version'],
                '{}.vo'.format(sys.argv[1])))
            print ('helm repo remove temp ')
    except yaml.YAMLError as exc:
        print(exc)
