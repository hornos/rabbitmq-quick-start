name "rabbitmq"
description "Rabbitmq server role"
all_env = [ 
  "role[base]",
  "recipe[rabbitmq]"
]

run_list(all_env)

# env_run_lists(
#   "_default" => all_env, 
#   "prod" => all_env,
#   #"dev" => all_env + ["recipe[php:module_xdebug]"],
#   "dev" => all_env
# )

override_attributes(
  :rabbitmq => {
    :cluster => true,
    :cluster_disk_nodes => ['rabbit@rabbit1','rabbit@rabbit2'],
    :erlang_cookie => "zRNri2qHxqse2ZrsxTnXi6j4B2IIOwr"
  }
)
