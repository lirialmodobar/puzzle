## Status

- Ja foi rodado para o cromossomo 1 de todos os individuos da coorte, mas sem a divisao PA vs SP. Esta testado e funcionando como esperado nessa versao que foi rodada e esta no cerebro.
%%
Collapse esta rodando cromossomo por cromossomo, sera que ainda vale manter a estrutura de loops de cromossomos considerando isso? Impactaria os outros scripts (count, futuros planos do plotgardener, pos_frags_vs_hg38, chr_fragments_plot.R).
%%
- Como collapse esta rodando cromossomo por cromossomo, coloquei o loop opcional com uma flag. Isso impacta nos scripts [[pos_frags_vs_hg38.sh]], [[chr_frag_plot.R]],[[count.sh]] e [[occur_all_ancs_states.Rmd e occur_anc_state.Rmd]] e gera uma nova versao do script, que esta no github e localmente e foi testada.
- Dividi SP e PA, script ja no github e testado, com ressalva de que nao teve como testar o dado separado pra sp ja que o meu dataset so tinha rs por enquanto. O modo que foi feita essa divisao pode impactar [[pos_frags_vs_hg38.sh]], [[chr_frag_plot.R]], [[count.sh]] e [[occur_all_ancs_states.Rmd e occur_anc_state.Rmd]] em quando for fazer essa divisao neles.
- IDs que nao serao utilizados foram removidos
- Nova versao sem os ids rodada separado para SP e PA com leves alteracoes e com todos os individuos, cromossomo 1. Testado e no github versao estavel. 
	- Obs para o futuro: Enquanto tiver so dado do chr 1, se for rodar sem a flag sp vai continuar bonitinho so com chr1, porque com certeza pra sp eu gerei so o cromossomo 1 mesmo, ja q os ids vem por ultimo e nesses lotes eu ja tava gerando separado, ja rs e rs_sp terao mistura.
- No diretorio local /home/yuri/liri/puzzle/comp tem-se registros de dados de comparacoes feitas entre versoes dos scripts, compostas por um conjunto diretorio (versao anterior) e subdiretorio (versao que esta sendo comparada), existindo dois conjuntos: 109_preliminar_oct23 e 109_sp_oct23.

## Tarefas

- ~~Testar se o output realmente esta se comportando como devia apos alteracao no codigo com a flag~~
	- ~~Ver se realmente precisa testar, porque sei la, sem alteracao no codigo~~
	- ~~Se precisar, vai ter que pegar dados legado do cerebro, baixar (precisa das ids especificas) e comparar pra ver se da na mesma. Vou fazer isso, acho mais assertivo.~~
- ~~Criar codigo para gerar output PA, SP, geral
		- Obter dados de ID e Estado: Tudo que inicia com 1 e RS e com 2 e SP.~~
- Entender e ~~remover IDs~~ que nao serao utilizados por dado faltante de LAI ou de bim. Ja resolve [[filter_bim.sh]].
	- ~~C20361, C20776 (lai, mas nao fam), C21218 (fam, mas nao lai). Vou remover os dois primeiros no inicio do script, e o [[filter_bim.sh]] com o keep vai manter so quem se sobrepoe, entao o terceiro ja ta ok.~~
		- ~~Adicionar pipe com grep -v~~ 
-~~Rodar de novo desde novo output do collapse pra gerar tudo certinho~~. 
-~~Ver se o output quando separado sai certinho tbm, logica seria que se sai certinho o inteiro,  deve sair o separado certinho tambem, ja q o sort e o msm codigo e ta sendo aplicado separadamente, mas preciso/quero checar esse raciocionio~~
- ~~Entender o codigo da flag.~~ 
- %%
	- OBS: Entendido superficialmente.Tem estudo no gpt, posso aprofundar quando der, mas acho que entendi bem. Titulo do chat no gpt: Shell script argument handling.
	%%
-  Ver se os move move do output collapse nao fizeram nada ficar fora do lugar.
- Ver se [[count.sh]] e a decisao de remover rs_sp tem alguma aplicaçao aqui.