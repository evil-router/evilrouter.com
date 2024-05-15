---
title: "Workload Federation with AWS and Terraform Cloud"
date: 2024-05-15T15:48:49-04:00
draft: false
slug: "workload-federation-aws-tfc"
---

# Workload Federation with AWS and Terraform Cloud

Here we are going to cover connecting an AWS Role with a Terraform Cloud workspace. This is a common pattern for managing
without needing to store long-lived credentials in your Terraform code. This greatly reduce the chances of high-privilege credentials being exposed.

## Prerequisites

A few things you'll need to have in place before you get started:
- An AWS account with permissions to create IAM roles and policies
- A Terraform Cloud account
- The Terraform CLI installed on your local machine

## Step 1: Set the credentials in Terraform Cloud for the role with access to AWS

1. Log in to your Terraform Cloud account.
2. Create a new Workspace for this AWS account.
3. In the wWorkspace, go to the Variables tab.
4. Set the following sensitive environment variables [how to get access credential](https://docs.aws.amazon.com/keyspaces/latest/devguide/access.credentials.html) (Ensure that the AWS account has the necessary permissions to create IAM roles and policies)
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET`
   - `AWS_SESSION_TOKEN` - (optional) 
5. Set the following non-sensitive environment variables (this is to keep information out of the code):
   - `project` - The name of the project in Terraform Cloud
   - `organization` - The name of the organization in Terraform Cloud
   - `workspace` - The name of the workspace in Terraform Cloud
   - `audience` - The audience for the OpenID Connect Provider
6. Save The variables.
7. Create a new Private GitHub repository and connect it to the workspace.

## Step 2: Create the Terraform configuration
1. Clone the repository to your local machine.
2. Add a new Terraform configuration file, `main.tf`.
   - Add the following code to the file to create an IAM role, Identify provider, and trust relationship in AWS:
           
   - {{< code file="pt1/main.tf" format="hcl" >}}
3. You can now commit the code to your repository and trigger a run in Terraform Cloud.
4. You should see the following plan in the Terraform Cloud UI. It should just be 2 resources to create, and 2 datasource's to read.
   ![Plan](/images/workload-federation-aws-tfc/Plan.png)
5. Apply the plan to create the resources in AWS.
6. Once the run is complete, make note of the ARN of the role that was created. You will need this in the next step.

## Step 3: Configure the Terraform Cloud workspace to use Dynamic Provider Configuration
1. In the Terraform Cloud workspace, go to the variables tab.
2. Delete following variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET`
   - `AWS_SESSION_TOKEN`
3. Add the following environment variables:
   - `TFC_AWS_RUN_ROLE_ARN` - The ARN of the role you created in AWS, it Should be in Output of the Terraform run before.
   - `TFC_AWS_WORKLOAD_IDENTITY_AUDIENCE` - The audience for the OpenID Connect Provider, this should be the same as the audience you set in the Terraform Cloud workspace.
   - `TFC_AWS_PROVIDER_AUTH` - This should be set to true.
   ![Variables](/images/workload-federation-aws-tfc/dynamic-provider-variables.png)
4. Save the variables.
5. Trigger a new run in Terraform Cloud.
6. You should see no changes, and the run should complete successfully.

## Step 4: Congratulations! You have successfully connected an AWS Role with a Terraform Cloud workspace.

Now you can use this role to manage resources in AWS without needing to store long-lived credentials in your Terraform code, you can now add mappings to new roles
and workspace to manage different resources in AWS, and to allow other teams access to resources in AWS. The creation of the OIDC provider should only need to be done once per AWS
account, and the roles can be created as needed.


## References
[Dynamic Provider Configuration](https://www.terraform.io/docs/language/providers/configuration.html#dynamic-provider-configuration) 
[Dynamic Aws Provider Configuration](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration)
[Token Specification](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens#token-specification)

