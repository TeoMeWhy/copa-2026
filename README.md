# Previsão do Campeão da Copa do Mundo FIFA 2026 🏆

Este projeto de Ciência de Dados tem como objetivo prever o favoritarismo e o novo campeão da Copa do Mundo de Futebol de 2026. Utilizando dados históricos de partidas internacionais e inteligência artificial, construímos uma modelagem preditiva end-to-end com engenharia de características (feature engineering) avançada no SQLite, pipeline de treinamento robusto com Random Forest e uma simulação inovadora das fases de grupo e mata-mata do torneio.

---

## Ranking Modelo Atual

> [!WARNING]
> 2a versão do modelo.

Modelo retreinado com novas variáveis:
- Removemos as variáveis dos nomes dos times na disputa;
- Criamos a variável de vitórias históricas;


|   rank | equipe         |   aproveitamento |
|-------:|:---------------|-----------------:|
|      1 | France         |         0.903226 |
|      2 | Spain          |         0.83871  |
|      3 | Brazil         |         0.83871  |
|      4 | Netherlands    |         0.83871  |
|      5 | Argentina      |         0.806452 |
|      6 | Germany        |         0.806452 |
|      7 | England        |         0.741935 |
|      8 | Portugal       |         0.612903 |
|      9 | Belgium        |         0.612903 |
|     10 | Uruguay        |         0.580645 |
|     11 | Mexico         |         0.548387 |
|     12 | Sweden         |         0.516129 |
|     13 | Croatia        |         0.516129 |
|     14 | Austria        |         0.483871 |
|     15 | Switzerland    |         0.451613 |
|     16 | United States  |         0.419355 |
|     17 | Turkey         |         0.419355 |
|     18 | Ecuador        |         0.387097 |
|     19 | South Korea    |         0.322581 |
|     20 | Tunisia        |         0.322581 |
|     21 | Colombia       |         0.322581 |
|     22 | Scotland       |         0.322581 |
|     23 | Morocco        |         0.290323 |
|     24 | Curaçao        |         0.258065 |
|     25 | Australia      |         0.225806 |
|     26 | Senegal        |         0.193548 |
|     27 | Iran           |         0.193548 |
|     28 | Egypt          |         0.129032 |
|     29 | Czech Republic |         0.129032 |

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
- [data/](data/): Diretório contendo todas as fontes de dados brutas e dados específicos das seleções e calendário da Copa 2026 na subpasta [data/2026/](data/2026/).

---

## 📊 Origem dos Dados

O modelo é alimentado por duas fontes ricas de informações extraídas do Kaggle:

1. **Dados Históricos de Partidas (1872 até hoje):**
   - Fonte: [International Football Results (1872-2017)](https://www.kaggle.com/datasets/martj42/international-football-results-from-1872-to-2017)
   - Contém os arquivos de partidas (results.csv), disputas de pênaltis (shootouts.csv), artilheiros (goalscorers.csv) e mapeamento de nomes antigos de federações futebolísticas (former_names.csv).

2. **Dados da Copa 2026 (para Predições):**
   - Fonte: [FIFA World Cup Complete Dataset (1930-2026)](https://www.kaggle.com/datasets/kulkarniparth09/fifa-world-cup-complete-dataset-19302026?select=wc_2026_fixtures.csv)
   - Contém o chaveamento oficial da fase de grupos, calendário de confrontos oficiais e o rol de equipes da Copa 2026 (wc_2026_fixtures.csv e wc_2026_teams.csv).

---

## 🛠️ Pipeline de ETL e Modelagem de Dados

A arquitetura do banco de dados SQLite foi desenhada para calcular features de cada seleção sem gerar vazamento de dados (*data leakage*). 


### 1. Preparação e unificação das partidas
Através do script [tb_team_matches.sql](tb_team_matches.sql), duplicamos a perspectiva de cada jogo da tabela `results` para gerar uma visão unificada onde qualquer equipe é tratada de forma agnóstica como o "Time de Interesse" (representado pela coluna `team_current_name`) e seu oponente (representado pela coluna `away_team_current_name`). Também realizamos o tratamento de nomes antigos de federações (com base na dimensão `former_names`) garantindo a integridade dos dados históricos (como a conversão da "Tchecoslováquia" ou "União Soviética" para seus respectivos nomes modernos, onde aplicável).

### 2. Agregando o Histórico de Desempenho (Safra a Safra)
Usamos as tabelas [tb_agg_life.sql](tb_agg_life.sql) e [tb_away.sql](tb_away.sql) para calcular, de forma acumulada e retroativa, o peso histórico de cada seleção em torneios cruciais (Copa do Mundo, eliminatórias da Copa, Copa América, Eurocopa, etc.) até o dia imediatamente anterior a cada partida histórica (`t1.dt_match > t2.dt_match`). Isso permite criar taxas de vitórias históricas, saldo de gols e peso de bagagem competitiva de forma dinâmica e precisa.

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

### Transformação e Codificação de Recursos
Para traduzir as variáveis categóricas dinâmicas em dados numéricos assimiláveis pelo classificador, o pipeline implementa:
1. **OneHotEncoder** (via Feature Engine) para codificação exclusiva da coluna `tournament` (tipo de partida), diferenciando a importância de uma Copa do Mundo de uma Nations League ou Amistoso.
2. **MeanEncoder** (via Feature Engine) para as colunas `team_current_name` e `away_team_current_name`. Essa estratégia calcula dinamicamente a taxa de vitórias histórica (target encoding) de cada federação de futebol nacional, representando numericamente a força institucional e tradição ("peso da camisa") daquela seleção frente ao histórico global.
3. **ArbitraryNumberImputer** imputando `0` para campos com valores ausentes das variáveis numéricas. Essa técnica é filosoficamente robusta por natureza: se um país nunca disputou a Copa América ou a Eurocopa devido ao seu continente geográfico, o valor cumulativo real de jogos e gols nessas federações é logicamente zero.

### Classificador e Tuning (Grid Search)
Utilizamos o algoritmo **Random Forest Classifier**, ideal para extrair relações não lineares de superioridade esportiva e que oferece alta robustez contra overfitting de features correlatas. 

Para encontrar os melhores parâmetros, realizamos um ajuste minucioso através do **GridSearchCV** do scikit-learn estruturado em uma validação cruzada com 4 dobras (4-Fold Cross Validation):
- `n_estimators`: [500] (para máxima estabilidade na média probabilística das árvores)
- `max_depth`: [None] (deixando as árvores crescerem até sua plenitude estrutural)
- `min_samples_leaf`: [20, 30, 50] (regulando o tamanho das folhas para evitar a memorização de ruídos pontuais)
- `max_features`: [None] (utilizando todo o espaço vetorial de features na divisão)
- Métrica de Otimização: Área Sob a Curva ROC (**AUC-ROC**), o melhor indicador para avaliar o ranqueamento probabilístico das forças das seleções.

Toda a rodada do treinamento, métricas finais de acurácia, curva ROC (salva no arquivo `roc_curve.png`) e a tabela de pesos em [feature_importance.md](feature_importance.md) são automaticamente persistidas via mlflow.

---

## 🔮 Simulador da Copa do Mundo 2026: Estratégias e Regras

A fase de prognósticos executada pelo script [04_predict.py](04_predict.py) opera sobre um conjunto complexo de regras realistas divididas em duas etapas.

### 1. Simulação da Fase de Grupos
Seguindo o design da Copa de 2026 (que é composta por 12 grupos de 4 equipes nacionais), o simulador calcula a classificação agregada obedecendo rigorosamente à estrutura definida:
- **Alinhamento Linguístico:** Corrigimos mapeamentos específicos de nomes na planilha oficial de jogos (wc_2026_fixtures.csv), mapeando strings variantes para as entidades padronizadas no banco (ex: "USA" para "United States", "Czechia" para "Czech Republic" e "Türkiye" para "Turkey").
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
