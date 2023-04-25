import sys
import ruamel.yaml

def reformat_yaml(input_file, output_file):
    yaml = ruamel.yaml.YAML()
    with open(input_file, 'r') as infile:
        data = yaml.load(infile)

    new_data = {}

    for key, value in data.items():
        name = value['name']
        esm_tag = key.split('_|', 1)[0] + '.present'
        new_data[name] = {
            esm_tag: {}
        }
        for k, v in value['new_state'].items():
            if k not in {'name', 'resource_id'}:
                new_data[name][esm_tag][k] = v

        if 'resource_id' in value['new_state']:
            new_data[name][esm_tag]['resource_id'] = value['new_state']['resource_id']

    with open(output_file, 'w') as outfile:
        yaml.dump(new_data, outfile)

if __name__ == '__main__':
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    reformat_yaml(input_file, output_file)
