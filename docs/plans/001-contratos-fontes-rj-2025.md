# 001 — Aquisição local e contratos de fontes: RJ/2025

**Status:** piloto executado — execução massiva pendente de avaliação
**Escopo:** aquisição local, conversão DBC, validação e rastreabilidade de CNES, SIH, IBGE e SIM para o piloto RJ/2025. Não calcula o IPH nem provisiona OCI.

## Objetivo e critérios de aceite

Entregar um processo Python parametrizado que obtenha os objetos públicos necessários sem redownload de artefatos válidos, preserve o bruto, converta DBC de modo reproduzível e permita a uma LLM (ou pessoa) observar, pausar, cancelar e retomar a execução.

Ao fim, cada competência deverá estar em um dos estados \`PENDENTE\`, \`BAIXANDO\`, \`BAIXADO_VALIDO\`, \`CONVERTENDO\`, \`CONVERTIDO_VALIDO\`, \`QUARENTENA\`, \`FALHA_RETENTAVEL\` ou \`FALHA_FINAL\`. Um novo processo deve recuperar estados transitórios deixados por interrupção. Nenhum arquivo validado será sobrescrito: alteração de hash cria versão nova e agenda a reconversão.

## Fontes e contrato inicial

| Fonte | Recurso inicial | Protocolo | Situação de acesso a validar no piloto |
|---|---|---|---|
| CNES | \`LT/LTRJ25MM.dbc\`, \`PF/PFRJ25MM.dbc\`, \`ST/STRJ25MM.dbc\`; \`EQ\` e \`SR\` opcionais | FTP DATASUS | rate limit não publicado: tratar como desconhecido |
| SIH-SUS | \`RDRJ25MM.dbc\` | FTP DATASUS | rate limit não publicado: tratar como desconhecido |
| IBGE municípios | \`https://servicodados.ibge.gov.br/api/v1/localidades/estados/33/municipios\` | HTTPS JSON | GET verificado em 11/08/2026; retornou 200 e JSON gzip |
| IBGE população | agregado 6579, variável 9324, período 2025, \`localidades=N6[N3[33]]\` | HTTPS JSON | GET verificado em 11/08/2026; retornou 200; \`HEAD\` retornou 405 |
| SIM final | \`.../SIM/CID10/DORES/DORJ2025.dbc\` quando publicado | FTP DATASUS | verificar listagem e hash; se indisponível, não fabricar substituto |
| SIM prévio | exportação oficial do painel/arquivo oficialmente identificável | HTTPS | somente mediante URL de recurso, data de extração e rótulo \`PRELIMINAR\` |

Os caminhos FTP completos e a existência de cada arquivo serão resolvidos por competência, a partir das bases definidas no \`AGENTS.md\`. Uma tentativa de listagem ou download deve ser registrada; 404/arquivo ausente não pode ser confundido com rate limit.

## Decisões operacionais

- Usar HTTP(S)/FTP passivo com \`User-Agent\` identificável e timeout configurável. O nome do projeto e um contato configurável ficam na configuração, nunca em segredo embutido.
- Não contornar limite de origem por troca de IP, proxy rotativo, identidade alternativa ou distribuição artificial de requisições. Em 429/503, aplicar \`Retry-After\` quando presente, backoff exponencial com *jitter*, reduzir concorrência e retomar depois. Se persistir, deixar \`FALHA_RETENTAVEL\` e encerrar sem perder itens válidos.
- Uma mudança manual de conexão ou endereço IP será tratada exclusivamente como transição de rede: erros de resolução DNS, conexão recusada/resetada, socket interrompido, timeout e FTP desconectado são transitórios. O trabalhador fecha a sessão afetada, persiste imediatamente tentativa/estado e aguarda o backoff antes de criar uma nova conexão. Não assume continuidade da conexão anterior nem descarta objetos já aprovados.
- Começar com uma transferência simultânea por host. Multithread é opcional e limitado por host, habilitado só após medir o piloto e confirmar que não há throttling. Nunca usar concorrência para escapar de limitação.
- Não assumir que \`.dbc\` é ZIP: armazenar o binário original e convertê-lo por conversor DBC selecionado em experimento reproduzível. Comparar licença, suporte ao layout, integridade e execução Windows/OCI; registrar versão e comando no manifesto.
- Arquivos são imutáveis em \`data/raw\`; gravação ocorre em \`*.part\` e só é promovida atomicamente após tamanho, SHA-256 e checagens. A conversão usa temporário e promoção atômica.

## Artefatos a implementar

\`\`\`
config/sources.rj-2025.yaml       # fontes, competências, URLs-base, limites e política
src/evolusus_acquisition/         # cliente, estado, manifesto, retry, DBC e validações
scripts/acquire.py                # CLI única e legível
data/raw/<sistema>/<uf>/<ano>/<mm>/<hash>/original.dbc
data/converted/<sistema>/<...>/<hash>/dados.(parquet|csv)
data/manifests/<sistema>/<...>/<hash>.json
data/state/acquisition.sqlite     # estado operacional; não é dado-fonte
logs/acquisition/<run_id>.jsonl   # eventos estruturados, um por linha
tests/                            # unitários e integração com servidor local simulado
\`\`\`

O SQLite contém planejamento, tentativas, lock, estados e ponteiros de versão. O manifesto JSON é a prova portátil de proveniência. Ambos têm chave lógica \`sistema, modalidade, UF, ano, mês, nome_original, url\` e chave de versão \`sha256\`.

## Arquitetura técnica de referência

**Runtime:** Python 3.11+ em ambiente virtual, dependências pinadas em \`pyproject.toml\` com arquivo de lock. O código deve usar \`pathlib\`, \`hashlib\`, \`sqlite3\`, \`ftplib\`, \`logging\`, \`threading\`, \`signal\`, \`tempfile\` e \`uuid\` da biblioteca padrão sempre que suficientes. Isso reduz dependências no mecanismo crítico de retomada.

| Necessidade | Biblioteca proposta | Uso e regra |
|---|---|---|
| HTTP/JSON IBGE e SIM | \`requests\` | \`Session\` por trabalhador, streaming e timeouts separados; sem retry implícito do adaptador, pois o retry precisa ser auditável no estado. |
| Configuração e modelos | \`pydantic\` + \`PyYAML\` | validar YAML e CLI antes de tocar na rede; rejeitar URL, mês, concorrência e timeout inválidos. |
| CLI e saída humana | \`typer\` + \`rich\` | subcomandos tipados e tabela de status; JSONL permanece a fonte de eventos para LLMs. |
| Dados convertidos | \`pandas\` + \`pyarrow\` | converter somente após o bruto ser válido; escrever Parquet atômico. |
| DBC | candidato inicial \`pyreaddbc\` | versão atual observada: 2.0.4, Python >=3.9 e licença declarada AGPL-3.0. Só adotar após aprovação explícita da licença e teste CNES/SIH; manter adaptador para substituir por conversor CLI/livre. |
| Testes | \`pytest\`, \`responses\`/\`pytest-httpserver\`, \`pyftpdlib\` | simular HTTP e FTP sem pressionar fontes públicas. |

Não usar Celery, filas externas, banco remoto ou \`asyncio\` no MVP. Uma fila local no SQLite e \`ThreadPoolExecutor\` são mais fáceis de inspecionar, pausar e reiniciar. Também não usar \`urllib3.Retry\`/\`HTTPAdapter\` como segunda política de retentativa: haveria tentativas ocultas fora do manifesto. A documentação do Requests confirma que o adaptador suporta retries, mas aqui a política explícita por objeto é necessária; Tenacity também pode ser avaliada, porém não deve ocultar o tratamento específico de \`Retry-After\` e FTP.

### Módulos e contratos de código

```text
src/evolusus_acquisition/
  cli.py              # Typer; apenas parseia, cria RunConfig e retorna exit code
  config.py           # Pydantic: SourceSpec, RetryPolicy, RunConfig
  planner.py          # expande SourceSpec em AcquisitionItem determinísticos
  state.py            # SQLite: transações, CAS de estado, locks e runs
  transport/http.py   # Requests streaming; traduz exceções para erros de domínio
  transport/ftp.py    # ftplib FTP_TLS/FTP passivo conforme contrato confirmado
  retry.py            # única função que classifica erro e calcula próxima tentativa
  downloader.py       # .part, hash incremental, fsync, os.replace
  converter.py        # protocolo DbcConverter + adaptador escolhido
  validator.py        # checks por fonte e formato
  manifest.py         # modelo e escrita JSON imutável
  events.py           # evento JSONL e renderização Rich
  orchestrator.py     # scheduler, ThreadPoolExecutor, pause/cancel cooperativo
