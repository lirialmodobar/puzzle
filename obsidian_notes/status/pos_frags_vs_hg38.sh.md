## Status
- Ja foi rodado para o cromossomo 1 para toda a coorte, mas sem a divisao.

## Tarefas

- Ver como o que mudou em [[frag_info_per_anc_chr.sh]] pode ser traduzido aqui de modo a tambem existir opcao com e sem loop.
	- Nao existir opcao sem loop, mas ver se tem alguma dentro do loop que so executa os comandos se aquele cromossomo ja nao estiver na tabela. A condicional de se o chrs_file existe ja previne de rodar pra chrs q nao foram rodados ainda, e essa condicional nova faria com que nao repetisse o append do mesmo cromossomo, assim cada vez que rodar de novo so complementa o arquivo geral, pra nao ser um arquivo patetico de uma linha.
		- Tentei uma condicional no GPT, falta testar.
	- Sera PAxSPxgeral, pelo menos por enquanto, porque ai garante todos os casos, e realmente como entre estados muda a posicao inicial e final, tem que dividir por estado.
		- Tem que ver o que altera no codigo e que complexidade adiciona.
- ~~Por nome de acordo com [[count.sh]]~~ 
- Checar se ta pronto pra teste, ja q fiz as subalteracoes, e ai testar.