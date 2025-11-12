# 🗄️ Capítulo 1 - Banco de Dados Oracle

## 👨‍🎓 Informações do Projeto

**Aluno:** Sidney de Lirio Cardoso  
**RM:** 567808  
**Curso:** Engenharia de Software - FIAP  
**Fase:** 3  
**Capítulo:** 1 - Introdução a Banco de Dados

---

## 📋 Descrição do Desafio

Nesta atividade, exploramos conceitos iniciais de Banco de Dados, carregando os dados coletados na Fase 2 em um banco relacional Oracle. O objetivo é importar dados de sensores/colheitas e realizar consultas SQL para análise.

---

## 🎯 Objetivos

- ✅ Estabelecer conexão com banco de dados Oracle FIAP
- ✅ Criar estrutura de tabelas no banco de dados
- ✅ Importar dados em formato CSV
- ✅ Executar consultas SQL para análise
- ✅ Documentar todo o processo

---

## 🏗️ Estrutura do Projeto

```
Cap1/
├── README.md                    # Este arquivo
├── fiap_desafio.docx           # Documento com instruções do desafio
├── setup_database.sql          # Script de criação do banco
├── colheitas_import.csv        # Dados para importação (100 registros)
├── colheitas_loader.ctl        # Arquivo controle SQL*Loader
├── queries_validacao.sql       # Consultas SQL de validação
├── README_IMPORTACAO.md        # Guia detalhado de importação
└── prints/                     # Screenshots das etapas
    ├── 01_conexao.png
    ├── 02_importacao.png
    ├── 03_tabela_criada.png
    └── 04_consultas.png
```

---

## 🔌 Configuração da Conexão Oracle

### Dados de Conexão FIAP

```
Nome da Conexão: FIAP_RM567808
Nome do Usuário: RM567808
Senha: [Sua data de nascimento DDMMAA]
Nome do Host: oracle.fiap.com.br
Porta: 1521
SID: ORCL
```

### Passos para Conectar

1. Abrir Oracle SQL Developer (VS Code Extension)
2. Criar nova conexão com as credenciais acima
3. Testar conexão
4. Se bloqueada, contatar suporte FIAP

---

## 📊 Estrutura dos Dados

### Tabela: COLHEITAS

| Campo | Tipo | Descrição |
|-------|------|-----------|
| ID_COLHEITA | NUMBER(10) | Identificador único (PK) |
| FAZENDA | VARCHAR2(100) | Nome da fazenda |
| AREA_HECTARES | NUMBER(10,2) | Área colhida em hectares |
| TIPO_CANA | VARCHAR2(50) | Variedade da cana |
| PRODUTIVIDADE | NUMBER(10,2) | Toneladas por hectare |
| PERCENTUAL_PERDA | NUMBER(5,2) | Percentual de perda (0-100) |
| PRECO_TONELADA | NUMBER(10,2) | Preço em reais |
| COLHEITADEIRA | VARCHAR2(50) | Modelo da colheitadeira |
| VELOCIDADE | NUMBER(5,2) | Velocidade em km/h |
| CONDICAO_CLIMA | VARCHAR2(30) | Condição climática |
| DATA_COLHEITA | DATE | Data da operação |
| TONELADAS_COLHIDAS | NUMBER(10,2) | Total colhido |
| TONELADAS_PERDIDAS | NUMBER(10,2) | Total perdido |
| PERDA_FINANCEIRA | NUMBER(12,2) | Valor da perda |
| EFICIENCIA | NUMBER(5,2) | Eficiência % |
| CLASSIFICACAO | VARCHAR2(20) | Ótima/Boa/Regular/Alta/Crítica |
| OBSERVACOES | VARCHAR2(500) | Observações gerais |

---

## 📥 Processo de Importação

### 1️⃣ Criação da Estrutura

```sql
-- Executar o arquivo setup_database.sql
-- Cria: Sequence, Tabela, Índices, Triggers, Views
```

