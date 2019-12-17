#!/usr/bin/env bash

git submodule update --init
rm reveal.js/index.html
ln -s $PWD/presentation.html reveal.js/index.html
ln -s $PWD/images reveal.js/
pushd reveal.js
npm i
popd

pom="spring-petclinic/pom.xml"
if ! grep 'jib-maven-plugin' "$pom" > /dev/null; then
  echo ' ⚙️ Adding jib to pom.xml...'
  gsed -i '/<\/plugins>/e cat jib.xml' "$pom"
  echo ' ✅ Done !'
else
  echo ' ✅ Jib already in pom.xml, ignoring.'
fi
