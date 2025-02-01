# MultiPGS - O que eu entendi 🔬📊

O MultiPGS combina vários PRS para melhorar a predição de um dado fenótipo. O GWAS/PRS desse fenótipo não necessariamente precisa estar incluído nessa biblioteca de PRS, permitindo uma boa predição até para fenótipos que não têm GWAS.

Ele se vale do fato de que o método selecionado de PRS, o **LDPred**, não precisa de uma amostra para fazer o fine-tuning dos parâmetros. Isso simplifica o uso de sumstats/PRS de bancos de dados, pois elimina a necessidade de que cada PRS tenha, além do conjunto de treino, um conjunto adicional para ajuste de parâmetros.

A ideia principal é juntar todos os PRS possíveis, **mantendo sempre a mesma ancestralidade**, para evitar vieses. 🧬

### Pipeline ⚙️

1. **Obtenção de sumstats**: Coleta dados do **GWAS Catalog, GWAS Atlas e PGC**: são metadados, incluindo onde baixar sumstats, já filtrando para certa ancestralidade.
2. **Filtragem**: Baixa as sumstats e garante que elas contenham os dados mínimos necessários.
3. **QC pré-PRS**: Realiza controles de qualidade. ✅
4. **Execução do LDPred**: Gera os PRS individuais.
5. **Combinação dos PRS**: Utiliza métodos **linear (LASSO) e não linear** para testar a melhor abordagem. O artigo conclui que o **método linear (LASSO)** funciona melhor e na pipeline é ele que fica. 📉

---

## O que a Cássia quer fazer 🎯

Usando **nossos próprios dados**, combinar os PRS de diversos transtornos para prever um fenótipo específico. A ideia é **não utilizar dados externos**, para termos melhor controle dos possíveis vieses, especialmente em relação à ancestralidade. 🌍

### O que precisávamos para fazer isso 🔍

Precisamos saber **o exato input utilizado na última etapa da pipeline**, que é a de combinar os PRS.

---

## O que tentamos 🛠️

Rodamos a pipeline do início para tentar chegar nesse input. No entanto, encontramos dificuldades de replicabilidade, pois **não temos exemplos dos inputs iniciais**.

Conseguimos rodar o primeiro passo com algo que talvez seja o input para a parte de download das sumstats, mas ficamos confusos nesse ponto. Então, enviamos um e-mail para a autora, que sugeriu baixar do **PGS Catalog** e pular direto para a etapa do **LASSO**.

O problema é que **ainda não temos certeza do input dessa etapa**. No material suplementar do artigo, há uma tabela, mas ela parece ser apenas de metadados e não tem informações suficientes para criar um PRS combinado. 

---

## Pautas para a reunião 📌

### 1. Input da última etapa 🏁

- **Qual é o formato exato desse input?**
- **Quais são as colunas necessárias e seu conteúdo?**

### 2. Comparação com PRS-CS ⚖️

- Mostrar um output do **PRS-CS**, que é o método que pretendemos usar no lugar do LDPred.
- Perguntar **quão distante esse output está do input da pipeline** usada no artigo.
- Se a correspondência não for óbvia, entender **o que precisaríamos alterar**.

### 3. Dados de genótipo 🧬

- O artigo menciona **dados de genótipo a nível individual**, além de sumstats.
- Entender **onde esses dados entram** na pipeline e **por que são enfatizados**.
- Avaliar se isso impactaria nossa abordagem (aparentemente, não seria um problema para nós, mas vale esclarecer). 🤔

### 4. Adaptação ao nosso contexto 🔄

- Perguntar se a autora vê **alguma adaptação necessária** ao rodarmos a pipeline com **nossos dados e PRS-CS**.

### 5. Rodar com múltiplas amostras no futuro 🔮

- Se um dia quisermos rodar **da forma original**, com múltiplas amostras de banco de dados, seria útil entender **as colunas necessárias para cada etapa da pipeline**.

---

## Sugestão de abordagem na reunião 💡

1. Explicar o que queremos fazer.
2. Perguntar **diretamente sobre o input** da última etapa.
3. Abordar os tópicos acima, **mostrando os resultados do PRS-CS**, especialmente as colunas que conseguimos obter.

---

## Para checar antes da reunião ✅

- **O PRS-CS precisa de tuning sample?** 🎯
    - Se sim, ele já não bate tanto com a ideia do MultiPGS, pelo menos no uso de dados externos.
    - Precisamos entender o impacto disso na nossa amostra.
    - No nosso caso, usar uma tuning sample pode não ser um problema, mas é importante ter clareza sobre isso antes de seguirmos adiante.