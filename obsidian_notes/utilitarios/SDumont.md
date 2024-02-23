##  criar arquivo

nano /etc/vpnc/sdumont.conf
### conteudo arquivo

IPSec gateway 146.134.0.14
IPSec ID sdumont
IPSec secret !$#Sdu#@mon!T321
Xauth username liriel.almodobar
## conectar na vpn

#vpnc /etc/vpnc/sdumont.conf
## conectar no ssh

ssh liriel.almodobar@login.sdumont.lncc.br