# infrastructure


## terraform

A utility to generate documentation from Terraform modules in various output formats.

Read the [User Guide](./docs/USER_GUIDE.md) and [Formats Guide](./docs/FORMATS_GUIDE.md) for detailed documentation.

## Installation

The latest version can be installed using `go get`:

``` bash
GO111MODULE="on" go get github.com/segmentio/terraform-docs@v0.9.1
```

If you are a Mac OS X user, you can use [Homebrew](https://brew.sh):

``` bash
brew install terraform
```

Windows users can install using [Chocolatey](https://www.chocolatey.org):

``` bash
choco install terraform
```

## Plan and applying the terraform

After installation plan the terraform 

``` bash
terraform plan 
```

To applay the planned terraform apply the terraform

``` bash
terraform apply
```

