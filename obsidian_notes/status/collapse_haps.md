### Status

- Parte do processar haps feita no sem_nome.sh, so precisa ver como colocar os A e B e fazer o sort de posicao, e ta sem nomes ou dirs bonitinhos (5_columns por ex tem que ir em infos, é que nao tem o infos nesse pc). Script chama sem_nome.sh e ja ta no github por garantia.
- Folha fisica na bolsa do lab com o desenho de onde tirei a ideia do rascunho, pode ser consultada pra caso eu tenha pulado algo.
- O arquivo ja sai no sort certinho, sl pq, e ja ta com os A e B.
- Processar haps testado
	- A troca de 1 e 0 pelos alelos bate, faltando apenas checar se eu acertei quem era pra ser 0 e quem era pra ser 1 (posso ter invertido e acho que inverti, porque o alelo raro tá aparecendo demais)
	- Transposição tbm bate (embora eu n tenha testado tão bem, acho que testei o suficiente)
- Cheguei até frequencias alélicas (github: allele_freq.sh -- alterar o nome aqui), falta testar toda essa parte e por os loops e dirs. O teste dessa parte, bem como dos intervalos, deve provavelmente ser o de comparar com o output do count, porque se a contagem bater, da pra considerar que o resto ta certo.
	- Teste feito e bem-sucedido!
	- Problema: quase não tem equivalência de variantes no .haps e no bim (as que tem estão em vars_comuns.txt no diretório puzzle do dell marquinhos). Resposta: diferentes versões do genoma, bim errado, to checando se o bim é certo agora
- O haps é separado por espaço, precisa ver se isso n tá influenciando em nada no meu script.
- Refatorado pra n precisar transpor. Encontrado erro na versão 1 que na hora do alelo ele pegava a partir da coluna 5 ao refatorar, versão refatorada não tem esse erro e está atualmente rodando no sdumont, mas ainda é bom checar coisa por coisa pra ver se ta igual nos resultados dos 127 no dell marquinhos.
### Tarefas

- Objetivo aqui: obter a freq alelica para cada anc da variante tal, e ter base para fazer a montagem. 
-  ~~awk '$3 >= 792461 && $3 <= 905373 {print  $2 "," $3 "," $6 "\t"}' haps_geno_header.txt. Isso aqui já me dá as infos que eu quero do haps, no formato q eu quero. Ai tem que só substituir o indice do id, e eu tenho funções q fazem isso na parte de transposição, assim como q coletam o indice, entao eu podia mudar pra so isso:~~
- ~~while read -r id chrom initial_pos final_pos _ _ _ _; do
		#### Search for matching positions in bim file
		index=$(awk -v val="$id" '{ for (i=1; i<=NF; i++) if ($i == val) { print i; exit } }' "$file")
		vars=$(awk -v OFS="\t" -v index_id="$index_id" -v ip="$initial_pos" -v fp="$final_pos" '$3> ip && $3 < fp { print $2 "," $3 "," $index_id}' "$var_file" | tr "\n" "\t")
		if [ -n "$vars" ]; then #testing only
			echo -e "$id\t$chrom\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
		fi
	done < "$pos_file"~~
- ~~Ver se os arquivos haps que peguei não são só de poucas pessoas, que nem parece pelo nome e se tem algum lugar com os haps de todos. Mas esses 107 ou 127 deve dar pra prototipar, acho. Ver onde tá o de todo mundo.~~
- ~~Ver se ser de altura influencia em algo. ~~
	- ~~Acho que pode ir rascunhando um merge independente disso, porque deve mudar mais o significado dos dados do que eles em si.~~
- Rascunho:
	- Processar haps
		- ~~.haps vai ter os haplotipos, com 2 colunas por individuo, precisa ver se os individuos do .sample as linhas correspondem à ordem das colunas~~, e tbm quem seria _A e _B
		- ~~identificar as colunas do .haps: cut na coluna do sample, sed /n por /t pra ficar horizontal, adicionar headers iniciais, dar um cat. Resolver: precisa que seja _A e _B.~~
		- ~~deixar o 1 já como o alelo que é, e o 0 já como o alelo que é~~
		- ~~transpor para que no fim tenha: ind, chr, pos, var, alelo, certificar que esta organizado por posicao da menor para a maior. esse arquivo provavelmente será mantido, para ser nosso arquivo de info de sequencia (talvez na hora a gente remova só o individuo). ~~
	- ~~Juntar haps com aquele output que vem por chr e anc (collapse_haps_extra_info)~~
		- ~~Vai precisar juntar as infos por intervalos, aquela mesma busca de intervalos do [[count.sh (aposentado)]], tem um rascunho no gpt e no kaggle da primeira func que faz isso, mas precisa adequar pra chave individuo~~.
		- ~~Deve gerar o output: ind chr pos_in pos_fin var,pos,geno var,pos, alelo outras_infos anc (checar se n to esquecendo nenhuma das infos dos dois no script ja rascunhado, e se realmente me interessa o outras_infos nesse momento, ja que inclusive vou deletar... acho que nao interessa), que provavelmente vai ser deletado pq tem o de seq mais acima e o de contagem mais abaixo~~
			- ~~Decidi que outras_infos n são pertinentes~~.
	- ~~Contar as combinacoes de var,pos, geno que aparecem (chave especifica var,pos, geno tem que ser contada, nao importa em que coluna esteja), gerando um output var  pos alelo cont. Tbm pode ser meio adaptado de [[count.sh (aposentado)]]~~
		- ~~que deve ser processado para gerar uma tabela com var pos geno cont cont tot (soma dos cont daquela var) freq (cont daquela linha / cont total)~~.
		- quando tiver essa tabela, ela talvez substitua a original do [[count.sh (aposentado)]], ao processar ela no R cortando geno, cont, fq, rm linha repetida ja pra aquele script. Teste possivel: cortar essas em bash msm e ai ver se tem dif com a original do [[count.sh (aposentado)]] usando grep (pq o sort n vai importar). Se sim, já vai matar o [[count.sh (aposentado)]], ele vai ficar só pra soma se precisar, e pros gaps. 
		- Tem tbm a parte do count que soma todo mundo, entao um processamento no proprio bash talvez fosse util pra ela, nem q seja com pipe ou so selecao de colunas e nao registrando o arquivo.
			- bash separado, só pra isso, com pipe e juntando com a funcao join_rec
				- prototipo: awk '{if (NR/2 == 1) {print $1, $2, $3, $4}}' count_chr_1_bla.txt (precisa so ver qual é a regra certa dessa divisao)
- ~~Adequar tudo para loop e dirs~~
- Ver no que implica nos outros scripts
- Separar o script em 2 e adequar para paralelizar.
