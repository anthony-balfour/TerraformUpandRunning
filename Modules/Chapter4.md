# Servers
Typically will have 2 envrionments, one for staging, and one for prod, both pretty identical.
Though probably less servers in staging group
Environments will have (ELB -> ASG -> MySQL)

# Module
- similar to a funciton, where reusable blocks of code can be used
- Entire infrastructure is a collection of reusable modules
- reusable, maintaable, scalable, and testable Terraform code