#!/usr/bin/env sh

opts=$(getopt --longoptions "with-kubeconform" --options "with-kubeconform" --name "$(basename "$0")" -- "$@")

with_kubeconform="unset"

while [[ $# -gt 0 ]]; do
    case "$1" in
    --with-kubeconform)
        with_kubeconform=1
        directory="$2"
        shift
        ;;
    *)
        directory="$1"
        shift
        break
        ;;
    esac
done

if [ "$with_kubeconform" = "1" ]; then
    kustomize build "$directory" | kubeconform --summary $@
else
    kustomize build "$directory" $@
fi
