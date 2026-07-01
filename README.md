# Previsão do Campeão da Copa do Mundo FIFA 2026 🏆

Este projeto de Ciência de Dados tem como objetivo prever o favoritarismo e o novo campeão da Copa do Mundo de Futebol de 2026. Utilizando dados históricos de partidas internacionais e inteligência artificial, construímos uma modelagem preditiva end-to-end com engenharia de características (feature engineering) avançada no SQLite, pipeline de treinamento robusto com Random Forest e uma simulação inovadora das fases de grupo e mata-mata do torneio.

---

## Ranking Modelo Atual

> [!WARNING]
> 2a versão do modelo.

Modelo retreinado com novas variáveis:
- Removemos as variáveis dos nomes dos times na disputa;
- Variável de vitórias  (total, médias por campeonatos, etc);


|   rank | equipe      |   aproveitamento |
|-------:|:------------|-----------------:|
|      1 | France      |         0.935484 |
|      2 | Spain       |         0.870968 |
|      3 | Brazil      |         0.870968 |
|      4 | ~~Netherlands~~ |         ~~0.870968~~ |
|      5 | Argentina   |         0.83871  |
|      6 | ~~Germany~~     |         ~~0.83871~~  |
|      7 | England     |         0.774194 |
|      8 | Portugal    |         0.677419 |
|      9 | Belgium     |         0.645161 |
|     10 | Mexico      |         0.612903 |

---

## 📁 Estrutura do Projeto

Abaixo estão os principais arquivos e pastas que estruturam nossa solução:

- [01_ingest.py](01_ingest.py): Executa a carga inicial dos dados brutos em arquivos CSV para o banco relacional SQLite.
- [02_exec_query.py](02_exec_query.py): Processa as safras de data de forma incremental para cálculo de features históricas agregadas no tempo sem vazamento de dados.
- [03_train.py](03_train.py): Constrói a pipeline de modelagem preditiva, otimiza hiperparâmetros (Grid Search) e treina o classificador RandomForest, monitorado via MLflow.
- [04_predict.py](04_predict.py): Realiza as predições de ponta a ponta para a Copa de 2026 (fase de grupos e mata-mata combinatório).
- [tb_team_matches.sql](tb_team_matches.sql): Consolida o histórico sob a ótica individual de cada equipe ("como time principal" e "como adversário"), tratando mudanças históricas de nomes de países.
- [tb_agg_life.sql](tb_agg_life.sql): Agrega o volume de jogos, gols, saldos e vitórias acumuladas de cada nação por campeonato ao longo do tempo.
- [tb_away.sql](tb_away.sql): Agrupa e resume o desempenho específico de confrontos diretos passados.
- [tb_team_away_features.sql](tb_team_away_features.sql): Mantém apenas a fotografia mais recente de confrontos contra adversários específicos.
- [tb_abt_winner.sql](tb_abt_winner.sql): Combina as tabelas dimensionais e de fatos para formar a Analytical Base Table (ABT) definitiva usada no treinamento.
- [feature_importance.md](feature_importance.md): Relatório das features mais representativas para a decisão do modelo de classificação.
- [data](data): Diretório contendo todas as fontes de dados brutas e dados específicos das seleções e calendário da Copa 2026 na subpasta [data/2026](data/2026).

---

## 📊 Origem dos Dados

O modelo é alimentado por duas fontes ricas de informações extraídas do Kaggle:

