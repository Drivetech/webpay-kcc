<?php
  require_once "vendor/autoload.php";
  Requests::register_autoloader();

  /**
   * Funcion que executa Checkmac
   *
   * @param  string $qs Valores del post concatenados
   *
   * @return boolean
   */
  function valid_mac($qs) {
    $filename_txt = "./log/MAC01Normal" . $_POST["TBK_ORDEN_COMPRA"] . ".txt";
    $cmdline = "./tbk_check_mac.cgi " . $filename_txt;
    $fp = fopen($filename_txt, "wt");
    fwrite($fp, $qs);
    fclose($fp);
    exec ($cmdline, $result, $retint);

    return ($result [0] == "CORRECTO") ? true : false;
  }

  /**
   * Funcion que retorna el post concatenado
   *
   * @return string Post concatenado
   */
  function get_qs() {
    $qs = "";

    foreach($_POST as $key=>$value) {
      $qs .= $key . "=" . $value . "&";
    }

    return $qs;
  }

  foreach($_POST as $key=>$value) $$key = $value;

  $TBK_MONTO = $TBK_MONTO / 100;
  $authorization_code = "";
  $success = false;

  $url = getenv("ORDER_URL") . $TBK_ORDEN_COMPRA;
  $headers = array("Content-Type" => "application/json");
  $response = Requests::get($url);

  if ($response->success) {
    $order = json_decode($response->body, true);
    $status = 0;
    $qs = get_qs();
    $payment_type = null;
    $number_quotas = null;

    $TBK_CODIGO_AUTORIZACION = (isset($TBK_CODIGO_AUTORIZACION)) ? $TBK_CODIGO_AUTORIZACION : "" ;

    if ($TBK_RESPUESTA == "0") {
      if (valid_mac($qs, $TBK_ORDEN_COMPRA) && $order["status"] == 0 && !in_array($TBK_CODIGO_AUTORIZACION, array("000000", ""))) {
        $authorization_code = (isset($order["authorization_code"]) ? $order["authorization_code"] : "");
        if ($order["amount"] == $TBK_MONTO && $authorization_code == "") {
          $authorization_code = $TBK_CODIGO_AUTORIZACION;
          $status = 1;
          $payment_type = $TBK_TIPO_PAGO;
          $number_quotas = (int) $TBK_NUMERO_CUOTAS;
          $success = true;
        } else {
          $status = 4;
        }
      } else {
        $status = 3;
      }
    } else {
      $success = true;
    }

    $data = array(
      "transaction_code" => $TBK_RESPUESTA,
      "gateway_response" => $qs,
      "transaction_id" => $TBK_ID_TRANSACCION,
      "last_4_digits" => $TBK_FINAL_NUMERO_TARJETA,
      "authorization_code" => $authorization_code,
      "payment_type" => $payment_type,
      "number_quotas" => $number_quotas,
      "status" => $status
    );
    $response = Requests::post($url, $headers, json_encode($data));
  }
?>
<!DOCTYPE html>
<html>
  <?php if ($success==true){?>
    ACEPTADO
  <?php } else {?>
    RECHAZADO
  <?php }?>
</html>
