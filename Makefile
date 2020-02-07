.DEFAULT_GOAL := help
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# env
Target=
StackName=$(shell echo "${Target}" | perl -pe 's%/%-%g')
ChangeSetName=change-set-$(StackName)
# filename
BundleFile=bundle.yaml
RootFile=root.yaml.j2
ParamCreateStackFile=param.create-stack.json
ParamCreateChangeSetFile=param.create-change-set.json

setup: ## install dependencies w/ python. ## -
	@if [ "" != `which pip3` ]; then pip3 install -r ./requirements.txt; \
		elif [ "" != `which pip` ]; then pip install -r ./requirements.txt; \
		else echo "Please install python3."; fi

bundle: init ## bundle partial templates into one ## make bundle Target=privileged-access
	@if [ ! -f ./src/${Target}/root.yaml.j2 ]; then echo "it is not found that './src/${Target}/root.yaml.j2'." && exit 1; fi
	@if [ "" != `which python3` ]; then OutputFile=$(BundleFile) RootFile=$(RootFile) python3 ./bin/bundle.py $(MAKEFLAGS); \
		elif [ "" != `which python` ]; then OutputFile=$(BundleFile) RootFile=$(RootFile) python ./bin/bundle.py $(MAKEFLAGS); \
		else echo "Please install python3."; fi

lint: init ## lint the template ## make lint Target=privileged-access
	aws cloudformation validate-template --template-body file://dist/${Target}/$(BundleFile)
	cfn-lint ./dist/${Target}/$(BundleFile)

create/stack: init ## call create-stack ## make create/stack Target=privileged-access
	aws cloudformation create-stack \
		--stack-name ${StackName} \
		--cli-input-json file://src/${Target}/$(ParamCreateStackFile) \
		--template-body file://dist/${Target}/$(BundleFile)

create/change-set: init ## call create-change-set ## make create/change-set Target=privileged-access
	aws cloudformation create-change-set \
		--stack-name ${StackName} \
		--change-set-name ${ChangeSetName} \
		--cli-input-json file://src/${Target}/$(ParamCreateChangeSetFile) \
		--template-body file://dist/${Target}/$(BundleFile)

wait/stack-create: init ## call wait stack-create-complete ## make wait/stack-create Target=privileged-access
	aws cloudformation wait stack-create-complete \
		--stack-name ${StackName}

wait/stack-update: init ## call wait stack-update-complete ## make wait/stack-update Target=privileged-access
	aws cloudformation wait stack-update-complete \
		--stack-name ${StackName}

wait/change-set-create: init ## call wait change-set-create-complete ## make wait/change-set-create Target=privileged-access
	aws cloudformation wait change-set-create-complete \
		--change-set-name ${ChangeSetName} \
		--stack-name ${StackName}

desc/change-set: init ## call describe-change-set ## make desc/change-set Target=privileged-access
	aws cloudformation describe-change-set \
		--change-set-name ${ChangeSetName} \
		--stack-name ${StackName}

exec/change-set: init ## call execute-change-set ## make exec/change-set Target=privileged-access
	aws cloudformation execute-change-set \
		--change-set-name ${ChangeSetName} \
		--stack-name ${StackName}

diff/change-set: init ## check stacks differences ## make diff/change-set Target=privileged-access
	@aws cloudformation get-template --stack-name ${StackName} --output text --query "TemplateBody" > .cache/a.diff
	@aws cloudformation get-template --stack-name ${StackName} --change-set-name ${ChangeSetName} --output text --query "TemplateBody" > .cache/b.diff
	@diff -U 3 .cache/{a,b}.diff || :

init:
	@if [ "" = "${Target}" ]; then echo 'The "Target" environment is empty. ex) `make lint Target=privileged-access` ' && exit 1; fi

help: ## print this message
	@echo "j2cfn-boiler operations by make."
	@echo ""
	@echo "Usage: make SUB_COMMAND Target=YOUR_STACK [env=production...etc, arg1=val1...etc]"
	@echo ""
	@echo "Command list:"
	@echo ""
	@printf "\033[36m%-30s\033[0m %-50s %s\n" "[Sub command]" "[Description]" "[Example]"
	@grep -E '^[/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | perl -pe 's%^([/a-zA-Z_-]+):.*?(##)%$$1 $$2%' | awk -F " *?## *?" '{printf "\033[36m%-30s\033[0m %-50s %s\n", $$1, $$2, $$3}'

.PHONY: setup init bundle lint create/stack create/change-set wait/stack-create wait/stack-update wait/change-set-create desc/change-set exec/change-set diff/change-set help

