# EvoluSUS

**EvoluSUS** é um projeto acadêmico de Engenharia e Análise de Dados aplicado à saúde pública brasileira.

O projeto integra dados reais de **CNES, SIH-SUS, SIM e IBGE** para analisar a relação entre **capacidade hospitalar, utilização dos serviços e desfechos em saúde**.

## Objetivo

O principal produto científico do projeto é o **Índice de Pressão Hospitalar (IPH)**: uma métrica desenvolvida para estimar a pressão relativa exercida sobre a infraestrutura hospitalar dos municípios.

A pergunta central da pesquisa é:

> Municípios com menor capacidade hospitalar e maior pressão assistencial apresentam piores desfechos em saúde?

O IPH considera dimensões relacionadas a:

- capacidade hospitalar;
- disponibilidade de leitos e profissionais;
- utilização e internações;
- permanência hospitalar;
- pressão territorial e fluxo de pacientes;
- sazonalidade da demanda.

Mortalidade é tratada prioritariamente como **variável externa de validação**, evitando circularidade na construção do índice.

## Escopo atual

O MVP utiliza:

- **Território:** 92 municípios do Estado do Rio de Janeiro;
- **Período piloto:** janeiro a dezembro de 2025;
- **Granularidade principal:** município × mês;
- **Fontes:** CNES, SIH-SUS, SIM e IBGE;
- **Dados:** exclusivamente dados públicos reais.

Após a validação do piloto, o projeto prevê expansão da série histórica para **2023–2025**.

## Pipeline

```text
DATASUS / IBGE
      ↓
Aquisição e validação
      ↓
Conversão e rastreabilidade
      ↓
Consolidação e tratamento
      ↓
Modelo analítico
      ↓
Cálculo e validação do IPH
      ↓
Oracle / OCI
      ↓
Oracle Analytics Cloud
```

O processamento pesado é realizado prioritariamente em **Python localmente**, reduzindo custos de infraestrutura. A arquitetura-alvo utiliza o ecossistema **Oracle Cloud Infrastructure (OCI)** para armazenamento, integração, camada analítica e visualização.

## Rastreabilidade

Cada arquivo adquirido possui informações de proveniência, incluindo:

- fonte e URL original;
- competência;
- data de aquisição;
- hash SHA-256;
- versão do conversor;
- quantidade de registros;
- situação da fonte;
- resultado das validações.

O pipeline foi projetado para ser **reprodutível e idempotente**, evitando downloads e processamentos duplicados.

## Tecnologias

- Python 3.10+
- PyYAML
- Pandas
- PyReadDBC
- SQL
- SQLite para controle do estado de aquisição
- Oracle Cloud Infrastructure
- Oracle Analytics Cloud

## Estrutura

```text
config/                     Configuração das fontes
data/consolidated/          Dados consolidados
docs/                       Arquitetura, decisões e planejamento
scripts/                    Aquisição, consolidação e processamento
sql/                        Estruturas e transformações SQL
src/evolusus_acquisition/   Pipeline de aquisição
tests/                      Testes automatizados
AGENTS.md                    Contexto técnico e metodológico completo
```

## Execução básica

Instale o projeto:

```bash
pip install -e .
```

Planeje uma aquisição:

```bash
python scripts/acquire.py plan --months 01-12
```

Execute a aquisição:

```bash
python scripts/acquire.py run --months 01-12
```

Consulte o estado do pipeline:

```bash
python scripts/acquire.py status
```

Execute os testes:

```bash
pytest
```

## Arquitetura-alvo

```text
DATASUS / IBGE
       ↓
Oracle Integration / OCI Functions
       ↓
OCI Object Storage
       ↓
OCI Data Integration
       ↓
Oracle Database / Lakehouse
       ↓
Oracle Analytics Cloud
```

Durante o MVP, partes desse fluxo são executadas localmente para garantir **viabilidade acadêmica, rastreabilidade e controle de custos**, mantendo um caminho explícito de implantação no ecossistema Oracle.

## Resultado esperado

O EvoluSUS busca entregar:

1. um pipeline reproduzível de integração de dados públicos de saúde;
2. uma camada analítica municipal e temporal;
3. o desenvolvimento e validação científica do **Índice de Pressão Hospitalar (IPH)**;
4. análises sobre desigualdade de capacidade e pressão hospitalar;
5. visualizações e dashboards para exploração dos resultados.

---

**EvoluSUS transforma dados públicos fragmentados do SUS em informação analítica rastreável para investigar onde e quando a infraestrutura hospitalar está sob maior pressão.**