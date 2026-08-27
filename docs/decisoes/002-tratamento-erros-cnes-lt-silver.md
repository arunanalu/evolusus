# Tratamento de erros de carga Silver — CNES LT e CNES PF/RJ/2025

## Contexto

Na carga dos arquivos CNES LT e CNES PF para a camada Silver da Oracle, foram produzidos os artefatos de evidência e os CSVs de recarga descritos neste documento. Os artefatos da CNES LT foram transferidos de `data/silver/` para `data/consolidated/cnes_lt/RJ/2025/`.

### CNES LT

- `data/consolidated/cnes_lt/RJ/2025/cnes_lt_data.csv`;
- `data/consolidated/cnes_lt/RJ/2025/export_log.csv`;
- `data/consolidated/cnes_lt/RJ/2025/export_bad.csv`;
- `data/consolidated/cnes_lt/RJ/2025/ERROR_SUMMARY_CNES_LT_DATA_CORRIGIDA_20260826.CSV`.

### CNES PF

- `data/consolidated/cnes_pf/RJ/2025/cnes_pf_data.csv`;
- `data/consolidated/cnes_pf/RJ/2025/ERROR_SUMMARY_CNES_PF_DATA_2_20260826.CSV`.

O objetivo foi corrigir a causa da rejeição sem descartar registros, alterar códigos válidos ou transformar silenciosamente informações do CNES.

## Tratamento CNES LT

### Evidências analisadas

Os arquivos `export_log.csv` e `export_bad.csv` possuem o mesmo conteúdo e hash. Eles são logs de execução, não uma relação separada de linhas rejeitadas.

O resumo de erros e o log indicam exclusivamente:

| Coluna | Tipo inferido pela Oracle | Erro | Ocorrências |
|---|---|---|---:|
| `REGSAUDE` | `NUMBER` | `ORA-01722: unable to convert string value ... to a number` | 2.802 |

O CSV de origem possui valores alfanuméricos válidos em `REGSAUDE`, por exemplo `RJ` e `AP1.`. Logo, a rejeição foi causada pela inferência de tipo numérico, e não por registros inválidos.

O log da tentativa posterior ainda referencia `cnes_lt_data.csv`. Portanto, aquela execução não consumiu o arquivo corrigido, ou reutilizou uma tabela de destino cuja coluna permanecia numérica.

### Correção aprovada

A coluna `REGSAUDE` deve ser armazenada como `VARCHAR2(10)`.

Essa decisão preserva códigos numéricos, alfanuméricos, pontuação e eventuais zeros à esquerda. Não é permitido converter a coluna para número, substituir valores por nulo ou remover as linhas rejeitadas apenas para concluir a carga.

### Artefatos gerados

| Artefato | Finalidade |
|---|---|
| `data/consolidated/cnes_lt/RJ/2025/cnes_lt_data_corrigida.csv` | Cópia validada da origem, sem alteração dos valores. |
| `data/consolidated/cnes_lt/RJ/2025/cnes_lt_data_oracle_safe.csv` | Mesmo conjunto de 47.681 registros, com uma linha já existente e alfanumérica posicionada como primeira linha de dados. Isso evita que a inferência automática classifique `REGSAUDE` como número. |
| `data/consolidated/cnes_lt/RJ/2025/cnes_lt_data_corrigida.manifest.json` | Contagens, hashes e regra de correção. |
| `scripts/repair_silver_cnes_lt.py` | Processo reproduzível de geração e validação dos CSVs. |
| `sql/002_create_cnes_lt_corrigida.sql` | DDL da tabela Oracle `EVOLUSUS_STG.CNES_LT_DATA_CORRIGIDA`. |

### Validações executadas

- origem: 47.681 registros;
- saída para Oracle: 47.681 registros;
- comparação de multiconjunto de linhas: idêntica à origem;
- primeira linha de dados do CSV seguro: `REGSAUDE = RJ`;
- registros com letras em `REGSAUDE`: 2.638;
- todos os 2.802 eventos do log apontam somente para `REGSAUDE`.

### Procedimento obrigatório de recarga na Oracle

