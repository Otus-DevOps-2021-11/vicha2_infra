#!/bin/bash
echo '=====Install Ruby====='
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential apt-transport-https ca-certificates
ruby -v
bundler -v
