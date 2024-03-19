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

### minha home

/prj/unifesp/pgt/liriel.almodobar

### desconectar da vpn (testar)

sudo vpnc-disconnect

### duvidas? deu problema?

email favoritado helpdesk lncc
#### manual 

[https://sdumont.lncc.br/support_manual.php?pg=support](https://sdumont.lncc.br/support_manual.php?pg=support "https://sdumont.lncc.br/support_manual.php?pg=support")

### senhas

senha padrao guaxinim
