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
scancel - cancela o job
squeue -u liriel.almodobar - permite ver todos os jobs desse usuário

### jobs em progresso

10997381 - collapse chr 2 (checar output)
11015460 - tentativa collapse paralelo
10990173 - frag info 22 (checar se ta ok os arquivos - dirs ja checados)
11015492 - allele freq refatorado
### desconectar da vpn (testar)

sudo vpnc-disconnect

### duvidas? deu problema?

email favoritado helpdesk lncc
#### manual 

[https://sdumont.lncc.br/support_manual.php?pg=support](https://sdumont.lncc.br/support_manual.php?pg=support "https://sdumont.lncc.br/support_manual.php?pg=support")

### senhas

senha padrao guaxinim
