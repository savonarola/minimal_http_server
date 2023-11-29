#!/bin/bash

openssl req \
    -x509 \
    -new \
    -nodes \
    -newkey rsa:2048 \
    -subj "/C=LT/ST=Vilniaus/L=Vilnius/O=RubyBox/CN=rubybox.dev" \
    -keyout ca.key \
    -sha256 \
    -days 10000 \
    -out ca.crt

openssl req \
    -batch \
    -new \
    -newkey rsa:2048 \
    -nodes \
    -keyout server.key \
    -subj '/CN=server/O=Server/C=LT/ST=Vilniaus/L=Vilnius' \
    -out server.csr

openssl x509 \
    -req \
    -in server.csr \
    -days 10000 \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out server.crt

