### Status

- Parte do processar haps feita no sem_nome.sh, so precisa ver como colocar os A e B e fazer o sort de posicao, e ta sem nomes ou dirs bonitinhos (5_columns por ex tem que ir em infos, é que nao tem o infos nesse pc). Script chama sem_nome.sh e ja ta no github por garantia.
- Folha fisica na bolsa do lab com o desenho de onde tirei a ideia do rascunho, pode ser consultada pra caso eu tenha pulado algo.
- O arquivo ja sai no sort certinho, sl pq, e ja ta com os A e B.
- Fiz por intervalo e gerei o output desejado, mas agora precisa ver se tudo realmente bate, em resumo, falta testar toda essa parte.
- Cheguei até frequencias alélicas, falta testar toda essa parte e por os loops e dirs.
### Tarefas

- Objetivo aqui: obter a freq alelica para cada anc da variante tal, e ter base para fazer a montagem. 
- Ver se os arquivos haps que peguei não são só de poucas pessoas, que nem parece pelo nome e se tem algum lugar com os haps de todos. Mas esses 107 ou 127 deve dar pra prototipar, acho. Ver onde tá o de todo mundo.
- Ver se ser de altura influencia em algo. 
	- Acho que pode ir rascunhando um merge independente disso, porque deve mudar mais o significado dos dados do que eles em si.
- Rascunho:
	- Processar haps
		- ~~.haps vai ter os haplotipos, com 2 colunas por individuo, precisa ver se os individuos do .sample as linhas correspondem à ordem das colunas~~, e tbm quem seria _A e _B
		- ~~identificar as colunas do .haps: cut na coluna do sample, sed /n por /t pra ficar horizontal, adicionar headers iniciais, dar um cat. Resolver: precisa que seja _A e _B.~~
		- ~~deixar o 1 já como o alelo que é, e o 0 já como o alelo que é~~
		- ~~transpor para que no fim tenha: ind, chr, pos, var, alelo, certificar que esta organizado por posicao da menor para a maior. esse arquivo provavelmente será mantido, para ser nosso arquivo de info de sequencia (talvez na hora a gente remova só o individuo). ~~
	- ~~Juntar haps com aquele output que vem por chr e anc (collapse_haps_extra_info)~~
		- ~~Vai precisar juntar as infos por intervalos, aquela mesma busca de intervalos do [[count.sh]], tem um rascunho no gpt e no kaggle da primeira func que faz isso, mas precisa adequar pra chave individuo~~.
		- ~~Deve gerar o output: ind chr pos_in pos_fin var,pos,geno var,pos, alelo outras_infos anc (checar se n to esquecendo nenhuma das infos dos dois no script ja rascunhado, e se realmente me interessa o outras_infos nesse momento, ja que inclusive vou deletar... acho que nao interessa), que provavelmente vai ser deletado pq tem o de seq mais acima e o de contagem mais abaixo~~
			- ~~Decidi que outras_infos n são pertinentes~~.
	- ~~Contar as combinacoes de var,pos, geno que aparecem (chave especifica var,pos, geno tem que ser contada, nao importa em que coluna esteja), gerando um output var  pos alelo cont. Tbm pode ser meio adaptado de [[count.sh]]~~
		- ~~que deve ser processado para gerar uma tabela com var pos geno cont cont tot (soma dos cont daquela var) freq (cont daquela linha / cont total)~~.
		- quando tiver essa tabela, ela talvez substitua a original do [[count.sh]], ao processar ela no R cortando geno, cont, fq, rm linha repetida ja pra aquele script. Teste possivel: cortar essas em bash msm e ai ver se tem dif com a original do [[count.sh]] usando grep (pq o sort n vai importar). Se sim, já vai matar o [[count.sh]], ele vai ficar só pra soma se precisar, e pros gaps. 
		- Tem tbm a parte do count que soma todo mundo, entao um processamento no proprio bash talvez fosse util pra ela, nem q seja com pipe ou so selecao de colunas e nao registrando o arquivo.
			- bash separado, só pra isso, com pipe e juntando com a funcao join_rec
				- prototipo: awk '{if (NR/2 == 1) {print $1, $2, $3, $4}}' count_chr_1_bla.txt (precisa so ver qual é a regra certa dessa divisao)
- Adequar tudo para loop e dirs
- Ver no que implica nos outros scripts
