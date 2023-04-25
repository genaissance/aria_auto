import sys
import os
import re

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read().strip().split('\n')

def main(ordered_file_path, unordered_file_path, output_file_path):
    ordered_lines = read_file(ordered_file_path)
    unordered_lines = read_file(unordered_file_path)

    ordered_object_names = [re.match(r'^([a-zA-Z0-9_]+):', line).group(1) for line in ordered_lines if re.match(r'^([a-zA-Z0-9_]+):', line)]
    unordered_objects = {}

    current_object = None
    for line in unordered_lines:
        if re.match(r'^([a-zA-Z0-9_]+):', line):
            current_object = re.match(r'^([a-zA-Z0-9_]+):', line).group(1)
            unordered_objects[current_object] = [line]
        elif current_object is not None:
            unordered_objects[current_object].append(line)

    with open(output_file_path, 'w') as output_file:
        for ordered_object_name in ordered_object_names:
            if ordered_object_name in unordered_objects:
                output_file.write('\n'.join(unordered_objects[ordered_object_name]))
                output_file.write('\n\n')

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python3 reorder.py <ordered_file> <unordered_file> <output_file>")
        sys.exit(1)

    ordered_file_path = sys.argv[1]
    unordered_file_path = sys.argv[2]
    output_file_path = sys.argv[3]

    main(ordered_file_path, unordered_file_path, output_file_path)
