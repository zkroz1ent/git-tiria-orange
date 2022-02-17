<?php
enqueueJS('bootstrap_switch');
enqueueJS('jquery_ui');
enqueueJS('jquery_dotimeout');
enqueueJS('jquery_passy');
enqueueJS('jquery_uniform');
enqueueJS('jquery_formatter');
enqueueJS('jquery_selectbox');
enqueueJS('jquery_datatables');

$user->loadMeta();

global $db;
$sql = "select count(*) as compteur from devices WHERE device_uuid not LIKE '' ";
$compteur = $db->getRow($sql);

$arg41 = array(':device_id' => $row['device_id']);
$sql41 = "SELECT meta_value FROM `devices_meta`where device_id=:device_id ORDER BY `meta_id` DESC LIMIT 9";

