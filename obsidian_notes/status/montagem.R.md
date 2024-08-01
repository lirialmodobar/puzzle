### Status

### Tarefas

- Modificar condicional da recursividade: O que eu quero? 1) Quando um subset chega na ultima linha possivel dele, ele ja nao é mais contado (acho que isso eu cuidei em algum lugar? talvez naquele yrows == 0; parece que sim, mas parece que está repetindo a df2, sera q é pra não deletar? parece ser isso msm, pelo resto do codigo) 2) Quando todos os subsets chegaram na ultima linha possivel deles, acabou. Talvez colocar algo que detecte se todos os subsets tem yrows == 0? Pq ai se ainda tiver um, segue com ele, se nao, ja ta coberto por nao contar mais aquele subset. 
	- um vetor? tipo, se aquela condicao foi verdadeira, fica salvo no vetor como 1, ai quando todos sao 1, acabou?
		- checar se nao tem como todos serem 1 em algum momento e ainda nao ter acabado pq vai gerar um novo q n sera 1 por causa daquilo dos subsets que se ramificam ou coisa assim.
- ~~Recuperar o script mais avancado do hd externo.~~
- Condicional nova funciona, mas gero uma lista de 13 itens, e nao preciso dos que ja estao contidos... tem que ver se entra naquela questao de subsets redundantes, mas parece que na vdd tao ficando os y == 0... se nao for redundante, acho que remover o y == 0 talvez?