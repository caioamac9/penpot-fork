#!/usr/bin/env bash
# Analisa o penpot-fork no SonarQube local (http://localhost:9000).
# Uso (Linux/macOS/Git Bash): SONAR_TOKEN=<token> sonarqube/analisar.sh
set -euo pipefail
: "${SONAR_TOKEN:?defina SONAR_TOKEN com um token gerado no SonarQube}"
SONAR_HOST_URL="${SONAR_HOST_URL:-http://host.docker.internal:9000}"

cd "$(dirname "$0")/.."
ROOT="$(pwd -W 2>/dev/null || pwd)"
JAR=$(ls sonarqube/plugins/sonar-clojure-plugin-*.jar)
export MSYS_NO_PATHCONV=1
mkdir -p target

# 1) Hooks de segurança do plugin para o clj-kondo (vêm dentro do jar)
rm -rf .clj-kondo/imports/net.typemark
unzip -qo "$JAR" 'clj-kondo.exports/net.typemark/*' -d target/plugin
mkdir -p .clj-kondo/imports
cp -r target/plugin/clj-kondo.exports/net.typemark .clj-kondo/imports/

# 2) clj-kondo -> target/clj-kondo.json (sai com código != 0 quando há findings).
#    Sem :analysis: a navegação de símbolos está desligada e o JSON cai de
#    ~190 MB para poucos KB, poupando memória do scanner.
docker run --rm -v "$ROOT:/src" -w /src cljkondo/clj-kondo \
  clj-kondo --parallel --lint frontend/src backend/src common/src exporter/src \
  --config '{:output {:format :json}}' \
  > target/clj-kondo.json || true

# 3) sonar-scanner (lê sonar-project.properties)
docker run --rm --add-host=host.docker.internal:host-gateway \
  -e SONAR_HOST_URL="$SONAR_HOST_URL" -e SONAR_TOKEN="$SONAR_TOKEN" \
  -e SONAR_SCANNER_JAVA_OPTS=-Xmx3g -v "$ROOT:/usr/src" \
  sonarsource/sonar-scanner-cli -Dsonar.javascript.node.maxspace=2048