1. Conectar como `ADMIN` ou `EVOLUSUS_STG` e executar `sql/002_create_cnes_lt_corrigida.sql`.
2. Se já existir uma tabela com `REGSAUDE NUMBER`, não reutilizá-la. Criar uma nova tabela de destino com a mesma definição e outro nome, por exemplo `CNES_LT_DATA_CORRIGIDA_V2`.
3. Criar uma nova tarefa de carga; não reutilizar o mapeamento que gerou o log anterior.
4. Escolher `data/consolidated/cnes_lt/RJ/2025/cnes_lt_data_oracle_safe.csv` como arquivo de origem.
5. Selecionar o schema `EVOLUSUS_STG` e a tabela de destino criada no passo 1.
6. Conferir no mapeamento que `REGSAUDE` é texto e chega em `VARCHAR2(10)`.
7. Executar a carga e validar que a quantidade carregada é 47.681.

### Reversão e rastreabilidade

Os arquivos originais (`cnes_lt_data.csv`, LOG e BAD) não foram modificados. O CSV seguro apenas altera a ordem de uma linha existente para influenciar a inferência de tipo; não altera valores nem reduz registros. O manifesto deve acompanhar a carga para permitir auditoria e repetição do processo.

## Tratamento CNES PF

### Evidências analisadas

O resumo `ERROR_SUMMARY_CNES_PF_DATA_2_20260826.CSV` identificou três campos cuja inferência automática como `NUMBER` é incompatível com códigos alfanuméricos:

| Coluna | Tipo inferido | Ocorrências | Exemplos válidos | Tipo de correção |
|---|---|---:|---|---|
| `CBO` | `NUMBER` | 70.729 | `2231G1`, `3135D2` | `VARCHAR2(20)` |
| `CBOUNICO` | `NUMBER` | 62.869 | `2231G1`, `3135D2` | `VARCHAR2(20)` |
| `CONSELHO` | `NUMBER` | 24 | `MG`, `BA` | `VARCHAR2(20)` |

Esses campos são códigos de classificação ou conselho profissional. Não devem ser convertidos para número, pois isso rejeita valores válidos e pode perder a semântica do código.

### Correção aprovada

Foi gerado um CSV com as mesmas linhas da origem e com linhas reais contendo `CBO`, `CBOUNICO` e `CONSELHO` alfanuméricos posicionadas no início. Isso impede que a criação automática da tabela classifique os três campos como numéricos. Nenhum valor foi modificado.

### Artefatos gerados

| Artefato | Finalidade |
|---|---|
| `data/consolidated/cnes_pf/RJ/2025/cnes_pf_data_corrigida.csv` | CSV seguro para recarga, com 6.370.387 registros preservados. |
| `data/consolidated/cnes_pf/RJ/2025/cnes_pf_data_corrigida.manifest.json` | Contagens, hashes, tipos aprovados e linhas reposicionadas. |
| `scripts/repair_silver_cnes_pf.py` | Processo reproduzível de geração do CSV e do manifesto. |
| `sql/003_create_cnes_pf_corrigida.sql` | DDL da tabela Oracle `EVOLUSUS_STG.CNES_PF_DATA_CORRIGIDA`. |

### Validações executadas

- origem e saída: 6.370.387 registros;
- `CBO` e `CBOUNICO`: primeira linha de dados com valor `2231F9`;
- `CONSELHO`: segunda linha de dados com valor `BA`;
- os valores e a quantidade de registros foram preservados; somente a ordem de duas linhas existentes foi alterada;
- o manifesto registra `SHA-256` da origem, da saída e do resumo de erros.

### Procedimento obrigatório de recarga na Oracle

1. Executar `sql/003_create_cnes_pf_corrigida.sql` como `ADMIN` ou `EVOLUSUS_STG`.
2. Não reutilizar a tabela que possua `CBO`, `CBOUNICO` ou `CONSELHO` como `NUMBER`.
3. Criar uma nova tarefa de carga usando `data/consolidated/cnes_pf/RJ/2025/cnes_pf_data_corrigida.csv`.
4. Definir a saída como `EVOLUSUS_STG.CNES_PF_DATA_CORRIGIDA`.
5. Conferir que `CBO`, `CBOUNICO` e `CONSELHO` são mapeados para `VARCHAR2(20)`.
6. Ao fim da carga, reconciliar a contagem com 6.370.387 registros.

### Reversão e rastreabilidade

O CSV de origem e o resumo de erros não foram modificados. Caso seja necessário repetir a carga, gerar novamente o CSV com `scripts/repair_silver_cnes_pf.py` e manter o manifesto correspondente junto ao artefato carregado.
