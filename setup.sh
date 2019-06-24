#!/usr/bin/env bash

git clone https://github.com/spring-projects/spring-petclinic.git --depth=1
git submodule update --init
rm reveal.js/index.html
ln -s $PWD/presentation.html reveal.js/index.html
ln -s $PWD/images reveal.js/
