# Rapport du TP Utilisation de Docker (suite)
  
  
__Nous avons travaillé ce TP sur Gitlab de Lyon 1. Ainsi, pour avoir le meilleur effet d'affichage de ce rapport dans l'environnement Markdown, veuillez vous rendre à l'adresse suivante__ [https://forge.univ-lyon1.fr/p1715490/tp-cloud-docker/blob/master/Rapport2.md](https://forge.univ-lyon1.fr/p1715490/tp-cloud-docker/blob/master/Rapport2.md).  
    
Binôme : SwarthXian   
Membres : KIAMPAMBA H'APELE Swarth-Elia et YANG Xian    
Promotion : Data Science Math      
L'adresse IP de la machine virtuelle : [http://192.168.76.13/](http://192.168.76.13/)   
Date : 20 nov. 2017   

 &ensp; &ensp;  
 &ensp; &ensp;  
  
## V. Appache ne redémarre pas, correction du bug
 
  
Effectivement quand on veut redémarrer un container `apache`, celui-ci s'éteint et réfuse de se remettre en route après. Pour résoudre ce problème, on modifie le `Dockerfile` 
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
$ mv apache2-foreground /docker/monApache/
$ docker build -t ubuntuapache:v2 /docker/monApache/
```

Après avoir recréé les containers en utilisant cette nouvelle docker image, on peut maintenant les relancer sans souci.  
  
   &ensp; &ensp;  
   &ensp; &ensp;  
   
## VI. Installation d'une application
    
 
On récupère d'abord le `zip` du projet `tiny` sur la VM
```sh
$ wget http://perso.univ-lyon1.fr/fabien.rico/site/_media/cloud:2016:master.zip
$ unzip cloud:2016:master.zip
``` 
 
### VI.1 Installation de mysql
On souhaite télécharger la docker image `mysql` et en lancer un container, tout en spésialisant les configurations dès le démarrage. En effet, quand l'image à utiliser
existe sur l'internet, on n'a même pas besoin de préciser le téléchargement. En revanche, on peut procéder directement à la création du container et le téléchargement
de l'image se fait automatiquement.
```sh
$ docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_DATABASE=tiny -e MYSQL_USER=usertiny -e MYSQL_PASSWORD=passtiny -v /root/tiny-master/_installation/:/docker-entrypoint-initdb.d/ -p 3306:3306 --net interne --ip 172.18.100.20 --name matheuAimeMysql mysql
```  
Puis pour récupérer le mot de passe de `root`
```sh
$ docker logs matheuAimeMysql 2>/dev/null | grep "GENERATED ROOT PASSWORD"
GENERATED ROOT PASSWORD: eiv6age6oboix8doiz3wue9go1meuRaH 
```
puis pour se connecter en tant que `root`
```sh
$ docker exec -it matheuAimeMysql mysql -u root -p  
```
en tapant le mot de passe affiché, on est entré sous mode mysql. Vérifions maintenant qu'on a bien démarré le container avec les base de données qu'on voulait importer : 
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
  
  
### VI.2 Installation de tiny
Dans un premier temps on déplace l'ancien fichier `index.php` vers `test1.php` sous le répertoire partagé des apaches `/docker/apache/html` 
```bash
$ mv /docker/apache/html/index.php /docker/apache/html/test1.php
```
et déplace tout le contenu dans le répertoire `tiny-master` sauf `_installation` vers le répertoire partagé
```bash
$ shopt -s extglob
$ mv /root/tiny-master/!(_installation) /docker/apache/html/
```
Pour que les apaches puisssent bien trouver et se connecter en tant qu'utilisateur `usertiny` à la base de données `tiny` de `mysql`, il faut faire la configuration 
suivante
```
define('DB_TYPE', 'mysql');
define('DB_HOST', '172.18.100.20');
define('DB_NAME', 'tiny');
define('DB_USER', 'usertiny');
define('DB_PASS', 'passtiny');
```
dans le fichier `/docker/apache/html/application/config/config.php` et supprimer `tiny-master` à la ligne `define('URL_SUB_FOLDER', 'tiny-master');`, 
puisque la page web `index.php` est directement sous le répertoire `html`.  
  
Finalement, on ajoute dans le fichier de configuration de `nginx` `/docker/nginx/config/nginx/conf.d/default.conf`
```
    location / {
        ...
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
```
Pour que ce proxy ne change pas l'adresse IP de l'hôte lors qu'il passe la requête de `nginx` aux `apache`s et renvoie toujours le vrai expéditeur de la requête.  
  
Maintenant quand on tape l'adresse IP de la VM dans notre navigateur, la page souhaitée avec une image demo et quatre liens apparaît. Si on clique ensuite 
le dernier lien, une liste de chansons avec leur liens dans `youtube` va s'ajouter en bas de la page.

 &ensp; &ensp;  
 &ensp; &ensp;  
  
## VII. Docker Compose

    
   
On installe d'abord la dernière version de `Docker Compose`, ce qui est compatible, 
d'après notre vérification sur le site Github, avec le format du fichier version `2.1`.
```sh
$ curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
docker-compose version 1.17.1, build 6d101fb
```
Après avoir supprimé tous les containers qui ne conernent pas la tâche de ce TP (en effet il n'y en a pas), 
on éteint également ces 4 containers `mysql`, 2 `apache` et `nginx`
```sh
docker stop $(docker ps -a -q)
```

Maintenant d'après l'énoncé on crée sous `/home/ubuntu/` un répertoire `compose` et y déplace tout ce qu'il faut pour `Docker Compose`
```sh
$ mkdir /home/ubuntu/compose
$ cp -r /docker /home/ubuntu/compose/docker
$ mkdir /home/ubuntu/compose/docker/mysql
$ cp -r /root/tiny-master/_installation /home/ubuntu/compose/docker/mysql/_installation
```

Ensuite on doit encore changer les adresses IP internes des 3 dockers (les deux `apache`s et `mysql`) vers la bonne plage (`172.20.20.0/24`)
comme il est demandé dans l'énoncé dans tous les fichiers de configuration où il faut (`/home/ubuntu/compose/docker/nginx/config/nginx/nginx.conf`,
`/home/ubuntu/compose/docker/nginx/config/nginx/conf.d/default.conf`, `/home/ubuntu/compose/docker/apache/html/application/config/config.php`). 
On change d'ailleurs aussi le nom et le mot de passe de l'utilisateur 
de la base de données dans le fichier de configuration d'apache `/home/ubuntu/compose/docker/apache/html/application/config/config.php`.  
  
Une fois toutes ces préparations soient faites, 
on peut rédiger un `docker-compose.yml` directement sous le répertoire `/home/ubuntu/compose` comme étant annexé à la fin du rapport.   
   
Dernièrement, dans le répertoire où il y a le fichier `docker-compose.yml` on l'exécute
```sh
$ docker-compose up -d
```
et on retrouvera tout ce qu'on a vu dans ce TP, mais construit automatiquement à l'aide de `Docker Compose`.
