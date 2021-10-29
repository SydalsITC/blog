
# SSL cheat sheet
Proper encryption with TLS is a science itself and can be quite tricky. Therefore it's neccessary to have some tools at hand if you need to check or debug things.
Because it's no everyday business to me, I always have to lookup the right commands and their arguments. So finally I decided to write my own SSL cheat sheet and am glad to share it.

## File with key, certificate and CA chain
Sometimes you get them all in one file. The private key is easy to detect ("-----BEGIN RSA PRIVATE KEY-----"), but what I always forget about is the order of the certificates. So here's a reminder to myself. The order of the entries in an all-in-one file is:
1. private key (or encrypted private key)
2. certificate for the same subject
3. the CA chain with
    1. intermediate CA(s)
    2. finally the Root CA



## Check a server with ssl termination, using the openssl s_client:
```
# simple version:
openssl s_client -connect tgt.server.tld:443 </dev/null
# with host for SNI
openssl s_client -showcerts -servername tgt.server.tld -connect tgt.server.tld:443 </dev/null
```


## Check key or certificate
```
# check certificate
openssl x509 -noout -text -in my-crt.pem 

# check key
openssl rsa -noout -text -in my-key.pem 
```

## Decrypt key (protected by password)
```
openssl rsa -in my-enc-key.pem -out my-key.pem
```


