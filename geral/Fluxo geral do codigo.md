
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

Organizar os dados obtidos do collapse de todas as pessoas (ou seja, todas as tabelas, de todas as pessoas) em tabelas para cada uma das 4 ancestralidades (africano, europeu, nativo-americano e desconhecido) e cada um dos cromossomos (1 ao 22). O output e organizado em diretorios, um para cada ancestralidade, com as tabelas individuais dos cromossomos 1 ao 22 sem as colunas anteriores de pos de outro jeito (colunas 5 e 6) + info adicional contidas neles. 

### Info adicional

Com esses dados, nesse mesmo script tambem sao adicionadas infos extras em novas colunas, como o calculo do tamanho do fragmento e a verificacao de se ha ou nao gaps entre um fragmento e o anterior (0 ausencia de gap, 1 com gap, NA nao existe anterior), e tambem uma coluna com o ID da pessoa (primeira coluna).

### Obs

Sao gerados dois outputs, um filtrado e outro nao, por isso, dentro do dir de cada ancestralidade, tem o filt e o unfilt, cada um contendo suas respectivas tabelas individuais do 1 ao 22. O filtrado vem de gerar essas tabelas conforme o objetivo e o adicional, mas manter somente o maior fragmento dentre os que se iniciam na mesma posicao, e o nao filtrado vem de nao fazer isso. 

### Estrutura de diretorios (atualizar)

![[Pasted image 20240109104543.png]]

### Exemplo de tabela filtrada (atualizar)

![[Pasted image 20240109104824.png]]

### Exemplo de tabela nao filtrada (atualizar)

![[Pasted image 20240109104856.png]]

Para ambas tabelas: Coluna 1 = id, coluna 2 = chr, coluna 3 = pos inicial, coluna 4 = pos final, coluna 5 = tamanho do fragmento, coluna 6 = verificar gap, coluna 7 = ancestralidade.

## [[chr_frag_plot.R]]

### Objetivo

Gerar um grafico com a imagem do cromossomo (ideograma) e os fragmentos obtidos para ele correspondendo posicionalmente ao cromossomo. 1 grafico por cromossomo, por ancestralidade. Utiliza o input filtrado, pois impossivel mesmo de representar todos os fragmentos.

### Obs 

Acompanha um arquivo renv.lock, pois utilizei o pacote renv para administrar dependencias de bibliotecas do projeto, salvando o estado delas. Alem disso, atualmente o script contem uma estruturacao para eu fazer um teste e ver qual o n ideal de fragmentos a ser plotados para cada ancestralidade.

### Exemplo (com 109 pessoas e sei la quantos fragmentos)

![[Pasted image 20240109105345.png]]

## [[check_largest_region.sh]]

### Objetivo

Verificar, na ancestralidade desconhecida, qual o maior fragmento desconhecido dentre todos os cromossomos. Gera um txt no diretorio infos, contendo as infos do fragmento.
Obs: Usa o input filtrado, porque ele ja vem com os maiores fragmentos (ver acima).

### Diretorio (ultimo arquivo)

![[Pasted image 20240109105420.png]]

### Output

![[Pasted image 20240109105451.png]]

Se houver dois ou mais fragmentos de mesmo tamanho, eles aparecerao.

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

## [[count.sh]]

### Objetivos

Contar quantas variantes estao dentro de cada gap e contar as ocorrencias (numero de vezes que uma variante aparece, pois apesar de cada variante ser de uma posicao especificica, existe overlap entre os fragmentos, entao pode aparecer mais de uma vez) por ancestralidade e entre todas as ancestralidades.

### Obs

O input para as ocorrencias vem do output nao filtrado, pois precisamos do dado de overlap. Tambem e utilizado o arquivo bim como input para a contagem de ocorrencias, pois pelo collapse ancestry a gente obtem apenas os fragmentos, nao as variantes que tem neles. Para a contagem de variantes em gaps, o input vem do filtrado, pois ele ja representa os reais gaps, (no nao filtrado, havera gaps entre um fragmento e outro que nao sao verdadeiros, pois existe um fragmento maior que abrange, e o filtrado ja seleciona esse gap maior) e tambem do dado de posicao em relacao ao hg38, para incluir os gaps em relacao ao genoma de referencia.

### Diretorio

Pego do legado, com 109 pessoas, por isso nao aparece na estrutura de diretorios mais acima - ainda nao rodei

![[Pasted image 20240109110306.png]]

### Output

![[Pasted image 20240109110407.png]]
Coluna 1 = id da variante, coluna 2 = chr, coluna 3 = pos (unica, porque a variante e de troca de uma unica base), coluna 4 = contagem de ocorrencias.

## [[occur_plot.Rmd]]

### Objetivo

Gerar um grafico por cromossomo contendo o ideograma desse cromossomo e a representacao dos picos de ocorrencias para cada ancestralidade posicionalmente em relacao ao cromossomo. Usa como input a tabela resultante do count.sh de ocorrencias por ancestralidade e ocorrencias entre todas as ancestralidades (globais).

## Grafico 
Legado, com 109 pessoas

![[Pasted image 20240109111111.png]]