- ~~Arrumar os problemas que tem nos scripts que ja existem.~~
	-~~Importante decidir, antes de tudo, se seguira com o loop dos cromossomos, ja que o collapse provavelmente sempre sera rodado um a um.~~
	- feito, precisa testar os scripts citados acima que precisa testar.
- ~~Adequar os scripts de acordo com PAxSPxgeral aos que isso se aplica/faz sentido fazer~~
	- Todos adequados, mas precisa testar [[chr_frag_plot.R]], [[check_largest_region.sh (aposentado)]] e [[pos_frags_vs_hg38.sh]], atualizar a doc de [[chr_frag_plot.R]] e testar nova versão de [[count.sh (aposentado)]], que não tem propriamente a ver com adequar pra PAxSP porque já tem.
- ~~Ir resolvendo dependencias adicionais dos scripts um por um na etapa de separar~~
	- feito, precisa testar os scripts citados acima que precisa testar.
- ~~Tem uns arquivos q rodou o collapse completo, ver o que fazer quanto a isso, se tem anotado em algum lugar quais foram, etc. A flag do frag tenho quase ctz que resolve isso, checar. ~~
	- ~~Quando rodar o collapse de novo pra o chr 2 e assim por diante, em teoria perde o do cromossomo anterior, ver como isso impacta e como lidar, se perde mesmo, se faz de outro jeito... No [[frag_info_per_anc_chr.sh]] se rodar collapse assim, acho q n precisa mais destinar nada a separar pro chr pq se n deletar, vai ser outro dir e um loop, tipo output_collapse/chr_1. Mas ainda assim flag seria bom pq tem os legado com tds, precisa pensar.~~
		- Mantive todos os arquivos somente com cromossomo 1. Testei o comando antes e o script rodou bonitinho de primeira, mas se tiver com o que contra-checar (arquivos do cérebro), só pra pegar um wc -l original e um wc -l atual e ter ctz q o número é o msm (script fácil de fazer, printa nome e numero de linhas e checa dif entre arquivos com grep -Ff pra caso seja só sorting) pra ter certeza que nao perdeu nada, melhor. **Acidentalmente limpei o arquivo da amostra C10001_A.bed, precisa pegar o original do cérebro, não tem como.**. 
		- Nova estrutura de dirs será: output_collapse/chr_1 e assim por diante, então não vamos perder o anterior, terá só que checar se está no dir certo, sempre. Acho mais seguro assim. Ver se não vira mó role conforme evolui, e também como altera o collapse_loop conforme isso for rolando.
- Apos gerar os dados PA, SP, geral (chr 1), rascunhar a montagem
	- Precisa ver se quer montar um genoma de ref ou reconstruir o max de genomas possivel. Pra esse segundo caso eu nao tenho ideia, so a possibilidade 3, mas msm assim o criterio pra montar fica arbitrario. Ai bate com aqueles negocios de montar os pequeninos e grandes e tal. Caos.
- Ver os graficos de 109.
	- Acho que perdeu um pouco a relevancia, muita coisa mudou, pode ficar secundário.

 