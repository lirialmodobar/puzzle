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


11024328 - allele freq nat sp 1 refatorado, 12h37 16/04, 17h57 ja tinha acabado, n sei quando acabou (verificado por cima, verificar mais detalhadamente)
11024825 - allele freq eur sp 1 18h27 16/04
11087459 - collapse 14,16,17 - 12h40 27/05, nó tinha caido. nós cairam de novo, 14 completo.
11096882 - collapse 16, 17- nó tinha caido, completo.
11115515 - cópia para o collapse, deu muito erro, sumiu a pasta
11115704 - collapse 10-19 20h54 17/06, pois eu fui besta e deletei tudo. 13h 25/06: 12 e 11 terminaram
11118358 - collapse 4 e 5 23h02 19/06
11118367 - collapse 6, 7 23h14 19/06
11118368 - collapse 8,9 23h15 19/06


11127348 - frag info 11, 12 terminou (PROXIMO VALIDO DE RODAR ALLELE FREQ)
11157692 - frag info 4-9 terminou
11157748 - frag info 10 terminou
11165135 - frag info 1-3 terminou, sem erro
11164777 - frag info 13-22 terminou
SEM MAIS FRAG INFO PRA FAZER, SÓ CHECAR

11158609 - haps 4-9 13h22 -- 18h36 ja tinha terminado
11159360 - haps 10 - 15 24/07 11h41 ja tinha terminaod
11160413 - haps 16-19 11h50 24/07 23/07 13h24 ja tinha terminado
11162512 - haps 1-3  VALIDO FAZER MSM SEM FRAG INFO terminou
11164810 - haps 20-22 terminou
SEM MAIS HAPS PRA FAZER, SÓ CHECAR.


11160520 - checagem collapse 4-19, terminou e ta ok
11162523 - checagem collapse 1 ao 3 terminou e ta ok
11165148 - checagem arquivos presentes frag info


11159362 - allele freq 4 e 5 nat 18h40 23/07  24/07 11h41 ja terminado
11162497 - allele freq nat 6-10 11h34 26/07  29/07 12h23 ja tinha terminado (provavelmente bem antes, no fds)
11164846 - allele freq nat 11-12 29/07 12h23 17h47 tinha terminado
11165355 - allele freq nat 1-3 17h49 29/07 11h56 30/07 ja tinha terminado
11168947 - allele freq nat 13-16 e 3 (tinha rodado 2x pra sp), 12h07 01/08 terminou
11173042 - allele freq nat 17-22 11h16  05/08 06/08 12h03 ja tinha terminado
11174537 - allele freq afr 17-22 12h06 06/08 10h42 07/08 ja tinha terminado
11175596 - allele freq afr 11-16 10h42 07/08 12h30 08/08 ja tinha terminado
11176392  - allele freq afr 5-10 12h32 08/08 23h55 11/08 ja tinha terminado
11180177 - allele freq afr 1-4 00h02 12/08 13/08 17h24 tinha terminado
11182148 - allele freq eur 1-4 pode falhar por time limit, 13/08 17h30 deu errado, apagar vestigios
11200888 - allele freq nat 1-5, problema: n tinha grep -w
11201890 - allele freq nat 1; problema: repeti o cohaps, tem q fazer pro 2 ao 5 tbm
11202229 - allele freq nat 2-5 terminou
11203009 - allele freq nat 6-11 terminou
11207672 - allele freq nat 12-17 terminou
11209561 - allele freq nat 18-22, falta o 10!  terminou
11210629 - allele freq nat 10

11180186 - tentativa reconstruct 23h54 11/08 TINHA ACABADO, ACABOU ANTES DO 30/08!!! nao escreveu nada, ue....

11236397 - reconstruct teste 28/11 12h

D no collapse: quando nao cobre o cromossomo inteiro, é porque as posicoes no array nao cobrem?
### desconectar da vpn (testar)

sudo vpnc-disconnect

### duvidas? deu problema?

email favoritado helpdesk lncc
#### manual 

[https://sdumont.lncc.br/support_manual.php?pg=support](https://sdumont.lncc.br/support_manual.php?pg=support "https://sdumont.lncc.br/support_manual.php?pg=support")

### senhas

senha padrao guaxinim
