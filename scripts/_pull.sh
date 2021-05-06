#!/bin/bash

echo "pulling project"
cd ~/project/
git pull
git log -n 4
