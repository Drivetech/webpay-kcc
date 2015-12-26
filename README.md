# docker-webPay

Transbank Webpay KCC 6.0.2 linux 64

## Example

```bash
# Development
docker run -d --restart=always -p 80:80 -v /path/local/log:/var/www/webpay/log --name webpay lgaticaq/webpay-kcc:dev

# Production
docker run -d --restart=always -p 80:80 -v /path/local/log:/var/www/webpay/log -e PRIVADA=`cat privada.pem` -e PUBLICA=`cat tbk_public_key.pem` -e IDCOMERCIO=XXXXXXXXXXXX -e IP=XXX.XXX.XXX.XXX lgaticaq/webpay-kcc
```