```

Tipos de domínio mínimos:

```python
class AcquisitionItem(BaseModel):
    item_id: str; source: str; uf: str; year: int; month: int | None
    url: AnyUrl; original_name: str; expected_format: Literal["dbc", "json", "csv"]

class RetryDecision(BaseModel):
    retryable: bool; delay_seconds: float | None; reason: str

class AcquisitionError(Exception):
    kind: Literal["network", "rate_limit", "server", "not_found", "auth", "integrity", "layout"]
    status_code: int | None = None
    retry_after_seconds: float | None = None
```

`state.py` é a única camada autorizada a mudar estado. Cada transição roda em transação SQLite curta com comparação do estado anterior (CAS), evitando que dois trabalhadores baixem o mesmo item. `orchestrator.py` nunca aceita o arquivo como válido; somente `validator.py` seguido de `manifest.py` pode promover `BAIXADO_VALIDO` ou `CONVERTIDO_VALIDO`.

### Esquema SQLite mínimo

```sql
CREATE TABLE acquisition_item (
  item_id TEXT PRIMARY KEY, source TEXT NOT NULL, uf TEXT NOT NULL,
  year INTEGER NOT NULL, month INTEGER, url TEXT NOT NULL, original_name TEXT NOT NULL,
  state TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0,
  next_attempt_at_utc TEXT, active_sha256 TEXT, last_error_json TEXT,
  updated_at_utc TEXT NOT NULL
);
CREATE TABLE run (
  run_id TEXT PRIMARY KEY, status TEXT NOT NULL, config_json TEXT NOT NULL,
  pause_requested INTEGER NOT NULL DEFAULT 0, cancel_requested INTEGER NOT NULL DEFAULT 0,
  created_at_utc TEXT NOT NULL, finished_at_utc TEXT
);
CREATE TABLE artifact_version (
  item_id TEXT NOT NULL, sha256 TEXT NOT NULL, path TEXT NOT NULL,
  size_bytes INTEGER NOT NULL, validation_json TEXT NOT NULL,
  downloaded_at_utc TEXT NOT NULL, PRIMARY KEY (item_id, sha256)
);
```

Habilitar WAL e \`busy_timeout\`; manter operações de rede fora de transações. Antes de cada nova tentativa, gravar \`BAIXANDO\` e incremento de \`attempts\`. Ao capturar exceção, gravar a decisão e \`next_attempt_at_utc\` antes de dormir. Assim uma queda de processo/rede não perde o plano.

### Fluxo de download e retry (referência para implementação)

```python
def acquire_one(item: AcquisitionItem, run: RunContext) -> None:
    if state.has_valid_version(item):
        events.emit("SKIPPED_VALID", item=item)
        return
    while decision := state.claim_if_due(item, run.run_id):
        try:
            part = paths.part_path(item, run.run_id)
            sha256, size = transport.download_streaming(item.url, part, timeout=run.timeout)
            validator.validate_download(item, part, size)
            final = paths.raw_hash_path(item, sha256)
            atomic_promote(part, final)       # os.replace no mesmo volume
            manifest.write_download(item, final, sha256, size)
            state.mark_valid(item, sha256)
            return
        except (OSError, requests.RequestException, ftplib.all_errors) as exc:
            retry = classify_retry(exc, attempt=decision.attempt, policy=run.retry_policy)
            state.record_failure(item, exc, retry)
            if not retry.retryable:
                return
            interruptible_wait(retry.delay_seconds, run.control)
