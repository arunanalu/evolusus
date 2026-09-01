# 011 — Auditoria da exportação Gold do IPH: RJ/2025

**Status:** diagnóstico executado; correções pendentes de aprovação e implementação.  
**Objeto auditado:** `data/gold_table/export.csv`, exportado em 31/08/2026.  
**Escopo:** avaliação estrutural e de coerência aritmética. Não constitui validação epidemiológica, causal ou estatística do IPH.

## Resultado executivo

A exportação demonstra que a aquisição, agregação mensal e os indicadores simples foram operacionalizados com coerência. Ela é apropriada como **resultado preliminar de ETL e protótipo de painel**. Não deve ainda ser apresentada como versão validada do Índice de Pressão Hospitalar (IPH), pois há lacunas de cobertura, uma regra temporal incorreta na proxy de ocupação e ausência de metadados necessários para reproduzir a fórmula.

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
- Não usar a mortalidade hospitalar para compor o IPH principal. Ela pode ser mantida como desfecho distinto; a validação externa requer SIM, com vintage e marca `PRELIMINAR` ou `FINAL`.
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

