# 🔌 Passo a Passo - Conexão e Importação Oracle

## 📋 Credenciais Configuradas

```
Nome da Conexão: FIAP_RM567808
Nome do Usuário: RM567808
Senha: 200583
Nome do Host: oracle.fiap.com.br
Porta: 1521
SID: ORCL
```

---

## 1️⃣ CONECTAR AO ORACLE (Via VS Code)

### Opção A: Extensão Oracle SQL Developer

1. **Abrir Command Palette**: `Ctrl + Shift + P`
2. **Digitar**: `Oracle: New Connection`
3. **Preencher os dados**:
   - Connection Name: `FIAP_RM567808`
   - Username: `RM567808`
   - Password: `200583`
   - Hostname: `oracle.fiap.com.br`
   - Port: `1521`
   - SID: `ORCL`
4. **Testar Conexão**
5. **📸 PRINT 1**: `prints/01_conexao.png`

### Opção B: SQL*Plus via Terminal

```powershell
# Se tiver Oracle Client instalado:
sqlplus RM567808/200583@oracle.fiap.com.br:1521/ORCL
```

---

## 2️⃣ CRIAR ESTRUTURA DO BANCO

### Executar setup_database.sql

1. **Abrir arquivo**: `setup_database.sql`
2. **Conectar ao Oracle** (se ainda não conectou)
3. **Executar todo o script** (F5 ou botão Run)

**O script vai criar:**
- ✅ Sequence: `SEQ_COLHEITA_ID`
- ✅ Tabela: `COLHEITAS` (17 colunas)
- ✅ Trigger: `TRG_COLHEITA_ID` (auto-increment)
- ✅ Trigger: `TRG_COLHEITA_TIMESTAMP` (timestamp)
- ✅ Índices: `IDX_COLHEITA_FAZENDA`, `IDX_COLHEITA_DATA`, `IDX_COLHEITA_CLASSIFICACAO`
- ✅ View: `VW_RESUMO_COLHEITAS`
- ✅ View: `VW_COLHEITAS_CRITICAS`

4. **Verificar criação**:

```sql
-- Ver tabelas criadas
SELECT table_name FROM user_tables WHERE table_name = 'COLHEITAS';

-- Ver estrutura da tabela
DESC COLHEITAS;
```

5. **📸 PRINT 2**: `prints/02_estrutura_criada.png`

---

## 3️⃣ IMPORTAR DADOS DO CSV

### Método 1: Via Oracle SQL Developer (GUI)

1. **No Explorer do Oracle**, expandir sua conexão
2. **Clicar com botão direito** em "Tabelas (Filtrado)"
3. **Selecionar**: "Import Data" ou "Importar Dados"
4. **Configurar Import Wizard**:
   - **File**: `C:\pessoal\fiap\modulo3\Cap1\colheitas_import.csv`
   - **Table**: `COLHEITAS`
   - **Delimiter**: `;` (ponto e vírgula)
   - **Encoding**: `UTF-8`
   - **First row is header**: ✅ Marcar
   - **Date Format**: `DD/MM/YYYY`
5. **Mapear colunas** (verificar se está correto)
6. **Executar importação**
7. **📸 PRINT 3**: `prints/03_importacao.png`

### Método 2: Via SQL*Loader (Terminal)

```powershell
# Navegar até a pasta
cd C:\pessoal\fiap\modulo3\Cap1

# Executar SQL*Loader
sqlldr RM567808/200583@oracle.fiap.com.br:1521/ORCL control=colheitas_loader.ctl log=import.log
```

### Método 3: Via Script SQL (INSERT INTO)

Se os métodos acima não funcionarem, posso gerar um arquivo `.sql` com todos os INSERTs.

---

## 4️⃣ VALIDAR IMPORTAÇÃO

```sql
-- Contar registros
SELECT COUNT(*) AS TOTAL_REGISTROS FROM COLHEITAS;
-- Resultado esperado: 100

-- Ver primeiros registros
SELECT * FROM COLHEITAS FETCH FIRST 10 ROWS ONLY;

-- Verificar classificações
SELECT CLASSIFICACAO, COUNT(*) AS QTD 
FROM COLHEITAS 
GROUP BY CLASSIFICACAO;
```

4. **📸 PRINT 4**: `prints/04_dados_importados.png`

---

