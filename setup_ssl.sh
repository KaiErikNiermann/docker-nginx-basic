#!/bin/bash

email_arg="--email k.e.niermann@student.vu.nl"
domain_args="-d asdfxyz.xyz"

docker compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $email_arg \
    $domain_args \
    --agree-tos \
    --force-renewal" certbot
echo