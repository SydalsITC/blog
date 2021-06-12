
# k8s and helm cheat sheet

<img src="img/postit_640px.jpg" width="100" align="right"/>Here's some of the commands I usually place in my ```.bash_aliases``` for making life easier with kubernetes and helm.

## Kubernetes

```
# kubectl has too many chars
alias kc='kubectl'

# sometimes I need the same information from every namespace
alias kca='f(){ kubectl "$@" --all-namespaces ;  unset -f f; }; f'

# change namespace on vanilla k8s
alias ns='f(){ kubectl config set-context $(kubectl config current-context) --namespace $1 ;  unset -f f; }; f'
```

## Helm

Helm stores the yaml files which result from the chart in a secret with a name like sh.helm.release.v1.MYAPP.v1 in the target namespace. The content is compressed and double base64 encoded. The following commands extract the full json or the resulting yaml, respectively, from helm chart.

```
#==== helm2json ====
# - parameters: 1) chart name 2) version; see name and current version with helm list
# - extracts the charts meta data and base64 encoded raw data as readable json
function helm2json
{
  oc get secrets sh.helm.release.v1.$1.v$2 -o yaml | grep "  release:" | awk '{print $2;}' | base64 -d | base64 -d | zcat  | python -m json.tool
}

#==== helm2yaml ====
# - parameters: 1) chart name 2) version; see name and current version with helm list
# - extracts all resulting deployment descrption as one yaml file
function helm2yaml
{
  oc get secret  sh.helm.release.v1.$1.v$2 -o yaml | grep "  release:" | awk '{print $2;}' | base64 -d  | base64 -d  | zcat | python -m json.tool | grep "manifest" | sed 's/\\n/\n/g'    | sed 's/\\"/\"/g' | sed  '1d;$d'
}
```

## Misc
Linting Yaml or Json with a third party like [yaml|json]lint.com leaves always some concern regarding data safety. So  I wrote my own linter app for yaml, json and xml and use it from command line with curl. If you'd like to use it, feel free to run your own copy (it's dockered). This keeps you on the safe side and the load on my web service low.

```
# linting documents with lint trilogy; run an own instance if you like, it's dockered
# - result is given in json; change last part of url to csv if you need the result tabular
function yamllint { curl -X POST -d "data=$(cat $1)" https://www.lint-trilogy.com/lint/yaml/json ; }
function jsonlint { curl -X POST -d "data=$(cat $1)" https://www.lint-trilogy.com/lint/json/json ; }
function  xmllint { curl -X POST -d "data=$(cat $1)" https://www.lint-trilogy.com/lint/xml/json  ; }

# always handy if working with json files - this formats it readable:
alias prettyjson='python3 -m json.tool'
```

