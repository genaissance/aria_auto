import sys
import re

def main(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if "resource_id" in line:
                resource_id = re.search("resource_id: (.+)", line).group(1)
                resource_type = re.search("aws.ec2.(\w+).present", prev_line).group(1)
                outfile.write(f"idem describe aws.ec2.{resource_type} --filter=\"[?resource[?resource_id=='{resource_id}']]\"\n")
            prev_line = line

if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    main(input_file, output_file)
