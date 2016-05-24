# webpay-kcc

[![Image Layers](https://imagelayers.io/badge/lgatica/webpay-kcc:latest.svg)](https://imagelayers.io/?images=lgatica/webpay-kcc:latest 'Get your own badge on imagelayers.io')
[![Docker Stars](https://img.shields.io/docker/stars/lgatica/webpay-kcc.svg)](https://hub.docker.com/r/lgatica/webpay-kcc/)
[![Docker Pulls](https://img.shields.io/docker/pulls/lgatica/webpay-kcc.svg)](https://hub.docker.com/r/lgatica/webpay-kcc/)

Transbank Webpay KCC 6.0.2 linux 64

Esta imagen de docker espera que se disponga de un endpoint de API para obtener y actualizar la orden de compra en el sitio web. Deben ser asi:

```bash
curl -i -H "Content-Type: application/json" -X GET http://hostname/resource/order_id
{
  "transaction_code": null,
  "gateway_response": null,
  "transaction_id": 111,
  "last_4_digits": null,
  "authorization_code": "",
  "payment_type": null,
  "number_quotas": null,
  "status": 0,
  "amount": 10000
}
curl -i -H "Content-Type: application/json" -X POST '{"transaction_code": "XX", "gateway_response": "XX", "transaction_id": "XX", "last_4_digits": "XX", "authorization_code": "XX", "payment_type": "XX", "number_quotas": "XX", "status": "XX"' http://hostname/resource/order_id
```

Ambas urls deben tener la misma base y se espera que con el metodo GET retorne un json con los datos de la orden como se muestra en el ejemplo. Con el metodo POST se espera actualizar la orden con la respuesta de Transbank, como se muestra en el ejemplo.

## Example

```bash
# Development
docker run -d --restart=always -p 80:80 -v /path/local/log:/var/www/webpay/log -e IP=XXX.XXX.XXX.XXX -e ORDER_URL=http://hostname/resource --name webpay lgaticaq/webpay-kcc:dev

# Production
docker run -d --restart=always -p 80:80 -v /path/local/log:/var/www/webpay/log -e PRIVADA=`cat privada.pem` -e PUBLICA=`cat tbk_public_key.pem` -e IDCOMERCIO=XXXXXXXXXXXX -e IP=XXX.XXX.XXX.XXX -e ORDER_URL=http://hostname/resource lgaticaq/webpay-kcc
```
