<?php

require_once('../includes/site.conf.php');
require_once('../includes/variables.php');
require_once('../includes/functions.php');
require_once(LIBRARY_PATH . 'class.new_dbAccess.php');
$db = new dbAccess();

$result = array('status' => 0, 'msg' => 'ERREUR');

$action = (isset($_REQUEST['action'])) ? $_REQUEST['action'] : false;
if ($action) {
    switch ($action) {
        case 'getDevices':
            //phase de teste pour savoir ce que l'on recois 
            $sql = "SELECT device_uuid ,code_activation ,device_active ,devices.device_id as device_id,devices.webapp_id as webapp_id, webapp_name FROM devices , webapps WHERE webapps.webapp_id=devices.webapp_id  AND device_uuid not LIKE ''";
            $retour = $db->getAssocArray($sql, false, 'device_id');
            $i = 0;
            foreach ($retour as $device_id => $row) {
                $i++;
                $arg41 = array(':device_id' => $device_id);
                $sql41 = "SELECT meta_key, meta_value FROM `devices_meta` where device_id=:device_id";
                $metas = $db->getAssocArray($sql41, $arg41, 'meta_key', 'meta_value');
                //$retour[$device_id]['meta']=$metas;
                $retour[$device_id] = array_merge($row, $metas);
            }
            $i = 0;
            foreach ($retour as $roow) {
                $tab[$i] = array(
                    // Chaque tableau sera converti en objet
                    "device_uuid" => $roow['device_uuid'],
                    "code_activation" => $roow['code_activation'],
                    "webapp_id" => $roow['webapp_id'],
                    "webapp_name" => $roow['webapp_name'],
                    "device" => array('active' => $roow['device_active'], 'id' => $roow['device_id'])
                );
                $i++;
            }
            $result['devices'] = $retour;
            $result['table'] = $tab;
            $result['status'] = 1;
            break;
        case 'activate':
            $device_id = isset($_GET['id']) ? $_GET['id'] : '';
            $sql = "select * from devices where device_id=:device_id";
            $arg =   array(":device_id" => $device_id);
            $retour = $db->getRow($sql, $arg);
            print_r($retour['device_active']);
            if ($retour['device_active'] == "1") {
                $retour = "0";
                $sql = "update devices set device_active=:device_active where device_id=:device_id";
                $arg = array(":device_active" => $retour, ":device_id" => $device_id);
                $retour = $db->dml($sql, $arg);
            } else {
                $retour = "1";
                $sql = "update devices set device_active=:device_active where device_id=:device_id";
                $arg = array(":device_active" => $retour, ":device_id" => $device_id);
                $retour = $db->dml($sql, $arg);
            }
            $result['status'] = $retour;
            $result['msg']='valide';
            break;
    }
}
header('Content-Type: application/json');
echo json_encode($result);
