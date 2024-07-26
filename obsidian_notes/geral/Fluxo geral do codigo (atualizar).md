
Importante: Todos os arquivos aqui mencionados (tirando o bim, que nao sei) sao separados por tab ou deveriam ser (checar)

## Input

A parte real do trabalho inicia a partir do output vindo do script collapse ancestry (python), entao considerarei ele nosso input inicial. Ele gera dois arquivos por pessoa (cada um representando um conjunto cromossomico completo, do 1 ao 22). Cada linha e referente aos dados de um fragmento.

### Output do collapse (nosso input)

![[Pasted image 20240108183610.png]]

### Exemplo de tabela individual

![[Pasted image 20240108183756.png]]

Coluna 1 = chr, coluna 2 = pos inicial, coluna 3 = pos final, coluna 4 = anc, coluna 5 = pos de outro jeito, coluna 6 = pos de outro jeito. 
Obs: Aqui tem todos os cromossomos, so que no caso eu rodei so pro 1 o collapse, entao aparece so do um. 

## [[frag_info_per_anc_chr.sh]]

### Objetivo

Organizar os dados obtidos do collapse de todas as pessoas (ou seja, todas as tabelas, de todas as pessoas) em tabelas para cada uma das 4 ancestralidades (africano, europeu, nativo-americano e desconhecido) e cada um dos cromossomos (1 ao 22), para cada estado (rs e sp_. O output e organizado em diretorios, um para cada estado, com um subdiretório para cada ancestralidade, contendo as tabelas individuais dos cromossomos 1 ao 22 sem as colunas anteriores de pos de outro jeito (colunas 5 e 6) + info adicional (explicado abaixo) contidas neles. 

### Info adicional

Com esses dados, nesse mesmo script tambem sao adicionadas infos extras em novas colunas, como o calculo do tamanho do fragmento e a verificacao de se ha ou nao gaps entre um fragmento e o anterior (0 ausencia de gap, 1 com gap, NA nao existe anterior), e tambem uma coluna com o ID da pessoa (primeira coluna).

### Obs

Sao gerados dois outputs, um filtrado e outro nao, por isso, dentro do dir de cada ancestralidade, tem o filt e o unfilt, cada um contendo suas respectivas tabelas individuais do 1 ao 22. O filtrado vem de gerar essas tabelas conforme o objetivo e o adicional, mas manter somente o maior fragmento dentre os que se iniciam na mesma posicao, e o nao filtrado vem de nao fazer isso. 

### Estrutura de diretorios (atualizar)

![[Pasted image 20240109104543.png]]

Tambem é gerado no diretório infos o arquivo com todas as ancestralidades juntas e não filtradas, para cada cromossomo (nao separado por estado). 

![[Pasted image 20240723115933.png]]
### Exemplo de tabela filtrada 

![[Pasted image 20240723115530.png]]

### Exemplo de tabela nao filtrada

![[Pasted image 20240723115637.png]]

Para ambas tabelas: Coluna 1 = id, coluna 2 = chr, coluna 3 = pos inicial, coluna 4 = pos final, coluna 5 = tamanho do fragmento, coluna 6 = verificar gap, coluna 7 = ancestralidade, coluna 8 = estado.
## [[chr_frag_plot.R]]

### Objetivo

Gerar um grafico com a imagem do cromossomo (ideograma) e os fragmentos obtidos para ele correspondendo posicionalmente ao cromossomo. 1 grafico por cromossomo, por ancestralidade. Utiliza o input filtrado, pois impossivel mesmo de representar todos os fragmentos.

### Obs 

Acompanha um arquivo renv.lock, pois utilizei o pacote renv para administrar dependencias de bibliotecas do projeto, salvando o estado delas. Alem disso, atualmente o script contem uma estruturacao para eu fazer um teste e ver qual o n ideal de fragmentos a ser plotados para cada ancestralidade.

### Exemplo (com 109 pessoas e sei la quantos fragmentos)

![[Pasted image 20240109105345.png]]

## [[pos_frags_vs_hg38.sh]]

### Objetivo

Verificar, em relacao ao genoma de referencia (hg38), se nossa posicao inicial e final para cada cromossomo bate com ele ou se existe um gap e qual seria o tamanho desse gap. Utiliza o input filtrado, pois com ele ja se tem a menor posicao inicial e a maior posicao final geral. Gera uma tabela unica por ancestralidade, ja com os dados de todos os cromossomos. Duas linhas por cromossomo, uma para verificar em relacao ao inicio e uma em relacao ao fim.

### Diretorio (terceiro arquivo de baixo para cima)

![[Pasted image 20240109110048.png]]

### Output

![[Pasted image 20240109110114.png]]

## [[filter_bim.sh]]

### Objetivo

Eliminar repeticoes de variantes no arquivo de genotipagem da coorte, que contem as variantes identificadas nela e dados posicionais delas.

 Utiliza o programa plink, um programa de linha de comando para manipular dados de genotipagem.

## [[collapse_haps]]

Substitui [[count.sh (aposentado)]]
### Objetivos

Contar as ocorrencias (numero de vezes que uma variante aparece, pois apesar de cada variante ser de uma posicao especificica, existe overlap entre os fragmentos, entao pode aparecer mais de uma vez) por ancestralidade, separado por estado. Além disso, calcular frequência alélica dessas variantes em cada estado-ancestralidade. 

### Obs

O input para as ocorrencias vem do output nao filtrado, pois precisamos do dado de overlap. O arquivo .haps, que contem as informacoes das variantes e genotipos delas para todas as coortes é usado como input para a contagem de ocorrencias e frequência alélica, pois pelo collapse ancestry a gente obtem apenas os fragmentos, nao as variantes que tem neles ou o genótipo das mesmas.  Infos sobre o arquivo .haps podem ser encontradas em: 

Para otimizacao e paralelizacao, esse script foi dividido em 2 etapas, representadas por outros 2 scripts:

### format_haps.sh

#### Objetivos

Filtrar o arquivo haps para apenas as criancas da bhrc, trocar as infos codificadas em 0 e 1 para letras, inserir infos de ID. Tudo isso para que seja possível obter as infos de seq e de freq alélica/contagem de ocorrências do script allele_freq.sh (para fazer o merge com o collapse processado por [[frag_info_per_anc_chr.sh]], precisa do id, pois o dado é de cada pessoa). 

#### Diretorio

Para o haps subsetado e com ids, mas ainda não com alelos e ids (pode ser util para outra pessoa nesse formato, por isso foi criado)

![[Pasted image 20240723121940.png]]

Para o haps com alelos e ids, no diretorio infos, é criado o arquivo haps_geno_header de cada cromossomo. 

![[Pasted image 20240723122217.png]]
#### Output

Haps subsetado (haps normal, mas so das criancas da bhrc)

![[Pasted image 20240723122419.png]]

Haps com info de id e alelo (parcial pq bem grande)


### allele_freq.sh (completar)

Objetivo: O descrito acima em [[collapse_haps]]. 

## [[occur_plot.Rmd - atualizar]]

### Objetivo

Gerar um grafico por cromossomo contendo o ideograma desse cromossomo e a representacao dos picos de ocorrencias para cada ancestralidade posicionalmente em relacao ao cromossomo. Usa como input a tabela resultante do count.sh de ocorrencias por ancestralidade e ocorrencias entre todas as ancestralidades (globais).

## Grafico 
Legado, com 109 pessoas

![[Pasted image 20240109111111.png]]