### Defining each environment in separate Terraform configuration ###

 /*
  -Dev
  -Stage
  -Prod


  Isolation Via Workspaces
    - Can use terraform workspace commands


#### Isolation via File Layout

- config files for each environment into separate folders.
  -staging files in stage
  -production files in prod

  ## different backend for each envrionment, using diff access controls
      -so separate aws account with separate s3 bucket
 */



