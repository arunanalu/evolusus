# 012 — Visualização do IPH no Looker Studio

**Status:** roteiro de demonstração com rótulo explícito `PRELIMINAR`.
**Fonte inicial:** `data/gold_table/export.csv`.

## Objetivo

Construir um painel interativo a partir da exportação Gold atual. O painel é demonstrativo: a Gold cobre 87 dos 92 municípios do RJ e o IPH ainda não foi validado como índice científico final.

## Roteiro de criação

1. Criar uma fonte de dados no Looker Studio com o conector **CSV file upload** e selecionar `data/gold_table/export.csv`.
2. Configurar `CODIGO_MUNICIPIO_7D` como texto; `ANO_COMPETENCIA` e `MES_COMPETENCIA` como número; medidas, taxas e IPH como número decimal ou inteiro conforme a unidade.
3. Criar `DATA_COMPETENCIA` como dimensão de data. Se `DATE(ANO_COMPETENCIA, MES_COMPETENCIA, 1)` não for suportada pela fonte, usar uma expressão `PARSE_DATE` que construa ano, mês e dia a partir dos campos numéricos.
4. Criar controles de filtro para Ano, Mês e Município. O mês deve usar uma dimensão de exibição ordenável, por exemplo `01 - Janeiro` até `12 - Dezembro`.
5. Criar os visuais abaixo:

   | Visual | Configuração |
   |---|---|
   | Série temporal | `DATA_COMPETENCIA` no eixo X; média de `INDICE_PRESSAO_HOSPITALAR` no eixo Y |
   | Ranking | Município como dimensão; média de IPH como métrica; ordem decrescente; sem categoria agregada `Outros` |
   | Dispersão | Município como dimensão; média de leitos SUS por mil habitantes no eixo X; média de uso estimado dos leitos no eixo Y; soma de internações como tamanho |
   | Tabela detalhada | Município e competência como dimensões; leitos e internações como soma; indicadores de razão, taxa e IPH como média |

6. Renomear os campos exibidos com linguagem clara:

   | Campo técnico | Nome exibido |
   |---|---|
   | `TOTAL_LEITOS_SUS` | Leitos SUS disponíveis |
   | `TOTAL_INTERNACOES` | Internações no mês |
   | `LEITOS_POR_MIL_HAB` | Leitos SUS por mil habitantes |
   | `TAXA_OCUPACAO_PROXY_PCT` | Uso estimado dos leitos (%) |
   | `INDICE_PRESSAO_HOSPITALAR` | IPH |

## Avisos obrigatórios no painel

Exibir o seguinte texto em local visível:

> **Dado preliminar:** a Gold atual cobre 87 dos 92 municípios do RJ. O IPH ainda não foi validado e não deve ser interpretado como diagnóstico, causalidade ou ranking definitivo.

Usar a seguinte explicação para o indicador de utilização:

> **Uso estimado dos leitos:** estimativa baseada nos dias de permanência das internações e na quantidade de leitos SUS disponíveis no mês. Não representa ocupação observada diretamente em tempo real.

## Faixas qualitativas exclusivamente demonstrativas

Aplicar as faixas obtidas pelos tercis dos 1.032 registros com IPH maior que zero no CSV atual:

| IPH | Interpretação demonstrativa |
|---:|---|
| até 18,66 | Baixa pressão relativa |
| 18,67 a 26,99 | Média pressão relativa |
| 27,00 ou mais | Alta pressão relativa |

O painel deve declarar que essas faixas são exploratórias, dependem da distribuição da amostra de 2025 e não são limites clínicos, regulatórios ou definitivos.

## Critérios de aceite

- CSV lido em UTF-8 e códigos municipais preservados como texto;
- filtros alteram todos os visuais relevantes;
- gráficos de dispersão usam médias para as taxas mensais, sem soma indevida de indicadores;
- nenhum visual trata ausência de cobertura como IPH zero;
- período, aviso preliminar e limitações ficam visíveis;
- pelo menos três valores do painel são conferidos contra o CSV.
