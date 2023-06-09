# printing 50 lines to compensate for codestream bug that omits a semi-random number of output from the beginnings of its logs.
for i in $(seq 1 50); do
    echo "placeholder line $i"
done
export PIPELINE_START_TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
echo "the pipeline is starting at $PIPELINE_START_TIMESTAMP"
mkdir $PIPELINE_START_TIMESTAMP
cd $PIPELINE_START_TIMESTAMP

# Set the BASH_XTRACEFD to the file descriptor of the log file (3 in this case)
export BASH_XTRACEFD=3

# Enable xtrace
set -x

export PIPELINE_EXECUTION_ID="${executionId}"
export your_github_token="${input.your_github_token}"
export repo_owner_or_org_name="${input.github_org_name}"
export public_repo_name="${input.github_public_repo_name}"
export private_repo_name="${input.github_private_repo_name}"
export aws_access_key_id="${input.aws_access_key_id}"
export aws_secret_access_key="${input.aws_secret_access_key}"
export aws_region_name="${input.aws_region_name}"
# Define envars for sls file to deploy vpc
export AvailabilityZones='us-east-2a,us-east-2b,us-east-2c'
export AvailabilityZone1="us-east-2a"
export AvailabilityZone2="us-east-2b"
export AvailabilityZone3="us-east-2c"
export PrivateSubnet1CIDR='10.0.0.0/19'
export PrivateSubnet2CIDR='10.0.32.0/19'
export PrivateSubnet3CIDR='10.0.64.0/19'
export PublicSubnet1CIDR='10.0.128.0/20'
export PublicSubnet2CIDR='10.0.144.0/20'
export PublicSubnet3CIDR='10.0.160.0/20'
export VPCCIDR='10.0.0.0/16'

# Configure idem
## Configure idem credentials
cat <<EOF > creds.yaml
aws:
  default:
    aws_access_key_id: $aws_access_key_id
    aws_secret_access_key: $aws_secret_access_key
    region_name: $aws_region_name
EOF
# Create the ACCT_FILE var which idem uses as a standard var name to identify the location of the account credentials file
export ACCT_FILE="$(realpath creds.yaml)"

# download upload_file_github.py 
wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/upload_file_github.py
# download init.sls file used to create/deploy defined objects in file
wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/init.template.sls
# download create_guardrails.py
wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/create_guardrails.py
# download other utilities
wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/reorder.py
wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/generate_idem_describe_commands.py
######## The Following line can be uncommented for testing without running idem state command
# wget https://raw.githubusercontent.com/genaissance/aria_auto/main/pipelines/aws-vpc_tanzu-ra/init.output.yaml
# Install any dependent packages in python scripts
pip install ruamel.yaml
pip install pipreqs
pipreqs .
pip install -r requirements.txt
# populate the init.sls template with local envars
envsubst < init.template.sls > init.sls
echo "Here is the init.sls file with envars populated:"
# run idem state on the init.sls to create the defined objects
## specify the output value as yaml and redirect output to deployment_guardrails.sls file
idem state init.sls --output yaml > init.output.yaml
# convert init.output.yaml to unordered_guardrails.sls using create_guardrails.py
python3 create_guardrails.py init.output.yaml unordered_resource_list.yaml
# call reorder.py to reorder the unordered_guardrails.sls file and save as deployment_guardrails.sls
python3 reorder.py init.sls unordered_resource_list.yaml ordered_resource_list.yaml
python3 generate_idem_describe_commands.py ordered_resource_list.yaml idem_describe_list.txt
# The following while loop executes each command in the idem_describe_list.txt and outputs the results to the deployment_guardrails.sls file
while IFS= read -r command
do
  # Execute the command and append the output to deployment_guardrails.sls
  eval "$command" >> deployment_guardrails.sls
done < "idem_describe_list.txt"
python3 upload_file_github.py "$your_github_token" "$repo_owner_or_org_name" "$private_repo_name" "init.output.yaml" "pipelines/aws-vpc_tanzu-ra/artifacts/$PIPELINE_START_TIMESTAMP/init.output.yaml"
python3 upload_file_github.py "$your_github_token" "$repo_owner_or_org_name" "$private_repo_name" "deployment_guardrails.sls" "pipelines/aws-vpc_tanzu-ra/artifacts/$PIPELINE_START_TIMESTAMP/deployment_guardrails.sls"
python3 upload_file_github.py "$your_github_token" "$repo_owner_or_org_name" "$private_repo_name" "init.sls" "pipelines/aws-vpc_tanzu-ra/artifacts/$PIPELINE_START_TIMESTAMP/init.sls"

# Disable xtrace
set +x
