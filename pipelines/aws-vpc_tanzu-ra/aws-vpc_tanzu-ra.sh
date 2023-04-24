# printing 50 lines to help compensate for codestream bug that omits a semi-random number of output from the beginnings of its logs.
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
# populate the init.sls template with local envars
envsubst < init.template.sls > init.sls
echo "Here is the init.sls file with envars populated:"
# run idem state on the init.sls to create the defined objects
## specify the output value as yaml and redirect output to deployment_guardrails.sls file
idem state init.sls --output yaml > init.output.yaml
deployment_guardrails.sls
pip install pipreqs
pipreqs .
pip install -r requirements.txt
python3 upload_file_github.py "$your_github_token" "$repo_owner_or_org_name" "$private_repo_name" "deployment_guardrails.sls" "pipelines/aws-vpc_tanzu-ra/artifacts/$PIPELINE_START_TIMESTAMP/deployment_guardrails.sls"
python3 upload_file_github.py "$your_github_token" "$repo_owner_or_org_name" "$private_repo_name" "init.sls" "pipelines/aws-vpc_tanzu-ra/artifacts/$PIPELINE_START_TIMESTAMP/init.sls"

# Disable xtrace
set +x
