# 009 — Correção da carga Silver de CNES LT

## Evidência e decisão

`export_log.csv` e `export_bad.csv` têm o mesmo conteúdo. O log registra 2.802 ocorrências de `ORA-01722` exclusivamente na coluna `REGSAUDE`. O CSV de origem possui códigos alfanuméricos nessa coluna, incluindo `RJ` e `AP1.`; portanto, a causa é tipagem numérica incorreta na carga Oracle, não dado inválido.

## Entrega

O script gera `data/silver/cnes_lt_data_corrigida.csv`, com todas as linhas da origem e `REGSAUDE` preservada como texto. Também gera `cnes_lt_data_oracle_safe.csv`, que apenas reposiciona uma linha alfanumérica já existente como primeira linha de dados para impedir que a inferência automática da Oracle classifique `REGSAUDE` como número. O manifesto registra as evidências, hashes, contagens e a regra aplicada. A tabela Oracle correspondente deve usar `REGSAUDE VARCHAR2(10)`.

## Aceite

- 47.681 registros de dados preservados;
- nenhuma alteração de valor em `REGSAUDE`;
- 2.802 erros do log explicados pela regra de tipo;
- saída e manifesto escritos atomicamente.

## Reversão

O arquivo de origem não é modificado. Para desfazer a tentativa de carga Oracle, remover somente a tabela de destino `CNES_LT_DATA_CORRIGIDA` criada para esta recarga.
