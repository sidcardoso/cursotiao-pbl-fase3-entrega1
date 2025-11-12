-- ==============================================================================
-- CanaOptimizer - Queries de Validação e Análise
-- ==============================================================================
-- Autor: Sidney de Lirio Cardoso - RM567808
-- Data: 12/11/2025
-- Descrição: Queries para validar importação e gerar análises
-- ==============================================================================

-- ==============================================================================
-- 1. VALIDAÇÃO BÁSICA DA IMPORTAÇÃO
-- ==============================================================================

-- 1.1 Contar total de registros
SELECT COUNT(*) AS TOTAL_REGISTROS 
FROM COLHEITAS;
-- Esperado: 100 registros

-- 1.2 Verificar se há valores NULL
SELECT 
    SUM(CASE WHEN FAZENDA IS NULL THEN 1 ELSE 0 END) AS NULL_FAZENDA,
    SUM(CASE WHEN AREA_HECTARES IS NULL THEN 1 ELSE 0 END) AS NULL_AREA,
    SUM(CASE WHEN PERCENTUAL_PERDA IS NULL THEN 1 ELSE 0 END) AS NULL_PERDA
FROM COLHEITAS;
-- Esperado: 0 em todos os campos

-- 1.3 Verificar range de datas
SELECT 
    MIN(DATA_COLHEITA) AS DATA_MAIS_ANTIGA,
    MAX(DATA_COLHEITA) AS DATA_MAIS_RECENTE,
    COUNT(DISTINCT DATA_COLHEITA) AS DATAS_DISTINTAS
FROM COLHEITAS;

-- ==============================================================================
-- 2. ANÁLISE POR CLASSIFICAÇÃO
-- ==============================================================================

-- 2.1 Distribuição por classificação
SELECT 
    CLASSIFICACAO,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_TOTAL
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
-- 3. ANÁLISE POR FAZENDA
-- ==============================================================================

-- 3.1 Ranking de fazendas por perda financeira
SELECT 
    FAZENDA,
    COUNT(*) AS TOTAL_COLHEITAS,
    ROUND(SUM(AREA_HECTARES), 2) AS AREA_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_TOTAL,
    ROUND(SUM(TONELADAS_PERDIDAS), 2) AS TONELADAS_PERDIDAS_TOTAL
FROM COLHEITAS
GROUP BY FAZENDA
ORDER BY PERDA_FINANCEIRA_TOTAL DESC;

-- 3.2 Melhores fazendas (menor perda média)
SELECT 
    FAZENDA,
    COUNT(*) AS COLHEITAS,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA
FROM COLHEITAS
GROUP BY FAZENDA
HAVING COUNT(*) >= 5
ORDER BY PERDA_MEDIA ASC
FETCH FIRST 5 ROWS ONLY;

-- ==============================================================================
-- 4. ANÁLISE POR TIPO DE CANA
-- ==============================================================================

-- 4.1 Performance por variedade
SELECT 
    TIPO_CANA,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PRODUTIVIDADE), 2) AS PRODUTIVIDADE_MEDIA,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA
FROM COLHEITAS
GROUP BY TIPO_CANA
ORDER BY EFICIENCIA_MEDIA DESC;

-- ==============================================================================
-- 5. ANÁLISE POR COLHEITADEIRA
-- ==============================================================================

-- 5.1 Desempenho por modelo de colheitadeira
SELECT 
    COLHEITADEIRA,
    COUNT(*) AS TOTAL_OPERACOES,
    ROUND(AVG(VELOCIDADE), 2) AS VELOCIDADE_MEDIA,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_TOTAL
FROM COLHEITAS
GROUP BY COLHEITADEIRA
ORDER BY EFICIENCIA_MEDIA DESC;

-- ==============================================================================
-- 6. ANÁLISE CLIMÁTICA
-- ==============================================================================

-- 6.1 Impacto das condições climáticas
SELECT 
    CONDICAO_CLIMA,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA
FROM COLHEITAS
GROUP BY CONDICAO_CLIMA
ORDER BY PERDA_MEDIA ASC;

-- ==============================================================================
-- 7. ANÁLISE TEMPORAL
-- ==============================================================================

-- 7.1 Performance por mês
SELECT 
    TO_CHAR(DATA_COLHEITA, 'YYYY-MM') AS MES_ANO,
    COUNT(*) AS TOTAL_COLHEITAS,
    ROUND(SUM(AREA_HECTARES), 2) AS AREA_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA
FROM COLHEITAS
GROUP BY TO_CHAR(DATA_COLHEITA, 'YYYY-MM')
ORDER BY MES_ANO;

-- ==============================================================================
-- 8. TOP 10 ANÁLISES
-- ==============================================================================

