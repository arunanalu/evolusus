# 008 — Extração do perfil municipal IBGE para RJ/2025

## Objetivo

Gerar um CSV complementar, no grão município, para os 92 municípios do Rio de Janeiro. A coluna de população é a estimativa oficial de 2025; sexo, idade, cor ou raça e renda preservam o último recorte municipal disponível no IBGE, o Censo Demográfico 2022.

## Contrato de fontes

| Medida | SIDRA | Referência |
|---|---:|---:|
| População estimada | 6579 / variável 9324 | 2025 |
| Sexo, idade e cor ou raça | 9606 / variável 93 | 2022 |
| Renda domiciliar per capita média e mediana | 10295 / variáveis 13431 e 13534 | 2022 |

Não há estimativa municipal anual de 2025 publicada pelo IBGE para sexo, idade, cor ou raça ou renda. O script não projeta esses atributos: nomeia cada coluna com o ano de referência para impedir mistura silenciosa de vintages.

## Execução e aceite

`python scripts/extract_ibge_perfil_rj.py --year 2025`

- gera `data/gold/ibge/rj/2025/ibge_perfil_municipal_rj_2025.csv`;
- preserva as respostas JSON e um manifesto com URL, SHA-256, data UTC, período e total de registros;
- interrompe caso não haja exatamente 92 códigos municipais únicos ou alguma métrica obrigatória;
- é idempotente: uma nova execução cria a mesma versão lógica e atualiza os artefatos somente de forma atômica.

## Riscos e reversão

O perfil de 2022 não deve ser interpretado como medida observada em 2025. Para reprocessar após atualização do IBGE, executar novamente o comando e manter o manifesto anterior fora do descarte. O processamento é local, sem custo OCI.