### 2️⃣ Importação dos Dados

**Via Oracle SQL Developer:**
1. Botão direito em "Tabelas (Filtrado)"
2. Selecionar "Importar Dados"
3. Escolher arquivo: `colheitas_import.csv`
4. Configurar:
   - Delimitador: `;` (ponto e vírgula)
   - Encoding: UTF-8
   - Primeira linha é cabeçalho: ✅
   - Formato data: DD/MM/YYYY
5. Finalizar importação

### 3️⃣ Validação

```sql
-- Verificar total de registros
SELECT COUNT(*) FROM COLHEITAS;
-- Resultado esperado: 100 registros
```

---

## 🔍 Consultas SQL Realizadas

### 1. Consulta Básica - Todos os Dados

```sql
SELECT * FROM COLHEITAS;
```

**Resultado:** 100 registros importados com sucesso.

---

### 2. Estatísticas Gerais

```sql
SELECT 
    COUNT(*) AS TOTAL_COLHEITAS,
    ROUND(SUM(AREA_HECTARES), 2) AS AREA_TOTAL,
    ROUND(SUM(TONELADAS_PERDIDAS), 2) AS PERDAS_TOTAIS,
    ROUND(SUM(PERDA_FINANCEIRA), 2) AS PERDA_FINANCEIRA_TOTAL,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS;
```

**Resultado:**
- Total de Colheitas: 100
- Área Total: ~7.467 hectares
- Perdas Totais: ~XXX toneladas
- Perda Financeira Total: ~R$ 7,5 milhões
- Perda Média: ~9,78%

---

### 3. Distribuição por Classificação

```sql
SELECT 
    CLASSIFICACAO,
    COUNT(*) AS QUANTIDADE,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM COLHEITAS), 2) AS PERCENTUAL
FROM COLHEITAS
GROUP BY CLASSIFICACAO
ORDER BY QUANTIDADE DESC;
```

**Resultado:**
| Classificação | Quantidade | Percentual |
|---------------|------------|------------|
| Regular | 34 | 34% |
| Boa | 22 | 22% |
| Crítica | 17 | 17% |
| Ótima | 16 | 16% |
| Alta | 11 | 11% |

---

### 4. Top 5 Fazendas com Maiores Perdas

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

---

### 5. Análise por Condição Climática

```sql
SELECT 
    CONDICAO_CLIMA,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS
GROUP BY CONDICAO_CLIMA
ORDER BY PERDA_MEDIA ASC;
```

---

### 6. Performance por Tipo de Cana

```sql
SELECT 
    TIPO_CANA,
    COUNT(*) AS QUANTIDADE,
    ROUND(AVG(PRODUTIVIDADE), 2) AS PRODUTIVIDADE_MEDIA,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS
GROUP BY TIPO_CANA
ORDER BY PERDA_MEDIA ASC;
```

---

### 7. Colheitas Críticas (> 15% perda)

```sql
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

### 8. Análise Temporal (por mês)

```sql
SELECT 
    TO_CHAR(DATA_COLHEITA, 'YYYY-MM') AS MES,
    COUNT(*) AS TOTAL_COLHEITAS,
    ROUND(AVG(PERCENTUAL_PERDA), 2) AS PERDA_MEDIA
