import yaml
import sys

def main(init_sls, init_output, output_filename):
    # Load the contents of init_sls
    with open(init_sls, "r") as file1:
        file1_data = yaml.safe_load(file1)

    # Load the contents of init_output
    with open(init_output, "r") as file2:
        file2_data = yaml.safe_load(file2)

    # Update the objects in file1_data with the "new_state" values from file2_data
    for key in file1_data:
        # Find the corresponding key in file2_data
        for file2_key in file2_data:
            if file2_data[file2_key].get("__id__") == key:
                # Update the object in file1_data with the "new_state" values from file2_data
                for new_state_key in file2_data[file2_key]["new_state"]:
                    file1_data[key][new_state_key] = file2_data[file2_key]["new_state"][new_state_key]
                break

    # Save the updated init.sls
    with open(output_filename, "w") as updated_file1:
        yaml.dump(file1_data, updated_file1)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: create_guardrails.py <init.sls> <init.output.yaml> <output_filename>")
        sys.exit(1)

    init_sls = sys.argv[1]
    init_output = sys.argv[2]
    output_filename = sys.argv[3]

    main(init_sls, init_output, output_filename)
