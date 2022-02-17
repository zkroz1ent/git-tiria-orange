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





    //affiche tout les jeux avec code_activation 
   





    //affiche tout les jeux avec code_activation 
    $sql = "SELECT webapps.webapp_id as webappID ,webapp_name ,code_activation ,device_id ,device_uuid FROM webapps ,devices where webapps.webapp_id=devices.webapp_id  AND device_uuid LIKE ''";
    $retour = $db->getArray($sql);
    //affiche tout les jeux avec code_activation mais grouo by pour le select et option
    $sql = "SELECT webapps.webapp_id as webappID ,webapp_name ,code_activation ,device_id ,device_uuid FROM webapps ,devices where webapps.webapp_id=devices.webapp_id  AND device_uuid LIKE ''  GROUP BY webapp_name ";
    $retour1 = $db->getArray($sql);

   
json_encode($retour);
json_encode($retour1);
?>


    <?php
    //permet de savoir et definir une limite d'affichage 
    $arg = array(':webapp_id' => $webapp_id);

    $sql = "SELECT COUNT(*) as compteur FROM webapps ,devices where webapps.webapp_id=devices.webapp_id  AND device_uuid LIKE '' ";
    if ($webapp_id != 'tous') {
        $arg = array(':webapp_id' => $webapp_id);
        $sql .= "and devices.webapp_id =:webapp_id ";
    }
    $compteur = $db->getRow($sql, $arg);


    $sql1 = "SELECT COUNT( DISTINCT devices.webapp_id) as compteur  FROM webapps ,devices where webapps.webapp_id=devices.webapp_id  AND device_uuid LIKE ''";
    if ($webapp_id != 'tous') {
        $sql .= " GROUP BY webapp_name";
    }
    $compteur1 = $db->getRow($sql1);




    ?>

