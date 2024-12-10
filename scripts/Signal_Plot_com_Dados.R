library(signal)

detect_ZeroCrossing <- function(signal, movwin_length, z){
# detect_ZeroCrossing detecta os pontos de um sinal onde houve cruzamento por 
# zero. Ao passar a diferença de dois sinais como sinal, serve como detecção de
# de cruzamento.
# Input
#   signal: vetor com o sinal a ser processado
#   movwin_length: tamanho da janela a ser usada para a média móvel de suavização.
#   z: estatística Z relativa ao nível de confiança desejado. Por exemplo,
#      z = 1.96 indica um nível de confiança de 95%. A base é a curva Normal mesmo.
# Output: 
#   signal_zc: um vetor com 0's em regiões sem zero-crossing e 1's onde há zero-crossing.

  signal_filtered <- stats::filter(signal, rep(1/movwin_length, movwin_length), sides = 2)
  thresh <- z*sd((signal-signal_filtered),na.rm = TRUE)/sqrt(movwin_length)
  signal_zc <- as.numeric(abs(signal_filtered) < thresh)
  return(signal_zc)
}


## NAT RS
read.table("/home/yuri/liri/puzzle/rs/nat/chr_info_unfilt/count_info/freqs_chr_1_nat_rs.txt", h=F) -> count_nat_rs
count_nat_rs <- count_nat_rs[order(count_nat_rs[,3]),]
count_nat_rs <- count_nat_rs[,c(2,3,6)]
count_nat_rs <- count_nat_rs[!duplicated(count_nat_rs),]
colnames(count_nat_rs) <- c("chrom","bp", "score")
paste("chr",count_nat_rs$chrom,sep='') -> count_nat_rs$chrom
count_nat_rs$end <- c(count_nat_rs$bp[2:length(count_nat_rs$bp)] - 1, count_nat_rs$bp[length(count_nat_rs$bp)] + 1)

count_nat_rs <- count_nat_rs[,c(1,2,4,3)]
colnames(count_nat_rs) <- c("chrom", "start", "end", "score")


##NAT SP

read.table("/home/yuri/liri/puzzle/sp/nat/chr_info_unfilt/count_info/freqs_chr_1_nat_sp.txt", h=F) -> count_nat_sp
count_nat_sp <- count_nat_sp[order(count_nat_sp[,3]),]
count_nat_sp <- count_nat_sp[,c(2,3,6)]
count_nat_sp <- count_nat_sp[!duplicated(count_nat_sp),]
colnames(count_nat_sp) <- c("chrom","bp", "score")
paste("chr",count_nat_sp$chrom,sep='') -> count_nat_sp$chrom
count_nat_sp$end <- c(count_nat_sp$bp[2:length(count_nat_sp$bp)] - 1, count_nat_sp$bp[length(count_nat_sp$bp)] + 1)

count_nat_sp <- count_nat_sp[,c(1,2,4,3)]
colnames(count_nat_sp) <- c("chrom", "start", "end", "score")


# Conferindo que a indexação de posição genômica é a mesma para ambos as UF
sum(count_nat_rs$start - count_nat_sp$start)
pg <- count_nat_rs$start # vetor de posições genômicas
y_inf <- min(c(count_nat_rs$score, count_nat_sp$score)) #count inferior
y_sup <- max(c(count_nat_rs$score, count_nat_sp$score)) #count superior


# Vizualizando apenas um trecho dos genomas
# Observe que sem modificação dos dados, não há cruzamentos
y_rs <- count_nat_rs$score
y_sp <- count_nat_sp$score
N <- length(y_rs) #Número de amostras

plot(pg,y_rs,type='l',col='blue', ylim = c(y_inf,y_sup))
lines(pg,y_sp,col='red')


# Modificando as contagens para ficarem em termos de frequência relativa
y_rs <- y_rs - min(y_rs)
y_rs <- y_rs/max(y_rs)
y_sp <- y_sp - min(y_sp)
y_sp <- y_sp/max(y_sp)

plot(pg,y_rs,type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pg,y_sp,col='red')
legend(x="topright", legend = c("RS","SP"),fill = c("blue","red")) ##arrumar posicionamento da legenda

# Identificando os cruzamentos de frequência relativa
y_diff <- y_rs - y_sp
nwin <- round(sqrt(N)) #Tamanho da janela de média móvel. Dei um chute inicial de usar raiz(N) das vozes da minha cabeça
if(nwin%%2==0){
  nwin<-nwin+1
}

# Vizualizando a diferença entre as populações
y_diff_smooth <- stats::filter(y_diff, rep(1/nwin, nwin), sides = 2)
plot(pg,y_diff,type='l',col='blue',
     ylab="Diferença", xlab = "Posição Genômica")

# Detecção de cruzamentos mesmo para valer real agora vai
zc <- detect_ZeroCrossing(y_diff, nwin, z = 1.96) #detecção de cruzamentos
zc[is.na(zc)]<-0 #trocando os NA por zero só para o plot ficar mais agradável

plot(pg,y_rs,type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pg,y_sp,col='red')
lines(pg,zc,col='green')
legend(x="topright", legend = c("RS","SP","zc"),fill = c("blue","red","green")) #ajeitar legenda 

# Detecção de Regiões de Diferenças. Como o N é gigantesco, não dá para usar o 
# intervalo de confiança. Então o critério é usar múltiplos do desvio-padrão.
y_diff_mean <- mean(y_diff)
y_diff_sd <- sd(y_diff)
is_diff <- abs(y_diff - y_diff_mean) > 1*y_diff_sd
is_diff <- as.numeric(is_diff)

# Plot com apenas um limiar
plot(pg,y_rs,type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pg,y_sp,col='red')
lines(pg,is_diff,col='green')
legend(x="topright", legend = c("RS","SP","Difer"),fill = c("blue","red","green"))

# Plot com dois limiares
is_diff2 <- abs(y_diff - y_diff_mean) > 2*y_diff_sd
is_diff2 <- as.numeric(is_diff2)

plot(pg,y_rs,type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pg,y_sp,col='red')
lines(pg,0.5*is_diff,col='black') #multipliquei por 1/2 para não ficar poluído
lines(pg,is_diff2,col='green') 
legend(x="topright", legend = c("RS","SP","Dif DP=1","Dif DP=2"), fill = c("blue","red","black","green"))

# Plot comparando regiões similares com regiões diferentes (limiar de 2*DP)
ini<-1
endi<-250000000
plot(pg[ini:endi],y_rs[ini:endi],type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pg[ini:endi],y_sp[ini:endi],col='red')

lines(pg[ini:endi],is_diff2[ini:endi],col='green')
lines(pg[ini:endi],zc[ini:endi],col="black")
#legend(x="topright", legend = c("RS","SP","Dif DP=2","Igual nwin=177"), fill = c("blue","red","green","black"))


# Forma programática de investigar as posições genômicas com diferenças e similaridades
posicoes_similares <- pg[as.logical(zc)] #similares
posicoes_diferentes <- pg[as.logical(is_diff)] #diferentes