```

Na implementação final, `classify_retry` deve distinguir: `429` e `503` (respeitar \`Retry-After\`), `408`, `425`, `5xx`, `socket.gaierror`, `ConnectionResetError`, `ConnectionRefusedError`, `BrokenPipeError`, `TimeoutError`, exceções `requests` e desconexões FTP como retentáveis; `400`, `401`, `403`, `404` e erro de validação/layout como não retentáveis por padrão. Erros de DNS/conexão durante uma transição manual de IP entram nesse primeiro grupo e não invalidam os artefatos promovidos anteriormente. O número de tentativas é finito; depois passa a \`FALHA_RETENTAVEL\`, nunca fica em loop.

### Download seguro e integridade

`download_streaming` usa blocos de 1 MiB, abre \`*.part\` em modo exclusivo, atualiza SHA-256 por bloco, chama \`flush\` e \`os.fsync\` antes de validar. Não será usado \`resume\` por Range HTTP ou FTP REST no primeiro incremento: ele só será habilitado por protocolo, após teste de servidor que confirme resposta parcial correta e hash final idêntico. Enquanto isso, uma interrupção descarta somente o \`*.part\` do item em curso e reinicia esse item do zero; os objetos promovidos não são tocados.

### Exemplo de configuração inicial

```yaml
runtime:
  output_root: data
  user_agent: "EvoluSUS-academic-pilot/0.1 (contact: PREENCHER_ANTES_DE_RODAR)"
  workers_per_host: 1
  connect_timeout_seconds: 15
  read_timeout_seconds: 90
