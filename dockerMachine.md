Docker-machine est pour créer de nouvelles VM
 
```bash
export OS_PASSWORD=$(python3 -c "import getpass; pa=getpass.getpass('Mot de passe : '); print (pa)")

./docker-machine create --driver openstack \ 
    --openstack-auth-url "http://cloud-info.univ-lyon1.fr:5000/v3/" \
    --openstack-domain-name univ-lyon1.fr \
    --openstack-username p1715490 \
    --openstack-ssh-user ubuntu \
    --openstack-tenant-id 0172faff8a6c4c63ad7095af44d86415 \
    --openstack-flavor-name m1.xsmall \
    --openstack-image-name "Ubuntu 16.04.3 LTS Xenial" \
    --engine-env "HTTP_PROXY=http://univ-lyon1.fr:3128" \
    --engine-env "HTTPS_PROXY=http://univ-lyon1.fr:3128" \
    Alsaxian-node-master
```