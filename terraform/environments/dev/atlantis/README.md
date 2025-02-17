
GitHub App details (id, key and webhook secret) are encoded by sops with KMS key.
https://github.com/mozilla/sops

KMS Key is created by module [atlantis](../../../modules/atlantis/kms.tf)

Encrypt/decrypt operations: 
```shell
# Encrypt
sops --kms "arn:aws:kms:us-west-2:446126668185:key/257ed8e0-e3f8-403a-bb6e-87fc27c7975e" -e -i ./gh_app.yaml
# Decrypt
sops --kms "arn:aws:kms:us-west-2:446126668185:key/257ed8e0-e3f8-403a-bb6e-87fc27c7975e" -d -i ./gh_app.yaml
```
