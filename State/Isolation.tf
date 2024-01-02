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

# Folder structure

/**

### Environments

- stage - pre production - testing
- prod - user-facing apps
- mgmt - devops tooling - bastion host, CI server
- global a place to put resources that are used across all environments


### Components within each folder

vpc - network topolgy for this environment

services - apps or microservices(modules of functions (shopping cart, user management))

data-storage - each data store should reside in each folder to isolate from other data stores


### Terraform configuration files

variables.tf
 - input variables

 output.tf
 - output variables

 main.tf
 - resources and data sources

 dependencies.tf
 - data sources to see what external things the code depends on

 providers.tf
 - providers the code talks to and what authentication youll have to provide

 main-xxx.tf
 -subgroupings/resources of main if main is getting too long for example:
 -main-iam.tf
  -IAM resources
-main.s3.tf
  -s3 resources
*/




