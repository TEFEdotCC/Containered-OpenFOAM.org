#!/bin/bash

echo "SHELL: $SHELL"
echo "PWD: $PWD"
echo "FOAM_SRC: $FOAM_SRC"

printenv

pisoFoam -help

