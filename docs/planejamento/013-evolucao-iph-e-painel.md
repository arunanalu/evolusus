# 013 — Evolução do IPH e do painel analítico

**Status:** roteiro de evolução.  
**Base atual:** exportação Gold RJ/2025 e painel no Looker Studio.

## Objetivo

Evoluir a solução de forma incremental, preservando a rastreabilidade dos dados, a comparabilidade mensal e a capacidade de demonstrar resultados no painel analítico.

## Próximas entregas

| Etapa | Entrega | Resultado esperado |
|---|---|---|
| 1. Cobertura Gold | grade município × competência e status de cobertura | visão mensal completa dos 92 municípios do RJ |
| 2. Métricas de capacidade | leitos, UTI e profissionais FTE | leitura ampliada da capacidade instalada |
| 3. Métricas de utilização | internações, permanência, uso estimado dos leitos e sazonalidade | acompanhamento da demanda e da pressão assistencial |
| 4. Fluxos assistenciais | matriz residência → atendimento | análise de entrada, saída e dependência intermunicipal |
| 5. Versão do IPH | componentes, normalização, pesos e versão da fórmula | cálculo rastreável por município e mês |
| 6. Desfechos | mortalidade SIM e indicadores de qualidade | avaliação externa do comportamento do índice |
| 7. Painel | páginas temáticas, filtros, mapa e documentação visual | navegação clara para análise e apresentação |

## Evolução dos dados

### Cobertura e qualidade

- manter a dimensão com os 92 municípios do RJ e as 12 competências mensais;
- registrar situação de cobertura para cada município, mês e fonte;
- manter chaves de fonte, hash, data de extração, versão de layout e quantidade de registros;
- registrar regras de tratamento de valores ausentes, denominadores baixos e observações atípicas;
- recalcular indicadores anuais a partir dos numeradores e denominadores mensais.

### Indicadores

- calcular leitos SUS, leitos de UTI e profissionais FTE por habitante;
- calcular internações por habitante e por leito;
- calcular dias de permanência por leito-dia disponível;
- acompanhar permanência média, óbitos hospitalares e valor das internações;
- criar indicadores de fluxo de pacientes entre residência e município de atendimento.

## Evolução metodológica do IPH

1. Definir e versionar o dicionário de componentes do índice.
2. Padronizar a direção dos componentes: valor maior deve representar maior pressão.
3. Aplicar tratamento documentado para extremos e denominadores reduzidos.
4. Comparar normalizações e conjuntos de pesos.
5. Produzir análises de sensibilidade por município, mês e componente.
6. Publicar a fórmula com identificador de versão e vintage das fontes.
7. Gerar uma consolidação anual a partir das medidas mensais.

## Evolução do painel

### Página 1 — Visão geral

- filtros de ano, mês e município;
- IPH médio mensal;
- ranking municipal;
- cards de leitos, internações e uso estimado dos leitos.

### Página 2 — Capacidade e utilização

- série temporal de leitos e internações;
- dispersão entre oferta de leitos e uso estimado;
- comparação por porte populacional;
- tabela detalhada por município e competência.

### Página 3 — Fluxos assistenciais

- municípios de residência e atendimento;
- entradas e saídas líquidas de pacientes;
- principais origens e destinos;
- leitura da rede regional.

### Página 4 — Metodologia e dados

- definição dos indicadores;
- fórmula e versão do IPH;
- fontes, período e atualização;
- glossário em linguagem simples;
- indicadores de cobertura e qualidade.

## Sequência recomendada de execução

1. Consolidar a grade mensal dos municípios e registrar cobertura.
2. Versionar os campos e componentes que alimentam o IPH.
3. Atualizar a tabela Gold com as medidas de capacidade, utilização e fluxo.
4. Recalcular o IPH por competência e gerar a consolidação anual.
5. Atualizar a fonte de dados do Looker Studio.
6. Expandir o painel por páginas e revisar textos, títulos, filtros e tabelas.
7. Registrar a avaliação de disponibilidade, custo e reprocessamento antes da expansão temporal para 2023–2025.

## Critérios de conclusão de cada evolução

- script ou transformação versionada;
- fonte e período identificados;
- regra de cálculo documentada;
- teste de consistência executado;
- atualização refletida no dicionário de dados;
- visual correspondente revisado no painel.
