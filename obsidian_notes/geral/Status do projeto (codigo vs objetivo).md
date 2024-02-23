
Obs: Em todos os casos, ta indo cromossomo por cromossomo, entao por agora so tem os dados do cromossomo 1 de base para tudo isso e o teste para gerar todos esses dados e cumprir os objetivos sera o cromossomo 1(logico que ja com a generalizacao para os outros poderem ter a mesma aplicacao).

## Objetivo geral​ (papel)

### Reconstruir haplótipos nativo americanos 

#### Status

Creio que seja a proxima prioridade, ja que nao tem base nenhuma ainda. Ate agora, 3 alternativas foram abstraidas: 

1.  entender o que fizeram no artigo anterior e traduzir pra codigo (bem do zero, nao consegui o codigo dos caras e achei bem pouco confiavel, tambem nao entendi bem como traduzir para codigo); 
2.  usar software de alinhamento e tratar fragmentos como reads (soa legal porque alguem ja lidou com todos os problemas de como montar, mas n sei se temos em quantidade suficiente e outros problemas tecnicos, preciso estudar melhor a viabilidade) 
3.  usar o mesmo codigo do [[count.sh]] adaptado para ao inves de ocorrencias de variantes, ter ocorrencias de cada fragmento, e ai no caso de sobreposicao, usar o que tem a maior ocorrencia (geral, sp, pa?).  Se for fazer nao so um, mas varios genomas, acho q esse seria o caso de uso, e ai ir montando os com menores ocorrencias, etc, mas ai fica muito arbitrario, tem que ver.

De forma geral, para obter a sequencia, penso em usar os dados combinados de individuo e fragmento que temos do collapse ancestry e ai usar bim e fam para extrair quais sao as variantes que estao dentro desse fragmento. Importante: precisa ter alguma sinalizacao de gap, porque nem toda posicao individual sera continua. Precisa ver gaps dentro dos fragmentos e entre fragmentos e como lidar com isso e como isso sai representado. Para codigo, precisa ver como fazer essa busca e se algum codigo no count.sh de busca no bim pode ser adaptado, porque tem a questao do individuo per se. 

### e distinguir as frequências alélicas de São Paulo e Porto Alegre.​

#### Status

1. A contagem de ocorrencias por alguma logica matematica deve virar uma frequencia alelica.
	1. Existe um arquivo em que dá pra pegar a informação do alelo, a qual precisamos para fazer a frequência. Precisa obter essa info por indivíduo e por variante para podermos fazer essa conta. Precisa ver como fazer esse merge e como isso pode se relacionar com arquivos intermediários rodados em [[count.sh]].
2. Precisa ver como faz essa distincao, que teste estatistico fazer.
## Objetivo geral (reunião com Marquinhos 24/01/24)

- Objetivo final do projeto: Montar genomas com crianças do INPD e ver se com esses genomas como referência conseguimos distinguir o que é NAT do RS e o que é NAT de SP ao aplicar LAI com eles. 
	- Teste primeiro, para ver se é possível o LAI diferenciar coisas tão próximas: Rodar um LAI com ref do HGDP, dividir em norte e sul da américa (atentar para o n não ficar bizarramente pequeno de um lado, 30 de cada lado idealmente pelo menos), alvo do lai colombianos do 1000 genomes e os mexicanos. Ver se os colombianos são mais identificados como sul e mexicanos como norte.
## Objetivos específicos​

### Aplicar LAI para obter os fragmentos de cada ancestralidade 

#### Status

Feito, por isso partimos do collapse ancestry.

### Reconstruir genomas europeus e africanos

#### Status

Mesma coisa do do objetivo geral.

### e compará-los com a referência do 1000 genomes para ver para qual subregião desses continentes cada cidade está enriquecida.

#### Status

Precisa ver que metodo usara para essa comparacao. F-statistics parece ser o apropriado, preciso ler mais artigos com ela e entender mais a fundo.