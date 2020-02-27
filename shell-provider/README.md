# Shell provider

Scott Winkler's shell provider lets you manage the create-update-destroy lifecycle of anything -- anything! -- by running arbitrary shell scripts that you specify. 

The provider can be downloaded from the releases section on GitHub (https://github.com/scottwinkler/terraform-provider-shell). The repo also contains documentation and examples in Bash and Python.

Embedding shell scripts in a Terraform feels like a hack, but it isn't. The whole world runs on shell scripts. How well it works really depends on the quality of the shell scripts you put in, and how well you test it. The provider itself is simple and reliable. 

## How to use it

The documentation on the provider's repo does a good job of explaining the concepts and how to use it: https://github.com/scottwinkler/terraform-provider-shell

The main thing is that instead of just writing a script that does something and hoping it works, you are now managing a whole create-update-destroy lifecycle. This is more work than just writing a shell script to create a resource, but the trade-off is well worth it.

To further illustrate the possibilities, this directory contains two examples with unsupported resources in Azure, one in Bash and one in Powershell:
* [Creating a cluster in Data Bricks](databrickscluster/)
* [Creating a linked service for Data Factory](datafactorylinkedservice/)

## Tips on reading and writing state

Your script will receive the existing state (if any) on stdin, and be expected to emit the new state (if any) on file descriptor 3. In both cases the data needs to be a map of strings to strings, encoded as JSON.

The `jq` tool is more-or-less essential for working with JSON in a shell.

The following snippets may be useful when you're getting started with the shell provider:
```bash
# Grab existing state
OLD_STATE="$(cat)"

# Build new state object based on shell variables
NEW_STATE="$(jq -n --arg cluster_id "$NEW_CLUSTER_ID" '{cluster_id: $cluster_id}')"

# Helper for adding keys to a JSON object as you go
jsonaddkey() { jq ". + {\"${1}\": \"${2}\"}"; }
NEW_STATE="$(echo "$NEW_STATE" | jsonaddkey number_of_cores "$NUMBER_OF_CORES")"

# Emit new state
echo "$NEW_STATE" >&3
```

## Tips on debugging shell scripts 

By default, stdout and stderr from your scripts are not shown. If you're hacking about trial-and-erroring like I tend to do, then you'll get errors and want to embed print statements everywhere so you can find your way.

Terraform makes its providers notoriously difficult to debug, and the shell provider is not immune. The following tips will help you:
* Running `TF_LOG=DEBUG terraform apply` will show you stdout and stderr from your shell scripts (separately), albeit sandwiched between 10,000 lines of other output.
* Use the `-target` argument to only run apply on the specific `shell_script` resource you want to debug.
* The shell provider has a concept of a "stack" (as in a call stack), where (for example) the `create` handler will call the `read` handler if your `create` script doesn't emit any state. Looking for the word "stack" in Terraform's output can help you find the shell provider-related bits.
* Depending on where you're running Terraform, you may be able to write to local files and pick up debugging output that way.
* The `working_directory` property on a `shell_script` resource should almost always be `.`.

## Tips on packaging the provider

As soon as you use a community provider such as the shell provider, you introduce the problem of making sure that the provider is present on whichever host you run Terraform on. Two ways you can do this reliably are to use Terraform Enterprise or to run Terraform in a Docker container (packaging the provider along with any command-line tools your shell scripts need to execute).

To get started quickly, run the following (with $PLATFORM set appropriately):
```sh
export PLATFORM=darwin_amd64
export PROVIDER_VERSION=0.1.3
curl -L "https://github.com/scottwinkler/terraform-provider-shell/releases/download/v${PROVIDER_VERSION}/terraform-provider-shell_v${PROVIDER_VERSION}.${PLATFORM}" > ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-shell_v${PROVIDER_VERSION}
chmod +x ~/.terraform.d/plugins/${PLATFORM}/terraform-provider-shell_v${PROVIDER_VERSION}
```

## PowerShell and file descriptor 3

PowerShell has its own concept of inputs and outputs which does not align with the Unix model of numbered file descriptors. It also does not get along well with Unix pipes! Fortunately, after much trial and error, the following snippet appears to reliably output state (on macOS and Linux) in a way that the shell provider can read in:

```
$new_state = @{ foo = "bar";
                qux = "quz" } | ConvertTo-Json
$new_state_bytes = [System.Text.Encoding]::UTF8.GetBytes($new_state)
$fs = [System.IO.File]::OpenWrite("/dev/fd/3")
$fs.Write($new_state_bytes, 0, $new_state_bytes.length)
$fs.Flush()
```

One you have conquered this hurdle, you may find that you enjoy PowerShell's object-oriented approach and easy access to the broad capabilities of the .NET ecosystem. Ha ha just kidding... unless...?