1. **Dados Históricos de Partidas (1872 até hoje):**
   - Fonte: [International Football Results (1872-2017)](https://www.kaggle.com/datasets/martj42/international-football-results-from-1872-to-2017)
   - Contém os arquivos de partidas [data/results.csv](data/results.csv), disputas de pênaltis [data/shootouts.csv](data/shootouts.csv), artilheiros [data/goalscorers.csv](data/goalscorers.csv) e mapeamento de nomes antigos de federações futebolísticas [data/former_names.csv](data/former_names.csv).

2. **Dados da Copa 2026 (para Predições):**
   - Fonte: [FIFA World Cup Complete Dataset (1930-2026)](https://www.kaggle.com/datasets/kulkarniparth09/fifa-world-cup-complete-dataset-19302026?select=wc_2026_fixtures.csv)
   - Contém o chaveamento oficial da fase de grupos, calendário de confrontos oficiais e o rol de equipes da Copa 2026 [data/2026/wc_2026_fixtures.csv](data/2026/wc_2026_fixtures.csv) e [data/2026/wc_2026_teams.csv](data/2026/wc_2026_teams.csv).

---

## 🛠️ Pipeline de ETL e Modelagem de Dados

A arquitetura do banco de dados SQLite foi desenhada para calcular features de cada seleção sem gerar vazamento de dados (*data leakage*). 


### 1. Preparação e unificação das partidas
Através do script [tb_team_matches.sql](tb_team_matches.sql), duplicamos a perspectiva de cada jogo da tabela `results` para gerar uma visão unificada onde qualquer equipe é tratada de forma agnóstica como o "Time de Interesse" (representado pela coluna `team_current_name`) e seu oponente (representado pela coluna `away_team_current_name`). Também realizamos o tratamento de nomes antigos de federações (com base na dimensão `former_names`) garantindo a integridade dos dados históricos (como a conversão da "Tchecoslováquia" ou "União Soviética" para seus respectivos nomes modernos, onde aplicável).

### 2. Agregando o Histórico de Desempenho (Safra a Safra)
Usamos as tabelas [tb_agg_life.sql](tb_agg_life.sql) e [tb_away.sql](tb_away.sql) para calcular, de forma acumulada e retroativa, o peso histórico de cada seleção em torneios cruciais (Copa do Mundo, eliminatórias da Copa, Copa América, Eurocopa, etc.) até o dia imediatamente anterior a cada partida histórica (`t1.dt_match > t2.dt_match`). Isso permite criar taxas de vitórias históricas, saldo de gols e peso de bagagem competitiva de forma dinâmica e precisa.

Na versão atual, adicionamos um expressivo conjunto de estatísticas globais e agregadas que ampliam a sensibilidade do modelo. As características incorporadas cobrem:
- **Desempenho Geral Acumulado:** Total e média de vitórias e derrotas acumuladas de cada nação ao longo do tempo (`qtdWinnerMatches`, `qtdLoserMatches`, `avgWinnerMatches`, `avgLoserMatches`).
- **Aproveitamento Médio nas Copas do Mundo:** Médias históricas de gols marcados, sofridos, saldo de gols diferenciado, número de vitórias e derrotas em fases finais de Copa do Mundo (`avgWorldCupScore`, `avgWorldCupAwayScore`, `avgWorldCupBalanceScore`, `avgWorldCupWinnerMatches`, `avgWorldCupLoserMatches`).
- **Aproveitamento Médio nas Eliminatórias da Copa:** Médias de desempenho detalhado no processo de qualificação qualificatória para os Mundiais (`avgWorldCupQualificationScore`, `avgWorldCupQualificationAwayScore`, `avgWorldCupQualificationBalanceScore`, `avgWorldCupQualificationWinnerMatches`, `avgWorldCupQualificationLoserMatches`).

### 3. Decisão de Arquitetura da ABT: Duplicação Simétrica de Partidas
Na construção da tabela analítica base em [tb_abt_winner.sql](tb_abt_winner.sql), um ponto metodológico essencial é a **Duplicação Simétrica das Partidas**. Para cada jogo real entre Time A e Time B (em torneios não amistosos desde o ano 2000), a base de treinamento registra duas linhas equivalentes:
- **Linha 1:** Time A como alvo (`team_current_name`) versus Time B como oponente (`away_team_current_name`). O alvo binário assume valor `1` caso o Time A vença, ou `0` caso contrário.
- **Linha 2:** Time B como alvo (`team_current_name`) versus Time A como oponente (`away_team_current_name`). O alvo binário assume valor `1` caso o Time B vença, ou `0` caso contrário.

**Motivos para essa decisão:**
- **Eliminação de Viés de Ordem de Coluna:** Garante que o classificador aprenda as características de força comparativa de forma totalmente neutra, sem assumir que o primeiro time listado tem alguma precedência teórica.
- **Equilíbrio e Simetria do Alvo:** Equilibra perfeitamente a proporção de vitórias e derrotas/empates no dataset, estabilizando e robustecendo o treinamento.
- **Volume Estatístico:** Dobra a quantidade de amostras de treinamento reais disponíveis, facilitando uma melhor convergência estatística do estimador.

---

## 🧠 Treinamento e Engenharia de Machine Learning

O treinamento e otimização são gerenciados passo a passo no script [03_train.py](03_train.py) integrado à ferramenta **MLflow** para governança de experimentos.

### Remodelagem das Variáveis e Eliminação de Vieses
Com o intuito de mitigar vazamento de dados (*data leakage*) e enviesamento por força do favoritismo direto do nome das federações, o pipeline de dados foi reformulado para remover por completo as variáveis categóricas de nomes de equipes (`team_current_name`, `away_team_current_name`) e o tipo de torneio (`tournament`).

Sendo assim:
1. **Remoção de Codificação Categórica:** O pipeline descontinua os passos de OneHotEncoder e MeanEncoder, assegurando que o classificador aprenda unicamente padrões estatísticos globais sem qualquer viés implícito ao nome nominal de um país.
2. **Imputação Racional de Dados Ausentes:** Mantemos o uso do **ArbitraryNumberImputer** preenchendo com `0` os valores ausentes de variáveis numéricas. Esta decisão é conceitualmente refinada: se uma nação nunca participou da Eurocopa ou da Copa América por fatores geográficos de sua confederação, o volume real acumulado e médias de gols e partidas nesses torneios é estatisticamente nulo.

### Classificador e Otimização de Hiperparâmetros
Utilizamos o classificador **Random Forest Classifier** com o critério de entropia (`criterion='entropy'`) e sem restrição de seleção de variáveis (`max_features=None`), o que permite identificar de forma robusta e não linear as nuances de dominância futebolística.

Os hiperparâmetros mais refinados foram vasculhados por meio de **GridSearchCV** integrado ao scikit-learn emparelhado em uma validação cruzada com 3 dobras (3-Fold Cross Validation):
- `n_estimators`: `[300, 400, 500, 600]` (definindo o volume ideal de árvores para convergência de probabilidades)
- `min_samples_leaf`: `[25, 30, 35]` (focado em regular o tamanho das folhas para uma excelente generalização estatística)
- Métrica de Otimização: Área Sob a Curva ROC (**AUC-ROC**), essencial para mensurar a precisão no ranqueamento probabilístico de embates.

Os dados de cada ciclo de treinamento, as melhores métricas calculadas pelo scikit-learn, o gráfico de curva ROC e o arquivo de pesos ordenados [feature_importance.md](feature_importance.md) são gravados diretamente sob as execuções do MLflow.

---

## 🔮 Simulador da Copa do Mundo 2026: Estratégias e Regras

A fase de prognósticos executada pelo script [04_predict.py](04_predict.py) opera sobre um conjunto complexo de regras realistas divididas em duas etapas.

### 1. Simulação da Fase de Grupos
Seguindo o design da Copa de 2026 (que é composta por 12 grupos de 4 equipes nacionais), o simulador calcula a classificação agregada obedecendo rigorosamente à estrutura definida:
- **Alinhamento Linguístico:** Corrigimos mapeamentos específicos de nomes na planilha oficial de jogos [data/2026/wc_2026_fixtures.csv](data/2026/wc_2026_fixtures.csv), mapeando strings variantes para as entidades padronizadas no banco (ex: "USA" para "United States", "Czechia" para "Czech Republic" e "Türkiye" para "Turkey").
- **Exploração Bidirecional:** Cada confronto previsto do calendário do arquivo oficial de fixtures é expandido em duas visões (Lado A e Lado B), alimentado com as features históricas de time e oponente e submetido ao preditor.
- **Resolução de Empates / Vencedor de Partida:** Para determinar o vencedor de cada partida, o modelo calcula a probabilidade de vitória de ambos os quadrantes. Aquele que obter a probabilidade absoluta superior (`prob_win` máximo correspondente a um dado `match_id`) é declarado o vencedor do confronto.
- **Tabela de Pontos e Classificação:**
  - **Classificados Diretos:** Os times que somarem **2 ou mais vitórias** na fase de grupos garantem classificação automática direta (correspondente às vagas diretas de líder e vice-líder de cada um dos 12 grupos, consolidando 24 equipes).
  - **Repescagem de Melhores 3º colocados:** De acordo com o novo regulamento oficial, os **8 melhores terceiros colocados** com exatamente uma vitória avançam para constituir o chaveamento de mata-mata de 32 times. Nosso simulador calcula esses classificados ordenando os times com 1 vitória de acordo com a sua probabilidade média de vitória (`prob_win`) de forma descendente, resgatando o top 8.

### 2. Simulação Heurística do Mata-mata (Simulação Combinatória Sustentada)
A modelagem clássica de chaves fixas em árvore de torneio pode introduzir alta volatilidade (onde um time superior pode cair precocemente por um azar tático único). Para determinar a resposta mais consistente do ponto de vista do potencial matemático real, criamos uma **Simulação Combinatória Sustentada:**

1. **Permutação de Cruzamentos:** Consolidamos as 32 melhores nações classificadas na etapa anterior e criamos todas as combinações bilaterais de confrontos possíveis entre elas, gerando as permutações completas:
   $$\text{Combinações Únicas} = \frac{32 \times 31}{2} = 496 \text{ confrontos simultâneos}$$
2. **Avaliação Bilateral:** Cada par competitivo é avaliado nos dois sentidos (time alvo contra time oponente e vice-versa).
3. **Determinação do Vencedor:** O modelo infere a maior probabilidade de vitória por partida unificada (mantendo a predição dominante com maior `prob_win`).
4. **Ranqueamento Global de Força (Power Ranking):**
   - Agrupamos o saldo de vitórias consolidado de cada seleção ao enfrentar todos os 31 potenciais oponentes sobreviventes do torneio.
   - Computamos a probabilidade média de vitória (`prob_win`) ponderada de cada seleção em todos os cenários possíveis.
   - Calculamos a taxa de **Aproveitamento Geral** do país como:
     $$\text{Aproveitamento} = \frac{\text{Quant. de Vitórias Obtidas nos Confrontos}}{31}$$
   - Classificamos as seleções pelo número decrescente de vitórias e desempate por probabilidade média de vitória. 

A seleção que figurar no **Rank #1** com o maior número de vitórias sustentadas (e maior aproveitamento proporcional) é apontada pelo projeto como o esperado **Campeão Mundial de 2026**!