## 5️⃣ EXECUTAR CONSULTAS SQL

### Abrir arquivo queries_validacao.sql e executar:

1. **Consulta 1 - Todos os dados**:
```sql
SELECT * FROM COLHEITAS;
```
📸 **PRINT 5**: `prints/05_select_all.png`

2. **Consulta 2 - Estatísticas gerais**:
```sql
SELECT 
    COUNT(*) AS TOTAL_COLHEITAS,
    ROUND(SUM(AREA_HECTARES), 2) AS AREA_TOTAL,
    ROUND(SUM(TONELADAS_PERDIDAS), 2) AS PERDAS_TOTAIS,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS;
```
📸 **PRINT 6**: `prints/06_estatisticas.png`

3. **Consulta 3 - Por classificação**:
```sql
SELECT 
    CLASSIFICACAO,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL
FROM COLHEITAS
GROUP BY CLASSIFICACAO
ORDER BY QUANTIDADE DESC;
```
📸 **PRINT 7**: `prints/07_classificacao.png`

4. **Consulta 4 - Top 5 fazendas com perdas**:
```sql
SELECT 
    FAZENDA,
    SUM(PERDA_FINANCEIRA) AS PERDA_TOTAL,
    COUNT(*) AS QUANTIDADE_COLHEITAS
FROM COLHEITAS
GROUP BY FAZENDA
ORDER BY PERDA_TOTAL DESC
FETCH FIRST 5 ROWS ONLY;
```
📸 **PRINT 8**: `prints/08_top_fazendas.png`

5. **Consulta 5 - Por condição climática**:
```sql
SELECT 
    CONDICAO_CLIMA,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS
GROUP BY CONDICAO_CLIMA
ORDER BY PERDA_MEDIA ASC;
```
📸 **PRINT 9**: `prints/09_clima.png`

---

## 6️⃣ CHECKLIST DE PRINTS NECESSÁRIOS

- [ ] `01_conexao.png` - Conexão estabelecida com Oracle
- [ ] `02_estrutura_criada.png` - Tabela COLHEITAS criada
- [ ] `03_importacao.png` - Wizard de importação do CSV
- [ ] `04_dados_importados.png` - Contagem de 100 registros
- [ ] `05_select_all.png` - SELECT * FROM COLHEITAS
- [ ] `06_estatisticas.png` - Consulta de estatísticas gerais
- [ ] `07_classificacao.png` - Distribuição por classificação
- [ ] `08_top_fazendas.png` - Top 5 fazendas
- [ ] `09_clima.png` - Análise por condição climática

---

## 7️⃣ POSSÍVEIS PROBLEMAS E SOLUÇÕES

### ❌ Erro: "ORA-12170: TNS:Connect timeout occurred"

**Causa**: Firewall bloqueando conexão ou servidor indisponível.

**Solução**:
1. Verificar se está na rede FIAP (ou VPN)
2. Testar ping: `ping oracle.fiap.com.br`
3. Contatar suporte FIAP

### ❌ Erro: "ORA-01017: invalid username/password"

**Causa**: Credenciais incorretas.

**Solução**:
1. Verificar se o RM está correto: `RM567808`
2. Verificar se a senha está correta: `200583`
3. Verificar se o usuário foi criado no Oracle

### ❌ Erro: "ORA-00942: table or view does not exist"

**Causa**: Tabela COLHEITAS não foi criada.

**Solução**:
1. Executar `setup_database.sql` primeiro
2. Verificar se está conectado com o usuário correto

### ❌ CSV não importa corretamente

**Causa**: Encoding ou delimitador errado.

**Solução**:
1. Verificar encoding: UTF-8
2. Verificar delimitador: `;` (ponto e vírgula)
3. Verificar formato de data: DD/MM/YYYY
4. Tentar método alternativo (SQL*Loader ou INSERTs)

---

## 📝 PRÓXIMOS PASSOS

Após completar tudo:

1. ✅ Organizar prints na pasta `prints/`
2. ✅ Atualizar README.md com resultados reais
3. ✅ Fazer commit no GitHub
4. ✅ Gravar vídeo demonstrativo (5 min)
5. ✅ Fazer upload no YouTube (não listado)
6. ✅ Adicionar link do vídeo no README.md

---

**Desenvolvido por Sidney de Lirio Cardoso - RM567808**
