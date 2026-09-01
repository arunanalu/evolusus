# 011 — Auditoria da exportação Gold do IPH: RJ/2025

**Status:** diagnóstico executado; correções pendentes de aprovação e implementação.  
**Objeto auditado:** `data/gold_table/export.csv`, exportado em 31/08/2026.  
**Escopo:** avaliação estrutural e de coerência aritmética. Não constitui validação epidemiológica, causal ou estatística do IPH.

## Resultado executivo

A exportação demonstra que a aquisição, agregação mensal e os indicadores simples foram operacionalizados com coerência. Ela é apropriada como **resultado de ETL e protótipo de painel**. Não deve ainda ser apresentada como versão validada do Índice de Pressão Hospitalar (IPH), pois há lacunas de cobertura, uma regra temporal incorreta na proxy de ocupação e ausência de metadados necessários para reproduzir a fórmula.

## Evidências verificadas

| Verificação | Resultado | Avaliação |
|---|---:|---|
| Registros | 1.044 | Sem duplicidade na chave município × ano × mês |
| Cobertura temporal | 12 competências de 2025 | Completa para os 87 municípios presentes |
| Cobertura municipal | 87 de 92 municípios do RJ | Incompleta; o critério de aceite requer 92 ou ausência justificada |
| `LEITOS_POR_MIL_HAB` | confere com `TOTAL_LEITOS_SUS / POPULACAO_TOTAL × 1.000` | Aprovado, considerando arredondamento a duas casas |
| `INTERNACOES_POR_MIL_HAB` | confere com `TOTAL_INTERNACOES / POPULACAO_TOTAL × 1.000` | Aprovado, considerando arredondamento a duas casas |
| `TAXA_MORTALIDADE_HOSP_PCT` | confere com `TOTAL_OBITOS_HOSPITALARES / TOTAL_INTERNACOES × 100` | Aprovado; nulo quando não há internações |
| `TAXA_OCUPACAO_PROXY_PCT` | confere com `TOTAL_DIAS_PERMANENCIA / (TOTAL_LEITOS_SUS × 30) × 100` | Regra de 30 dias deve ser corrigida |

Os cinco municípios ausentes da Gold são: Cardoso Moreira (`3301157`), Iguaba Grande (`3301876`), Macuco (`3302452`), Paty do Alferes (`3303856`) e São José de Ubá (`3305133`). Eles devem permanecer na dimensão municipal e produzir linha mensal com estado de cobertura explicitado, mesmo quando não houver capacidade ou utilização local.

## Achados e tratamento necessário

### P0 — bloqueadores de uma versão científica/publicável

1. **Cobertura municipal incompleta.** A chave de integração provavelmente exclui municípios sem correspondência em uma fonte. Substituir junções eliminatórias por `DIM_MUNICIPIO × DIM_TEMPO` como grade-base, com `LEFT JOIN` para as medidas e coluna de situação de cobertura.
2. **Proxy de ocupação usa 30 dias fixos.** Aplicar a fórmula acordada no projeto:

   `OCUPACAO_PROXY = SOMA(DIAS_PERM_SIH) / SOMA(LEITOS_SUS_NO_MES × DIAS_DO_MES)`

   Isso reduz o denominador indevido em fevereiro e evita superestimação nos meses de 31 dias. Quatro observações excedem 100%; elas devem ser preservadas como proxy e receber nota metodológica, não truncadas silenciosamente.
3. **Município sem rede não pode receber automaticamente IPH zero.** Italva (`3302056`) tem 0 leitos e 0 internações nos 12 meses, consequentemente IPH 0. O valor deve ser `NULL`/não comparável ou acompanhado de uma categoria como `SEM_CAPACIDADE_LOCAL`, após analisar os fluxos residência → atendimento. Zero não significa baixa pressão.
4. **Fórmula não auditável.** A Gold não traz `VERSAO_IPH`, `VINTAGE_DADOS`, parâmetros de normalização, componentes normalizados, pesos, perspectiva geográfica ou regra para valores ausentes. Sem esses itens não é possível reproduzir ou validar o IPH final.

### P1 — completar antes de validar o índice

- Declarar explicitamente a perspectiva como `SERVICO` ou `POPULACAO`. Pelo uso de internações no município de atendimento, a hipótese é perspectiva de serviço, mas isso deve ser confirmado na transformação e no dicionário.
- Exportar os componentes de capacidade/escassez, intensidade de utilização e tensão territorial, além do IPH. A tabela atual contém leitos e utilização, mas não UTI, profissionais FTE ou fluxo intermunicipal.
- Não usar a mortalidade hospitalar para compor o IPH principal. Ela pode ser mantida como desfecho distinto; a validação externa requer SIM com versão e situação de publicação registradas.
- Investigar as colunas de raça/cor, todas zeradas, e a diferença entre população total e a soma de homens e mulheres. Não usar esses campos para ajuste até reconciliação com a fonte IBGE.

