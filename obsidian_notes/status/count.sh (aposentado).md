## Status

- Dados dos 109 sem divisao de estado e para o cromossomo 1 foram rodados, resultado em 109_preliminar_oct23.
- Sempre tem a duvida de dividir ou nao esse script em contagem de gaps vs contagem de ocorrencias. 
- Nao esta otimizado em termos de colocacao de coisas no loop e n sei se o grafico do gap for necessario tbm.
- Rodando ate agr so contagem de ocorrencias, ainda precisa ver do join and sum pairwise e do gap.
- Versao com contagem de ocorrencias testada, testei so com rs_sp, mas e porque tinha o correspondente e o processo demora muito pra rodar. Esta no git.
- Versao com total de ocorrencias semi-testada: deu diff, mas parece ser problema de sort, nao consegui fazer bater o sort de como sai o meu e de como saiu anteriormente de jeito nenhum, so fui chegando perto, e onde vi, os nomes das variantes sao os mesmos, pos, chr e score tbm, entao considerei ok. Por teste com grep -Ff/-Fvf, realmente tudo que tem um tem em outro, entao a ordem deve ser diferente. Alias, pode sempre usar grep desse jeito pra testar se a ordem nao importar, so o conteudo. Está no git.
- Nao havera mais a opcao rs_sp, pois gasta mt poder computacional e gera um dado redundante, que caso eu precise, posso gerar utilizando minha func de join para cada anc dos dois estados e tbm se for o total, o join do total dos dois estados. Em [[frag_info_per_anc_chr.sh]] faz sentido porque muda quais sao os gaps e quais sao os fragmentos e tudo mais, mas uma hora seria legal olhar nele se todas as etapas precisam ser assim ou se eu otimizo alguma, mas acho que ta ok.
- Prot_count.sh a ser testado e subido no git, com tudo de forma funcional e usando argumentos no terminal. Deve ser testado após testar o funcional do join_rec. Gap_info deve ser testado após testar o count normal, q ja valida boa parte da alteração funcional e o teste é menor e depende do teste de [[pos_frags_vs_hg38.sh]].
- Versao nao prototipo rodada para nat, chr 1, rs e sp, deletei o resto dos counts porque nao lembrava onde tava, tem que rodar no SDumont

## Tarefas

- Existe uma anotacao antiga pra checar a logica da contagem de gaps, porque ela e parecida com a logica original da contagem de ocorrencias e na de ocorrencias tinha algum problema que fazia sair estranho, que eu nao lembro qual era e que parecia nao ocorrer para os gaps por uma questao do dado. Precisa dessa checagem pra cuidar da minha consciencia. 
- Aplicar logica de [[frag_info_per_anc_chr.sh]]  de modo a tambem existir opcao com e sem loop 
	- Ideia de transformar em uma func que o yuri deu, ai eu posso colocar chr, label, state como argumentos dessa func, envelopar aquele codigo todo nela, e ai da pra chamar com ou sem o loop, mas ja dentro dessa logica. Seria uma flag tbm, mas uma mais objetiva e legivel e que receberia os argumentos dessa func qdo especificado, e se nao, rodaria o loop que proveria args pra essa func ele mesmo.
		- Transformei em uma func com args de terminal, precisa testar, se der certo, atendeu ambas as coisas acima.
- Fazer divisao (PAxSP) no codigo. 
	- ~~Checar se os nomes modificados estao batendo (acho que foi)~~
	- ~~Rodar para teste,  com os 109 de rs que ja sairam com a divisao de diretorios desejada (109_17jan24, deletei o bim filtrado feito uma besta). Uma vez rodado, da pra comparar a saida com a saida do 109_preliminar_oct23, ja que nele so existia rs.~~
	- ~~join and sum pairwise precisa agr ser aplicado de modo diferente, incluindo pra estados, entao precisa dessa expansao/ajuste. (comentei por enquanto pra poder testar mais facil apos testar essa primeira parte)~~
		- ~~Teste: aplicar nos dados que ja tem do 109_preliminar e comparar com o output anterior.~~
		~~- Ver como o novo sorting do arquivo (que sei la qual e, vou deixar sair puro da funcao) precisa ser ajustado para [[occur_all_ancs_states.Rmd e occur_anc_state.Rmd]] e se ajusto aqui ou nele.~~
			~~-Ajustei nele, ta tudo bem~~
	- Checar se coloquei certinho o que tem que remover na parte do gap
- ~~Nome alterado para` $ANC_DIR/$CHRS_FILT/$state_"$label_lower"_comp_hg38.txt`  precisa corrigir/concordar/alterar com/no [[pos_frags_vs_hg38.sh]].~~