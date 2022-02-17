<?php
enqueueJS('bootstrap_switch');
enqueueJS('jquery_ui');
enqueueJS('jquery_dotimeout');
enqueueJS('jquery_passy');
enqueueJS('jquery_uniform');
enqueueJS('jquery_formatter');
enqueueJS('jquery_selectbox');
enqueueJS('jquery_datatables');
enqueueJS('highcharts');
$user->loadMeta();
global $db;
$sql = "select webapp_id , webapp_name from webapps order by webapp_name asc";
$retour = $db->getArray($sql);
$submit = isset($_POST['submit']);
if ($submit) {
   $number = isset($_POST['number']) ? $_POST['number'] : '';
   $webapp_id = isset($_POST['webapps']) ? $_POST['webapps'] : '';
    for ($i = 0; $i < $number; $i++) {
        $code_activation = generator();
        $args = array(':webapp_id' => $webapp_id, ':code_activation' => $code_activation);
        $sql = "INSERT INTO `devices`(`device_active`, `code_activation`, `webapp_id`) VALUES ( '0' ,:code_activation ,:webapp_id)";
        $retour = $db->getRow($sql, $args);
    }
    header('Location: device');     
}
function generator(){
    $db = new dbAccess();
    do{
    $comb = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $pass = array(); 
    $combLen = strlen($comb) - 1; 
    for ($i = 0; $i < 15; $i++) {
        $n = rand(0, $combLen);
        $pass[] = $comb[$n];
    }
   $code_activation=implode($pass); 
   $sql = "select count(*) as compteur from devices where code_activation=:code_activation";
   $arg =   array(":code_activation" => $code_activation);
   $retour = $db->getRow($sql, $arg);
    }while($retour['compteur']!=0) ;
   return $code_activation ;
   }
