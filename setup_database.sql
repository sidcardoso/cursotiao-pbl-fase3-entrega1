-- ==============================================================================
-- CanaOptimizer - Script de Criação do Banco de Dados Oracle
-- ==============================================================================
-- Autor: Sidney de Lirio Cardoso
-- Data: 14/10/2025
-- Descrição: Cria tabelas e objetos necessários para o sistema
-- ==============================================================================

-- ==============================================================================
-- 1. TABELA PRINCIPAL: COLHEITAS
-- ==============================================================================

-- Remover tabela se existir (cuidado em produção!)
DROP TABLE COLHEITAS CASCADE CONSTRAINTS;

-- Remover sequence se existir
DROP SEQUENCE SEQ_COLHEITA_ID;

-- Criar sequence para ID auto-incremento
CREATE SEQUENCE SEQ_COLHEITA_ID
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Criar tabela de colheitas
CREATE TABLE COLHEITAS (
    ID_COLHEITA         NUMBER(10)      PRIMARY KEY,
    FAZENDA             VARCHAR2(100)   NOT NULL,
    AREA_HECTARES       NUMBER(10,2)    NOT NULL CHECK (AREA_HECTARES > 0),
    TIPO_CANA           VARCHAR2(50)    NOT NULL,
    PRODUTIVIDADE       NUMBER(10,2)    NOT NULL CHECK (PRODUTIVIDADE > 0),
    PERCENTUAL_PERDA    NUMBER(5,2)     NOT NULL CHECK (PERCENTUAL_PERDA >= 0 AND PERCENTUAL_PERDA <= 100),
    PRECO_TONELADA      NUMBER(10,2)    NOT NULL CHECK (PRECO_TONELADA > 0),
    COLHEITADEIRA       VARCHAR2(50)    NOT NULL,
    VELOCIDADE          NUMBER(5,2)     NOT NULL CHECK (VELOCIDADE > 0),
    CONDICAO_CLIMA      VARCHAR2(30)    NOT NULL,
    DATA_COLHEITA       DATE            NOT NULL,
    TONELADAS_COLHIDAS  NUMBER(10,2)    NOT NULL,
    TONELADAS_PERDIDAS  NUMBER(10,2)    NOT NULL,
    PERDA_FINANCEIRA    NUMBER(12,2)    NOT NULL,
    EFICIENCIA          NUMBER(5,2)     NOT NULL,
    CLASSIFICACAO       VARCHAR2(20)    NOT NULL CHECK (CLASSIFICACAO IN ('Ótima', 'Boa', 'Regular', 'Alta', 'Crítica')),
    OBSERVACOES         VARCHAR2(500),
    CRIADO_EM           TIMESTAMP       DEFAULT SYSTIMESTAMP,
    ATUALIZADO_EM       TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- Comentários na tabela
COMMENT ON TABLE COLHEITAS IS 'Registros de colheitas de cana-de-açúcar';
COMMENT ON COLUMN COLHEITAS.ID_COLHEITA IS 'Identificador único da colheita';
COMMENT ON COLUMN COLHEITAS.FAZENDA IS 'Nome da fazenda';
COMMENT ON COLUMN COLHEITAS.AREA_HECTARES IS 'Área colhida em hectares';
COMMENT ON COLUMN COLHEITAS.TIPO_CANA IS 'Variedade de cana plantada';
COMMENT ON COLUMN COLHEITAS.PRODUTIVIDADE IS 'Produtividade em toneladas por hectare';
COMMENT ON COLUMN COLHEITAS.PERCENTUAL_PERDA IS 'Percentual de perda (0-100)';
COMMENT ON COLUMN COLHEITAS.PRECO_TONELADA IS 'Preço da tonelada em reais';
COMMENT ON COLUMN COLHEITAS.CLASSIFICACAO IS 'Classificação da perda: Ótima (<5%), Boa (5-8%), Regular (8-12%), Alta (12-15%), Crítica (>15%)';

-- ==============================================================================
-- 2. ÍNDICES PARA PERFORMANCE
-- ==============================================================================

CREATE INDEX IDX_COLHEITAS_FAZENDA ON COLHEITAS(FAZENDA);
CREATE INDEX IDX_COLHEITAS_DATA ON COLHEITAS(DATA_COLHEITA DESC);
CREATE INDEX IDX_COLHEITAS_CLASSIFICACAO ON COLHEITAS(CLASSIFICACAO);
CREATE INDEX IDX_COLHEITAS_PERDA ON COLHEITAS(PERCENTUAL_PERDA);

-- ==============================================================================
-- 3. TRIGGER PARA AUTO-INCREMENTO
-- ==============================================================================

CREATE OR REPLACE TRIGGER TRG_COLHEITA_ID
BEFORE INSERT ON COLHEITAS
FOR EACH ROW
BEGIN
    IF :NEW.ID_COLHEITA IS NULL THEN
        :NEW.ID_COLHEITA := SEQ_COLHEITA_ID.NEXTVAL;
    END IF;
END;
/

-- ==============================================================================
-- 4. TRIGGER PARA ATUALIZAR TIMESTAMP
-- ==============================================================================

CREATE OR REPLACE TRIGGER TRG_COLHEITA_UPDATE
BEFORE UPDATE ON COLHEITAS
FOR EACH ROW
BEGIN
    :NEW.ATUALIZADO_EM := SYSTIMESTAMP;
END;
/

-- ==============================================================================
-- 5. VIEW PARA ESTATÍSTICAS
-- ==============================================================================

CREATE OR REPLACE VIEW VW_ESTATISTICAS_COLHEITAS AS
SELECT 
    COUNT(*) AS TOTAL_REGISTROS,
    SUM(AREA_HECTARES) AS AREA_TOTAL_HA,
    AVG(PERCENTUAL_PERDA) AS PERDA_MEDIA_PCT,
    MIN(PERCENTUAL_PERDA) AS PERDA_MINIMA_PCT,
    MAX(PERCENTUAL_PERDA) AS PERDA_MAXIMA_PCT,
    SUM(TONELADAS_PERDIDAS) AS TONELADAS_PERDIDAS_TOTAL,
    SUM(PERDA_FINANCEIRA) AS PERDA_FINANCEIRA_TOTAL,
    SUM(TONELADAS_COLHIDAS) AS TONELADAS_COLHIDAS_TOTAL
FROM COLHEITAS;

-- ==============================================================================
-- 6. VIEW PARA RANKING DE FAZENDAS
-- ==============================================================================

CREATE OR REPLACE VIEW VW_RANKING_FAZENDAS AS
SELECT 
    FAZENDA,
    COUNT(*) AS NUM_COLHEITAS,
    SUM(AREA_HECTARES) AS AREA_TOTAL,
    AVG(PERCENTUAL_PERDA) AS PERDA_MEDIA,
    SUM(TONELADAS_PERDIDAS) AS TONELADAS_PERDIDAS,
    SUM(PERDA_FINANCEIRA) AS PERDA_FINANCEIRA_TOTAL,
    MIN(PERCENTUAL_PERDA) AS MELHOR_PERDA,
    MAX(PERCENTUAL_PERDA) AS PIOR_PERDA
FROM COLHEITAS
GROUP BY FAZENDA
ORDER BY PERDA_MEDIA;

-- ==============================================================================
-- 7. VIEW PARA ANÁLISE POR CLASSIFICAÇÃO
-- ==============================================================================

CREATE OR REPLACE VIEW VW_ANALISE_CLASSIFICACAO AS
SELECT 
    CLASSIFICACAO,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL,
    AVG(PERCENTUAL_PERDA) AS PERDA_MEDIA,
    SUM(AREA_HECTARES) AS AREA_TOTAL,
    SUM(PERDA_FINANCEIRA) AS PERDA_FINANCEIRA
FROM COLHEITAS
GROUP BY CLASSIFICACAO
ORDER BY 
    CASE CLASSIFICACAO
        WHEN 'Ótima' THEN 1
        WHEN 'Boa' THEN 2
        WHEN 'Regular' THEN 3
        WHEN 'Alta' THEN 4
        WHEN 'Crítica' THEN 5
    END;

-- ==============================================================================
-- 8. DADOS DE EXEMPLO (OPCIONAL)
-- ==============================================================================

-- Inserir colheitas de exemplo
INSERT INTO COLHEITAS (
    FAZENDA, AREA_HECTARES, TIPO_CANA, PRODUTIVIDADE, PERCENTUAL_PERDA,
    PRECO_TONELADA, COLHEITADEIRA, VELOCIDADE, CONDICAO_CLIMA, DATA_COLHEITA,
    TONELADAS_COLHIDAS, TONELADAS_PERDIDAS, PERDA_FINANCEIRA, 
    EFICIENCIA, CLASSIFICACAO, OBSERVACOES
) VALUES (
    'Fazenda Modelo', 100.0, 'RB867515', 95.0, 3.5,
    120.0, 'John Deere', 5.5, 'Ensolarado', TO_DATE('15/10/2024', 'DD/MM/YYYY'),
    9167.5, 332.5, 39900.0,
    96.5, 'Ótima', 'Excelente condição de colheita'
);

INSERT INTO COLHEITAS (
    FAZENDA, AREA_HECTARES, TIPO_CANA, PRODUTIVIDADE, PERCENTUAL_PERDA,
    PRECO_TONELADA, COLHEITADEIRA, VELOCIDADE, CONDICAO_CLIMA, DATA_COLHEITA,
    TONELADAS_COLHIDAS, TONELADAS_PERDIDAS, PERDA_FINANCEIRA, 
    EFICIENCIA, CLASSIFICACAO, OBSERVACOES
) VALUES (
    'Fazenda São João', 75.0, 'CTC4', 105.0, 8.5,
    120.0, 'Case IH', 6.0, 'Nublado', TO_DATE('18/10/2024', 'DD/MM/YYYY'),
    7201.88, 668.63, 80235.6,
    91.5, 'Regular', 'Clima adverso aumentou perdas'
);

INSERT INTO COLHEITAS (
    FAZENDA, AREA_HECTARES, TIPO_CANA, PRODUTIVIDADE, PERCENTUAL_PERDA,
    PRECO_TONELADA, COLHEITADEIRA, VELOCIDADE, CONDICAO_CLIMA, DATA_COLHEITA,
    TONELADAS_COLHIDAS, TONELADAS_PERDIDAS, PERDA_FINANCEIRA, 
    EFICIENCIA, CLASSIFICACAO, OBSERVACOES
) VALUES (
    'Fazenda Primavera', 50.0, 'IACSP95-5000', 88.0, 14.2,
    120.0, 'Valtra', 7.2, 'Chuvoso', TO_DATE('20/10/2024', 'DD/MM/YYYY'),
    3774.4, 625.6, 75072.0,
    85.8, 'Alta', 'Chuva dificultou operação'
);

-- Commit das inserções
COMMIT;

-- ==============================================================================
-- 9. VERIFICAÇÃO
-- ==============================================================================

-- Ver estatísticas
SELECT * FROM VW_ESTATISTICAS_COLHEITAS;

-- Ver ranking de fazendas
SELECT * FROM VW_RANKING_FAZENDAS;

-- Ver análise por classificação
SELECT * FROM VW_ANALISE_CLASSIFICACAO;

-- Contar registros
SELECT COUNT(*) AS TOTAL_COLHEITAS FROM COLHEITAS;

-- ==============================================================================
-- FIM DO SCRIPT
-- ==============================================================================

PROMPT
PROMPT ===================================================================
PROMPT  ✅ BANCO DE DADOS CRIADO COM SUCESSO!
PROMPT ===================================================================
PROMPT
PROMPT  Tabelas criadas:
PROMPT    • COLHEITAS (com triggers e constraints)
PROMPT
PROMPT  Views criadas:
PROMPT    • VW_ESTATISTICAS_COLHEITAS
PROMPT    • VW_RANKING_FAZENDAS
PROMPT    • VW_ANALISE_CLASSIFICACAO
PROMPT
PROMPT  Índices criados:
PROMPT    • IDX_COLHEITAS_FAZENDA
PROMPT    • IDX_COLHEITAS_DATA
PROMPT    • IDX_COLHEITAS_CLASSIFICACAO
PROMPT    • IDX_COLHEITAS_PERDA
PROMPT
PROMPT  Dados de exemplo: 3 colheitas inseridas
PROMPT
PROMPT ===================================================================
