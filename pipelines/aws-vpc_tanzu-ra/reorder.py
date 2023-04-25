# The purpose of this file is to change the order of objects in a target sls file to match the order of objects defined in an ordered file path. The ordered_file_path file should be a txt file that can be generated from the init.sls file with the command `grep "^[[:alnum:]]" init.sls > object_order.txt`. The target sls file should only include object definitions and not include any parameter definitions.
# Usage: python3 reorder.py <ordered_file> <unordered_file> <output_file>
import sys
import os

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read().strip().split('\n')

def main(ordered_file_path, unordered_file_path, output_file_path):
    ordered_keys = read_file(ordered_file_path)
    unordered_lines = read_file(unordered_file_path)

    unordered_dict = {}
    current_key = None
    for line in unordered_lines:
        if line in ordered_keys:
            current_key = line
            unordered_dict[current_key] = []
        else:
            unordered_dict[current_key].append(line)

    temp_output_file_path = 'temp_output.txt'

    with open(temp_output_file_path, 'w') as temp_output_file:
        for key in ordered_keys:
            if key in unordered_dict:
                temp_output_file.write(key + '\n')
                for line in unordered_dict[key]:
                    temp_output_file.write(line + '\n')
                temp_output_file.write('\n')

    # Read the temporary output file and remove blank lines
    with open(temp_output_file_path, 'r') as temp_output_file:
        lines = temp_output_file.readlines()

    with open(output_file_path, 'w') as output_file:
        for line in lines:
            if line.strip():
                output_file.write(line)

    # Remove the temporary output file
    os.remove(temp_output_file_path)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 reorder.py <ordered_file> <unordered_file> <output_file>")
        sys.exit(1)

    ordered_file_path = sys.argv[1]
    unordered_file_path = sys.argv[2]
    output_file_path = sys.argv[3]

    main(ordered_file_path, unordered_file_path, output_file_path)
