---
title: "Workload Federation with AWS and Terraform Cloud"
date: 2024-05-13T15:48:49-04:00
draft: true
---

# Workload Federation with AWS and Terraform Cloud

Here we are going to cover connecting an AWS Role with a Terraform Cloud workspace. This is a common pattern for managing
without needing to store long-lived credentials in your Terraform code.

## Prerequisites

A few things you'll need to have in place before you get started:
- An AWS account with permissions to create IAM roles and policies
- A Terraform Cloud account
- The Terraform CLI installed on your local machine

## Step 1: Set the credentials in Terraform Cloud for the role with access to AWS

1. Log in to your Terraform Cloud account.
2. Create a new workspace for this AWS account.
3. In the workspace, go to the Variables tab.
4. Set the following sensitive environment variables (we will be deleting these later):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET`
5. Create a new workspace in Terraform Cloud
6. Create a new folder locally and create a new Terraform configuration file, `main.tf`.
   - Add the following code to the file replacing the Organization and Workspace names with your own:
   - ```hcl
        provider "aws" {
        region = "us-west-2"
     }
     terraform {
       cloud {
          organization = "$YOUR_ORG_NAME"

       workspaces {
         name = "$YOUR_WORKSPACENAME"
          }
       }
      }
     
     ```

