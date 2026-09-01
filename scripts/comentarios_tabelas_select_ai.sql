-- =============================================================================
-- EvoluSUS — Comentários para Oracle Select AI
-- =============================================================================
-- Objetivo: Adicionar comentários descritivos em todas as tabelas e colunas
-- carregadas no Oracle Autonomous Database para que o Oracle Select AI
-- interprete corretamente o significado dos dados ao gerar SQL a partir
-- de perguntas em linguagem natural.
--
-- Tabelas cobertas:
--   1. DADOS_CNES_LT           — Leitos hospitalares (CNES)
--   2. DADOS_CNES_PF           — Profissionais de saúde (CNES)
--   3. DADOS_CNES_ST           — Estabelecimentos de saúde (CNES)
--   4. DADOS_SIH_RD            — Internações hospitalares AIH (SIH-SUS)
--   5. IBGE_DEMOGRAFICO_RJ     — Demografia municipal IBGE
--   6. PROVENANCE_CNES_LT      — Rastreabilidade da ingestão de leitos
--   7. PROVENANCE_CNES_PF      — Rastreabilidade da ingestão de profissionais
--   8. PROVENANCE_CNES_ST      — Rastreabilidade da ingestão de estabelecimentos
--   9. PROVENANCE_SIH_RD       — Rastreabilidade da ingestão de internações
--  10. V_AGREG_CNES_LEITOS     — View agregada de leitos SUS por município/mês
--  11. V_AGREG_SIH_INTERNACOES — View agregada de internações por município/mês
--  12. TB_ANALYTICS_IPH_RJ     — Tabela Golden analítica com o IPH calculado
--
-- Uso: Execute este script no SQL Worksheet do Database Actions (ADMIN).
-- =============================================================================


-- =============================================================================
-- 1. DADOS_CNES_LT — Leitos hospitalares do CNES (RJ, 2025)
-- =============================================================================
COMMENT ON TABLE DADOS_CNES_LT IS
'Cadastro Nacional de Estabelecimentos de Saude (CNES) - Leitos hospitalares do estado do Rio de Janeiro, competencias de janeiro a dezembro de 2025. Cada linha representa um registro de leito em um estabelecimento de saude, com tipo de leito, quantidade existente, quantidade SUS e quantidade nao-SUS. Fotografia mensal: nao somar estoques entre meses.';

COMMENT ON COLUMN DADOS_CNES_LT.CNES IS 'Codigo CNES do estabelecimento de saude (7 digitos)';
COMMENT ON COLUMN DADOS_CNES_LT.CODUFMUN IS 'Codigo IBGE do municipio do estabelecimento (6 digitos, sem digito verificador)';
COMMENT ON COLUMN DADOS_CNES_LT.REGSAUDE IS 'Codigo da regiao de saude do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_LT.MICR_REG IS 'Codigo da microrregiao de saude';
COMMENT ON COLUMN DADOS_CNES_LT.DISTRSAN IS 'Codigo do distrito sanitario';
COMMENT ON COLUMN DADOS_CNES_LT.DISTRADM IS 'Codigo do distrito administrativo';
COMMENT ON COLUMN DADOS_CNES_LT.TPGESTAO IS 'Tipo de gestao: M=Municipal, E=Estadual, D=Dupla, S=Sem gestao';
COMMENT ON COLUMN DADOS_CNES_LT.PF_PJ IS 'Tipo de pessoa: 1=Pessoa Fisica, 3=Pessoa Juridica';
COMMENT ON COLUMN DADOS_CNES_LT.CPF_CNPJ IS 'CPF ou CNPJ do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_LT.NIV_DEP IS 'Nivel de dependencia: 1=Individual, 3=Mantido';
COMMENT ON COLUMN DADOS_CNES_LT.CNPJ_MAN IS 'CNPJ da entidade mantenedora';
COMMENT ON COLUMN DADOS_CNES_LT.ESFERA_A IS 'Esfera administrativa: 01=Federal, 02=Estadual, 03=Municipal, 04=Privada';
COMMENT ON COLUMN DADOS_CNES_LT.ATIVIDAD IS 'Codigo da atividade de ensino/pesquisa';
COMMENT ON COLUMN DADOS_CNES_LT.RETENCAO IS 'Codigo de retencao (fluxo de clientela)';
COMMENT ON COLUMN DADOS_CNES_LT.NATUREZA IS 'Natureza da organizacao do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_LT.CLIENTEL IS 'Tipo de clientela: 01=SUS, 02=Particular, 03=Plano de Saude';
COMMENT ON COLUMN DADOS_CNES_LT.TP_UNID IS 'Tipo de unidade/estabelecimento (ex: 05=Hospital Geral, 07=Hospital Especializado)';
COMMENT ON COLUMN DADOS_CNES_LT.TURNO_AT IS 'Turno de atendimento';
COMMENT ON COLUMN DADOS_CNES_LT.NIV_HIER IS 'Nivel de hierarquia do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_LT.TERCEIRO IS 'Indica se o estabelecimento e terceirizado (S/N)';
COMMENT ON COLUMN DADOS_CNES_LT.TP_LEITO IS 'Tipo de leito: 1=Internacao, 2=Day Hospital/Repouso, 3=Intermediario';
COMMENT ON COLUMN DADOS_CNES_LT.CODLEITO IS 'Codigo especifico do leito conforme tabela CNES (ex: 64=Clinica Medica, 74=UTI Adulto, 76=UTI Neonatal, 80=Obstetricia Clinica, 87=Complementar)';
COMMENT ON COLUMN DADOS_CNES_LT.QT_EXIST IS 'Quantidade total de leitos existentes neste registro';
COMMENT ON COLUMN DADOS_CNES_LT.QT_CONTR IS 'Quantidade de leitos contratados/conveniados';
COMMENT ON COLUMN DADOS_CNES_LT.QT_SUS IS 'Quantidade de leitos disponiveis para o SUS. Coluna principal para calcular a capacidade hospitalar publica';
COMMENT ON COLUMN DADOS_CNES_LT.QT_NSUS IS 'Quantidade de leitos nao-SUS (particulares ou planos de saude)';
COMMENT ON COLUMN DADOS_CNES_LT.COMPETEN IS 'Competencia no formato AAAAMM (ex: 202501 = janeiro de 2025)';
COMMENT ON COLUMN DADOS_CNES_LT.NAT_JUR IS 'Natureza juridica do estabelecimento conforme tabela da Receita Federal';
COMMENT ON COLUMN DADOS_CNES_LT.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025). Campo de rastreabilidade adicionado na consolidacao';
COMMENT ON COLUMN DADOS_CNES_LT.MES_COMPETENCIA IS 'Mes da competencia (01 a 12). Campo de rastreabilidade adicionado na consolidacao';
COMMENT ON COLUMN DADOS_CNES_LT.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original para rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_LT.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem (ex: LTRJ2501.dbc)';
COMMENT ON COLUMN DADOS_CNES_LT.VERSAO_CONVERSOR IS 'Versao do conversor DBC utilizado (ex: pyreaddbc==2.0.4)';
COMMENT ON COLUMN DADOS_CNES_LT.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados utilizado na conversao';


