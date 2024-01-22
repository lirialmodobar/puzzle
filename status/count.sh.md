## Status

- Ainda nem rodado para o geral, so tem dado dos 109.
- Sempre tem a duvida de dividir ou nao esse script em contagem de gaps vs contagem de ocorrencias. 
- Nao esta otimizado em termos de colocacao de coisas no loop e n sei se o grafico do gap for necessario tbm.
- Rodando ate agr so contagem de ocorrencias, ainda precisa ver do join and sum pairwise e do gap.
- Versao com contagem de ocorrencias testada, testei so com rs_sp, mas e porque tinha o correspondente e o processo demora muito pra rodar. Esta no git.
- Versao com total de ocorrencias semi-testada: deu diff, mas parece ser problema de sort, nao consegui fazer bater o sort de como sai o meu e de como saiu anteriormente de jeito nenhum, so fui chegando perto, e onde vi, os nomes das variantes sao os mesmos, pos, chr e score tbm, entao considerei ok. Por teste com grep -Ff/-Fvf, realmente tudo que tem um tem em outro, entao a ordem deve ser diferente. Alias, pode sempre usar grep desse jeito pra testar se a ordem nao importar, so o conteudo.
- Rodando para eur, rs, pq nao queremos abusar do computador.
- Ideia: func com estado, label e chr de argumento

## Tarefas

- Existe uma anotacao antiga pra checar a logica da contagem de gaps, porque ela e parecida com a logica original da contagem de ocorrencias e na de ocorrencias tinha algum problema que fazia sair estranho, que eu nao lembro qual era e que parecia nao ocorrer para os gaps por uma questao do dado. Precisa dessa checagem pra cuidar da minha consciencia. 
- Aplicar logica de [[frag_info_per_anc_chr.sh]]  de modo a tambem existir opcao com e sem loop 
- Fazer divisao (PAxSPxgeral) no codigo. 
	- ~~Checar se os nomes modificados estao batendo (acho que foi)~~
	- ~~Rodar para teste,  com os 109 de rs que ja sairam com a divisao de diretorios desejada (109_17jan24, deletei o bim filtrado feito uma besta). Uma vez rodado, da pra comparar a saida com a saida do 109_preliminar_oct23, ja que nele so existia rs.~~
	- ~~join and sum pairwise precisa agr ser aplicado de modo diferente, incluindo pra estados, entao precisa dessa expansao/ajuste. (comentei por enquanto pra poder testar mais facil apos testar essa primeira parte)
		- ~~Teste: aplicar nos dados que ja tem do 109_preliminar e comparar com o output anterior.~~
		- Ver como o novo sorting do arquivo (que sei la qual e, vou deixar sair puro da funcao) precisa ser ajustado para [[plotgardener.Rmd]] e se ajusto aqui ou nele.
	- Checar se coloquei certinho o que tem que remover na parte do gap
- Nome alterado para` $ANC_DIR/$CHRS_FILT/$state_"$label_lower"_comp_hg38.txt`  precisa corrigir/concordar/alterar com/no [[pos_frags_vs_hg38.sh]].