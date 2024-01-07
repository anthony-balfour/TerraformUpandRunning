### This file is used in congruence with the Terraform function templatefile
# which reads a file from a given path, and inserts variables that are given with the $ sytax
# it accesses the variables passed in

###

# user_data = templatefile("user-data.sh"), {
#   server_port = var.server_port
#   db_address = data.terraform_remote_state.db.outputs.address
#   db_port = data.terraform_remote_state.db.outputs.port
# })

#!/bin/bash

cat > index.xhtml <<EOF
<h1>Hellow, World</h1>
<p>DB Address: ${db_address}</p>
<p>DB port: ${db_port}</p>