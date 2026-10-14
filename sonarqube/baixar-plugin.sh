#!/usr/bin/env bash
# Baixa o plugin sonar-clojure (typmk) para sonarqube/plugins e confere o sha256.
set -euo pipefail
VERSION=0.1.4
SHA256=b4a53773c23601933a7b70e5219a455e5da23a0ee4f41fa375c0bcec3ac9f641
JAR="sonar-clojure-plugin-$VERSION.jar"

cd "$(dirname "$0")/plugins"
curl -fsSLo "$JAR" "https://github.com/typmk/sonar-clojure/releases/download/v$VERSION/$JAR"
echo "$SHA256  $JAR" | sha256sum -c -
