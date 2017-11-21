# Rapport du TP Utilisation de Docker (suite)
  
  
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
```sh
$ wget http://perso.univ-lyon1.fr/fabien.rico/site/_media/cloud:dockerfile_apache.zip 
$ apt-get install unzip
$ unzip cloud:dockerfile_apache.zip 
$ mv ...
...
```

Après avoir recréé les containers, on peut maintenant les relancer sans souci.  

## VI. Installation d'une application
```sh
$ wget http://perso.univ-lyon1.fr/fabien.rico/site/_media/cloud:2016:master.zip
$ unzip cloud:2016:master.zip

``` 
 
### VI.1 Installation de mysql
no pull, directly  
```sh
$ docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_DATABASE=tiny -e MYSQL_USER=usertiny -e MYSQL_PASSWORD=passtiny -v /root/tiny-master/_installation/:/docker-entrypoint-initdb.d/ -p 3306:3306 --net interne --ip 172.18.100.20 --name matheuAimeMysql mysql
```  
then 
```sh
$ docker logs matheuAimeMysql 2>/dev/null | grep "GENERATED ROOT PASSWORD"
GENERATED ROOT PASSWORD: pahb8weibei6ua4Oog3gai0Un2chohcu 
```
puis 
```sh
$ docker exec -it matheuAimeMysql mysql -u root -p  
```
en tapant le mot de passe obtenu, on est entré sous mode mysql. Vérifions maintenant qu'on a bien démarré le container avec les base de données qu'on voulait importer : 
```sh
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| tiny               |
+--------------------+
5 rows in set (0.00 sec)

mysql> use tiny; show tables;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
+----------------+
| Tables_in_tiny |
+----------------+
| song           |
+----------------+
1 row in set (0.00 sec)

mysql> exit
Bye
```
Maintenant vérifions également l'accessibilité réduite de l'utilisateur `user` :
```sh
$ docker exec -it matheuAimeMysql mysql -u usertiny -p  
```
En rentrant le mot de passe "passtiny", cet utilisateur doit pouvoir accéder à la base de données `tiny`.
```sh
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| tiny               |
+--------------------+
2 rows in set (0.00 sec)

mysql> use tiny;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------+
| Tables_in_tiny |
+----------------+
| song           |
+----------------+
1 row in set (0.00 sec)

mysql> select * from song;
```
Et `mysql` renvoie la table des 30 chansons dans l'enregistrement.




