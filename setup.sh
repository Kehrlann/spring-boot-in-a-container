#!/usr/bin/env bash

git submodule update --init
rm reveal.js/index.html
ln -s $PWD/presentation.html reveal.js/index.html
ln -s $PWD/images reveal.js/
pushd reveal.js
npm i
popd
