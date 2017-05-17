name "cmserver"
description "Cloudera manager server role"
run_list "recipe[scm::server]"
default_attributes "scm" => { "server_port" => "7182" }