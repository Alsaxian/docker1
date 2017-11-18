# Rapport du TP Utilisation de Docker

Binôme : Swarth-Elia ___ et Xian YANG   
Promotion : Data Science Math   
L'adresse IP de la machine virtuelle : [http://192.168.76.13/](http://192.168.76.13/)   
Date : 16 nov. 2017   

[TOC]

## 0. Préparation d'une machine virtuelle avec Docker
En premier temps, on monte une VM avec docker pré-installé sur Openstack. 
Après passer en root afin de faciliter la saisie de commandes, 
on vérifie l’installation de docker sur la VM avec
```sh
$ docker version
```
ce qui vous renvoie le numéro de sa version et assure son bon fonctionnement.
  
  
## I. Installation d'un docker nginx
  
  
- [x] Sélection et téléchargement d'une docker image nginx sur dockerhub 
- [x] Lancement d'un premier docker container d'essai avec l'attachement des ports 
- [x] Recherche de sa position et sa structure dans le system de fichiers de l'hôte
- [x] Création d'un nouveau container avec un volume partagé
- [x] Test du fonctionnement du volume partagé  

  
On va d’abord trouver la bonne version de docker ```nginx``` qu’on va utiliser par la suite. 
Pour le faire, on peut taper
```sh
$ docker search --stars=3 --no-trunc nginx
```
qui va chercher par défaut sur dockerhub et puis afficher toutes les docker images disponibles 
portant le nom ```nginx```, ayant au moins 3 étoiles accompagnées d’une description non-tronquée. 
On voit bien en tête de cette liste l’image officielle avec 7219 étoiles au moment de la rédaction de ce rapport.  
  
