# EvoluSUS — contexto operacional do projeto

> Ponto de entrada obrigatório para pessoas e LLMs. Leia este arquivo antes de planejar, modelar ou implementar. Atualize-o quando uma decisão estrutural for aprovada.

## 1. Resumo executivo

O **EvoluSUS** é um projeto acadêmico de engenharia e análise de dados em saúde pública. Ele integrará dados reais do **CNES**, **SIH-SUS**, **SIM** e **IBGE** para estudar a relação entre:

1. capacidade hospitalar instalada;
2. pressão exercida sobre os serviços;
3. mortalidade e outros desfechos em saúde.

O principal produto científico será o **Índice de Pressão Hospitalar (IPH)**, uma métrica nova, criada e validada pelo projeto. O produto tecnológico terá arquitetura-alvo no ecossistema Oracle/OCI, com dados rastreáveis, tabelas analíticas, relatórios e painéis no Oracle Analytics Cloud.

**Pergunta central:** municípios com menor capacidade hospitalar e maior pressão assistencial apresentam maiores taxas de mortalidade?

**Hipótese:** menor capacidade instalada combinada com maior utilização está associada a piores desfechos. Associação não deve ser descrita como causal sem desenho e evidência adequados.

## 2. Escopo vigente

- **Território inicial:** todos os 92 municípios do estado do Rio de Janeiro, código IBGE da UF `33`.
- **Período piloto:** janeiro a dezembro de 2025.
- **Grão analítico principal:** município × mês.
- **Consolidação secundária:** município × ano, derivada dos dados mensais para comparação e validação acadêmica.
- **Grão preservado na ingestão:** o maior detalhamento temporal oferecido pela fonte; competência mensal para CNES e SIH.
- **Dados:** somente dados públicos reais; dados sintéticos são permitidos apenas em testes explicitamente identificados.
- **Primeira expansão planejada:** três anos completos, de janeiro de 2023 a dezembro de 2025, somente após aprovação do piloto de 2025 e da avaliação operacional descrita na seção 5.6.
- **Expansões posteriores:** outros anos e UFs, sem embutir regras específicas do RJ no modelo central.
- **Fase opcional:** análise preditiva do IPH ou de desfechos futuros, somente depois da validação do índice e da ampliação da série histórica.

O IPH será calculado mensalmente para capturar sazonalidade, picos de demanda e mudanças de capacidade. Indicadores anuais devem ser recalculados a partir dos numeradores e denominadores mensais, e não obtidos por média simples dos doze IPHs. O recorte de 2025 é suficiente para o MVP descritivo, mas **não é suficiente, isoladamente, para treinar ou avaliar seriamente uma previsão temporal**.

## 3. Restrições inegociáveis

### 3.1 Ecossistema Oracle

Oracle/OCI é o **ecossistema-alvo da solução**, não uma proibição de ferramentas locais de desenvolvimento. Ingestão gerenciada, armazenamento definitivo, consumo, segurança, IA e visualização devem ter uma implementação ou caminho de implantação Oracle documentado, mas o repositório pode conter scripts e ambientes locais que tornem o projeto acadêmico viável.

- O print de Power BI no slide 11 é apenas um protótipo visual. **Power BI não integra a solução-alvo.**
- Python é permitido para aquisição, conversão, exploração, testes, qualidade, ETL e ciência de dados. Scripts úteis devem ser versionados, parametrizados e preparados para posterior execução em serviço OCI compatível ou migração controlada para uma capacidade Oracle equivalente.
- Bibliotecas abertas como Pandas, GeoPandas, PySUS, conversores DBC e alternativas equivalentes podem ser avaliadas e usadas. Registrar versão, licença, função, limitações e teste de reprodutibilidade, sem exigir que cada dependência seja produzida pela Oracle.
- Bancos, contêineres e serviços locais podem simular a solução durante o desenvolvimento. PostgreSQL, MySQL ou outro mecanismo podem ser usados quando forem compatíveis com uma opção oficialmente oferecida/suportada no ecossistema Oracle ou quando houver um plano explícito de migração.
- O catálogo de tecnologias Oracle não está fechado: avaliar todo serviço Oracle disponível que reduza custo, esforço ou risco, em vez de assumir antecipadamente Autonomous Database como única alternativa.
- Git e ferramentas usuais de desenvolvimento local são permitidos; não são componentes de consumo da plataforma final.
- DATASUS, OpenDataSUS e IBGE são interfaces externas de origem, não componentes tecnológicos escolhidos pelo projeto.
- Para DBC, priorizar a alternativa gratuita, simples e reproduzível: primeiro recursos oficiais equivalentes em CSV/JSON; depois biblioteca/conversor livre validado; por fim uma implementação customizada ou serviço pago, somente se necessário. A conversão pode ocorrer localmente e ser levada manualmente à OCI durante o piloto.

