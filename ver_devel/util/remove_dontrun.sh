#!/bin/bash
##### This script removes the dontrun tags and so
##### all the example codes will be executed

for i in ./bio3d/man/*.Rd; do
   # skip some examples because of the missing 
   # data or run errors
#   if [ `basename $i` != "read.crd.Rd" ] && \
#      [ `basename $i` != "read.crd.amber.Rd" ] && \
#      [ `basename $i` != "read.crd.charmm.Rd" ] && \
#      [ `basename $i` != "as.pdb.Rd" ] && \
#      [ `basename $i` != "atom.select.Rd" ] && \
#      [ `basename $i` != "read.prmtop.Rd" ] && \
#      [ `basename $i` != "read.mol2.Rd" ]; then
      echo $i
      # find and delete tags \dontrun{ and }
      awk 'BEGIN{bok=0; n=0} 
           /\\dontrun\{/{bok=1}
           bok {a=$0; while(sub(/\{/,"",a)) n++; while(sub(/\}/,"",a)) n--}
           n>0 && !/\\dontrun\{/ {print} 
           !bok{print} 
           bok && n==0 {bok=0}' $i > t.Rd
      mv t.Rd $i
#   fi
    
   # find help(), demo(), identify or identify.cna() and add \dontrun{}
   sed -e '/\\examples\s*{/,$s/^\(\s*help\s*(.*).*\)$/\\dontrun{\n\1\n}/' \
       -e '/\\examples\s*{/,$s/^\(\s*demo\s*(.*).*\)$/\\dontrun{\n\1\n}/' \
       -e '/\\examples\s*{/,$s/^\([^#]*identify\s*(.*).*\)$/\\dontrun{\n\1\n}/' \
       -e '/\\examples\s*{/,$s/^\([^#]*identify.cna\s*(.*).*\)$/\\dontrun{\n\1\n}/' \
   $i > t.Rd
   mv t.Rd $i

   if [ `basename $i` == "hmmer.Rd" ]; then
     # replace the tag '\cr' to newlines to avoid some errors from staticdocs
     sed -i 's/\\cr/\n/g' $i
   fi
done
