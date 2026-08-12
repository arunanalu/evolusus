# 001 — Adoção do conversor `pyreaddbc`

**Data:** 11/08/2026
**Status:** aprovada
**Responsável pela autorização:** Nalu Aruna — FIAP

## Decisão

Adotar `pyreaddbc==2.0.4` como conversor local inicial de arquivos DATASUS no formato DBC para CSV no pipeline de aquisição do EvoluSUS.

## Justificativa

- É gratuito e possui API Python compatível com o pipeline local reproduzível.
- A conversão ocorre antes da carga em OCI, preservando o processamento bruto local e o limite financeiro do projeto.
- O adaptador está isolado em `src/evolusus_acquisition/converter.py`, permitindo substituição sem alterar o mecanismo de aquisição, manifesto ou estado.

## Licença e condição de uso

`pyreaddbc` declara licença **AGPL-3.0**. A equipe autorizou sua adoção para este repositório acadêmico e manterá a dependência, sua versão e o código de integração versionados. Instalar com:

```powershell
python -m pip install -e ".[dbc]"
```

Antes da execução piloto, validar conversão de uma competência CNES e uma SIH, incluindo abertura do arquivo, quantidade de registros e colunas contra o dicionário aplicável.

## Reversão

Caso a licença, compatibilidade ou conversão falhe na validação, substituir somente o adaptador `converter.py` por conversor livre validado. Os arquivos DBC brutos, hashes, manifestos e objetos já convertidos permanecem preservados; não haverá exclusão ou sobrescrita silenciosa.
