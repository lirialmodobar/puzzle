## Status
- Ja foi rodado para o cromossomo 1 para toda a coorte, mas sem a divisao.
- Protótipo com adequação no github (ja com nome do script itself) para divisão de estados e adequação da questão de cromossomo no loop.

## Tarefas

- Ver como o que mudou em [[frag_info_per_anc_chr.sh]] pode ser traduzido aqui de modo a tambem existir opcao com e sem loop.
	- Nao existir opcao sem loop, mas ver se tem alguma dentro do loop que so executa os comandos se aquele cromossomo ja nao estiver na tabela. A condicional de se o chrs_file existe ja previne de rodar pra chrs q nao foram rodados ainda, e essa condicional nova faria com que nao repetisse o append do mesmo cromossomo, assim cada vez que rodar de novo so complementa o arquivo geral, pra nao ser um arquivo patetico de uma linha.
		- Tentei uma condicional no GPT, falta testar.
			- Não lembro mais se isso ta ai, acho que sim, checar.
	- Sera PAxSPxgeral, pelo menos por enquanto, porque ai garante todos os casos, e realmente como entre estados muda a posicao inicial e final, tem que dividir por estado e ter o geral.
		- Tem que ver o que altera no codigo e que complexidade adiciona.
		- Checar se realmente precisa ter o geral e se ele não é dedutivel a partir de rs e sp, mas acho que não.
- ~~Por nome de acordo com [[count.sh (aposentado)]]~~ 
- Checar se ta pronto pra teste, ja q fiz as subalteracoes, e ai testar.