Pour trouver des informations sur ses différentes versions, 
on peut aller sur [dockerhub](http://dockerhub.com) et lire la documentation docker de ```nginx```, 
où on peut reconnaître sa dernière version ```1.13.6``` par l'étiquette ```latest```. 
D’ailleurs la différence entre la version principale et celle de Perl consiste en 
la ligne 31 du fichier ```Dockerfile``` de cette dernière, où il ajoute le module Perl avec
> nginx-module-perl=${NGINX_VERSION} 

Du coup sans exigences particulières on télécharge tranquillement 
la dernière version de ```nginx``` en saisissant la commande
```bash
$ docker pull nginx
```
Pour vérifier que le téléchargement de l’image était bonne, on peut taper
```bash
$ docker images nginx
```
ce qui nous donne entre autres son nom (```nginx```) et son libellé (```latest```).  
  
A partir de cette image on peut créer et lancer notre premier container nommé test avec

```bash
$ run -d --name test --hostname test -p 80:80 -p 443:443 nginx
```
qui lie les ports 80 et 443 du container avec resp. 
ceux de la VM. On peut vérifier ceci en entrant dans le navigateur l’adresse IP 
de notre machine virtuelle [http://192.168.76.13/](http://192.168.76.13/) 
(où le navigateur va chercher par défaut le port 80 de la VM) et on voit 
la page d’accueil de nginx 
> Welcome to nginx!

Ensuite on va aller dans le container et y créer un fichier `toto` sous la racine contenant "coucou".
```bash
$ docker exec -it test bash
$ echo coucou > /toto
```
Pour vérifier, on peut faire
```bash
$ cat /toto
```
ce qui nous affichera "coucou".  
  
Après sortir du container, on essaie maintenant de retrouver ce message dans notre VM. 
On peut saisir la commande suivante dans le terminal pour extraire le chemin vers 
le driver overlay2 du container dans la VM.
```bash
$ docker container inspect test | grep Dir
```
ou encore mieux
```bash
$ docker container inspect -f "{{ json .GraphDriver }}" test | python3 -m json.tool
```
On y reconnaît entre autres un "LowerDir" représentant les répertoires de l’image ngninx 
utilisé par ce container qui sont constitués de plusieurs couches, 
un `UpperDir` représentant la couche ajoutée par le container et un `MergedDir` 
le point de montage de ces deux premiers.  
  
Une fois qu’on a trouvé le répertoire `UpperDir`, on peut retrouver le fichier 
qu’on vient de créer en dehors du container.
```bash
$ ls /var/lib/docker/overlay2/ac5ade1ec1b1fb3a1cfb871b77192fe61ce8cedbe1f1f2b61a86b13614945c6e/diff
```
ce qui nous affiche bien le fichier `toto`.  
  
Maintenant on veut monter un docker container en répertoire partagé afin de 
faciliter sa configuration en dehors du container. Pour le faire, 
on garde d’abord une copie du répertoire de configuration du présent container dans la VM
```bash
$ mkdir -p /docker/nginx/config
$ docker cp test:/etc/nginx /docker/nginx/config
```
Ensuite on supprime le container test et en créer un nouveau avec un répertoire partagé
```bash
$ docker rm -f test
$ docker run -d --name nginx --hostname nginx -p 80:80 -p 443:443 -v /docker/nginx/config/nginx:/etc/nginx nginx
```
Puis, on peut modifier le fichier de configuration dans le répertoire partagé 
de la VM en y ajoutant p. ex. une phrase personnalisée dans le message d’erreurs à afficher. 
On redémarre le container. Après, quand on demande un site inexistant sous l’adresse IP 
de cette VM dans le navigateur, on peut voir, avec le journal dynamique ou non 
```bash
$ docker logs -f nginx
```
que le message d’erreurs est maintenant personnalisé, ce qui montre le bon fonctionnement 
du répertoire partagé entre le container et la VM.


## II. Installation d'un docker apache
  
  
- [x] Construction d'un docker image partir d'un Dockerfile 
- [x] Personnalisation du Dockerfile 
- [x] Création d'un containers apache et attachement de celui-ci au serveur nginx
- [x] Test de son fonctionnement avec la visite de la page web dont s'occupe le serveur apache à travers le serveur nginx
 

  
On télécharger d’abord le Dockerfile sous le nouveau répertoire `/docker/monApache`
```bash
$ mkdir /docker/monApache
$ wget -O /docker/monApache/Dockerfile http://perso.univ-lyon1.fr/fabien.rico/site/_media/cloud:dockerfile_apache-tp2.txt  
```
A partir de ce fichier on peut construire une image d’essai `ubuntuapache:v0`
```bash
$ docker build -t ubuntuapache:v0 /docker/monApache/
```

Après, on va modifier le Dockerfile de façon   
   
1. qu’il installera les modules nécessaire, en changeant la ligne d’installation à
    > RUN  apt-get update && apt-get -y install apache2 \  
       &ensp; &ensp; php-pear php5-ldap php-auth php5-mysql php5-common \   
       &ensp; &ensp; libapache2-mod-php5 && apt-get clean  
 
2. que le nom du serveur à créer soit MatheuxEstGenial en le mettant dans la commande 
    commançant par `RUN sed`,
    
3. que l'affichage des erreurs php soit activé, en ajoutant dans le fichier une ligne
    > RUN sed -ie 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
        

Puis on recrée une docker image à partir de ce Dockerfile et on va en lancer un container apache
```bash
$ docker build -t ubuntuapache:v1 /docker/monApache/
$ docker run -d --name apache --hostname apache -v /docker/apache/html/:/var/www/html/ ubuntuapache:v1
```
On peut demander son adresse IP dans le réseau interne par défaut
```bash
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' apache
```
Le système répond `172.17.0.3`.

On peut aussi tester le fonctionnement du container par une commande `telnet`
```bash
telnet 172.17.0.3 80
```
Pour que le chemin ‘/site’ soit envoyé sur le serveur apache, 
on peut modifier le fichier `/docker/nginx/config/nginx/conf.d/default.conf` en y ajoutant
> location /site {  
	&ensp; &ensp; proxy_pass http://172.17.0.3/;  
> } 

Maintenant après avoir relancé le container `nginx`, 
on peut visiter le site `http://192.168.76.13/site` et c’est le serveur apache qui répond.  
  
On peut demander d’afficher les informations du serveur en créant une page `index.php` 
dans le répertoire partagé `/docker/apache/html/` et en y mettant
> <?php  
    &ensp; &ensp; echo "Salut les matheux !";  
    &ensp; &ensp; phpinfo();  
> ?>

Quand on renouvelle le site web, on peut y constater 
(dans le tableau `Apache Environment`) entre autres 

1. que l'adresse du serveur (SERVER_ADDR) est `172.17.0.3`,
2. que le chemin de la page web utilisé (`DOCUMENT_ROOT`) est `/var/www/html` et
3. que l'adresse du client (`REMOTE_ADDR`) est `172.17.0.2`. 



## III. Utilisation du réseau
  
  
- [x] Création d'un réseau utilisateur
- [x] Lancement d'un premier docker container d'essai avec l'attachement des ports 
- [x] Recherche de sa position et sa structure dans le system de fichiers de l'hôte
- [x] Création d'un nouveau container avec un volume partagé
- [x] Test du fonctionnement du volume partagé  

  
Afin de rendre possible l’affectation d’une adresse IP de notre choix au container, 
il faut d’abord créer un réseau autre que celui par défaut
```bash
$ docker network create --subnet 172.18.100.0/24 interne
```
On peut maitenant supprimer l’ancien container `apache` et en créer deux nouveaux dans ce réseau
```bash
$ docker rm -f apache
$ docker run -d --name alsaxian1 --hostname alsaxian1 -v /docker/apache/html/:/var/www/html/ --net interne --ip 172.18.100.10 ubuntuapache:v1
$ docker run -d --name alsaxian2 --hostname alsaxian2 -v /docker/apache/html/:/var/www/html/ --net interne --ip 172.18.100.11 ubuntuapache:v1
```
Puis on supprime aussi l’ancien docker `nginx` et le recréer en ajoutant à son fichier hosts les containers `apache`
```bash
$ docker run -d --name nginx --hostname nginx -p 80:80 -p 443:443 -v /docker/nginx/config/nginx:/etc/nginx --add-host "alsaxian1:172.18.100.10" --add-host "alsaxian2:172.18.100.11" nginx
```
On le connecte ensuite avec le nouveau réseau
```bash
$ docker network connect interne nginx
```
avec la commande
```bash
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx
```
On voit bien que le container est à la fois dans les deux réseaux (celui par défaut et celui créé par l’utilisateur).  
  
On peut trouver ces dockers au sein de la VM p. ex. avec une commande `telnet`. 
Par contre une autre VM ne peut pas y avoir accès sauf faire des ssh enchaînés de façon à se connecter 
d’abord à la VM actuelle, puisque ces réseaux-là sont internes à la VM.  
  
En ajoutant cette partie 
> location /site1 {   
    &ensp; &ensp;	proxy_pass http://172.18.100.10/;  
> }  
> location /site2 {  
    &ensp; &ensp;	proxy_pass http://172.18.100.11/;  
> }

au fichier `/docker/nginx/config/nginx/conf.d/default.conf` et après avoir relancé `nginx`, 
on peut visiter les deux serveurs dans le navigateur resp. à 
[http://192.168.76.13/site1](http://192.168.76.13/site1) et [http://192.168.76.13/site2](http://192.168.76.13/site2].





### IV. Equilibrage de charge

Afin que le charge de requêtes de nginx soit réparti de façon alternée sur les deux serveurs apache, 
on ajoute au fichier `/docker/nginx/config/nginx/conf.d/default.conf`, dans "location / {...}"
> proxy_pass http://project;

et au fichier `/docker/nginx/config/nginx/nginx.conf`
> upstream project {  
>    &ensp; &ensp;	server 172.18.100.10;  
>    &ensp; &ensp;	server 172.18.100.11;  
> }

Ensuite pour différencier bien les deux sites on crée sous `/docker/apache/html` un site web `test.php` qui contient
> <?php  
>    &ensp; &ensp;	echo "\<pre\>".print_r($_SERVER, true)."\</pre\>";  
> ?>

En appelant l’adresse [http://192.168.76.13/test.php](http://192.168.76.13/test.php) plusieurs fois, 
on peut constater que les requêtes sont bien prises en charges par les deux serveurs apache de façon alternées. 
La variable permettant de détecter le container visité c’est `[SERVER_ADDR]`.



  

  
  

  
  

  

  


  
  


  

  

```flow
st=>start: Start
op=>operation: Your Operation
cond=>condition: Yes or No?
e=>end

st->op->cond
cond(yes)->e
cond(no)->op
```

### 5. 高效绘制 [序列图](https://www.zybuluo.com/mdeditor?url=https://www.zybuluo.com/static/editor/md-help.markdown#8-序列图)

```seq
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```

### 6. 高效绘制 [甘特图](https://www.zybuluo.com/mdeditor?url=https://www.zybuluo.com/static/editor/md-help.markdown#9-甘特图)

```gantt
    title 项目开发流程
    section 项目确定
        需求分析       :a1, 2016-06-22, 3d
        可行性报告     :after a1, 5d
        概念验证       : 5d
    section 项目实施
        概要设计      :2016-07-05  , 5d
        详细设计      :2016-07-08, 10d
        编码          :2016-07-15, 10d
        测试          :2016-07-22, 5d
    section 发布验收
        发布: 2d
        验收: 3d
```

### 7. 绘制表格

| 项目        | 价格   |  数量  |
| --------   | -----:  | :----:  |
| 计算机     | \$1600 |   5     |
| 手机        |   \$12   |   12   |
| 管线        |    \$1    |  234  |