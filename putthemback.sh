#! /bin/bash
if  [ "$#" -ne 1 ]; then
 echo "Bad number of parameters : $#"
 return 2;
fi


i=0;
enableMv="false" ;
while read -r line;
do
   echo $((i=i+1))
   var1=$(echo "$line" | cut -f1 -d" ")
   var2=$(echo "$line" | cut -f2 -d" ")
   var3=$(echo "$line" | cut -f3 -d" ")
   if [ "$enableMv" == "true" ]; then
      searchstr=".jpg "
      to=${line%%$searchstr*}
      from=${line##*$searchstr}
      enableMv="false" ;
      echo "[$from][$to.jpg]"
      mv "$from" "$to.jpg"
   fi
   if [ "$var1" == "Moving" ] && [ "$var2" == "the" ] && [ "$var3" == "file..." ]; then
      enableMv="true" ;
      echo "[$line][$enableMv][$var1][$var2][$var3]"
   fi
   #if [ $i -gt 267 ]; then
   #   exit 2
   #fi
done < "$1"


#parameter     result
#-----------   ------------------------------
#$name         polish.ostrich.racing.champion
#${name#*.}           ostrich.racing.champion
#${name##*.}                         champion
#${name%%.*}   polish
#${name%.*}    polish.ostrich.racing
