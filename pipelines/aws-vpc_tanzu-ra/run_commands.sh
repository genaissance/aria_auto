#!/bin/bash

input_file="$1"
output_file="$2"

# Create an empty deployment_guardrails.sls file
> $output_file

# Read and execute commands from the input file
while IFS= read -r command
do
  # Execute the command and append the output to deployment_guardrails.sls
  eval "$command" >> $output_file
done < "$input_file"
