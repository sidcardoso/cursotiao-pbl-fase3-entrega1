# 🗄️ Guia de Importação Oracle - CanaOptimizer

**Autor:** Sidney de Lirio Cardoso - RM567808  
**Data:** 12/11/2025  
**Capítulo:** 1 - Banco de Dados Oracle

---

## 📋 Arquivos Disponíveis

1. ✅ `setup_database.sql` - Script de criação do banco
2. ✅ `colheitas_import.csv` - Dados para importação (100 registros)

---

## 🚀 Passo a Passo: Importação usando Oracle SQL Developer (VS Code)

### 1️⃣ Conectar ao Banco Oracle

1. Abra o **Command Palette** (`Ctrl+Shift+P`)
2. Digite: `Oracle: Connect to Database`
3. Configure a conexão:
   - **Connection Name:** CanaOptimizer_Dev
   - **User:** seu_usuario
   - **Password:** sua_senha
   - **Connection Type:** Basic
   - **Hostname:** localhost (ou seu servidor)
   - **Port:** 1521
   - **Service Name:** XEPDB1 (ou seu service)

### 2️⃣ Criar a Estrutura do Banco

1. Abra o arquivo `setup_database.sql`
2. Selecione **todo o conteúdo** do arquivo
3. Clique com botão direito → `Execute Selection`
4. Ou use: `Ctrl+E` para executar

**Resultado esperado:**
```
✅ Sequence SEQ_COLHEITA_ID criada
✅ Tabela COLHEITAS criada
✅ Índices criados
✅ Triggers criados
✅ Views criadas
```

### 3️⃣ Importar Dados do CSV

#### Opção A: Usando SQL Developer Extension

1. Clique com botão direito na tabela `COLHEITAS`
2. Selecione: `Import Data...`
3. Escolha o arquivo: `colheitas_import.csv`
4. Configure:
   - **Delimiter:** `;` (ponto e vírgula)
   - **Encoding:** UTF-8
   - **First row is header:** ✅ Sim
   - **Date Format:** DD/MM/YYYY
5. Clique em `Import`

#### Opção B: Usando SQL*Loader (Terminal)

1. Crie o arquivo de controle `colheitas.ctl`:

```sql
LOAD DATA
INFILE 'colheitas_import.csv'
INTO TABLE COLHEITAS
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    ID_COLHEITA,
    FAZENDA,
    AREA_HECTARES,
    TIPO_CANA,
    PRODUTIVIDADE,
    PERCENTUAL_PERDA,
    PRECO_TONELADA,
    COLHEITADEIRA,
    VELOCIDADE,
    CONDICAO_CLIMA,
    DATA_COLHEITA DATE "DD/MM/YYYY",
    TONELADAS_COLHIDAS,
    TONELADAS_PERDIDAS,
    PERDA_FINANCEIRA,
    EFICIENCIA,
    CLASSIFICACAO,
    OBSERVACOES
)
```

2. Execute no terminal:
```bash
sqlldr userid=usuario/senha@servico control=colheitas.ctl log=colheitas.log bad=colheitas.bad
```

#### Opção C: INSERT via SQL (Arquivo já gerado)

Execute o script `insert_colheitas.sql` que será gerado automaticamente.

---

## ✅ Validação da Importação

Execute as queries abaixo para validar:

```sql
-- 1. Contar registros importados
SELECT COUNT(*) AS TOTAL_REGISTROS FROM COLHEITAS;
-- Esperado: 100

-- 2. Verificar distribuição por classificação
SELECT 
    CLASSIFICACAO,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL
FROM COLHEITAS
GROUP BY CLASSIFICACAO
ORDER BY QUANTIDADE DESC;

-- 3. Verificar totais financeiros
SELECT 
    COUNT(*) AS TOTAL_COLHEITAS,
    SUM(AREA_HECTARES) AS AREA_TOTAL,
    SUM(TONELADAS_PERDIDAS) AS PERDAS_TOTAIS,
    SUM(PERDA_FINANCEIRA) AS PERDA_FINANCEIRA_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS;

-- 4. Top 5 fazendas com maiores perdas
SELECT 
    FAZENDA,
    SUM(PERDA_FINANCEIRA) AS PERDA_TOTAL,
    COUNT(*) AS QUANTIDADE_COLHEITAS,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS
GROUP BY FAZENDA
ORDER BY PERDA_TOTAL DESC
FETCH FIRST 5 ROWS ONLY;

-- 5. Colheitas críticas (> 15% perda)
SELECT 
    FAZENDA,
    DATA_COLHEITA,
    PERCENTUAL_PERDA,
    PERDA_FINANCEIRA,
    OBSERVACOES
FROM COLHEITAS
WHERE CLASSIFICACAO = 'Crítica'
ORDER BY PERDA_FINANCEIRA DESC;
```

---

## 📊 Estatísticas Esperadas

Após importação bem-sucedida, você deve ver:

- 📈 **100 registros** na tabela COLHEITAS
- 🌾 **~7.467 hectares** de área total
- 💰 **~R$ 7,5 milhões** em perdas totais
- 📉 **~9,78%** de perda média

**Distribuição:**
- 16% Ótimas
- 22% Boas
- 34% Regulares
- 11% Altas
- 17% Críticas

---

## 🔧 Troubleshooting

### Erro: "Table already exists"
```sql
DROP TABLE COLHEITAS CASCADE CONSTRAINTS;
DROP SEQUENCE SEQ_COLHEITA_ID;
-- Depois execute setup_database.sql novamente
```

### Erro: "Date format invalid"
- Verifique se o formato de data está configurado como `DD/MM/YYYY`
- Ou altere no SQL*Loader control file

### Erro: "Character encoding"
- Use `UTF-8 with BOM` ao salvar o CSV
- Ou especifique `CHARACTERSET UTF8` no SQL*Loader

---

## 📝 Próximos Passos

Após importação bem-sucedida:

1. ✅ Criar queries de análise (SELECT)
2. ✅ Criar procedures e functions
3. ✅ Criar views analíticas
4. ✅ Implementar package PL/SQL
5. ✅ Documentar resultados

---

## 🎓 Entrega do Cap1

Documente em seu relatório:

1. Screenshots da conexão Oracle no VS Code
2. Resultado da execução do `setup_database.sql`
3. Resultado da importação do CSV
4. Execução das queries de validação
5. Análises e insights dos dados

---

**Boa sorte! 🚀**
