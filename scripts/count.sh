#!/bin/bash
WD=/home/santoro-lab/liri/teste_dir
COLLAPSE=$WD/output_collapse
INFOS_TXT=$WD/infos_txt
[ ! -f "$INFOS_TXT/individuos.txt" ] && ls "$COLLAPSE" | sed -e 's/_A.bed//g; s/_B.bed//g' | sort | uniq > "$INFOS_TXT/individuos.txt"