Princípio de decisão: **viabilidade acadêmica primeiro, sem abandonar a arquitetura-alvo Oracle**. Uma solução local é aceitável quando reduz um impedimento real, preserva rastreabilidade e possui caminho claro de implantação, substituição ou migração para OCI. Diferenças entre o ambiente local e o alvo devem ser registradas e testadas.

### 3.2 Limite financeiro Oracle

O projeto dispõe de um plano acadêmico/gratuito com **crédito total máximo de US$ 400**, fornecido pela instituição de ensino. Esse teto é uma restrição inegociável e deve orientar todas as decisões de arquitetura e execução.

- Processar dados brutos localmente por padrão: download, conversão DBC, limpeza, integração, agregação e testes.
- Subir para a OCI preferencialmente resultados tratados e compactos, manifestos, scripts e uma amostra bruta mínima quando ela for necessária para demonstrar rastreabilidade.
- Não reproduzir na nuvem processamento pesado já validado localmente apenas para aderir ao desenho conceitual.
- Usar serviços/tamanhos gratuitos ou de menor custo sempre que atenderem à demonstração.
- Não provisionar serviço pago sem registrar preço vigente, região, duração, volume, custo estimado, responsável e procedimento de desligamento/exclusão.
- Verificar se “parar” o recurso interrompe realmente a cobrança; quando não interromper, exportar o necessário e excluir o recurso.
- Evitar transferência repetida, armazenamento duplicado, alta disponibilidade, autoscaling e ambientes paralelos quando não forem necessários ao projeto acadêmico.
- Manter pelo menos 10% do crédito como reserva para integração e apresentação final. Alertas internos recomendados: 50%, 75% e 90% do teto; ao atingir 90%, suspender cargas e recursos não essenciais.
- A expansão para três anos deve caber no **saldo restante**, não apenas no teto original.

Custos devem ser medidos, não presumidos. A elegibilidade de um serviço ao plano gratuito e seu preço devem ser confirmados antes de cada provisionamento.

### 3.3 IPH é resultado da pesquisa

- Não tratar os valores, pesos ou faixas mostrados nos protótipos como reais.
- Não copiar a composição ilustrativa `40/30/20/10` nem os limites `0,40/0,70` sem validação.
- Toda fórmula deve ser versionada, justificada, reproduzível e submetida a análises de sensibilidade.
- O valor final deve trazer período, município, versão da fórmula e versão/vintage das fontes.

### 3.4 Mortalidade e circularidade

A versão principal do IPH deve medir **pressão**, usando oferta e utilização. Mortalidade deve ser, em primeiro lugar, um **desfecho externo para validar o índice**. Incluir mortalidade simultaneamente no IPH e usá-la como variável de resultado criaria circularidade e vazamento de alvo.

Se a equipe decidir criar um composto que inclua mortalidade, ele deverá ter outro nome, por exemplo `Índice Ampliado de Pressão e Desfecho`, e não poderá ser validado contra a mesma mortalidade que contém.

## 4. Arquitetura de referência

Fluxo lógico alvo, útil para demonstrar a evolução arquitetural:

`DATASUS/IBGE → Oracle Integration 3 e/ou OCI Functions → OCI Object Storage (Landing/Bronze) → OCI Data Integration → Autonomous AI Database/Lakehouse (Silver/Gold) → Oracle Analytics Cloud`

Implantação física preferida para o MVP econômico:

`DATASUS/IBGE → scripts Python locais → dados brutos e intermediários locais → arquivos/tabelas Gold compactos + manifestos → carga manual na OCI → Oracle Analytics Cloud`

No piloto, scripts Python locais devem executar download, conversão DBC, validação, transformação, cálculo e preparação da carga. Esses scripts são artefatos oficiais do projeto. A arquitetura lógica não obriga a contratar ou executar todos os serviços OCI; a demonstração deve usar apenas os componentes que agreguem valor acadêmico dentro do orçamento.

