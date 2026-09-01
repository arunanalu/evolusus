# 012 — Visualização gratuita e compartilhável do IPH

**Status:** demonstração recomendada com rótulo explícito `PRELIMINAR`.  
**Fonte inicial:** `data/gold_table/export.csv`.

## Decisão recomendada

Usar **Looker Studio** para a demonstração compartilhável com o professor. O conector oficial permite carregar diretamente um CSV e compartilhar o relatório por e-mail como visualizador; se o upload ainda não estiver habilitado na conta, usar Google Sheets como ponte. O conector Google Sheets conecta uma única aba do arquivo e permite compartilhar o relatório sem dar ao visualizador acesso de edição à planilha. [Upload CSV oficial](https://docs.cloud.google.com/looker/docs/studio/upload-csv-files-to-looker-studio), [conector Google Sheets](https://cloud.google.com/looker/docs/studio/connect-to-google-sheets) e [compartilhamento](https://cloud.google.com/looker/docs/studio/tutorial-view-and-share-your-report).

Como alternativa reproduzível, o repositório contém uma demonstração web estática em `docs/visualizacao/`. Ela será publicada gratuitamente por GitHub Pages depois que a equipe habilitar Pages no repositório. O site leva uma cópia controlada do CSV somente no artefato publicado; o dado-fonte continua em `data/gold_table/export.csv`. GitHub alerta que Pages pode tornar conteúdo público mesmo quando o repositório é privado; publicar somente após confirmar que a agregação municipal pode ser pública. [Documentação GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).

**Power BI não é a opção escolhida para esta apresentação:** Power BI Desktop é gratuito para criar, mas compartilhamento interativo normalmente exige Pro/PPU para autor e destinatário, exceto em capacidade Premium/Fabric compatível. [Requisitos de compartilhamento](https://learn.microsoft.com/en-us/power-bi/collaborate-share/service-share-dashboards).

## Roteiro imediato no Looker Studio

1. Abrir Looker Studio com a conta institucional.
2. Criar **Fonte de dados → CSV file upload** e selecionar `data/gold_table/export.csv`. Se o conector não aparecer, importar o CSV em Google Sheets e conectar a aba via conector Google Sheets.
3. Configurar `CODIGO_MUNICIPIO_7D` como texto, ano/mês como número e criar `DATA_COMPETENCIA` com `DATE(ANO_COMPETENCIA, MES_COMPETENCIA, 1)`.
4. Criar filtros `ANO_COMPETENCIA`, `MES_COMPETENCIA` e `NOME_MUNICIPIO`.
5. Criar os visuais abaixo:

   | Visual | Campos | Objetivo |
   |---|---|---|
   | Série temporal | `DATA_COMPETENCIA`, média de `INDICE_PRESSAO_HOSPITALAR` | evolução estadual mensal |
   | Ranking | `NOME_MUNICIPIO`, média de `INDICE_PRESSAO_HOSPITALAR` | comparação municipal, com filtro temporal |
   | Dispersão | `LEITOS_POR_MIL_HAB`, `TAXA_OCUPACAO_PROXY_PCT`, tamanho por `TOTAL_INTERNACOES` | capacidade × pressão |
   | Tabela de qualidade | município, mês, leitos, internações, IPH | evitar leitura de ausência como zero |

6. Inserir no topo: **"Gold preliminar: cobertura de 87/92 municípios; IPH não validado."**
7. Usar **Compartilhar → convidar e-mail institucional do professor → Pode visualizar**. Não habilitar link público sem confirmar a política institucional.

## Publicação da demonstração web do repositório

1. Fazer push da branch que contém `docs/visualizacao/`.
2. Em GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. Mesclar a branch na padrão ou executar manualmente o workflow `Deploy demonstration dashboard`.
4. Compartilhar a URL gerada em **Settings → Pages**.

O workflow publica somente o HTML e `data/gold_table/export.csv`. A página deixa visível o aviso de preliminariedade e não apresenta IPH como diagnóstico ou causalidade.

### Mapa

Não publicar mapa municipal antes de corrigir os cinco municípios ausentes e de incluir a dimensão geográfica oficial. Para a demonstração atual, ranking e série temporal são mais seguros.

## Uso de IA e JSON: o que é viável

| Necessidade | Melhor formato | Fluxo |
|---|---|---|
| Dashboard interativo compartilhável | Looker Studio | IA sugere layout/campos; equipe carrega CSV e compartilha por e-mail |
| Gráfico reproduzível por copiar/colar | JSON Vega-Lite | IA gera especificação → colar no Vega Editor → validar contra CSV → exportar |
| Demonstração pública reproduzível | HTML + JSON Vega-Lite + GitHub Pages | workflow publica o CSV e os gráficos |
| Versionar uma solução Power BI já existente | PBIP/PBIR + JSON | criar primeiro no Desktop → salvar como projeto → revisar diffs JSON |

Vega-Lite usa uma especificação JSON declarativa que pode descrever dados, transformações e gráficos. [Documentação](https://vega.github.io/vega-lite/docs/) e [Vega Editor](https://vega.github.io/editor/). Looker Studio não possui um formato JSON oficial de dashboard para colar; nele, a IA deve produzir o roteiro de configuração. Em Power BI, gerar JSON antes de existir um projeto é frágil.

## Critérios de aceite

- o CSV é lido em UTF-8 e códigos municipais preservam sete dígitos;
- filtros alteram todos os visuais relevantes;
- nenhum gráfico apresenta IPH como diagnóstico, causalidade ou resultado final validado;
- municípios sem cobertura são destacados, não tratados como pressão zero;
- título, período e limitações ficam visíveis;
- pelo menos uma visualização é conferida manualmente contra três linhas do CSV.