## Contrato mínimo da próxima Gold

Além das medidas-base já presentes, a tabela mensal deverá conter:

`COD_MUNICIPIO`, `ANO_COMPETENCIA`, `MES_COMPETENCIA`, `PERSPECTIVA_GEOGRAFICA`, `STATUS_COBERTURA`, `VERSAO_IPH`, `VINTAGE_DADOS`, `VERSAO_FONTE_CNES`, `VERSAO_FONTE_SIH`, `METODO_NORMALIZACAO`, `COMPONENTE_*_NORMALIZADO`, `PESO_*`, `IPH`, `FLAG_DENOMINADOR_BAIXO` e `OBSERVACAO_QUALIDADE`.

A consolidação anual deve ser recalculada pelos numeradores e denominadores mensais; não deve ser a média aritmética dos IPHs mensais.

## Critérios de aceite para reexportação

- 1.104 linhas esperadas (92 municípios × 12 meses), ou justificativa rastreável por linha ausente;
- nenhuma duplicidade em município × competência × perspectiva × versão × vintage;
- ocupação calculada com dias reais do mês;
- município sem rede/dado classificado sem induzir IPH baixo artificial;
- fórmula e componentes do IPH reproduzíveis e versionados;
- reconciliação documentada de uma amostra de totais CNES e SIH;
- teste de sensibilidade dos pesos, normalização e tratamento de ausências antes de qualquer ranking público.

## Roteiro de evolução do IPH e do painel

### Próximas entregas

| Etapa | Entrega | Resultado esperado |
|---|---|---|
| 1. Cobertura Gold | grade município × competência e status de cobertura | visão mensal completa dos 92 municípios do RJ |
| 2. Métricas de capacidade | leitos, UTI e profissionais FTE | leitura ampliada da capacidade instalada |
| 3. Métricas de utilização | internações, permanência, uso estimado dos leitos e sazonalidade | acompanhamento da demanda e da pressão assistencial |
| 4. Fluxos assistenciais | matriz residência → atendimento | análise de entrada, saída e dependência intermunicipal |
| 5. Versão do IPH | componentes, normalização, pesos e versão da fórmula | cálculo rastreável por município e mês |
| 6. Desfechos | mortalidade SIM e indicadores de qualidade | avaliação externa do comportamento do índice |
| 7. Painel | páginas temáticas, filtros, mapa e documentação visual | navegação clara para análise e apresentação |

### Dados e indicadores

- manter a dimensão com os 92 municípios do RJ e as 12 competências mensais;
- registrar situação de cobertura para cada município, mês e fonte;
- manter chaves de fonte, hash, data de extração, versão de layout e quantidade de registros;
- registrar regras de tratamento de valores ausentes, denominadores baixos e observações atípicas;
- recalcular indicadores anuais a partir dos numeradores e denominadores mensais;
- calcular leitos SUS, leitos de UTI e profissionais FTE por habitante;
- calcular internações por habitante e por leito, dias de permanência por leito-dia disponível e permanência média;
- criar indicadores de fluxo de pacientes entre residência e município de atendimento.

### Método do IPH

1. Definir e versionar o dicionário de componentes do índice.
2. Padronizar a direção dos componentes: valor maior deve representar maior pressão.
3. Aplicar tratamento documentado para extremos e denominadores reduzidos.
4. Comparar normalizações e conjuntos de pesos.
5. Produzir análises de sensibilidade por município, mês e componente.
6. Publicar a fórmula com identificador de versão e vintage das fontes.
7. Gerar uma consolidação anual a partir das medidas mensais.

### Painel analítico

| Página | Conteúdo |
|---|---|
| Visão geral | filtros de ano, mês e município; IPH médio mensal; ranking; cards de leitos, internações e uso estimado |
| Capacidade e utilização | séries temporais, dispersão entre oferta e uso estimado, comparação por porte e tabela detalhada |
| Fluxos assistenciais | residência e atendimento, entradas e saídas líquidas, principais origens e destinos |
| Metodologia e dados | definição dos indicadores, fórmula e versão do IPH, fontes, período, glossário e cobertura |

### Sequência recomendada

1. Consolidar a grade mensal dos municípios e registrar cobertura.
2. Versionar os campos e componentes que alimentam o IPH.
3. Atualizar a tabela Gold com as medidas de capacidade, utilização e fluxo.
4. Recalcular o IPH por competência e gerar a consolidação anual.
5. Atualizar a fonte de dados do Looker Studio.
6. Expandir o painel por páginas e revisar textos, títulos, filtros e tabelas.
7. Registrar a avaliação de disponibilidade, custo e reprocessamento antes da expansão temporal para 2023–2025.

### Critérios de conclusão de cada evolução

- script ou transformação versionada;
- fonte e período identificados;
- regra de cálculo documentada;
- teste de consistência executado;
- atualização refletida no dicionário de dados;
- visual correspondente revisado no painel.
