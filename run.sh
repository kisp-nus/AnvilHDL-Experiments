#!/bin/bash


set -e

rebuild=false
while getopts "r" opt; do
  case $opt in
    r)
      rebuild=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ "$(docker images -q anvil-experiments 2> /dev/null)" == "" ]] || [[ "$rebuild" = true ]]; then
  echo "Building Docker image : anvil-experiments"
  docker build -t anvil-experiments .
else
  echo "Docker image anvil-experiments already exists... skipping build"
  mkdir -p out
  docker run -it -v $(pwd)/out:/workspace/Anvil-Experiments/out anvil-experiments
fi
