#!/bin/sh -ex
# sudo certbot certonly --key-type rsa --manual --preferred-challenges dns
sudo kubectl delete secret rosterbater-tls
sudo kubectl create secret tls rosterbater-tls --cert=/etc/letsencrypt/live/rosterbater.com/fullchain.pem --key=/etc/letsencrypt/live/rosterbater.com/privkey.pem
