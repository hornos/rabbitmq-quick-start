name "cluster"
description "Cluster node"
run_list(
  "recipe[cluster::hosts]",
  "recipe[cluster::node]"
)

