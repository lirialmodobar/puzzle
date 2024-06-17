## caso nao tenha vpnc

sudo apt-get install vpnc
##  criar arquivo

sudo nano /etc/vpnc/sdumont.conf
### conteudo arquivo

IPSec gateway 146.134.0.14
IPSec ID sdumont
IPSec secret !$#Sdu#@mon!T321
Xauth username liriel.almodobar
## conectar na vpn

sudo vpnc /etc/vpnc/sdumont.conf --enable-weak-encryption
## conectar no ssh

ssh liriel.almodobar@login.sdumont.lncc.br (por algum motivo copiar e colar aqui nao da, tem que digitar mesmo --- ver se mudando pra linha de codigo corrige isso)

### minha home e scratch (submeter jobs)

/prj/unifesp/pgt/liriel.almodobar
/scratch/unifesp/pgt/liriel.almodobar
### comandos

sbatch - submete job
sacct - se o job nao está no squeue, da pra checar aqui o status 
scancel  (sem flag --job)- cancela o job
squeue -u liriel.almodobar - permite ver todos os jobs desse usuário

### jobs em progresso

10997381 - collapse chr 2 (checar output)
11022639 - tentativa collapse paralelo
10990173 - frag info 22 (checar se ta ok os arquivos - dirs ja checados)
11024328 - allele freq nat sp 1 refatorado, 12h37 16/04, 17h57 ja tinha acabado, n sei quando acabou (verificado por cima, verificar mais detalhadamente)
11024825 - allele freq eur sp 1 18h27 16/04
11087459 - collapse 14,16,17 - 12h40 27/05, nó tinha caido. nós cairam de novo, 14 completo.
11096882 - collapse 16, 17- nó tinha caido, completo.
11115515 - cópia para o collapse, deu muito erro, sumiu a pasta
11115704 - collapse 10-19 20h54 17/06, pois eu fui besta e deletei tudo

D no collapse: quando nao cobre o cromossomo inteiro, é porque as posicoes no array nao cobrem?
### desconectar da vpn (testar)

sudo vpnc-disconnect

### duvidas? deu problema?

email favoritado helpdesk lncc
#### manual 

[https://sdumont.lncc.br/support_manual.php?pg=support](https://sdumont.lncc.br/support_manual.php?pg=support "https://sdumont.lncc.br/support_manual.php?pg=support")

### senhas

senha padrao guaxinim
