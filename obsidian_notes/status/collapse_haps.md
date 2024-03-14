### Status

- Parte do processar haps feita no sem_nome.sh, so precisa ver como colocar os A e B e fazer o sort de posicao, e ta sem nomes ou dirs bonitinhos (5_columns por ex tem que ir em infos, é que nao tem o infos nesse pc). Script chama sem_nome.sh e ja ta no github por garantia.
- Folha fisica na bolsa do lab com o desenho de onde tirei a ideia do rascunho, pode ser consultada pra caso eu tenha pulado algo.
- O arquivo ja sai no sort certinho, sl pq. 
### Tarefas

- Objetivo aqui: obter a freq alelica para cada anc da variante tal, e ter base para fazer a montagem. 
- Ver se os arquivos haps que peguei não são só de poucas pessoas, que nem parece pelo nome e se tem algum lugar com os haps de todos. Mas esses 107 ou 127 deve dar pra prototipar, acho.
- Ver se ser de altura influencia em algo. 
	- Acho que pode ir rascunhando um merge independente disso, porque deve mudar mais o significado dos dados do que eles em si.
- Rascunho:
	- Processar haps
		- .haps vai ter os haplotipos, com 2 colunas por individuo, precisa ver se os individuos do .sample as linhas correspondem à ordem das colunas, e tbm quem seria _A e _B
		- identificar as colunas do .haps: cut na coluna do sample, sed /n por /t pra ficar horizontal, adicionar headers iniciais, dar um cat. Resolver: precisa que seja _A e _B.
		- deixar o 1 já como o alelo que é, e o 0 já como o alelo que é
		- transpor para que no fim tenha: ind, chr, pos, var, alelo, certificar que esta organizado por posicao da menor para a maior. esse arquivo provavelmente será mantido, para ser nosso arquivo de info de sequencia (talvez na hora a gente remova só o individuo). 
A partir daqui talvez divida em outro script ou encaixe em [[count.sh]]
	- Juntar haps com aquele output que vem por chr e anc (collapse_haps_extra_info)
		- Vai precisar juntar as infos por intervalos, aquela mesma busca de intervalos do [[count.sh]], tem um rascunho no gpt e no kaggle da primeira func que faz isso
		- Deve gerar o output: ind chr pos_in pos_fin var,pos,geno var,pos, alelo outras_infos anc (checar se n to esquecendo nenhuma das infos dos dois no script ja rascunhado, e se realmente me interessa o outras_infos nesse momento, ja que inclusive vou deletar... acho que nao interessa), que provavelmente vai ser deletado pq tem o de seq mais acima e o de contagem mais abaixo
Ou daqui
	- Contar as combinacoes de var,pos, geno que aparecem (chave especifica var,pos, geno tem que ser contada, nao importa em que coluna esteja), gerando um output var  pos alelo cont. Tbm pode ser meio adaptado de [[count.sh]]
		- que deve ser processado para gerar uma tabela com var pos geno cont cont tot (soma dos cont daquela var) freq (cont daquela linha / cont total).
		- quando tiver essa tabela, ela talvez substitua a original do [[count.sh]], ao processar ela no R cortando geno, cont, fq, rm linha repetida ja pra aquele script. Teste possivel: cortar essas em bash msm e ai ver se tem dif com a original do [[count.sh]] usando grep (pq o sort n vai importar). Se sim, já adaptar o [[count.sh]] pra isso, e ai realmente vale a pena ter um script rapido de processar haps e juntar por intervalos, que seria esse do collapse_haps, e ai um que faz a contagem, que seria a adaptação do count, ou um corte de primeira apos processar o haps e o resto tudo em count. Tem tbm a parte do count que soma todo mundo, entao um processamento no proprio bash talvez fosse util pra ela, nem q seja com pipe ou so selecao de colunas e nao registrando o arquivo. 
- Ver no que implica nos outros scripts
