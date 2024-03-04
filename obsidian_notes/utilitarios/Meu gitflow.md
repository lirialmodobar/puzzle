### Inicio (checar)

1) Clonar repositorio puzzle:
	https://github.com/lirialmodobar/puzzle.git
2) Criar branch nova para o computador:
	git checkout -b puzzle_nome_pc
3) Colocar para branch local poder pegar atualizações da main:
   git branch --set-upstream-to=origin/puzzle_main puzzle_nome_pc
4) git config --local credential.helper store (de dentro do repo, o que deve estar a essa altura; esse comando fará com que a proxima vez que digitar as credenciais seja a ultima, depois ele preenche sozinho, pelo menos enquanto a credencial for aquela --- ver como faz quando muda o token por algum motivo; pode ser --global tbm, usei o local em servidores por mais segurança de nao bugar dos outros, principalmente no do sdumont, mas pelo que  vi se tem um usuario certinho no servidor, da pra ser global - M)
### Primeira vez alterando algo 

1) Git status: Ver se tem algo para adicionar ou fazer commit localmente e se tiver, fazer as operaçoes recomendadas de acordo com o meu discernimento
	- Se nunca mexeu em nada no git, pro commit vai precisar dessa config:
		git config user.email liriel.almodobar@gmail.com 
		git config user.name lirialmodobar
		obs: colocar --global depois do config se for só meu, que ai já vai isso pra todos os meus repos.
	- Em geral, a cada operação feita com um arquivo indicada pelo status e pelo meu bom-senso, fazer um commit especifico, pra ter uma descrição de cada coisa e nao um commit que abrange varias mudanças. No obsidian faço de uma vez pq sao so atualizações das anotações.
2) Git push origin HEAD: Sobe minhas atualizações para a branch remota que bate com a minha local, e não para a main. Gosto de dar um git push antes para ver ele me perguntando justo isso (aparentemente se fez como do 1 ao 3, ele nao da o aviso, pelo menos nao no SDumont, checar em outros)
3) No github, a main vai aparecer dizendo que tem atualizações de outra branch e se quer fazer pull request, colocar que sim e ir seguindo instruções para o merge, resolver conflitos caso haja.
4) Git fetch: Pegar mudanças que ocorreram na main depois desse merge
5) Git pull: Atualizar a branch local com as mudanças da main
### Proximas vezes

Bonitinho: Fetch --> pull --->  status ---> push origin HEAD ----> github merge ---> fetch ----> pull
Checar: se o fetch e  pull apos ter feito alterações nao sobrepoe o status, mas acho que nao
### Permissoes

usuario: lirialmodobar
senha: [[Token git]]


