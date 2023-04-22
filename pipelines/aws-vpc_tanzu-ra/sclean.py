# this file attemps to delete any resources created by the defined input sls file
import os
import re
import subprocess

def process_file(file_path):
    with open(file_path, 'r') as file:
        content = file.readlines()

    result = []
    for line in content:
        match = re.search(r'^\s*aws\.ec2\..*\.present:', line)
        if match:
            cleaned_line = match.group().strip()
            cleaned_line = re.sub(r'\.present:.*$', '', cleaned_line)
            result.append(cleaned_line)

    return result

def execute_commands(processed_lines):
    for line in reversed(processed_lines):
        env = {
            **os.environ,
            "LINE": line,
        }

        describe_command = 'idem describe $LINE --filter="[?resource[?tags.LandingZone==\'dev_cloud\']]" --no-progress-bar'
        describe_result = subprocess.run(describe_command, shell=True, env=env, capture_output=True, text=True)

        if describe_result.stdout.strip():
            with open(f'{line}.sls', 'w') as outfile:
                outfile.write(describe_result.stdout)

            state_command = 'idem state $LINE.sls --invert'
            subprocess.run(state_command, shell=True, env=env)

file_path = 'init.sls'
processed_lines = process_file(file_path)
execute_commands(processed_lines)
