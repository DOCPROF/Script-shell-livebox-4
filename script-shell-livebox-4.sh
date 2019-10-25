# Script de récupération des informations du LIVEBOX4
# Pour utiliser ce script vous devez avoir accés aux commandes curl et jq (json query)
# Il vous suffit de compléter les 2 variables ci-dessous avec vos paramètres
# J.LASSON - 2019

myLivebox=192.168.1.1
myPassword="votremotdepasse"

# Récupère le chemin où est lancé le script

myBashDir=`readlink -f $0 | xargs dirname`
myOutput=$myBashDir/myOutput.txt
myCookies=$myBashDir/myCookies.txt

# Connexion et recuperation du cookies

postData="{\"service\":\"sah.Device.Information\",\"method\":\"createContext\",\"parameters\":{\"applicationName\":\"so_sdkut\",\"username\":\"admin\",\"password\":\"${myPassword}\"}}"

curl -s -o "$myOutput" -X POST -c "$myCookies" -H 'Content-Type: application/x-sah-ws-1-call+json' -H 'Authorization: X-Sah-Login' -d $postData "http://${myLivebox}/ws" > /dev/null

# Lecture du cookies pour utilisation ulterieure

myContextID=`jq -r .data.contextID $myOutput`

# Préparation de la récuperation des json

getMIBs=`curl -s -b "$myCookies" -X POST -H 'Content-Type: application/x-sah-ws-4-call+json' -H "X-Context: $myContextID" -d "{\"service\":\"NeMo.Intf.data\",\"method\":\"getMIBs\",\"parameters\":{}}" http://${myLivebox}/ws`
  
getDSLStats=`curl -s -b "$myCookies" -X POST -H 'Content-Type: application/x-sah-ws-4-call+json' -H "X-Context: $myContextID" -d "{\"service\":\"NeMo.Intf.dsl0\",\"method\":\"getDSLStats\",\"parameters\":{}}" http://${myLivebox}/ws`

getWANStatus=`curl -s -b "$myCookies" -X POST -H 'Content-Type: application/x-sah-ws-4-call+json' -H "X-Context: $myContextID" -d "{\"service\":\"NMC\",\"method\":\"getWANStatus\",\"parameters\":{}}" http://${myLivebox}/ws`

getDeviceInfo=`curl -s -b "$myCookies" -X POST -H 'Content-Type: application/x-sah-ws-4-call+json' -H "X-Context: $myContextID" -d "{\"service\":\"DeviceInfo\",\"method\":\"get\",\"parameters\":{}}" http://${myLivebox}/ws`

getDevices=`curl -s -b "$myCookies" -X POST -H 'Content-Type: application/x-sah-ws-4-call+json' -H "X-Context: $myContextID" -d "{\"service\":\"Devices\",\"method\":\"get\",\"parameters\":{}}" http://${myLivebox}/ws`

# Affichage du resultat
# Là je mets tout dans un fichier texte mais libre à vous de choisir
# jq permet en plus de filtrer sur des valeurs précises 
# Exemples :
# echo $getDSLStats | jq -r .status.TransmitBlocks
# echo $getDSLStats | jq -r .status.ReceiveBlocks

echo "RAPPORT DU :" > $myBashDir/Result.txt
date +"%Y-%m-%d %Hh%Mm%Ss" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo "Info sur la LIVEBOX :" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo $getDeviceInfo | jq . >> $myBashDir/Result.txt
echo "Info sur les paramètres (MIBs) :" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo $getMIBs | jq . >> $myBashDir/Result.txt
echo "Info sur les indicateurs DSL :" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo $getDSLStats | jq . >> $myBashDir/Result.txt
echo "Info sur la configuration du WAN :" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo $getWANStatus | jq . >> $myBashDir/Result.txt
echo "Info sur les Devices connectés à la BOX :" >> $myBashDir/Result.txt
echo "--------------------------------------------------------" >> $myBashDir/Result.txt
echo $getDevices | jq . >> $myBashDir/Result.txt

# Deconnexion et suppression des fichiers temporaires

curl -s -b "$myCookies" -X POST http://$myLivebox/logout > /dev/null
rm "$myCookies" "$myOutput"

# pour être complet il existe des methodes set pour scripter des changements de valeurs
# Exemple : Activation / Désactivation du Wifi


