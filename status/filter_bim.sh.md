## Status

- Feito e nao muda independente de PAxSP, porque o bim ja ta pra toda a coorte.  

### Problema

O LAI da BHRC (que da origem ao output do collapse) tem 2191 individuos, mas o fam (arquivo complementar ao bim, mas que contem as infos dos individuos, ID deles e essas coisas, trabalhado em conjunto com o bim no plink) BHRC_Probands.fam tem apenas 2189, e mais estranho ainda como esse numero esta composto:Tem dois individuos que nao tem no fam, mas tem no LAI (C20361, C20776) . Tem um individuo que tem no fam, mas nao tem no LAI (C21218). Marquinhos disse pra so seguir adiante e usar esses 2189. 

#### Hipotese 

Cássia Maués:  Eu acho que sei.  Tem dois indivíduos, no meu dado, que tavam sem informação de estado. Quando eu tava fazendo o inner_join, portanto, essas amostras saíam pq não estavam presentes em todas as tabelas unidas. O Lucas me deu uma informação que deu pra deduzir qual era o estado dessas amostras.E então eu adicionai a info manualmente. Ao menos isso era o motivo do pq as minhas amostras tavam com 2189.

 - Marquinhos disse pra so seguir adiante e usar esses 2189. Gostaria de entender melhor e tambem ver em que momento entao seria util remover os que nao serao utilizados, que seriam esses 3 e na verdade fica 2188. Queria tambem entender melhor que tipos de QC esse bim passou e se ta adequado usar. 

## Planejamento
