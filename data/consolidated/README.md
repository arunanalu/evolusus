# Dados consolidados — RJ/2025

Esta pasta contém arquivos anuais construídos a partir das 12 competências mensais de 2025. Eles são artefatos locais de transição entre a conversão técnica dos arquivos DATASUS e a futura camada Silver/Gold do EvoluSUS; não são ainda o Índice de Pressão Hospitalar (IPH) nem uma carga Oracle.

Cada subpasta mantém dois arquivos:

- `dados.csv`: registros de todas as competências da modalidade, com campos de rastreabilidade (`ANO_COMPETENCIA`, `MES_COMPETENCIA`, `SHA256_ORIGEM`, `ARQUIVO_ORIGEM`, `VERSAO_CONVERSOR` e `LAYOUT_SHA256`).
- `provenance.csv`: uma linha por competência, com origem, hash, layout e quantidade de registros. Ele permite conferir se os 12 meses foram incluídos.

| Pasta | Dados | Papel no projeto |
|---|---|---|
| `cnes_lt/` | Leitos por estabelecimento e tipo de leito. | Base da capacidade instalada e dos indicadores de leitos SUS/UTI. |
| `cnes_pf/` | Vínculos, ocupações e cargas horárias de profissionais. | Base para estimar profissionais equivalentes a tempo integral (FTE); vínculos não devem ser interpretados automaticamente como pessoas distintas. |
| `cnes_st/` | Cadastro e características dos estabelecimentos de saúde. | Dimensão de estabelecimentos e contexto da rede assistencial; é uma fotografia mensal, não estoque acumulável. |
| `sih_rd/` | Autorizações de Internação Hospitalar (AIH) reduzidas. | Base da utilização SUS: internações, dias de permanência, óbito hospitalar, município de residência, município de atendimento e fluxos intermunicipais. |

## Regras de uso

- Não unir as quatro pastas em um CSV único: elas têm grãos e significados diferentes.
- Não somar leitos, estabelecimentos ou vínculos mensalmente como se fossem eventos. Para capacidade, usar medida mensal apropriada (por exemplo, média ou leitos-dia).
- SIH representa internações financiadas pelo SUS; não representa todas as internações do território.
- Uma alteração aditiva de layout é preservada por `LAYOUT_SHA256`. Em 2025, o SIH adicionou `FONTE_ORC` a partir de março; janeiro e fevereiro ficam vazios nesse campo.
- Dados brutos, CSVs convertidos e consolidados são locais e ignorados pelo Git. Apenas este README é versionado. Antes de OCI/OAC, os dados devem passar pelas validações e pelo modelo do plano 003.
