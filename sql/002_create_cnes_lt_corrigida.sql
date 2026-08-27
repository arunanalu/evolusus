-- Executar conectado como EVOLUSUS_STG (ou como ADMIN qualificando o schema).
-- Regra de correção: REGSAUDE é código alfanumérico, portanto VARCHAR2(10).

CREATE TABLE EVOLUSUS_STG.CNES_LT_DATA_CORRIGIDA (
    CNES               VARCHAR2(7),
    CODUFMUN           VARCHAR2(7),
    REGSAUDE           VARCHAR2(10),
    MICR_REG           VARCHAR2(10),
    DISTRSAN           VARCHAR2(10),
    DISTRADM           VARCHAR2(10),
    TPGESTAO           VARCHAR2(2),
    PF_PJ              VARCHAR2(1),
    CPF_CNPJ           VARCHAR2(14),
    NIV_DEP            VARCHAR2(2),
    CNPJ_MAN           VARCHAR2(14),
    ESFERA_A           VARCHAR2(2),
    ATIVIDAD           VARCHAR2(2),
    RETENCAO           VARCHAR2(2),
    NATUREZA           VARCHAR2(2),
    CLIENTEL           VARCHAR2(2),
    TP_UNID            VARCHAR2(2),
    TURNO_AT           VARCHAR2(2),
    NIV_HIER           VARCHAR2(2),
    TERCEIRO           VARCHAR2(1),
    TP_LEITO           VARCHAR2(2),
    CODLEITO           VARCHAR2(2),
    QT_EXIST           NUMBER(10),
    QT_CONTR           NUMBER(10),
    QT_SUS             NUMBER(10),
    QT_NSUS            NUMBER(10),
    COMPETEN           VARCHAR2(6),
    NAT_JUR            VARCHAR2(4),
    ANO_COMPETENCIA    NUMBER(4),
    MES_COMPETENCIA    VARCHAR2(2),
    SHA256_ORIGEM      VARCHAR2(64),
    ARQUIVO_ORIGEM     VARCHAR2(255),
    VERSAO_CONVERSOR   VARCHAR2(50),
    LAYOUT_SHA256      VARCHAR2(64),
    CARGADO_EM_UTC     TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL
);

COMMENT ON TABLE EVOLUSUS_STG.CNES_LT_DATA_CORRIGIDA IS
  'Carga Silver corrigida de CNES LT/RJ/2025. REGSAUDE armazenada como texto.';

COMMENT ON COLUMN EVOLUSUS_STG.CNES_LT_DATA_CORRIGIDA.REGSAUDE IS
  'Código da região de saúde do CNES; pode conter letras e pontuação, portanto não é numérico.';
