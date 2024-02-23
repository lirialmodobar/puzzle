## Status 

- Rodado para 109 pessoas, perdi o codigo.
- Refiz o codigo e rodei novamente pras 109 pessoas. Teve uma diferenca no eixo x que arredondou algo que na versao anterior nao arredondou, mas acho q a diferenca vem so disso e meio que ta tudo bem. Esta no github com os ajustes.

## Tarefas

- ~~Recuperar ou refazer o codigo ajustado e que tinha dado certo~~
- ~~Colocar no github~~
- ~~Alterar nome para um mais adequado, talvez occur_plot.Rmd~~.
- Problema: Precisa ver se o ideograma realmente corresponde posicionalmente, porque num vi no codigo algo que garanta isso e eu tenha entendido e se tem algo que eu mudei que alteraria essa correspondencia, tem que falar com a Jess.
	- Jess disse que sim, e pra checar na documentação tbm, vou ler com calma
- Ver como o que mudou em [[frag_info_per_anc_chr.sh]] pode ser traduzido aqui de modo a tambem existir opcao com e sem loop 
	-  Loop ancestralidade (checar, pq o input ja vem o das 4 ancs, acho que capaz de ser so estado) e estado, mas cromossomo per se vai ser flag. Consultar como faz frag e esses loops em [[chr_fragments_plot]]
- Ver como interfaceia Rmd e terminal.  
- Dividir PA, SP, geral
	- Vale a pena dividir geral ainda?
- Precisa ver se tem como automatizar o ajuste desses parametros, sem precisar tanto usar o meu olho e ajustar manualmente. Se descobrir, pode ser util para [[chr_fragments_plot]]. 
	- Nao deve mudar muito do 1 pros outros os parametros, entao quando rodar do 1 pra todos, otimo, e ai a automatizacao vai pras melhorias de codigo.
- Tirar repeticoes eternas do processamento de cada tabela e por como uma func, que pegue como argumento a tabela a ser processada e o nome da variavel.
- Tirar repeticoes eternas do plot e colocar de algum modo como uma func que so pegue a variavel e aplique (meio que ja é uma func, entao nao sei bem o que fazer, acho que e o caso de tipo a func ja ter os parametros se for td igual e ai so substituir a var como arg da outra)
- Ver como nao precisar colocar a posicao final do chr manualmente toda vez (algo no output de [[pos_frags_vs_hg38.sh]] pode ajudar ou talvez se nao der ele ja preencha)
- Colocar renv
- Colocar datas