Serviços transversais possíveis: OCI IAM, Vault, Audit, Logging, Monitoring, Notifications, Data Safe e Data Catalog. Habilitar somente os necessários e financeiramente viáveis. Select AI poderá oferecer consultas em linguagem natural sobre objetos Gold devidamente descritos e autorizados, desde que caiba no orçamento.

| Camada | Responsabilidade | Alvo Oracle possível | MVP econômico preferido |
|---|---|---|---|
| Aquisição | FTP/HTTP/REST, agenda, repetição e manifesto | Oracle Integration 3, OCI Functions | Python local e execução manual/agendada |
| Landing/Bronze | preservar e converter arquivos publicados | OCI Object Storage | armazenamento local; enviar apenas amostra ou objetos necessários |
| Orquestração/ETL | validação, carga, dependências e reprocessamento | OCI Data Integration | scripts Python locais idempotentes |
| Silver | limpeza, chaves, padronização e qualidade | serviço de banco/analytics Oracle escolhido | processamento local e exportação compacta |
| Gold | modelo dimensional, métricas, IPH e consumo | serviço de banco/analytics Oracle escolhido | carregar somente tabelas e visões necessárias à demonstração |
| API, se necessária | exposição controlada de produtos Gold | Oracle Integration 3 ou ORDS | omitir no MVP se o OAC consumir diretamente |
| Visualização | mapas, séries, ranking, metodologia e qualidade | Oracle Analytics Cloud | manter como entrega Oracle prioritária |
| Estatística/ML | validação e modelos | Oracle Machine Learning ou OCI Data Science | executar localmente; demonstrar na OCI apenas se houver saldo e valor acadêmico |

**Nomenclatura:** o slide usa “Oracle Data Integration (ODI)”. Não confundir **OCI Data Integration** com o produto **Oracle Data Integrator (ODI)**. A escolha deverá ser registrada; a preferência atual é o serviço gerenciado OCI Data Integration. “Autonomous Data Lake (ADLC)” também é uma descrição conceitual do slide, não um nome de produto aprovado.

## 5. Fontes de dados reais para o MVP RJ/2025

As interfaces devem ser revalidadas em cada execução. Um catálogo ou painel não é automaticamente uma API estável.

### 5.1 CNES — capacidade instalada

