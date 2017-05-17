name "cmagent"
description "Cloudera manager agent role"
run_list "recipe[scm::agent]"
default_attributes "scm" => { "server_port" => "7182" }