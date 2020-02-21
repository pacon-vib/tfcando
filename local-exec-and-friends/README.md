# Local-exec and other built-in escape hatches

## The local-exec provisioner

A local-exec provisioner causes Terraform to run a command (on the host running Terraform) after creating (or before destroying) a resource:

```hcl
resource "azurerm_resource_group" "demo" {
  name     = "demo"
  location = "australiaeast"

  provisioner "local-exec" {
    command = "echo Hello from local-exec on ${self.name}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "echo Goodbye from local-exec on ${self.name}"
  }
}
```

Local-execs are ideal for very simple commands that relate to a resource, such as setting a property that isn't supported by the Terraform provider or triggering a separate configuration management tool.

However, the [Terraform docs](https://www.terraform.io/docs/provisioners/local-exec.html) are not wrong when they say "provisioners should only be used as a last resort." They are brittle and difficult to work with. If a create-time local-exec fails, then the resource to which it is attached is marked as tainted. That causes Terraform to destroy and re-create the resource next time `terraform apply` is run, even if there is nothing wrong with the resource and it is just the local-exec that failed. But there is no other way to re-run the local-exec.

The above can be ameliorated slightly by splitting the local-exec out onto its own `null_resource`:

```hcl
resource "azurerm_resource_group" "demo" {
  name     = "demo"
  location = "australiaeast"
}

resource "null_resource" "demo" {

  triggers = {
    foo = "bar"
  }

  provisioner "local-exec" {
    command = "echo Hello from local-exec on ${azurerm_resource_group.demo.name}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "echo Goodbye from local-exec on ${azurerm_resource_group.demo.name}"
  }
}
```

The references to the resource group's name will set up a dependency relationship, but alternatively you can use `depends_on` to control the order of execution.

The key problem with local-execs is the absence of state management:
* You cannot output state from the local-exec (e.g. to track the ID of some unsupported resource created by the local-exec).
* You can trigger the null_resource to be destroyed and re-created by changing a `trigger` value, thus re-running the local-exec, but this is not automatically triggered by changes to the substantive resource nor by changes to the text of the local-exec command.

The possibilities for hacks are endless -- for example you can run an arbitrary command on every `apply` by setting a `trigger` value to `timestamp()` so that it is always changing -- but you are on flimsy, unprofitable ground.

If you are having problems with local-execs, don't waste time trying to make them work! Move on to the other patterns in this repo.

## HTTP data source and `external` data source

If you only need to pull information about an unsupported resource, and not create it, then then built-in `http` and `external` data sources may meet your needs, without you needing to take the leap to the shell provider.

### HTTP data source

The `http` data source, as its name suggests, sends a HTTP request and returns the response:

```hcl
data "http" "ifconfig" {
  url = "https://ifconfig.co"
}
```

```sh
$ terraform apply
data.http.ifconfig: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
$ terraform state show data.http.ifconfig
# data.http.ifconfig:
data "http" "ifconfig" {
    body = <<~EOT
        111.222.111.222
    EOT
    id   = "2020-06-12 08:34:11.10300 +0000 UTC"
    url  = "https://ifconfig.co"
}
```

Depending on the service, some combination of `trim()`, `jsondecode()` or other functions may be necessary to extract the desired data and massage it into a form that can be used as an input attribute on another resource.

Arbitrary headers can be added, so in theory you could access services that require authentication.

### External data source

The `external` data source runs a shell command on the host where Terraform is running. Terraform will pass the contents of the `query` map to the command as stdin, and the command is expected to print a JSON object to stdout, which will become the data source's `result` attribute in Terraform. (This protocol is similar to that of the shell provider, although the shell provider is considerably more flexible.)

The example below is difficult to follow due to the need to escape quoted quotes, but what it does is pass through the input object with an additional property added.

```hcl
data "external" "demo" {
  program = ["sh", "-c", "cat | jq '. + {\"blorb\": \"flarb\"}'"]

  query = {
    foo = "bar"
    quz = "qux"
  }
}
```

```sh
$ terraform console
> data.external.demo.result
{
  "blorb" = "flarb"
  "foo" = "bar"
  "quz" = "qux"
}
```

In a real-world example you might call a command-line tool to obtain some information. If the tool returns a JSON-encoded map of strings, great; if not, then you can use `jq` (https://github.com/stedolan/jq) to massage it.
