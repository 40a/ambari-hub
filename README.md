# **Ambari-hub**
Ambari templates, docker, packer, terraform etc.

It's more of a backup then anything else, you can use it I guess. And if you want to commit to it, be my guest ;-)

# **Basic Info**

Rename the variables.tf.example (obviously) and fill in the variables.
The public zone inside route53 needs to be there upfront, simply because of the latency DNS has when adding a new zone (it takes a while before everything is updated, as in couple of hours).

Also the security group might have to be changed manually, since this is just for testing it has erm....*ahum* really bad security...(as in none) it's open to the world...which you obviously DON'T want!

# **Type of nodes**

So we have different types of nodes, right now just three:

 1. Ambari Master; since HA is not really working yet within ambari (not talking about the services for the platform itselft) this can and should be a middle-end single node machine of coarse when HA is finished in the plans the amount can be raised.
 2. Server agents; with this I mean the nodes that actually run the "server services" for example a resource manager, name/data node namely the non-computational systems. I should rename this later but for now it's fine.
 3. Client agents; these are the machines that actually rely heavily on CPU (for example the C4 instances of AWS) for example Spark clients.

Now obviously this is highly biased, anyone with a better suggestion please "fix" it ;-) And probably we need more node-types later on, for now this is fine.

# **Terraform Graph**

![Graph icon](graph.png)

# **TODO**

1. The plan needs to be split into several modules.
2. Extend AWS support to also allow for private VPC (eg. don't expose anything public).
3. Add other cloudsupport (eg. Cloudstack).
4. Add basic blueprint, maybe just export a handmade cluster.