-- =============================================================================
-- 2. DADOS_CNES_PF — Profissionais de saúde do CNES (RJ, 2025)
-- =============================================================================
COMMENT ON TABLE DADOS_CNES_PF IS
'Cadastro Nacional de Estabelecimentos de Saude (CNES) - Profissionais de saude vinculados a estabelecimentos do estado do Rio de Janeiro, competencias de janeiro a dezembro de 2025. Cada linha representa um vinculo profissional em um estabelecimento. Um mesmo profissional pode ter multiplos vinculos em estabelecimentos diferentes. Usar carga horaria (HORAHOSP, HORA_AMB) para calcular profissionais equivalentes a tempo integral (FTE).';

COMMENT ON COLUMN DADOS_CNES_PF.CNES IS 'Codigo CNES do estabelecimento de saude (7 digitos)';
COMMENT ON COLUMN DADOS_CNES_PF.CODUFMUN IS 'Codigo IBGE do municipio do estabelecimento (6 digitos, sem digito verificador)';
COMMENT ON COLUMN DADOS_CNES_PF.REGSAUDE IS 'Codigo da regiao de saude do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.MICR_REG IS 'Codigo da microrregiao de saude';
COMMENT ON COLUMN DADOS_CNES_PF.DISTRSAN IS 'Codigo do distrito sanitario';
COMMENT ON COLUMN DADOS_CNES_PF.DISTRADM IS 'Codigo do distrito administrativo';
COMMENT ON COLUMN DADOS_CNES_PF.TPGESTAO IS 'Tipo de gestao: M=Municipal, E=Estadual, D=Dupla';
COMMENT ON COLUMN DADOS_CNES_PF.PF_PJ IS 'Tipo de pessoa: 1=Pessoa Fisica, 3=Pessoa Juridica';
COMMENT ON COLUMN DADOS_CNES_PF.CPF_CNPJ IS 'CPF ou CNPJ do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.NIV_DEP IS 'Nivel de dependencia do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.CNPJ_MAN IS 'CNPJ da entidade mantenedora';
COMMENT ON COLUMN DADOS_CNES_PF.ESFERA_A IS 'Esfera administrativa: 01=Federal, 02=Estadual, 03=Municipal, 04=Privada';
COMMENT ON COLUMN DADOS_CNES_PF.ATIVIDAD IS 'Codigo da atividade de ensino/pesquisa';
COMMENT ON COLUMN DADOS_CNES_PF.RETENCAO IS 'Codigo de retencao';
COMMENT ON COLUMN DADOS_CNES_PF.NATUREZA IS 'Natureza da organizacao do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.CLIENTEL IS 'Tipo de clientela atendida';
COMMENT ON COLUMN DADOS_CNES_PF.TP_UNID IS 'Tipo de unidade/estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.TURNO_AT IS 'Turno de atendimento';
COMMENT ON COLUMN DADOS_CNES_PF.NIV_HIER IS 'Nivel de hierarquia do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.TERCEIRO IS 'Indica se o estabelecimento e terceirizado';
COMMENT ON COLUMN DADOS_CNES_PF.CPF_PROF IS 'CPF do profissional (dado sensivel, pode estar mascarado)';
COMMENT ON COLUMN DADOS_CNES_PF.CPFUNICO IS 'Indica se o CPF e unico no cadastro: 1=Sim';
COMMENT ON COLUMN DADOS_CNES_PF.CBO IS 'Codigo Brasileiro de Ocupacoes (CBO) do profissional. Identifica a ocupacao: 225 = medicos, 223 = enfermeiros';
COMMENT ON COLUMN DADOS_CNES_PF.CBOUNICO IS 'CBO unico do profissional';
COMMENT ON COLUMN DADOS_CNES_PF.NOMEPROF IS 'Nome do profissional de saude';
COMMENT ON COLUMN DADOS_CNES_PF.CNS_PROF IS 'Cartao Nacional de Saude (CNS) do profissional';
COMMENT ON COLUMN DADOS_CNES_PF.CONSELHO IS 'Codigo do conselho profissional (ex: CRM, COREN)';
COMMENT ON COLUMN DADOS_CNES_PF.REGISTRO IS 'Numero de registro no conselho profissional';
COMMENT ON COLUMN DADOS_CNES_PF.VINCULAC IS 'Tipo de vinculo empregaticio conforme tabela CNES';
COMMENT ON COLUMN DADOS_CNES_PF.VINCUL_C IS 'Vinculo contratista';
COMMENT ON COLUMN DADOS_CNES_PF.VINCUL_A IS 'Vinculo autonomo';
COMMENT ON COLUMN DADOS_CNES_PF.VINCUL_N IS 'Vinculo nenhum';
COMMENT ON COLUMN DADOS_CNES_PF.PROF_SUS IS 'Indica se o profissional atende pelo SUS: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_PF.PROFNSUS IS 'Indica se o profissional atende fora do SUS: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_PF.HORAOUTR IS 'Carga horaria semanal em outras atividades (horas)';
COMMENT ON COLUMN DADOS_CNES_PF.HORAHOSP IS 'Carga horaria semanal hospitalar (horas). Usar para calculo de FTE hospitalar';
COMMENT ON COLUMN DADOS_CNES_PF.HORA_AMB IS 'Carga horaria semanal ambulatorial (horas). Usar para calculo de FTE ambulatorial';
COMMENT ON COLUMN DADOS_CNES_PF.COMPETEN IS 'Competencia no formato AAAAMM (ex: 202501 = janeiro de 2025)';
COMMENT ON COLUMN DADOS_CNES_PF.UFMUNRES IS 'Codigo IBGE do municipio de residencia do profissional (6 digitos)';
COMMENT ON COLUMN DADOS_CNES_PF.NAT_JUR IS 'Natureza juridica do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_PF.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025). Campo de rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_PF.MES_COMPETENCIA IS 'Mes da competencia (01 a 12). Campo de rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_PF.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original para rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_PF.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem (ex: PFRJ2501.dbc)';
COMMENT ON COLUMN DADOS_CNES_PF.VERSAO_CONVERSOR IS 'Versao do conversor DBC utilizado';
COMMENT ON COLUMN DADOS_CNES_PF.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados utilizado na conversao';


