# upload_file_github.py
# Description: uploads a file to github
# Example Usage:
## python3 upload_to_github.py "$your_github_token" "$repo_owner_or_org_name" "$repo_name" "/path/to/your/local/file.txt" "path/in/repo/where/you/want/to/upload/file.txt"
## python3 upload_to_github.py "$your_github_token" "$repo_owner_or_org_name" "$repo_name" "sclean.py" "pipelines/aws-vpc_tanzu-ra/artifacts/sclean.py"
"""
Let's assume you have a GitHub repository named example-repo owned by the user john-doe. You want to upload a local file named example.txt to this repository in the data folder. You have a personal access token (PAT) for authentication.

First, make sure you have the updated Python script saved as upload_to_github.py. Then, execute the script in your terminal as follows:

```bash
python upload_to_github.py "your_personal_access_token" "john-doe" "example-repo" "/path/to/your/local/example.txt" "data/example.txt"
```
Replace your_personal_access_token with the actual token, and /path/to/your/local/example.txt with the correct path to the example.txt file on your local machine.

If the file is uploaded successfully, you should see the following message:

```bash
File '/path/to/your/local/example.txt' uploaded successfully to the repository.
```
The example.txt file will now be available in the data folder of the example-repo GitHub repository.

Remember to replace the placeholders with the appropriate values for your use case, and be cautious when using your personal access token in scripts, as it provides access to your GitHub account. Do not share your token or include it in version-controlled code.
"""

import requests
import base64
import argparse

def upload_to_github(token, repo_owner, repo_name, file_path, file_destination):
    with open(file_path, 'rb') as file:
        content = file.read()
    
    # Encode the file content in Base64
    content_base64 = base64.b64encode(content).decode('utf-8')

    # Create or update the file in the repository
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/contents/{file_destination}"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github+json",
    }
    data = {
        "message": f"Add or update file '{file_destination}'",
        "content": content_base64,
    }

    response = requests.put(url, json=data, headers=headers)

    if response.status_code in (201, 200):
        print(f"File '{file_path}' uploaded successfully to the repository.")
    else:
        print(f"Error uploading file. Status code: {response.status_code}")
        print(response.json())

def main():
    parser = argparse.ArgumentParser(description='Upload a file to a GitHub repository using the GitHub API.')
    parser.add_argument('token', help='GitHub personal access token (PAT).')
    parser.add_argument('repo_owner', help='GitHub repository owner.')
    parser.add_argument('repo_name', help='GitHub repository name.')
    parser.add_argument('file_path', help='Path to the local file to be uploaded.')
    parser.add_argument('file_destination', help='Destination file path in the GitHub repository.')

    args = parser.parse_args()

    upload_to_github(args.token, args.repo_owner, args.repo_name, args.file_path, args.file_destination)

if __name__ == '__main__':
    main()
