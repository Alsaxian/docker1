# Rapport du TP Utilisation de Docker
  
  
__Nous avons travaillé ce TP sur Gitlab de Lyon 1. Ainsi, pour avoir le meilleur effet d'affichage de ce rapport dans l'environnement Markdown, veuillez vous rendre à l'adresse suivante__ [https://forge.univ-lyon1.fr/p1715490/tp-cloud-docker/](https://forge.univ-lyon1.fr/p1715490/tp-cloud-docker/).  
    
Binôme : SwarthXian   
Membres : KIAMPAMBA H'APELE Swarth-Elia et YANG Xian    
Promotion : Data Science Maths      
L'adresse IP de la machine virtuelle : [http://192.168.76.13/](http://192.168.76.13/)   
Date : 20 nov. 2017   

 &ensp; &ensp;  
 &ensp; &ensp;  
  
## V. Appache ne redémarre pas, correction du bug
 &ensp; &ensp;  
  
Effectivement quand on veut redémarrer un container `apache`, celui-ci s'éteint et réfuse de s remettre en route après. Pour résoudre ce problème, on modifie le `Dockerfile` 
en remplaçant la ligne 
> CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

par
> COPY apache2-foreground /usr/local/bin/  
RUN  chmod a+x /usr/local/bin/apache2-foreground  
CMD ["/usr/local/bin/apache2-foreground"]  

Et on ajoute dans le même répertoire un fichier `apache2-foreground` qui provient de [cette archive](http://perso.univ-lyon1.fr/fabien.rico/site/_media/cloud:dockerfile_apache.zip).
Après avoir recréé les containers, on peut maintenant les relancer sans souci.  
apt-get install
wget 
unzip
## VI. Installation d'une application
wget 
unzip  
### VI.1 Installation de mysql
no pull, directly  
docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_DATABASE=tiny -e MYSQL_USER=usertiny -e MYSQL_PASSWORD=passtiny -v /root/tiny-master/_installation/:/docker-entrypoint-initdb.d/ -p 3306:3306 --net interne --ip 172.18.100.20 --name matheuAimeMysql mysql
  
then docker logs matheuAimeMysql 2>/dev/null | grep "GENERATED ROOT PASSWORD"  
le système répond GENERATED ROOT PASSWORD: pahb8weibei6ua4Oog3gai0Un2chohcu  
puis docker exec -it matheuAimeMysql mysql -u root -p  
en tapant le mot de passe obtenu, on est entré sous mode mysql   
mysql> mysql> show tables;





