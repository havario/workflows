#!/bin/bash

curl -Ls https://repo1.maven.org/maven2/org/codehaus/mojo/exec-maven-plugin/maven-metadata.xml | grep latest | sed 's/.*<latest>\(.*\)<\/latest>.*/\1/'