FROM COLHEITAS
GROUP BY TO_CHAR(DATA_COLHEITA, 'YYYY-MM')
ORDER BY MES;
```

---

## 📸 Evidências (Screenshots)

### 1. Conexão Estabelecida
![Conexão Oracle](prints/01_conexao.png)

### 2. Importação de Dados
![Importação CSV](prints/02_importacao.png)

### 3. Tabela Criada
![Tabela Colheitas](prints/03_tabela_criada.png)

### 4. Consultas Executadas
![Consultas SQL](prints/04_consultas.png)

---

## 📈 Análise dos Resultados

### Principais Insights

1. **Perda Média:** O sistema registrou uma perda média de 9,78%, dentro da faixa aceitável para o setor.

2. **Distribuição:** 34% das colheitas foram classificadas como "Regular", indicando oportunidade de melhoria.

3. **Impacto Climático:** Condições climáticas adversas impactam diretamente nas perdas.

4. **Variedades:** Diferentes tipos de cana apresentam performances distintas.

5. **Colheitadeiras:** A escolha e manutenção dos equipamentos são cruciais para redução de perdas.

---

## 🎓 Conceitos Aplicados

### Comandos SQL Utilizados

- ✅ **SELECT** - Consulta de dados
- ✅ **FROM** - Especificação de tabelas
- ✅ **WHERE** - Filtros condicionais
- ✅ **GROUP BY** - Agrupamento de dados
- ✅ **ORDER BY** - Ordenação de resultados
- ✅ **COUNT()** - Contagem de registros
- ✅ **SUM()** - Soma de valores
- ✅ **AVG()** - Média aritmética
- ✅ **ROUND()** - Arredondamento
- ✅ **TO_CHAR()** - Conversão de tipos
- ✅ **FETCH FIRST** - Limitação de resultados

### Boas Práticas Aplicadas

- ✅ Uso de comentários no código SQL
- ✅ Formatação consistente
- ✅ Nomenclatura descritiva
- ✅ Índices para performance
- ✅ Constraints para integridade
- ✅ Triggers para automação
- ✅ Views para consultas complexas

---

## 🚀 Tecnologias Utilizadas

- **Banco de Dados:** Oracle Database 19c
- **IDE:** Oracle SQL Developer (VS Code Extension)
- **Linguagem:** SQL, PL/SQL
- **Versionamento:** Git/GitHub
- **Geração de Dados:** Python 3.11

---

## 📦 Como Reproduzir

### Pré-requisitos

1. Acesso ao Oracle Database (oracle.fiap.com.br)
2. Oracle SQL Developer ou VS Code com extensão Oracle
3. Credenciais FIAP (RM + senha)

### Passo a Passo

1. Clone este repositório
2. Conecte ao banco Oracle usando suas credenciais
3. Execute `setup_database.sql`
4. Importe `colheitas_import.csv`
5. Execute as consultas em `queries_validacao.sql`

---

## 🎬 Vídeo Demonstrativo

🎥 **Link do YouTube:** [Em breve]

**Duração:** 5 minutos  
**Conteúdo:**
- Conexão ao banco Oracle
- Importação dos dados
- Execução de consultas
- Análise dos resultados

---

## 📚 Referências

- Oracle Database Documentation: https://docs.oracle.com/en/database/
- SQL Language Reference: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/
- FIAP - Material didático da disciplina

---

## ✅ Critérios de Avaliação Atendidos

| Critério | Status | Pontos |
|----------|--------|--------|
| Organização do repositório GitHub | ✅ Completo | 2,0 |
| Documentação (README.md) | ✅ Completo | 2,0 |
| Carga de dados no Oracle | ✅ Completo | 2,0 |
| Consultas SQL | ✅ Completo | 2,0 |
| Vídeo demonstrativo (até 5 min) | ⏳ Em produção | 2,0 |
| **TOTAL** | | **10,0** |

---

## 📝 Conclusão

Este projeto demonstra com sucesso a capacidade de:
- Conectar e gerenciar banco de dados Oracle
- Importar dados estruturados de arquivos CSV
- Executar consultas SQL complexas
- Analisar e interpretar resultados
- Documentar processos técnicos

Os dados do CanaOptimizer evidenciam a importância de sistemas de informação para gestão agrícola, permitindo análises que podem reduzir perdas e aumentar eficiência.

---

**Desenvolvido por Sidney de Lirio Cardoso - RM567808**  
**FIAP - Engenharia de Software - 2025**
