# j2cfn-boiler

> CloudFormation management pattern using Jinja2

## Requirements

* awscli and credentials
* make
* python (python3 recommended)
* nodejs (stable:v8 recommended)

## Directory structure

```
.
├── .cache                # put temporary files for diff
├── bin                   # put a python script to use jinja
├── dist                  # put files bundled by jinja
│   ├── ecr               # `privileged-access` and `ecr` are example dir
│   └── privileged-access
└── src                   # write cfn templates by yaml
    ├── ecr
    └── privileged-access
```

## Usage

### 1. Setup

Install cfn-lint and jinja2.

```
make setup
```

### 2. Edit templates and bundle

At first, make a directory and edit template codes.

```
mkdir ./src/$YOUR_STACK_NAME
$EDITOR ./src/$YOUR_STACK_NAME/root.yaml.j2
```

Note: `$YOUR_STACK_NAME` used to call make, as the target argument.

Well, bundle that into one template which putting `./dist/$YOUR_STACK_NAME`.

```
make bundle Target=privileged-access env=development
```

You can embedding variables by matching arguments at `make bundle`, with the template embedded variable of jinja.

### 3. Lint

Also you lint it by `aws cloudformation validate-template` and `cfn-lint`.

```
make lint Target=privileged-access
```

### 4. Execute

#### Create stack

```
make create/stack Target=privileged-access
make wait/stack-create Target=privileged-access
```

#### Create and apply your change set

```
make create/change-set Target=privileged-access
make wait/change-set-create Target=privileged-access
make exec/change-set Target=privileged-access
make wait/stack-update Target=privileged-access
```

#### Waiter failed

Get the notification from stderr when failed to create or update.

```
Waiter StackUpdateComplete failed: Waiter encountered a terminal failure state
```



## Maintainer

[@ktrysmt](https://twitter.com/ktrysmt)
