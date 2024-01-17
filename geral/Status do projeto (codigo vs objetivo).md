
Obs: Em todos os casos, ta indo cromossomo por cromossomo, entao por agora so tem os dados do cromossomo 1 de base para tudo isso e o teste para gerar todos esses dados e cumprir os objetivos sera o cromossomo 1(logico que ja com a generalizacao para os outros poderem ter a mesma aplicacao).

## Objetivo geral​

### Reconstruir haplótipos nativo americanos 

#### Status

Creio que seja a proxima prioridade, ja que nao tem base nenhuma ainda. Ate agora, 3 alternativas foram abstraidas: 

1.  entender o que fizeram no artigo anterior e traduzir pra codigo (bem do zero, nao consegui o codigo dos caras e achei bem pouco confiavel, tambem nao entendi bem como traduzir para codigo); 
2.  usar software de alinhamento e tratar fragmentos como reads (soa legal porque alguem ja lidou com todos os problemas de como montar, mas n sei se temos em quantidade suficiente e outros problemas tecnicos, preciso estudar melhor a viabilidade) 
3.  usar o mesmo codigo do [[count.sh]] adaptado para ao inves de ocorrencias de variantes, ter ocorrencias de cada fragmento, e ai no caso de sobreposicao, usar o que tem a maior ocorrencia (geral, sp, pa?).  Se for fazer nao so um, mas varios genomas, acho q esse seria o caso de uso, e ai ir montando os com menores ocorrencias, etc, mas ai fica muito arbitrario, tem que ver.

De forma geral, para obter a sequencia, penso em usar os dados combinados de individuo e fragmento que temos do collapse ancestry e ai usar bim e fam para extrair quais sao as variantes que estao dentro desse fragmento. Importante: precisa ter alguma sinalizacao de gap, porque nem toda posicao individual sera continua. Precisa ver gaps dentro dos fragmentos e entre fragmentos e como lidar com isso e como isso sai representado. Para codigo, precisa ver como fazer essa busca e se algum codigo no count.sh de busca no bim pode ser adaptado, porque tem a questao do individuo per se. 

### e distinguir as frequências alélicas de São Paulo e Porto Alegre.​

#### Status

1. A contagem de ocorrencias por alguma logica matematica deve virar uma frequencia alelica, a gente precisaria dessa tabela separada por SP e PA, e ai ter a contagem de ocorrencias dividida pelo n (de fragmentos?). Precisa checar essa logica, mas a derivacao disso deve estar facil. 
2. Precisa ver se calcula entre todas as ancestralidades, por ancestralidade ou ambos. Precisa ver tambem como faz essa distincao, que teste estatistico fazer.

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