# 010 — Correção da carga Silver de CNES PF

## Evidência

`ERROR_SUMMARY_CNES_PF_DATA_2_20260826.CSV` aponta inferência `NUMBER` incompatível com valores alfanuméricos em `CBO` (70.729 ocorrências), `CBOUNICO` (62.869) e `CONSELHO` (24). Exemplos: `2231G1`, `3135D2`, `MG` e `BA`.

## Decisão

Os três campos são códigos e serão carregados como texto. A tabela de recarga é `EVOLUSUS_STG.CNES_PF_DATA_CORRIGIDA`. Para impedir nova inferência automática, o CSV de saída inicia com linhas reais que apresentam conteúdo alfanumérico em cada coluna com erro. Nenhum valor é alterado ou removido.

## Aceite

- mesma quantidade de linhas e mesmo multiconjunto de registros da origem;
- `CBO`, `CBOUNICO` e `CONSELHO` alfanuméricos nas primeiras linhas de dados;
- DDL com os três campos em `VARCHAR2`;
- manifesto com hashes, contagem e posição das linhas reposicionadas.