-- =============================================================================
-- 3. DADOS_CNES_ST — Estabelecimentos de saúde do CNES (RJ, 2025)
-- =============================================================================
COMMENT ON TABLE DADOS_CNES_ST IS
'Cadastro Nacional de Estabelecimentos de Saude (CNES) - Cadastro de estabelecimentos de saude do estado do Rio de Janeiro, competencias de janeiro a dezembro de 2025. Cada linha e uma fotografia mensal de um estabelecimento com suas caracteristicas, infraestrutura, leitos resumidos, instalacoes e servicos de apoio. Nao acumular entre meses.';

COMMENT ON COLUMN DADOS_CNES_ST.CNES IS 'Codigo CNES do estabelecimento de saude (7 digitos). Chave principal do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_ST.CODUFMUN IS 'Codigo IBGE do municipio do estabelecimento (6 digitos)';
COMMENT ON COLUMN DADOS_CNES_ST.COD_CEP IS 'CEP do endereco do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_ST.CPF_CNPJ IS 'CPF ou CNPJ do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_ST.PF_PJ IS 'Tipo de pessoa: 1=Fisica, 3=Juridica';
COMMENT ON COLUMN DADOS_CNES_ST.NIV_DEP IS 'Nivel de dependencia: 1=Individual, 3=Mantido';
COMMENT ON COLUMN DADOS_CNES_ST.CNPJ_MAN IS 'CNPJ da entidade mantenedora';
COMMENT ON COLUMN DADOS_CNES_ST.COD_IR IS 'Codigo de retencao de IR';
COMMENT ON COLUMN DADOS_CNES_ST.REGSAUDE IS 'Codigo da regiao de saude';
COMMENT ON COLUMN DADOS_CNES_ST.MICR_REG IS 'Codigo da microrregiao de saude';
COMMENT ON COLUMN DADOS_CNES_ST.DISTRSAN IS 'Codigo do distrito sanitario';
COMMENT ON COLUMN DADOS_CNES_ST.DISTRADM IS 'Codigo do distrito administrativo';
COMMENT ON COLUMN DADOS_CNES_ST.VINC_SUS IS 'Vinculo com o SUS: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.TPGESTAO IS 'Tipo de gestao: M=Municipal, E=Estadual, D=Dupla';
COMMENT ON COLUMN DADOS_CNES_ST.ESFERA_A IS 'Esfera administrativa';
COMMENT ON COLUMN DADOS_CNES_ST.RETENCAO IS 'Retencao de fluxo de clientela';
COMMENT ON COLUMN DADOS_CNES_ST.ATIVIDAD IS 'Atividade de ensino/pesquisa';
COMMENT ON COLUMN DADOS_CNES_ST.NATUREZA IS 'Natureza organizacional';
COMMENT ON COLUMN DADOS_CNES_ST.CLIENTEL IS 'Tipo de clientela atendida';
COMMENT ON COLUMN DADOS_CNES_ST.TP_UNID IS 'Tipo de unidade (ex: 01=Posto de Saude, 02=Centro de Saude, 05=Hospital Geral, 07=Hospital Especializado, 22=Consultorio)';
COMMENT ON COLUMN DADOS_CNES_ST.TURNO_AT IS 'Turno de atendimento';
COMMENT ON COLUMN DADOS_CNES_ST.NIV_HIER IS 'Nivel de hierarquia';
COMMENT ON COLUMN DADOS_CNES_ST.TP_PREST IS 'Tipo de prestador';
COMMENT ON COLUMN DADOS_CNES_ST.CO_BANCO IS 'Codigo do banco para pagamento';
COMMENT ON COLUMN DADOS_CNES_ST.CO_AGENC IS 'Codigo da agencia bancaria';
COMMENT ON COLUMN DADOS_CNES_ST.C_CORREN IS 'Conta corrente';
COMMENT ON COLUMN DADOS_CNES_ST.CONTRATM IS 'Numero do contrato municipal';
COMMENT ON COLUMN DADOS_CNES_ST.DT_PUBLM IS 'Data de publicacao do contrato municipal';
COMMENT ON COLUMN DADOS_CNES_ST.CONTRATE IS 'Numero do contrato estadual';
COMMENT ON COLUMN DADOS_CNES_ST.DT_PUBLE IS 'Data de publicacao do contrato estadual';
COMMENT ON COLUMN DADOS_CNES_ST.ALVARA IS 'Numero do alvara sanitario';
COMMENT ON COLUMN DADOS_CNES_ST.DT_EXPED IS 'Data de expedicao do alvara sanitario';
COMMENT ON COLUMN DADOS_CNES_ST.ORGEXPED IS 'Orgao expedidor do alvara';
COMMENT ON COLUMN DADOS_CNES_ST.AV_ACRED IS 'Indicador de acreditacao hospitalar';
COMMENT ON COLUMN DADOS_CNES_ST.CLASAVAL IS 'Classificacao da avaliacao de acreditacao';
COMMENT ON COLUMN DADOS_CNES_ST.DT_ACRED IS 'Data de acreditacao';
COMMENT ON COLUMN DADOS_CNES_ST.AV_PNASS IS 'Avaliacao do PNASS (Programa Nacional de Avaliacao de Servicos de Saude)';
COMMENT ON COLUMN DADOS_CNES_ST.DT_PNASS IS 'Data da avaliacao PNASS';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG1E IS 'Gestao/Programa Saude da Familia estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG1M IS 'Gestao/Programa Saude da Familia municipal';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG2E IS 'Gestao/Programa de Agentes Comunitarios estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG2M IS 'Gestao/Programa de Agentes Comunitarios municipal';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG4E IS 'Programa de gestao 4 estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG4M IS 'Programa de gestao 4 municipal';
COMMENT ON COLUMN DADOS_CNES_ST.NIVATE_A IS 'Nivel de atencao ambulatorial';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG3E IS 'Programa de gestao 3 estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG3M IS 'Programa de gestao 3 municipal';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG5E IS 'Programa de gestao 5 estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG5M IS 'Programa de gestao 5 municipal';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG6E IS 'Programa de gestao 6 estadual';
COMMENT ON COLUMN DADOS_CNES_ST.GESPRG6M IS 'Programa de gestao 6 municipal';
COMMENT ON COLUMN DADOS_CNES_ST.NIVATE_H IS 'Nivel de atencao hospitalar';
COMMENT ON COLUMN DADOS_CNES_ST.QTLEITP1 IS 'Quantidade de leitos de internacao SUS';
COMMENT ON COLUMN DADOS_CNES_ST.QTLEITP2 IS 'Quantidade de leitos de internacao nao-SUS';
COMMENT ON COLUMN DADOS_CNES_ST.QTLEITP3 IS 'Quantidade de leitos complementares';
COMMENT ON COLUMN DADOS_CNES_ST.LEITHOSP IS 'Indica se possui leitos hospitalares: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.URGEMERG IS 'Indica atendimento de urgencia/emergencia: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.ATENDAMB IS 'Indica atendimento ambulatorial: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.CENTRCIR IS 'Indica se possui centro cirurgico: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.CENTROBS IS 'Indica se possui centro obstetrico: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.CENTRNEO IS 'Indica se possui centro neonatal: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.ATENDHOS IS 'Indica atendimento hospitalar: 0=Nao, 1=Sim';
COMMENT ON COLUMN DADOS_CNES_ST.SERAPOIO IS 'Servicos de apoio disponibilizados';
COMMENT ON COLUMN DADOS_CNES_ST.RES_BIOL IS 'Gerenciamento de residuos biologicos';
COMMENT ON COLUMN DADOS_CNES_ST.RES_QUIM IS 'Gerenciamento de residuos quimicos';
COMMENT ON COLUMN DADOS_CNES_ST.RES_RADI IS 'Gerenciamento de residuos radioativos';
COMMENT ON COLUMN DADOS_CNES_ST.RES_COMU IS 'Gerenciamento de residuos comuns';
COMMENT ON COLUMN DADOS_CNES_ST.COLETRES IS 'Coleta de residuos';
COMMENT ON COLUMN DADOS_CNES_ST.COMISSAO IS 'Comissoes ativas no estabelecimento';
COMMENT ON COLUMN DADOS_CNES_ST.ATEND_PR IS 'Indica atendimento prestado';
COMMENT ON COLUMN DADOS_CNES_ST.DT_ATUAL IS 'Data da ultima atualizacao do cadastro (formato AAAAMM)';
COMMENT ON COLUMN DADOS_CNES_ST.COMPETEN IS 'Competencia no formato AAAAMM (ex: 202501 = janeiro de 2025)';
COMMENT ON COLUMN DADOS_CNES_ST.NAT_JUR IS 'Natureza juridica do estabelecimento';
COMMENT ON COLUMN DADOS_CNES_ST.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025). Campo de rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_ST.MES_COMPETENCIA IS 'Mes da competencia (01 a 12). Campo de rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_ST.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original para rastreabilidade';
COMMENT ON COLUMN DADOS_CNES_ST.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem (ex: STRJ2501.dbc)';
COMMENT ON COLUMN DADOS_CNES_ST.VERSAO_CONVERSOR IS 'Versao do conversor DBC utilizado';
COMMENT ON COLUMN DADOS_CNES_ST.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados utilizado na conversao';