retry:
  max_attempts: 5
  base_delay_seconds: 5
  max_delay_seconds: 300
  jitter_ratio: 0.20
  cooldown_on_429_seconds: 300
sources:
  ibge_municipios:
    protocol: https
    url: https://servicodados.ibge.gov.br/api/v1/localidades/estados/33/municipios
    expected_format: json
  ibge_populacao_2025:
    protocol: https
    url: https://servicodados.ibge.gov.br/api/v3/agregados/6579/periodos/2025/variaveis/9324?localidades=N6[N3[33]]
    expected_format: json
```

Segredos não são necessários. O campo \`contact\` é obrigatório antes de executar contra fonte pública. URLs e parâmetros de fontes ficam versionados, mas tokens nunca devem ser adicionados ao YAML ou log.

## CLI e controle supervisionável

\`\`\`powershell
python scripts/acquire.py plan --source cnes --uf RJ --year 2025
python scripts/acquire.py run --source cnes,sih,ibge --uf RJ --year 2025 --months 01-12 --workers-per-host 1
python scripts/acquire.py status --run-id <id> --format json
python scripts/acquire.py pause --run-id <id>
python scripts/acquire.py resume --run-id <id>
python scripts/acquire.py cancel --run-id <id> --graceful
python scripts/acquire.py retry --state FALHA_RETENTAVEL
python scripts/acquire.py verify --source cnes --uf RJ --year 2025
\`\`\`

\`run\` imprime resumo humano conciso e eventos JSONL com \`run_id\`, objeto, estado anterior/novo, URL redigida quando necessário, tentativa, espera, HTTP/FTP code, bytes, hash e próxima ação. \`pause\` cria sinal durável; trabalhadores terminam o objeto atual, não iniciam outro e saem. \`cancel --graceful\` faz o mesmo, marcando itens não iniciados como pendentes. Ctrl+C faz a mesma finalização, mantendo \`*.part\` apenas para diagnóstico; retomada reinicia o objeto, salvo se Range/REST for comprovado e validado. Durante transição manual de rede/IP, o operador pode usar \`pause\`, efetuar a mudança e \`resume\`; se não pausar, as exceções transitórias seguem a mesma recuperação automática.

Parâmetros YAML/CLI: \`connect_timeout\`, \`read_timeout\`, \`max_attempts\`, \`base_delay_seconds\`, \`max_delay_seconds\`, \`jitter_ratio\`, \`workers_per_host\`, \`cooldown_on_429_seconds\`, \`output_root\`, \`dry_run\` e filtros. A configuração efetiva é salva no manifesto da execução.

## Algoritmo de aquisição e recuperação

1. Expandir plano determinístico e adquirir lock por chave lógica; listar o plano antes de transferir.
2. Se existir versão com hash e validação aprovados, pular e registrar \`SKIPPED_VALID\`.
3. Baixar para \`*.part\`, calculando SHA-256 durante escrita; nunca expor temporário como válido.
4. Em sucesso, validar tamanho não nulo, assinatura/abertura quando aplicável e integridade; promover atomicamente e registrar \`BAIXADO_VALIDO\`.
5. Converter DBC em tabular temporário, validar abertura, colunas do layout escolhido e contagem; promover e registrar versão/layout/conversor.
6. Em rede, timeout, 408, 425, 429, 5xx ou FTP transitório: esperar \`min(max_delay, base_delay × 2^(tentativa-1))\` com jitter; prevalece \`Retry-After\` válido. Em 401/403, URL inválida, layout incompatível ou corrupção persistente: quarentena com evidência, sem loop infinito.
7. Reexecuções usam estado e manifestos. Mudança de conteúdo no endereço gera versão por hash, mantém a anterior e emite evento de dependência para reprocessamento.

## Validação por fonte

- **CNES/SIH:** nome/competência esperados, SHA-256, conversão concluída, contagem e colunas mínimas confirmadas contra dicionário de versão. Não inferir campos.
- **IBGE:** JSON válido, exatamente 92 municípios RJ, códigos de sete dígitos sem duplicidade; população 2025 conciliada à dimensão, com faltas/divergências bloqueando Gold.
- **SIM:** \`FINAL\` somente para base final oficial; prévio exige \`PRELIMINAR\`, URL exata e data/hora UTC. Ausência de 2025 final é estado esperado.

## Testes e piloto controlado

1. Unitários de backoff, \`Retry-After\`, jitter determinístico, transições, hash, promoção e parâmetros inválidos.
2. Integração com servidor HTTP/FTP local: 429→200, queda no meio, 5xx esgotado, arquivo alterado, falha de DNS/socket simulada e interrupção/reinício. Confirmar que segunda execução não baixa artefato aprovado e que uma reconexão posterior conclui somente o item interrompido.
3. Smoke test IBGE, arquivando resposta, cabeçalhos relevantes e manifesto.
4. Piloto DATASUS: uma competência CNES e uma SIH, um trabalhador/host, em horário de baixa demanda. Medir disponibilidade, volume, tempo, falhas e limites.
5. Somente sem throttling/degradação, comparar 1 vs. 2 trabalhadores por host em conjunto pequeno; manter a menor concorrência suficiente e registrar para a avaliação 002.

## Riscos, custos e reversão

Processamento/armazenamento ficam locais; sem custo OCI nesta etapa. Riscos: endpoint/layout mudado, indisponibilidade FTP, DBC inválido, bloqueio temporário e SIM preliminar. Mitigações: catálogo URL versionado, cache por hash, quarentena, retentativas responsáveis e conversor testado. Para reverter uma versão, mudar o ponteiro ativo; nunca apagar bruto/manifestações como rollback.

## Referências verificadas em 11/08/2026

- [DATASUS — Transferência de Arquivos](https://datasus.saude.gov.br/transferencia-de-arquivos/) disponibiliza a interface oficial, mas não expõe contrato de rate limit na interface consultada.
- [IBGE — documentação da API de agregados v3](https://servicodados.ibge.gov.br/api/docs/agregados?versao=3) e endpoints acima. Ambas as consultas foram testadas por GET; não usar \`HEAD\`, que retornou 405.
- [SIM — painel CID-10](https://svs.aids.gov.br/daent/centrais-de-conteudos/paineis-de-monitoramento/mortalidade/cid10/) informa que 2025 é a 3ª prévia, extraída em 02/04/2026.
- [SIM — portal e dados prévios](https://svs.aids.gov.br/daent/cgiae/coesv/sistemas-informacao/sim/) para identificação da publicação preliminar.

## Próxima aprovação necessária

Antes do piloto DATASUS: validar conversão de uma competência CNES e uma SIH com \`pyreaddbc==2.0.4\`, cuja adoção AGPL-3.0 foi registrada em \`docs/decisoes/001-adocao-pyreaddbc.md\`. A política de uso/substituição do SIM 2025 preliminar permanece decisão científica em aberto.

## Implementação entregue

- \`scripts/acquire.py\` planeja, baixa e consulta estado; não executa transferência com contato-padrão, salvo no cenário explícito de teste local. Dependência de runtime verificada: \`requirements.lock\`.
- \`config/sources.rj-2025.yaml\` contém os 48 objetos mensais obrigatórios CNES/SIH e os dois objetos IBGE, totalizando 50 no ciclo completo. A execução-piloto proposta é \`--months 01\`: 3 CNES + 1 SIH + 2 IBGE = **6 objetos**.
- O conversor DBC está isolado em adaptador opcional e só é chamado com \`--convert-dbc\`, após a instalação do extra e a decisão de licença. Bruto, hash e manifesto continuam preservados mesmo sem conversão.
- Testes locais cobrem plano, retentativa, promoção/manifesta, validação dos 92 municípios IBGE e idempotência; nenhum teste toca fonte pública.

## Resultado do piloto — RJ, competência 01/2025

**Executado em:** 11/08/2026. **Escopo executado:** seis objetos; sem carga OCI e sem expansão mensal.

| Objeto | Estado final | Registros convertidos | Bruto |
|---|---:|---:|---:|
| CNES LT `LTRJ2501.dbc` | `CONVERTIDO_VALIDO` | 3.981 | 46.233 B |
| CNES PF `PFRJ2501.dbc` | `CONVERTIDO_VALIDO` | 518.564 | 26.834.793 B |
| CNES ST `STRJ2501.dbc` | `CONVERTIDO_VALIDO` | 36.227 | 1.680.688 B |
| SIH RD `RDRJ2501.dbc` | `CONVERTIDO_VALIDO` | 75.893 | 5.890.232 B |
| IBGE municípios | `BAIXADO_VALIDO` | n/a | 2.105 B |
| IBGE população 2025 | `BAIXADO_VALIDO` | n/a | 11.580 B |

Os quatro DBC geraram CSVs de 156.341.530 B no total. Brutos, CSVs, manifestos de aquisição, provas de conversão e hashes estão sob `data/` (ignorado pelo Git). O primeiro download do recurso de municípios do IBGE retornou gzip; o validador foi corrigido para reconhecer gzip e a segunda tentativa foi validada. Não houve falha persistente, quarentena ou throttling observado neste piloto.

O piloto demonstra aquisição, conversão e retomada para uma competência; **não aprova ainda a execução massiva**. A liberação dos 12 meses depende da avaliação operacional/custos prevista no plano 002 e da conferência de layouts e totais contra fontes oficiais em amostra documentada.

## Estrutura local de `data/` e política de consolidação

```text
data/
  raw/<sistema>/RJ/<ano>/<mm|annual>/<sha256>/<nome-original>
  converted/<sistema>/RJ/<ano>/<mm>/<sha256>/dados.csv
  manifests/<sistema>/RJ/<ano>/<mm|annual>/<sha256>.json
  manifests/<sistema>/RJ/<ano>/<mm>/<sha256>.conversion.json
  state/acquisition.sqlite