Fonte primária: [Transferência de Arquivos DATASUS](https://datasus.saude.gov.br/transferencia-de-arquivos/) e FTP oficial.

- Base: `ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/`
- Competências verificadas para RJ/2025: janeiro a dezembro.
- Arquivos prioritários:
  - `LT/LTRJ25MM.dbc`: leitos;
  - `PF/PFRJ25MM.dbc`: profissionais e vínculos/carga horária;
  - `ST/STRJ25MM.dbc`: estabelecimentos;
  - `EQ/EQRJ25MM.dbc`: equipamentos, opcional no primeiro IPH;
  - `SR/SRRJ25MM.dbc`: serviços especializados, opcional.

CNES é uma fotografia mensal. Não somar estoques de leitos ou profissionais ao longo dos meses; calcular média, mediana ou leitos-dia conforme a métrica.

### 5.2 SIH-SUS — utilização hospitalar

Fonte primária: Transferência de Arquivos DATASUS.

- Base: `ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/`
- Arquivos de AIH Reduzida: `RDRJ25MM.dbc`.
- Competências verificadas para RJ/2025: janeiro a dezembro.
- Variáveis-alvo: município de residência, município/estabelecimento de internação, CNES, internações/AIHs, dias de permanência, valor, óbito hospitalar, diagnóstico CID-10, idade e sexo quando necessários para ajuste.

SIH representa internações financiadas pelo SUS; não equivale a todas as internações ocorridas no território. Reapresentações e regras de AIH devem ser tratadas conforme o dicionário oficial da competência.

### 5.3 SIM — mortalidade

- Base final histórica: `ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/`.
- Em 11/08/2026, o FTP oficial foi verificado com arquivo final de RJ até `DORJ2024.dbc`, sem `DORJ2025.dbc`.
- Há dados **preliminares** de 2025 nos painéis oficiais do DAENT/SVSA; a terceira prévia informava extração em 02/04/2026.
- Referências: [painel de mortalidade CID-10](https://svs.aids.gov.br/daent/centrais-de-conteudos/paineis-de-monitoramento/mortalidade/cid10/), [dados prévios do SIM](https://svs.aids.gov.br/daent/cgiae/coesv/sistemas-informacao/sim/dados-previos/) e [documentação do SIM](https://svs.aids.gov.br/daent/cgiae/coesv/sistemas-informacao/sim/documentacao/).

Regra para o MVP: usar 2025 preliminar somente com marca `PRELIMINAR`, data de extração, origem e política de reprocessamento. Nunca misturar silenciosamente versões prévias e finais.

Quando a data de ocorrência estiver disponível, o SIM poderá ser agregado por mês analítico. Isso não altera sua frequência de publicação nem elimina a baixa contagem em municípios pequenos; para esses casos, manter também consolidação anual, médias móveis e medidas de incerteza.

### 5.4 IBGE — população e geografia

- API SIDRA v3: [documentação oficial](https://servicodados.ibge.gov.br/api/docs/agregados?versao=3).
- Estimativa municipal de 2025: agregado `6579`, variável `9324`.
- Consulta validada para os municípios do RJ: `https://servicodados.ibge.gov.br/api/v3/agregados/6579/periodos/2025/variaveis/9324?localidades=N6[N3[33]]`
- Lista/códigos dos municípios: `https://servicodados.ibge.gov.br/api/v1/localidades/estados/33/municipios`.

Usar o código IBGE de sete dígitos na dimensão Município. Preservar o código original de cada fonte e documentar a transformação quando o DATASUS fornecer seis dígitos.

A estimativa populacional é anual. No cálculo mensal, usar a estimativa do respectivo ano como população de referência, sem dividir a população por 12. Quando o indicador representar exposição acumulada, ajustar o tempo explicitamente na fórmula. Qualquer interpolação populacional deverá ser aprovada e versionada.

### 5.5 OpenDataSUS e TabNet

- [OpenDataSUS](https://opendatasus.saude.gov.br/) pode fornecer recursos CSV/JSON e metadados, especialmente para SIM. Usá-lo como catálogo/fonte alternativa e registrar a URL exata do recurso; não depender de uma API CKAN antiga sem teste automatizado.
- TabNet é útil para conferência de totais e consultas exploratórias. Não deve ser o mecanismo principal de ingestão em lote enquanto não houver contrato de API oficial e estável.

### 5.6 Estratégia de ampliação temporal

A ampliação ocorrerá em duas fases:

1. **Piloto — 2025:** ingerir, processar e validar as 12 competências, mensurar o comportamento de cada fonte e estabilizar o pipeline.
2. **Expansão — 2023 a 2025:** após aprovação do piloto, ingerir 36 competências de CNES e SIH e os períodos equivalentes disponíveis de SIM e IBGE.

Antes da expansão, produzir uma avaliação registrada em `docs/planejamento/` contendo:

- disponibilidade real de arquivos e layouts para os 36 meses;
- existência de limites publicados, bloqueios, throttling ou restrições de uso;
- volume total, tempo de download, conversão, carga e reprocessamento;
- taxa de falhas, comportamento de repetição e estabilidade dos endpoints;
- mudanças de esquema, dicionário ou nomenclatura entre competências;
- custo estimado de Object Storage, processamento, serviço de banco/analytics Oracle escolhido e OAC;
- saldo do crédito de US$ 400, custo incremental da expansão e reserva necessária para a apresentação final;
- situação preliminar/final de cada fonte e estratégia de atualização;
- capacidade de executar novamente sem duplicar downloads ou registros.

Se a fonte não publicar rate limit, tratá-lo como desconhecido: usar concorrência conservadora, cache por hash, repetição com espera exponencial e jitter, limite de tentativas e retomada por competência. A expansão só será aprovada se o piloto demonstrar aquisição idempotente, rastreável, sem impacto indevido sobre as fontes públicas e executável prioritariamente fora da OCI. Na nuvem devem entrar os resultados consolidados necessários à demonstração, não uma repetição integral do processamento bruto.

## 6. Rastreabilidade de aquisição

Cada objeto ingerido deve gerar um manifesto com, no mínimo:

- sistema, modalidade, UF, ano e competência;
- URL e nome original;
- instante de download em UTC;
- tamanho, `SHA-256` e quantidade de registros após conversão;
- versão do layout/dicionário e versão do conversor;
- situação `PRELIMINAR`, `FINAL` ou `DESCONHECIDA`;
- data de referência e data de publicação/extração;
- resultado das validações e motivo de eventual quarentena.

Ingestões devem ser idempotentes. Alteração de hash na origem cria nova versão e reprocessa dependências; nunca sobrescrever silenciosamente o histórico.

## 7. Duas perspectivas geográficas obrigatórias

Fluxos de pacientes entre municípios tornam inadequada uma única interpretação geográfica.

1. **Perspectiva do serviço:** capacidade e utilização atribuídas ao município do estabelecimento/internação. Mede pressão sobre a rede local.
2. **Perspectiva da população:** internações e óbitos atribuídos ao município de residência. Mede acesso e desfecho dos residentes.

Manter também uma matriz origem–destino `município_residência → município_atendimento`. Não unir pressão do local de atendimento à mortalidade de residentes sem explicitar a hipótese e o método.

## 8. Modelo analítico mínimo

Objetos sugeridos; os nomes finais devem seguir o padrão aprovado no plano de modelagem.

- `DIM_MUNICIPIO`, `DIM_TEMPO`, `DIM_ESTABELECIMENTO`, `DIM_CID10`;
- `FATO_CAPACIDADE_CNES_MES`;
- `FATO_INTERNACAO_SIH` ou agregado mensal rastreável;
- `FATO_MORTALIDADE_SIM`;
- `FATO_POPULACAO_IBGE_ANO`;
- `FATO_FLUXO_ASSISTENCIAL_MES`;
- `FATO_IPH_MUNICIPIO_MES`;
- visão ou tabela de consolidação `IPH_MUNICIPIO_ANO` recalculada a partir das medidas-base;
- visões Gold separadas para perspectiva do serviço e da população.

O identificador do IPH mensal deve incluir `COD_MUNICIPIO`, `ANO_COMPETENCIA`, `MES_COMPETENCIA`, `VERSAO_IPH` e `VINTAGE_DADOS`.

## 9. Catálogo inicial de indicadores

### Capacidade

- leitos SUS por 1.000 habitantes;
- leitos de UTI SUS por 100.000 habitantes;
- médicos equivalentes a tempo integral (FTE) por 1.000 habitantes;
- enfermeiros FTE por 1.000 habitantes;
- disponibilidade média e variação mensal de leitos.

Contar profissionais por FTE/carga horária sempre que o CNES permitir, evitando contar múltiplos vínculos como pessoas distintas.

### Utilização e pressão

- internações por 1.000 habitantes;
- internações por leito médio;
- dias de permanência por leito-dia disponível, como proxy de ocupação;
- permanência média;
- internações por profissional FTE;
- sazonalidade e pico mensal;
- entrada líquida de pacientes de outros municípios.

Proxy inicial de ocupação:

`OCUPACAO_PROXY = SOMA(DIAS_PERM_SIH) / SOMA(LEITOS_SUS_NO_MES × DIAS_DO_MES)`

Ela não é ocupação censitária observada. O nome e as limitações devem aparecer no catálogo e no dashboard.

### Desfechos e validação

- mortalidade hospitalar SIH: óbitos durante internação / internações;
- mortalidade geral SIM por 100.000 residentes;
- mortalidade por grupos CID-10 pertinentes;
- versões ajustadas por idade/sexo e, se viável, padronizadas por idade;
- cobertura, completude e proporção de causas mal definidas do SIM.

SIH e SIM medem fenômenos diferentes: morte durante internação financiada pelo SUS versus óbito registrado na população.

## 10. Método de construção do IPH

### 10.1 Definição do construto

IPH é o grau relativo de pressão sobre recursos hospitalares municipais em determinado período. Valor maior deve significar maior pressão.

Dimensões candidatas:

- **escassez de capacidade:** inverso de leitos, UTI e FTE por habitante;
- **intensidade de utilização:** internações/leito, ocupação proxy e permanência;
- **tensão territorial:** saldo de pacientes recebidos e picos sazonais.

### 10.2 Pipeline metodológico

1. elaborar dicionário e sinal esperado de cada variável;
2. avaliar completude, extremos, estabilidade e redundância/correlação;
3. ajustar denominadores populacionais e de capacidade;
4. tratar extremos com regra documentada, por exemplo winsorização;
5. normalizar em escala comum, preservando a direção “maior = pior”;
6. comparar pesos iguais, pesos orientados por especialistas e método empírico como PCA/análise fatorial;
7. selecionar a solução por interpretabilidade, validade, estabilidade e sensibilidade — não apenas por melhor correlação;
8. transformar para escala publicável, por exemplo `0–100`;
9. definir faixas somente após observar distribuição e relevância substantiva;
10. versionar fórmula, parâmetros, população de referência e vintage.

Forma genérica, ainda não aprovada:

`IPH(m,t,v) = Σ wi(v) × Zi(m,t,v)`, com `wi ≥ 0` e `Σ wi = 1`.

`Zi` é o indicador normalizado e orientado para pressão. Esta expressão é um contrato estrutural, não a fórmula final.

### 10.3 Validação mínima

- validade de conteúdo com literatura e especialistas;
- validade convergente com indicadores conhecidos de pressão;
- associação externa com mortalidade, sem incluí-la no IPH principal;
- estabilidade a métodos de normalização, pesos e remoção de componentes;
- incerteza por bootstrap quando aplicável;
- análise específica de municípios pequenos e denominadores baixos;
- auditoria de viés, cobertura e qualidade das fontes;
- revisão acadêmica da interpretação e das limitações.

## 11. Análise estatística e preditiva

Primeiro entregar análise descritiva, espacial e inferencial. Modelos de regressão devem controlar, conforme disponibilidade, porte populacional, composição etária, sexo, perfil de causas e fluxos assistenciais. Correlação simples não responde sozinha à pergunta científica.

A fase preditiva é opcional e posterior:

- concluir primeiro a expansão planejada para 2023–2025 e avaliar se 36 competências oferecem histórico suficiente para o alvo escolhido;
- ampliar além de três anos quando sazonalidade, dependência temporal, mudança de esquema ou tamanho efetivo da amostra exigirem;
- definir alvo temporal inequívoco, como `IPH(t+1)` ou mortalidade futura;
- impedir vazamento entre componentes, desfecho e período previsto;
- separar treino/validação/teste por tempo, nunca somente de forma aleatória;
- comparar baseline ingênuo, regressões e modelos disponíveis no Oracle Machine Learning;
- reportar erro, calibração, explicabilidade, estabilidade e limitações;
- não apresentar previsão como diagnóstico clínico ou verdade causal.

## 12. Produtos no Oracle Analytics Cloud

O painel mínimo deve conter:

- visão geral do IPH RJ/2025;
- série mensal do IPH e de seus componentes, com consolidação anual separada;
- mapa municipal com versão e vintage visíveis;
- ranking com incerteza/qualidade, não apenas posição;
- capacidade, utilização e desfechos em visões separadas;
- perspectiva do serviço versus perspectiva da população;
- fluxos intermunicipais;
- metodologia completa e composição do IPH;
- indicadores de completude e marca explícita para dados preliminares;
- data da última atualização.

O visual pode se inspirar no protótipo, mas deve ser reconstruído no OAC e não reproduzir números fictícios.

## 13. Como uma LLM deve trabalhar neste repositório

1. Ler este arquivo e os documentos citados na tarefa.
2. Inspecionar o repositório antes de propor mudanças.
3. Tratar as decisões das seções 2 e 3 como restrições.
4. Não inventar campos, endpoints, disponibilidade ou capacidades Oracle; validar em documentação oficial.
5. Antes de código relevante, criar um plano pequeno e executável em `docs/planejamento/`.
6. Transformar planos aprovados em artefatos concretos: contratos de fonte, DDL Oracle, SQL/PLSQL, pipelines OCI, testes e painéis OAC.
7. Tratar scripts Python, conversores, notebooks e simulações locais como artefatos válidos quando possuírem configuração reproduzível, testes e caminho documentado para OCI.
8. Registrar decisões irreversíveis ou científicas em `docs/decisoes/`.
9. Manter rastreabilidade requisito → fonte → transformação → indicador → visualização.
10. Incluir critérios de aceite, testes, custos/riscos e estratégia de reversão nos planos.
11. Atualizar este arquivo apenas quando o contexto global mudar; detalhes de execução pertencem aos documentos de planejamento.

Ordem sugerida de planejamento:

1. `001-contratos-fontes-rj-2025.md`;
2. `002-avaliacao-expansao-2023-2025.md`;
3. `003-modelo-dados-oracle.md`;
4. `004-metodologia-validacao-iph.md`;
5. `005-pipeline-ingestao-etl-oci.md`;
6. `006-dashboard-oac.md`;
7. `007-analise-preditiva.md`, somente quando habilitada.

## 14. Critérios de aceite do MVP

- 92 municípios do RJ presentes ou ausência justificada;
- 12 competências de CNES e SIH de 2025 processadas;
- IPH calculado no grão município × mês, com 12 períodos esperados por município ou ausência justificada;
- consolidação anual recalculada a partir das medidas mensais;
- população IBGE 2025 conciliada pelo código municipal;
- SIM 2025 rotulado como preliminar ou substituído por versão final quando publicada;
- arquivos originais e manifestos preservados;
- reconciliação de totais com fonte oficial em amostra documentada;
- modelo Silver/Gold compatível com a tecnologia Oracle escolhida e implantação validada em OCI quando o ambiente estiver disponível;
- scripts locais reproduzíveis, testados e acompanhados do procedimento de execução ou migração para OCI;
- processamento bruto executado prioritariamente fora da OCI e carga em nuvem limitada ao necessário para demonstração;
- IPH reproduzível, versionado e acompanhado de análise de sensibilidade;
- mortalidade fora do IPH principal e usada como desfecho de validação;
- painel produzido no Oracle Analytics Cloud;
- gasto total dentro do teto de US$ 400, com custos registrados e reserva para a apresentação final;
- nenhuma credencial ou dado sensível versionado.

Critérios adicionais para liberar a expansão de 2023–2025:

- avaliação de disponibilidade, rate limit/throttling, volume, custo e mudanças de layout concluída;
- ingestão idempotente e retomável por fonte, ano, UF e competência;
- cache e hashes impedindo downloads e cargas desnecessários;
- limites de concorrência e política de repetição documentados;
- capacidade estimada e orçamento OCI aprovados;
- custo incremental compatível com o saldo disponível após preservar a reserva financeira;
- plano para distinguir e atualizar dados preliminares e finais aprovado.

## 15. Decisões em aberto

- saldo atual, data de expiração dos créditos e serviços efetivamente incluídos no plano acadêmico;
- serviço/banco Oracle exato e licenças habilitadas;
- escolha do conversor DBC gratuito, sua licença e o caminho de execução local e/ou implantação na OCI;
- banco/serviço Oracle definitivo e equivalentes permitidos para simulação local;
- política de uso e substituição do SIM 2025 preliminar;
- perspectiva principal do IPH: município do serviço, residência ou duas versões;
- componentes, normalização, pesos e faixas do IPH;
- referência para padronização etária;
- fonte oficial das regiões de saúde do RJ;
- suficiência dos 36 meses de 2023–2025 para a fase preditiva e eventual necessidade de histórico adicional.

Não resolver essas questões por suposição silenciosa.

## 16. Referências-base

- Apresentação local: `docs/evolusus_arquitetura.pptx` — contexto, arquitetura OCI, tecnologias, protótipos e planejamento.
- [DATASUS — Transferência de Arquivos](https://datasus.saude.gov.br/transferencia-de-arquivos/).
- [CNES — documentação e contexto oficial](https://wiki.datasus.gov.br/cnes/index.php/P%C3%A1gina_principal).
- [SIM — portal oficial](https://svs.aids.gov.br/daent/cgiae/coesv/sistemas-informacao/sim/).
- [IBGE — API de dados agregados/SIDRA v3](https://servicodados.ibge.gov.br/api/docs/agregados?versao=3).
- [Oracle — OCI Data Integration](https://docs.oracle.com/en-us/iaas/Content/data-integration/home.htm).
- [Oracle — OCI Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm).
- [Oracle — Autonomous AI Database](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/).
- [Oracle — Oracle Analytics Cloud](https://docs.oracle.com/en/cloud/paas/analytics-cloud/).
- [Oracle — Data Catalog](https://docs.oracle.com/en-us/iaas/Content/data-catalog/home.htm).
- [Oracle — Select AI](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai.html).
- [Oracle — Machine Learning](https://docs.oracle.com/en/database/oracle/machine-learning/).

Última verificação das fontes e interfaces: **11/08/2026**.
