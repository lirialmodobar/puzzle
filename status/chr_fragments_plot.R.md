## Status

- Ainda nao rodado para geral, so para 109.
- Teste incluido no script farei mais quando tiver todos os dados. Nao foi testada essa parte do script ainda em termos de codigo, foi puramente abstracao, seria legal ver se funciona, inventar um conjunto de dados quaisquer pra ver como executa e se comporta como esperado. 
- Tambem pode ser necessario reavaliar a execucao desse teste, pois tem bastante trabalho manual envolvido de ver os graficos e determinar, e tbm pode exigir muito poder computacional a toa/para pouco ganho. Nao acho que va rodar no cerebro.
- Posso testar e gerar para o cromossomo 1. No entanto, ai so terei o numero otimo de fragmentos dele, enquanto a ideia geral era ver o numero otimo para todos os cromossomos de cada ancestralidade, entao no futuro o grafico pode mudar ligeiramente, e terei tido o trabalho do teste 2x, e tambem existe a questao de se gero esse grafico separado por PA e SP, ou PAxSPxgeral ou so geral. 
- Codei a parte para ter PAXSPXGeral, ta no git, falta testar.
 - Reestruturando para listas, localmente, ainda nao no git. No momento, estou indo calcular a media ponderada pra cada estado (rs e sp, sem geral) considerando a prop de cada anc em rel ao total de fragmentos. Ai vou descobrindo como isso vai se desdobrando no codigo.
## Tarefas

 - Nome: Mudar para frags ao inves de fragments.
 - Ver como o que mudou em [[frag_info_per_anc_chr.sh]] pode ser traduzido aqui de modo a tambem existir opcao com e sem loop
	- O dado vai acabar sendo gerado cromossomo por cromossomo por causa do jeito que to rodando o collapse, entao nao adianta esperar ter todos eles para entao fazer o teste. Isso pode ficar como uma versao para quem for gerar todos de uma vez, a ultima versao de 2023 (porque nela o loop era obrigatorio pro fim de ver o numero otimo para todos os cromossomos de cada anc), mas com a divisao de estados implementada na primeira versao de 2024.
	- Como desenhar o teste cromossomo por cromossomo sem ser uma quantidade absurda de dado? 
		- Inverter a logica e ver labels:
			- Tirar uma media de n de linhas de todos os labels para aquele cromossomo
				-  Testar para todos os labels com media, media - valor proporcional a tamanho da media (2sd?), media + valor proporcional a tamanho da media (2sd?) e ai ver para cada label qual dessas 3 ops ficou melhor naquele label.  
				- 4 labels, 3 ops de teste pra cada label.
		- Ok, mas e estado? 
					-  Rs_sp (media nat, unk, afr e eur), sp (media nat, unk, afr e eur), rs (media nat, unk. afr e eur).  nao calcula media rs_sp pq rs_sp resulta dos dados de rs e sp juntos e ai fica mt grande o n de fragmentos, calcula media entre as medias de rs e sp. Com essa media, faz os testes citados.
						- vale a pena ponderar por prop de anc brasileira? somaria tds os frags de cada anc ponderados pela prop e obteria a media e ai faria a media de rs e sp so e ai esse numero seria o numero de linhas pra tudo.... como ja ta com a prop implementada, deve sair considerativo.
							- proporcao de cada anc em relacao ao total de fragmentos (n frag anc/n frag total)
								- e ai pondera o n de fragmentos de cada anc pra ter o valor (anc1*prop+anc2*prop etc), ai tem a media ponderada pra cada estado (bem logico e representativo). 
									- Com isso, faz media entre os dois estados (mais fraco, a contribuicao deles pra amostra talvez seja diferente - pode ver a prop de fragmentos europeus que sao de rs, q sao de sp, e ai ponderar por isso na hr de fazer essa ultima media).
							- Total de fragmentos europeus obtidos, por ex, seria o n de linhas/fragmentos do chr_1_eur_rs_sp.  