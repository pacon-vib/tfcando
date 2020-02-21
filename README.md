# How to do anything in Terraform

Terraform is a powerful, best-in-breed tool for infrastructure-as-code. But every infracoder is destined to hit that point in their journey where they need to do something that is not supported in Terraform, and the journey comes to abrupt halt.

_"I can't do this in Terraform, what now?"_ Is it necessary to go back and start my IaC again using a different tool? Well, maybe not.

The patterns in this repo will help you understand the trade-offs involved in the various ways to get your job done even if the official provider does not natively support it. If you understand, at least in general terms, how each option works, then you can assess the risk and select the right way forward for your project.

To solve any problem in Terraform, simply follow the list below:

| Pattern  | When to use... |
| ------------- | ------------- |
| Official or community provider  | Whenever possible!  |
| [Local-exec or other built-in "escape hatches"](/local-exec-and-friends/README.md)  | Simple commands that are unlikely to fail  |
| [Shell provider](/shell-provider/README.md) | <ul><li>For proofs of concept</li><li>A command-line tool solves the problem neatly, you just need to manage state</li><li>You don't know how to Golang and there is insufficient time to learn</li><li>There is no provider at all, and the task at hand doesn't justify creating a new one</li></ul>
| Writing/patching a provider | <ul><li>Long-term production use</li><li>To contribute to the community's IaC capability</li></ul> |

## Miscellaneous patterns

The following pages contain information about other ways of getting things done in Terraform. I don't recommend them, but the information may prove useful.

* Cloud platform-specific templating (e.g. ARM templates, CloudFormation)
* restapi provider
* Calling cloud platform APIs directly from shell scripts