-- =============================================================================
-- 4. DADOS_SIH_RD — Internações hospitalares AIH Reduzida (RJ, 2025)
-- =============================================================================
COMMENT ON TABLE DADOS_SIH_RD IS
'Sistema de Informacoes Hospitalares do SUS (SIH-SUS) - Autorizacoes de Internacao Hospitalar (AIH) reduzidas do estado do Rio de Janeiro, competencias de janeiro a dezembro de 2025. Cada linha e uma internacao hospitalar financiada pelo SUS com informacoes de paciente, diagnostico, procedimento, valores pagos, dias de permanencia e desfecho (obito ou alta). Nao representa todas as internacoes do territorio, apenas as financiadas pelo SUS.';

COMMENT ON COLUMN DADOS_SIH_RD.UF_ZI IS 'Codigo da UF de processamento da AIH (330000 = Rio de Janeiro)';
COMMENT ON COLUMN DADOS_SIH_RD.ANO_CMPT IS 'Ano de competencia da AIH (ex: 2025)';
COMMENT ON COLUMN DADOS_SIH_RD.MES_CMPT IS 'Mes de competencia da AIH (01 a 12)';
COMMENT ON COLUMN DADOS_SIH_RD.ESPEC IS 'Especialidade do leito utilizado na internacao';
COMMENT ON COLUMN DADOS_SIH_RD.CGC_HOSP IS 'CNPJ do hospital onde ocorreu a internacao';
COMMENT ON COLUMN DADOS_SIH_RD.N_AIH IS 'Numero da Autorizacao de Internacao Hospitalar (AIH). Identificador unico da internacao';
COMMENT ON COLUMN DADOS_SIH_RD.IDENT IS 'Identificacao do tipo de AIH: 1=Normal, 5=Longa permanencia';
COMMENT ON COLUMN DADOS_SIH_RD.CEP IS 'CEP de residencia do paciente';
COMMENT ON COLUMN DADOS_SIH_RD.MUNIC_RES IS 'Codigo IBGE do municipio de residencia do paciente (6 digitos). Usar para perspectiva da populacao';
COMMENT ON COLUMN DADOS_SIH_RD.NASC IS 'Data de nascimento do paciente (formato AAAAMMDD)';
COMMENT ON COLUMN DADOS_SIH_RD.SEXO IS 'Sexo do paciente: 1=Masculino, 3=Feminino';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_MES_IN IS 'Dias de UTI no mes de internacao';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_MES_AN IS 'Dias de UTI no mes anterior';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_MES_AL IS 'Dias de UTI no mes de alta';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_MES_TO IS 'Total de dias de UTI nesta internacao';
COMMENT ON COLUMN DADOS_SIH_RD.MARCA_UTI IS 'Marcador de tipo de UTI utilizada';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_INT_IN IS 'Dias de UTI intermediaria no mes de internacao';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_INT_AN IS 'Dias de UTI intermediaria no mes anterior';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_INT_AL IS 'Dias de UTI intermediaria no mes de alta';
COMMENT ON COLUMN DADOS_SIH_RD.UTI_INT_TO IS 'Total de dias de UTI intermediaria';
COMMENT ON COLUMN DADOS_SIH_RD.DIAR_ACOM IS 'Diarias de acompanhante';
COMMENT ON COLUMN DADOS_SIH_RD.QT_DIARIAS IS 'Quantidade total de diarias da internacao';
COMMENT ON COLUMN DADOS_SIH_RD.PROC_SOLIC IS 'Codigo do procedimento solicitado na AIH';
COMMENT ON COLUMN DADOS_SIH_RD.PROC_REA IS 'Codigo do procedimento realizado na AIH';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SH IS 'Valor dos servicos hospitalares (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SP IS 'Valor dos servicos profissionais (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SADT IS 'Valor dos servicos auxiliares de diagnostico e terapia (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_RN IS 'Valor referente ao recem-nascido (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_ACOMP IS 'Valor de acompanhante (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_ORTP IS 'Valor de ortese/protese (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SANGUE IS 'Valor de sangue e hemoderivados (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SADTSR IS 'Valor de SADT servico de referencia (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_TRANSP IS 'Valor de transplante (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_OBSANG IS 'Valor de obstetricia sangue (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_PED1AC IS 'Valor pediatria 1 acompanhante (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_TOT IS 'Valor total da internacao em reais (R$). Soma de todos os componentes de custo da AIH';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_UTI IS 'Valor referente a diarias de UTI (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.US_TOT IS 'Valor total em unidades de servico';
COMMENT ON COLUMN DADOS_SIH_RD.DT_INTER IS 'Data de internacao do paciente (formato AAAAMMDD)';
COMMENT ON COLUMN DADOS_SIH_RD.DT_SAIDA IS 'Data de saida/alta do paciente (formato AAAAMMDD)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAG_PRINC IS 'Diagnostico principal da internacao no codigo CID-10 (ex: C829=Linfoma nao-Hodgkin, J189=Pneumonia)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAG_SECUN IS 'Diagnostico secundario no codigo CID-10';
COMMENT ON COLUMN DADOS_SIH_RD.COBRANCA IS 'Motivo de cobranca da AIH';
COMMENT ON COLUMN DADOS_SIH_RD.NATUREZA IS 'Natureza juridica do hospital';
COMMENT ON COLUMN DADOS_SIH_RD.NAT_JUR IS 'Natureza juridica detalhada do hospital';
COMMENT ON COLUMN DADOS_SIH_RD.GESTAO IS 'Tipo de gestao do municipio onde ocorreu a internacao';
COMMENT ON COLUMN DADOS_SIH_RD.RUBRICA IS 'Rubrica de despesa';
COMMENT ON COLUMN DADOS_SIH_RD.IND_VDRL IS 'Indicador de teste VDRL (sifilis) realizado';
COMMENT ON COLUMN DADOS_SIH_RD.MUNIC_MOV IS 'Codigo IBGE do municipio onde ocorreu a internacao (6 digitos). Usar para perspectiva do servico e calculo de pressao hospitalar';
COMMENT ON COLUMN DADOS_SIH_RD.COD_IDADE IS 'Codigo da unidade de idade: 2=Dias, 3=Meses, 4=Anos';
COMMENT ON COLUMN DADOS_SIH_RD.IDADE IS 'Idade do paciente na unidade indicada por COD_IDADE';
COMMENT ON COLUMN DADOS_SIH_RD.DIAS_PERM IS 'Dias de permanencia total da internacao. Usar para calcular taxa de ocupacao proxy e permanencia media';
COMMENT ON COLUMN DADOS_SIH_RD.MORTE IS 'Indicador de obito durante a internacao: 0=Nao, 1=Sim. Usar para calcular taxa de mortalidade hospitalar';
COMMENT ON COLUMN DADOS_SIH_RD.NACIONAL IS 'Codigo de nacionalidade do paciente';
COMMENT ON COLUMN DADOS_SIH_RD.NUM_PROC IS 'Numero de procedimentos secundarios';
COMMENT ON COLUMN DADOS_SIH_RD.CAR_INT IS 'Carater da internacao: 01=Eletiva, 02=Urgencia';
COMMENT ON COLUMN DADOS_SIH_RD.TOT_PT_SP IS 'Total de pontos de servico profissional';
COMMENT ON COLUMN DADOS_SIH_RD.CPF_AUT IS 'CPF do medico autorizador (dado sensivel)';
COMMENT ON COLUMN DADOS_SIH_RD.HOMONIMO IS 'Indicador de homonimia';
COMMENT ON COLUMN DADOS_SIH_RD.NUM_FILHOS IS 'Numero de filhos (obstetrica)';
COMMENT ON COLUMN DADOS_SIH_RD.INSTRU IS 'Grau de instrucao do paciente';
COMMENT ON COLUMN DADOS_SIH_RD.CID_NOTIF IS 'CID-10 de notificacao compulsoria';
COMMENT ON COLUMN DADOS_SIH_RD.CONTRACEP1 IS 'Metodo contraceptivo 1';
COMMENT ON COLUMN DADOS_SIH_RD.CONTRACEP2 IS 'Metodo contraceptivo 2';
COMMENT ON COLUMN DADOS_SIH_RD.GESTRISCO IS 'Indicador de gestacao de risco';
COMMENT ON COLUMN DADOS_SIH_RD.INSC_PN IS 'Inscricao pre-natal';
COMMENT ON COLUMN DADOS_SIH_RD.SEQ_AIH5 IS 'Sequencial de AIH tipo 5 (longa permanencia)';
COMMENT ON COLUMN DADOS_SIH_RD.CBOR IS 'CBO do profissional responsavel';
COMMENT ON COLUMN DADOS_SIH_RD.CNAER IS 'CNAE do estabelecimento';
COMMENT ON COLUMN DADOS_SIH_RD.VINCPREV IS 'Vinculo previdenciario do paciente';
COMMENT ON COLUMN DADOS_SIH_RD.GESTOR_COD IS 'Codigo do gestor';
COMMENT ON COLUMN DADOS_SIH_RD.GESTOR_TP IS 'Tipo de gestor';
COMMENT ON COLUMN DADOS_SIH_RD.GESTOR_CPF IS 'CPF do gestor (dado sensivel)';
COMMENT ON COLUMN DADOS_SIH_RD.GESTOR_DT IS 'Data de cadastro do gestor';
COMMENT ON COLUMN DADOS_SIH_RD.CNES IS 'Codigo CNES do hospital onde ocorreu a internacao. Permite cruzamento com tabelas CNES';
COMMENT ON COLUMN DADOS_SIH_RD.CNPJ_MANT IS 'CNPJ da entidade mantenedora do hospital';
COMMENT ON COLUMN DADOS_SIH_RD.INFEHOSP IS 'Indicador de infeccao hospitalar';
COMMENT ON COLUMN DADOS_SIH_RD.CID_ASSO IS 'CID-10 associado';
COMMENT ON COLUMN DADOS_SIH_RD.CID_MORTE IS 'CID-10 da causa do obito quando MORTE=1';
COMMENT ON COLUMN DADOS_SIH_RD.COMPLEX IS 'Complexidade do procedimento: 01=Atencao Basica, 02=Media, 03=Alta';
COMMENT ON COLUMN DADOS_SIH_RD.FINANC IS 'Tipo de financiamento: 04=FAEC, 06=MAC';
COMMENT ON COLUMN DADOS_SIH_RD.FAEC_TP IS 'Subtipo de financiamento FAEC';
COMMENT ON COLUMN DADOS_SIH_RD.REGCT IS 'Regra contratual';
COMMENT ON COLUMN DADOS_SIH_RD.RACA_COR IS 'Raca/cor do paciente: 01=Branca, 02=Preta, 03=Parda, 04=Amarela, 05=Indigena';
COMMENT ON COLUMN DADOS_SIH_RD.ETNIA IS 'Codigo da etnia indigena quando RACA_COR=05';
COMMENT ON COLUMN DADOS_SIH_RD.SEQUENCIA IS 'Sequencial de processamento da AIH';
COMMENT ON COLUMN DADOS_SIH_RD.REMESSA IS 'Identificacao da remessa de dados ao Ministerio da Saude';
COMMENT ON COLUMN DADOS_SIH_RD.AUD_JUST IS 'Justificativa de auditoria';
COMMENT ON COLUMN DADOS_SIH_RD.SIS_JUST IS 'Sistema de justificativa';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SH_FED IS 'Valor de servicos hospitalares parcela federal (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SP_FED IS 'Valor de servicos profissionais parcela federal (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SH_GES IS 'Valor de servicos hospitalares parcela gestor (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_SP_GES IS 'Valor de servicos profissionais parcela gestor (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.VAL_UCI IS 'Valor de unidade de cuidados intermediarios (R$)';
COMMENT ON COLUMN DADOS_SIH_RD.MARCA_UCI IS 'Marcador de tipo de unidade de cuidados intermediarios';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC1 IS 'Diagnostico secundario 1 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC2 IS 'Diagnostico secundario 2 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC3 IS 'Diagnostico secundario 3 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC4 IS 'Diagnostico secundario 4 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC5 IS 'Diagnostico secundario 5 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC6 IS 'Diagnostico secundario 6 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC7 IS 'Diagnostico secundario 7 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC8 IS 'Diagnostico secundario 8 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.DIAGSEC9 IS 'Diagnostico secundario 9 (CID-10)';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC1 IS 'Tipo de diagnostico secundario 1';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC2 IS 'Tipo de diagnostico secundario 2';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC3 IS 'Tipo de diagnostico secundario 3';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC4 IS 'Tipo de diagnostico secundario 4';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC5 IS 'Tipo de diagnostico secundario 5';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC6 IS 'Tipo de diagnostico secundario 6';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC7 IS 'Tipo de diagnostico secundario 7';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC8 IS 'Tipo de diagnostico secundario 8';
COMMENT ON COLUMN DADOS_SIH_RD.TPDISEC9 IS 'Tipo de diagnostico secundario 9';
COMMENT ON COLUMN DADOS_SIH_RD.FONTE_ORC IS 'Fonte orcamentaria. Campo adicionado a partir de marco/2025 (ausente em janeiro e fevereiro)';
COMMENT ON COLUMN DADOS_SIH_RD.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025). Campo de rastreabilidade adicionado na consolidacao';
COMMENT ON COLUMN DADOS_SIH_RD.MES_COMPETENCIA IS 'Mes da competencia (01 a 12). Campo de rastreabilidade adicionado na consolidacao';
COMMENT ON COLUMN DADOS_SIH_RD.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original para rastreabilidade';
COMMENT ON COLUMN DADOS_SIH_RD.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem (ex: RDRJ2501.dbc)';
COMMENT ON COLUMN DADOS_SIH_RD.VERSAO_CONVERSOR IS 'Versao do conversor DBC utilizado';
COMMENT ON COLUMN DADOS_SIH_RD.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados utilizado na conversao';


-- =============================================================================
-- 5. IBGE_DEMOGRAFICO_RJ — Demografia municipal do Rio de Janeiro
-- =============================================================================
COMMENT ON TABLE IBGE_DEMOGRAFICO_RJ IS
'Dados demograficos dos 92 municipios do estado do Rio de Janeiro obtidos do IBGE. Contem a estimativa populacional de 2025 (agregado 6579, variavel 9324) e dados de sexo e raca/cor do Censo 2022. Usar esta tabela para normalizar indicadores de saude por populacao (ex: leitos por 1000 habitantes, internacoes por 1000 habitantes).';

COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.COD_MUNICIPIO IS 'Codigo IBGE do municipio com 7 digitos (inclui digito verificador). Para cruzar com tabelas CNES/SIH que usam 6 digitos, utilizar SUBSTR(COD_MUNICIPIO, 1, 6)';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.NOME IS 'Nome completo do municipio com a sigla da UF (ex: Rio de Janeiro - RJ)';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.POP_2025 IS 'Populacao total estimada para 2025 pelo IBGE. Denominador principal para indicadores per capita';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.BRANCA IS 'Populacao que se declarou branca no Censo 2022. Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.PRETA IS 'Populacao que se declarou preta no Censo 2022. Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.AMARELA IS 'Populacao que se declarou amarela no Censo 2022. Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.PARDA IS 'Populacao que se declarou parda no Censo 2022. Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.INDIGENA IS 'Populacao que se declarou indigena no Censo 2022. Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.HOMENS IS 'Populacao masculina do municipio conforme Censo 2022';
COMMENT ON COLUMN IBGE_DEMOGRAFICO_RJ.MULHERES IS 'Populacao feminina do municipio conforme Censo 2022';


-- =============================================================================
-- 6. PROVENANCE_CNES_LT — Rastreabilidade da ingestão de leitos
-- =============================================================================
COMMENT ON TABLE PROVENANCE_CNES_LT IS
'Tabela de proveniencia e rastreabilidade da ingestao dos dados de leitos CNES para o Rio de Janeiro em 2025. Contem uma linha por competencia mensal com a fonte, hash do arquivo original, nome do arquivo DBC, hash do layout e contagem de registros. Usar para auditoria e verificacao de completude das 12 competencias.';

COMMENT ON COLUMN PROVENANCE_CNES_LT.FONTE IS 'Identificacao do sistema de origem (cnes_lt)';
COMMENT ON COLUMN PROVENANCE_CNES_LT.ANO_COMPETENCIA IS 'Ano da competencia (2025)';
COMMENT ON COLUMN PROVENANCE_CNES_LT.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN PROVENANCE_CNES_LT.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original';
COMMENT ON COLUMN PROVENANCE_CNES_LT.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem';
COMMENT ON COLUMN PROVENANCE_CNES_LT.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados';
COMMENT ON COLUMN PROVENANCE_CNES_LT.REGISTROS IS 'Quantidade de registros convertidos nesta competencia';


-- =============================================================================
-- 7. PROVENANCE_CNES_PF — Rastreabilidade da ingestão de profissionais
-- =============================================================================
COMMENT ON TABLE PROVENANCE_CNES_PF IS
'Tabela de proveniencia e rastreabilidade da ingestao dos dados de profissionais CNES para o Rio de Janeiro em 2025. Uma linha por competencia mensal com contagem de vinculos profissionais convertidos.';

COMMENT ON COLUMN PROVENANCE_CNES_PF.FONTE IS 'Identificacao do sistema de origem (cnes_pf)';
COMMENT ON COLUMN PROVENANCE_CNES_PF.ANO_COMPETENCIA IS 'Ano da competencia (2025)';
COMMENT ON COLUMN PROVENANCE_CNES_PF.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN PROVENANCE_CNES_PF.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original';
COMMENT ON COLUMN PROVENANCE_CNES_PF.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem';
COMMENT ON COLUMN PROVENANCE_CNES_PF.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados';
COMMENT ON COLUMN PROVENANCE_CNES_PF.REGISTROS IS 'Quantidade de vinculos profissionais convertidos nesta competencia';


-- =============================================================================
-- 8. PROVENANCE_CNES_ST — Rastreabilidade da ingestão de estabelecimentos
-- =============================================================================
COMMENT ON TABLE PROVENANCE_CNES_ST IS
'Tabela de proveniencia e rastreabilidade da ingestao dos dados de estabelecimentos CNES para o Rio de Janeiro em 2025. Uma linha por competencia mensal com contagem de estabelecimentos convertidos.';

COMMENT ON COLUMN PROVENANCE_CNES_ST.FONTE IS 'Identificacao do sistema de origem (cnes_st)';
COMMENT ON COLUMN PROVENANCE_CNES_ST.ANO_COMPETENCIA IS 'Ano da competencia (2025)';
COMMENT ON COLUMN PROVENANCE_CNES_ST.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN PROVENANCE_CNES_ST.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original';
COMMENT ON COLUMN PROVENANCE_CNES_ST.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem';
COMMENT ON COLUMN PROVENANCE_CNES_ST.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados';
COMMENT ON COLUMN PROVENANCE_CNES_ST.REGISTROS IS 'Quantidade de estabelecimentos convertidos nesta competencia';


-- =============================================================================
-- 9. PROVENANCE_SIH_RD — Rastreabilidade da ingestão de internações
-- =============================================================================
COMMENT ON TABLE PROVENANCE_SIH_RD IS
'Tabela de proveniencia e rastreabilidade da ingestao dos dados de internacoes SIH-SUS para o Rio de Janeiro em 2025. Uma linha por competencia mensal com contagem de AIHs convertidas. O SIH apresentou evolucao aditiva de layout: janeiro-fevereiro possuem 113 colunas e marco-dezembro adicionam FONTE_ORC (114 colunas).';

COMMENT ON COLUMN PROVENANCE_SIH_RD.FONTE IS 'Identificacao do sistema de origem (sih_rd)';
COMMENT ON COLUMN PROVENANCE_SIH_RD.ANO_COMPETENCIA IS 'Ano da competencia (2025)';
COMMENT ON COLUMN PROVENANCE_SIH_RD.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN PROVENANCE_SIH_RD.SHA256_ORIGEM IS 'Hash SHA-256 do arquivo DBC original';
COMMENT ON COLUMN PROVENANCE_SIH_RD.ARQUIVO_ORIGEM IS 'Nome do arquivo DBC de origem';
COMMENT ON COLUMN PROVENANCE_SIH_RD.LAYOUT_SHA256 IS 'Hash SHA-256 do layout/dicionario de dados';
COMMENT ON COLUMN PROVENANCE_SIH_RD.REGISTROS IS 'Quantidade de AIHs (internacoes) convertidas nesta competencia';


-- =============================================================================
-- 10. V_AGREG_CNES_LEITOS — View agregada de leitos SUS
-- =============================================================================
COMMENT ON TABLE V_AGREG_CNES_LEITOS IS
'Visao agregada dos leitos SUS por municipio e mes, derivada da tabela DADOS_CNES_LT. Consolida todos os tipos de leito de todos os estabelecimentos em um unico total de leitos SUS por municipio/competencia. Utilizada como entrada para o calculo do Indice de Pressao Hospitalar (IPH).';

COMMENT ON COLUMN V_AGREG_CNES_LEITOS.CODIGO_MUNICIPIO_6D IS 'Codigo IBGE do municipio com 6 digitos (sem digito verificador). Derivado de CODUFMUN';
COMMENT ON COLUMN V_AGREG_CNES_LEITOS.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025)';
COMMENT ON COLUMN V_AGREG_CNES_LEITOS.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN V_AGREG_CNES_LEITOS.TOTAL_LEITOS_SUS IS 'Soma de todos os leitos disponiveis para o SUS no municipio naquele mes. Inclui todos os tipos e especialidades de leito';


-- =============================================================================
-- 11. V_AGREG_SIH_INTERNACOES — View agregada de internações SIH
-- =============================================================================
COMMENT ON TABLE V_AGREG_SIH_INTERNACOES IS
'Visao agregada das internacoes SUS por municipio de atendimento e mes, derivada da tabela DADOS_SIH_RD. Consolida total de internacoes, dias de permanencia, obitos hospitalares e valor total pago. Utiliza a perspectiva do servico (municipio onde ocorreu a internacao). Utilizada como entrada para o calculo do IPH.';

COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.CODIGO_MUNICIPIO_6D IS 'Codigo IBGE do municipio de atendimento com 6 digitos (derivado de MUNIC_MOV). Perspectiva do servico';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.ANO_COMPETENCIA IS 'Ano da competencia (ex: 2025)';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.MES_COMPETENCIA IS 'Mes da competencia (01 a 12)';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.TOTAL_INTERNACOES IS 'Quantidade total de internacoes (AIHs) no municipio naquele mes';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.TOTAL_DIAS_PERMANENCIA IS 'Soma de todos os dias de permanencia das internacoes no municipio naquele mes';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.TOTAL_OBITOS_HOSPITALARES IS 'Total de obitos ocorridos durante internacoes SUS no municipio naquele mes';
COMMENT ON COLUMN V_AGREG_SIH_INTERNACOES.VALOR_TOTAL_INTERNACOES IS 'Soma dos valores totais (em reais) de todas as internacoes SUS no municipio naquele mes';


-- =============================================================================
-- 12. TB_ANALYTICS_IPH_RJ — Tabela Golden com o IPH calculado
-- =============================================================================
COMMENT ON TABLE TB_ANALYTICS_IPH_RJ IS
'Tabela analitica principal do projeto EvoluSUS (Golden Record). Contem os dados demograficos, de capacidade hospitalar, de utilizacao do SUS e os indicadores calculados para cada municipio do Rio de Janeiro em cada mes de 2025, incluindo o Indice de Pressao Hospitalar (IPH). Tabela desnormalizada e otimizada para consultas por linguagem natural via Oracle Select AI. Cruzamento entre IBGE (populacao), CNES (leitos SUS) e SIH (internacoes).';

COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.CODIGO_MUNICIPIO_7D IS 'Codigo IBGE do municipio com 7 digitos (com digito verificador). Chave de identificacao unica do municipio';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.CODIGO_MUNICIPIO_6D IS 'Codigo IBGE do municipio com 6 digitos (sem digito verificador). Usado nos JOINs com dados CNES e SIH';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.NOME_MUNICIPIO IS 'Nome do municipio com sigla da UF (ex: Rio de Janeiro - RJ, Niteroi - RJ)';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.ANO_COMPETENCIA IS 'Ano de referencia dos dados (2025)';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.MES_COMPETENCIA IS 'Mes de referencia dos dados (01 a 12). Cada municipio possui ate 12 registros, um por mes';

-- Demografia
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_TOTAL IS 'Populacao total estimada do municipio em 2025 pelo IBGE. Denominador principal dos indicadores per capita';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_HOMENS IS 'Populacao masculina do municipio (Censo 2022)';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_MULHERES IS 'Populacao feminina do municipio (Censo 2022)';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_BRANCA IS 'Populacao branca do municipio (Censo 2022). Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_PRETA IS 'Populacao preta do municipio (Censo 2022). Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_PARDA IS 'Populacao parda do municipio (Censo 2022). Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_AMARELA IS 'Populacao amarela do municipio (Censo 2022). Valor 0 indica dado nao disponivel';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.POPULACAO_INDIGENA IS 'Populacao indigena do municipio (Censo 2022). Valor 0 indica dado nao disponivel';

-- Capacidade, Utilização e Desfecho
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TOTAL_LEITOS_SUS IS 'Total de leitos SUS disponiveis no municipio no mes, somando todos os estabelecimentos e tipos de leito';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TOTAL_INTERNACOES IS 'Total de internacoes SUS (AIHs) realizadas no municipio no mes';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TOTAL_DIAS_PERMANENCIA IS 'Soma dos dias de permanencia de todas as internacoes SUS no municipio no mes';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TOTAL_OBITOS_HOSPITALARES IS 'Total de obitos ocorridos durante internacoes SUS no municipio no mes';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.VALOR_TOTAL_INTERNACOES IS 'Valor total pago em reais (R$) por todas as internacoes SUS do municipio no mes';

-- Indicadores de Pressão
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.LEITOS_POR_MIL_HAB IS 'Leitos SUS por 1.000 habitantes. Indicador de capacidade hospitalar: quanto maior, mais leitos disponiveis por populacao';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.INTERNACOES_POR_MIL_HAB IS 'Internacoes SUS por 1.000 habitantes no mes. Indicador de utilizacao: quanto maior, mais internacoes proporcionais a populacao';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TAXA_OCUPACAO_PROXY_PCT IS 'Taxa de ocupacao proxy em percentual. Calculada como (dias de permanencia / (leitos SUS x 30 dias)) x 100. Nao e ocupacao censitaria observada; e uma estimativa baseada em dados administrativos';
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.TAXA_MORTALIDADE_HOSP_PCT IS 'Taxa de mortalidade hospitalar em percentual. Calculada como (obitos / internacoes) x 100. Mede a proporcao de internacoes SUS que resultaram em obito';

-- IPH
COMMENT ON COLUMN TB_ANALYTICS_IPH_RJ.INDICE_PRESSAO_HOSPITALAR IS 'Indice de Pressao Hospitalar (IPH) do municipio no mes, escala de 0 a 100. Quanto MAIOR o valor, MAIOR a pressao sobre os servicos hospitalares. Calculado a partir da escassez de leitos, intensidade de internacoes e taxa de ocupacao proxy. E o principal indicador criado pelo projeto EvoluSUS para medir a pressao sobre a rede hospitalar SUS';

COMMIT;
