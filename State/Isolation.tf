### Defining each environment in separate Terraform configuration ###

 /*
  -Dev
  -Stage
  -Prod


  Isolation Via Workspaces
    - Can use terraform workspace commands


#### Isolation via File Layout

- config files for each environment into separate folders.
  -staging files in "stage"
  -production files in "prod"

  ## different backend for each envrionment, using diff access controls
      -so separate aws account with separate s3 bucket
 */

 # Component Isolation

/**

- Isolating VPC, services, databases
- For example: If I set up a VPC component that changed only every couple months,
- and a web server that changed multiple times per day, it would be best to separate
- the infrastructure configurations of both
*/



