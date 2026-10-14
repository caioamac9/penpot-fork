# SonarQube Server + sonar-clojure

Análise local do penpot-fork com SonarQube Community em Docker e o plugin
[typmk/sonar-clojure](https://github.com/typmk/sonar-clojure) (suporta `deps.edn`).

Requisitos: Docker e um shell bash (Linux, macOS ou Git Bash no Windows).

## 1. Subir o servidor

```bash
sonarqube/baixar-plugin.sh          # baixa o jar e confere o sha256
docker compose -f sonarqube/docker-compose.yml up -d
```

Abra http://localhost:9000, entre com `admin` / `admin` e troque a senha.
Gere um token em *My Account > Security* (tipo *Global Analysis Token*).

## 2. Analisar

```bash
SONAR_TOKEN=<token> sonarqube/analisar.sh
```

O script instala os hooks de segurança do plugin no clj-kondo, gera
`target/clj-kondo.json` e roda o sonar-scanner com `sonar-project.properties`.
O resultado fica em http://localhost:9000/dashboard?id=penpot-fork.

## Limitações conhecidas

- O plugin 0.1.4 quebra ao montar a tabela de símbolos de
  `backend/src/app/rpc/commands/audit.clj`, então a navegação de símbolos e o
  taint entre funções ficam desligados (`sonar.clojure.kondo.analysisPaths`).
- Sem relatórios de cobertura (cloverage) e de testes (kaocha), a métrica de
  completude da análise fica em 25%.