-- 8.1 Top 10 maiores perdas financeiras
SELECT 
    ID_COLHEITA,
    FAZENDA,
    DATA_COLHEITA,
    AREA_HECTARES,
    PERCENTUAL_PERDA,
    PERDA_FINANCEIRA,
    CLASSIFICACAO,
    OBSERVACOES
FROM COLHEITAS
ORDER BY PERDA_FINANCEIRA DESC
FETCH FIRST 10 ROWS ONLY;

-- 8.2 Top 10 melhores colheitas
SELECT 
    ID_COLHEITA,
    FAZENDA,
    DATA_COLHEITA,
    AREA_HECTARES,
    PERCENTUAL_PERDA,
    EFICIENCIA,
    CLASSIFICACAO
FROM COLHEITAS
ORDER BY PERCENTUAL_PERDA ASC
FETCH FIRST 10 ROWS ONLY;

-- ==============================================================================
-- 9. ESTATÍSTICAS GERAIS
-- ==============================================================================

-- 9.1 Resumo geral completo
SELECT 
    COUNT(*) AS TOTAL_COLHEITAS,
    COUNT(DISTINCT FAZENDA) AS TOTAL_FAZENDAS,
    COUNT(DISTINCT TIPO_CANA) AS VARIEDADES_CANA,
    ROUND(SUM(AREA_HECTARES), 2) AS AREA_TOTAL_HECTARES,
    ROUND(SUM(TONELADAS_COLHIDAS), 2) AS TONELADAS_COLHIDAS_TOTAL,
    ROUND(SUM(TONELADAS_PERDIDAS), 2) AS TONELADAS_PERDIDAS_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA_PERCENTUAL,
    ROUND(MIN(PERCENTUAL_PERDA), 2) AS PERDA_MINIMA,
    ROUND(MAX(PERCENTUAL_PERDA), 2) AS PERDA_MAXIMA,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_TOTAL,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA
FROM COLHEITAS;

-- 9.2 Distribuição de perdas em faixas
SELECT 
    CASE 
        WHEN PERCENTUAL_PERDA < 5 THEN '0-5% (Ótima)'
        WHEN PERCENTUAL_PERDA < 8 THEN '5-8% (Boa)'
        WHEN PERCENTUAL_PERDA < 12 THEN '8-12% (Regular)'
        WHEN PERCENTUAL_PERDA < 15 THEN '12-15% (Alta)'
        ELSE '>15% (Crítica)'
    END AS FAIXA_PERDA,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL
FROM COLHEITAS
GROUP BY 
    CASE 
        WHEN PERCENTUAL_PERDA < 5 THEN '0-5% (Ótima)'
        WHEN PERCENTUAL_PERDA < 8 THEN '5-8% (Boa)'
        WHEN PERCENTUAL_PERDA < 12 THEN '8-12% (Regular)'
        WHEN PERCENTUAL_PERDA < 15 THEN '12-15% (Alta)'
        ELSE '>15% (Crítica)'
    END
ORDER BY MIN(PERCENTUAL_PERDA);

-- ==============================================================================
-- 10. ANÁLISES AVANÇADAS
-- ==============================================================================

-- 10.1 Correlação entre velocidade e perda
SELECT 
    CASE 
        WHEN VELOCIDADE < 4 THEN 'Baixa (<4 km/h)'
        WHEN VELOCIDADE < 6 THEN 'Média (4-6 km/h)'
        ELSE 'Alta (>6 km/h)'
    END AS FAIXA_VELOCIDADE,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(EFICIENCIA), 2) AS EFICIENCIA_MEDIA
FROM COLHEITAS
GROUP BY 
    CASE 
        WHEN VELOCIDADE < 4 THEN 'Baixa (<4 km/h)'
        WHEN VELOCIDADE < 6 THEN 'Média (4-6 km/h)'
        ELSE 'Alta (>6 km/h)'
    END
ORDER BY PERDA_MEDIA;

-- 10.2 Análise de produtividade vs perda
SELECT 
    CASE 
        WHEN PRODUTIVIDADE < 70 THEN 'Baixa (<70 t/ha)'
        WHEN PRODUTIVIDADE < 80 THEN 'Média (70-80 t/ha)'
        ELSE 'Alta (>80 t/ha)'
    END AS FAIXA_PRODUTIVIDADE,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA,
    ROUND(AVG(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_MEDIA
FROM COLHEITAS
GROUP BY 
    CASE 
        WHEN PRODUTIVIDADE < 70 THEN 'Baixa (<70 t/ha)'
        WHEN PRODUTIVIDADE < 80 THEN 'Média (70-80 t/ha)'
        ELSE 'Alta (>80 t/ha)'
    END
ORDER BY PERDA_MEDIA;

-- ==============================================================================
-- FIM DAS QUERIES
-- ==============================================================================
