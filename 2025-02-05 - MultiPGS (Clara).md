
### Pipeline ⚙️

1. **Obtenção de sumstats**: Coleta dados do **GWAS Catalog, GWAS Atlas e PGC**: são metadados, incluindo onde baixar sumstats, já filtrando para certa ancestralidade.
2. **Filtragem**: Baixa as sumstats e garante que elas contenham os dados mínimos necessários.
3. **QC pré-PRS**: Realiza controles de qualidade. ✅
4. **Execução do LDPred**: Gera os PRS individuais.
5. **Combinação dos PRS**: Utiliza métodos **linear (LASSO) e não linear** para testar a melhor abordagem. O artigo conclui que o **método linear (LASSO)** funciona melhor e na pipeline é ele que fica. 📉

#### Esclarecimentos da Reunião 💬

- **Etapas 1 e 2**: São formas de baixar dados de maneira mais automatizada para chegar ao input do LDPred, enquanto a etapa 3 também contribui, mas atua mais como uma filtragem (o QC).
- Tudo que ocorre antes da etapa de combinar os PRS está, na verdade, preparando o input para o LDPred. Com a documentação dele, já se sabe qual o formato necessário, e o mesmo vale para os outros métodos de PRS. Assim, podemos usar o código existente como base para esse preparo, principalmente nas etapas 1 e 2, de baixar as sumstats e garantir que contenham os dados necessários.
- **Etapa 4**: Depois do input preparado, é hora de rodar todos os PRS. Acreditamos que isso seja viável, pois basta executar os PRS como fazemos normalmente; o script fornecido deve ajudar a tornar essa etapa computacionalmente mais eficiente.
- **Etapa 5**: Por fim, ocorre a regressão linear, penalizada ou não (para poucos PRS, a penalização, segundo a Clara, não importa tanto).

---

#### Para a Pergunta de Pesquisa da Cássia 🔍

- Como estamos analisando vários timepoints com os mesmos indivíduos, há risco de overfitting, o que torna necessária a aplicação de cross-validation.
- Se não me engano, o paper também utiliza cross-validation, então talvez o código fornecido já contemple essa abordagem para que possamos nos basear.
- Dado que a amostra é miscigenada, foi sugerido incluir PRSs de cada ancestralidade. Dessa forma, poderemos verificar se a melhora na predição está ocorrendo mais devido à maior ancestralidade europeia ou se é realmente uma melhoria geral (é isso, né?). Assim, a avaliação não se limitará apenas ao R².

---

#### Sobre o Input 📊

- Trata-se de um input para regressão linear. Pelo que entendi, a Clara vai enviar a parte específica da função (que é um GLM) e também uma descrição das colunas — embora ainda não esteja totalmente claro se essa última parte será realmente fornecida.