```

- **`raw/`** guarda exatamente o objeto recebido da fonte. O diretório pelo SHA-256 permite manter duas versões do mesmo endereço sem sobrescrita.
- **`converted/`** guarda o resultado técnico da conversão DBC. O nome `dados.csv` é propositalmente genérico: o caminho completo — em especial sistema, competência e hash — é sua identidade.
- **`manifests/`** contém a proveniência do download; o sufixo `.conversion.json` registra conversor, versão, saída e número de registros.
- **`state/`** é o controle operacional SQLite (estados, tentativas e ponteiro do hash ativo), não uma fonte analítica e não deve ser carregado para OCI/OAC.

No piloto existem quatro CSVs, e **eles não devem ser unidos em um único arquivo**: possuem grãos e esquemas diferentes.

| CSV atual | Papel | Regra de consolidação futura |
|---|---|---|
| CNES LT | estoque de leitos por estabelecimento/tipo | anexar somente as 12 competências `LT` em uma tabela Silver de leitos; não anexar PF/ST. |
| CNES PF | vínculos/carga horária de profissionais | anexar somente as competências `PF`, preservando vínculo, profissional e competência. |
| CNES ST | cadastro/fotografia de estabelecimentos | anexar somente as competências `ST`; tratar como fotografia mensal, não como soma de estoque. |
| SIH RD | AIHs/internações | anexar somente as competências `RD`; manter AIH/estabelecimento, residência e atendimento para os dois recortes geográficos. |

A consolidação será criada somente após a coleta das 12 competências e validação de layout. Ela produzirá, no máximo, um conjunto particionado por modalidade (`CNES_LT`, `CNES_PF`, `CNES_ST`, `SIH_RD`) e nunca apagará os CSVs por competência. Cada linha consolidada deverá receber `ANO_COMPETENCIA`, `MES_COMPETENCIA`, `SHA256_ORIGEM`, `ARQUIVO_ORIGEM` e `VERSAO_CONVERSOR`. Transformações analíticas, dimensões e agregações município × mês pertencem ao plano 003; não serão feitas por simples concatenação nesta etapa.

### Execução completa 2025 e consolidação

Após o piloto aprovado, a execução completa baixa as 11 competências restantes de cada modalidade (`LT`, `PF`, `ST`, `RD`), totalizando **44 DBC adicionais**. Os dois recursos IBGE já validados são reutilizados sem novo download. Ao terminar, `scripts/consolidate.py` exige os 12 CSVs convertidos de cada modalidade e cria, por modalidade, `data/consolidated/<modalidade>/RJ/2025/dados.csv` e `provenance.csv`.

O consolidador processa os CSVs em streaming, interrompe caso haja competência ausente e anexa os campos de rastreabilidade. Para evolução aditiva de layout, produz a união explícita das colunas e preenche com vazio a coluna ainda inexistente em competências anteriores; cada linha e `provenance.csv` recebem `LAYOUT_SHA256`. Mudança não aditiva, semântica ambígua ou tipo incompatível continua exigindo quarentena/revisão antes da camada Silver. A escrita ocorre em `.part` e é promovida atomicamente; falha não altera a consolidação anterior. Critério de aceite: quatro consolidados, 12 competências distintas em cada `provenance.csv` e nenhuma competência ausente/duplicada.

Na execução de 2025, SIH `RD` apresentou evolução aditiva: janeiro–fevereiro têm 113 colunas e março–dezembro adicionam `FONTE_ORC` (114 colunas). A consolidação anual preserva a coluna e deixa-a vazia nos dois primeiros meses, com `LAYOUT_SHA256` para distinguir os layouts.

### Resultado da execução completa — RJ/2025

**Executado em:** 11/08/2026. Os 48 DBC previstos (36 CNES e 12 SIH) foram obtidos, convertidos e mantidos com manifesto; os dois objetos IBGE previamente validados completam os 50 objetos do escopo. Não há item pendente, em falha ou quarentena no estado final.

| Consolidado | Competências | Registros | Tamanho CSV | Layouts |
|---|---:|---:|---:|---:|
| `cnes_lt` | 12 | 47.681 | 12.774.436 B | 1 |
| `cnes_pf` | 12 | 6.370.387 | 2.350.156.795 B | 1 |
| `cnes_st` | 12 | 450.770 | 289.337.530 B | 1 |
| `sih_rd` | 12 | 926.214 | 583.445.690 B | 2 |

Volume local ao fim da execução: bruto 423.729.415 B; CSVs convertidos mensais 1.926.035.860 B; consolidados 3.235.722.775 B. A duplicação é intencional nesta fase para preservar a trilha de auditoria, mas esses brutos/CSVs não devem ser enviados integralmente à OCI. O próximo plano deve definir camada Silver/Gold compacta (preferencialmente Parquet/tabelas) e retenção local antes de qualquer carga em nuvem.
