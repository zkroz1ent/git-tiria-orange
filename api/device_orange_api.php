<?php
//use :
session_start();
require_once('../includes/site.conf.php');
require_once('../includes/variables.php');
require_once('../includes/functions.php');
require_once(LIBRARY_PATH . 'class.new_dbAccess.php');
include'device_orange_meta.php';
//phase de teste pour savoir ce que l'on recois 
$insert_get = isset($_GET['insert_get']) ? $_GET['insert_get'] : '';
$verify_get = isset($_GET['verify_get']) ? $_GET['verify_get'] : '';
$action = '';
if ($insert_get != '') {
    $action = 'insert_get';
} else if ($verify_get != '') {
    $action = 'verify_get';
}
$result = array('status' => 0, 'msg' => _('Une erreur est survenue.'));

$allowIP = array("192.168.0.159", "213.229.108.80", "185.40.100.154", "78.234.92.119", "92.158.170.28", "86.206.137.166", "86.250.183.17"); //serveur de prod, TIRIA IP public, FE corse 
// utiliser pour la cron tab et lancer inactive à la main
function allowUseAPi($hostNameId)
{
    $db = new dbAccess();
    $return = false;
    $referer = isset($_SERVER['SERVER_ADDR']) ? $_SERVER['REMOTE_ADDR'] : '';
    $sql = "SELECT screen_IpPublic from screen_dd where screen_hostname = '$hostNameId' and  screen_active = 1";
    $screen_IpPublic = $db->get1x1($sql, $args);
    if ($referer == $screen_IpPublic) $return = true;
    else $return = false;
    return $return;
}

if ($action != '') {
    $db = new dbAccess();
    switch ($action) {

        case 'verify_get':

            $insert_get = isset($_GET['verify_get']) ? $_GET['verify_get'] : '';
            $insert_get = urldecode($insert_get);
            $insert_get = json_decode($insert_get, 1);
            $insert_get[0] = $insert_get;

            writeLog('device_orange_api.php', 'device_uuid:' . $insert_get[0]['device_uuid'] . ',web_app:' . $insert_get[0]['webapp_id']);
            if ($insert_get != '') {
                if ($insert_get[0]['code_activation'] != '') {
                    $args = array(':device_uuid' => $insert_get[0]['device_uuid'], ':code_activation' => $insert_get[0]['code_activation'], ':webapp_id' => $insert_get[0]['webapp_id']);
                    //api permettant de savoir si Android Id est bien present dans la serveur
                    $sql = "select device_active , COUNT(*) as compteur from devices where device_uuid=:device_uuid and code_activation=:code_activation and webapp_id =(SELECT webapp_id FROM webapps WHERE webapp_id =:webapp_id)";
                    $retour = $db->getRow($sql, $args);


                    $sql = "SELECT TIMESTAMPDIFF(DAY, campaign_start_date , sysdate()) AS day_Start ,
                    TIMESTAMPDIFF(DAY, campaign_end_date , sysdate()) AS day_End
                   
                    , device_id, device_uuid, device_active, code_activation, devices.webapp_id, meta_id, webapp_name, 
                    webapp_link, type_id, client_id, campaign_id, campaign_link, campaign_nbclicks, campaign_start_date, 
                    campaign_end_date, campaign_name 
                    FROM devices , webapps ,campaigns  
                    WHERE devices.webapp_id=webapps.webapp_id and campaigns.webapp_id=webapps.webapp_id and webapps.webapp_id=:webapp_id AND code_activation=:code_activation ORDER BY campaign_start_date DESC ;";
                    $args = array(':code_activation' => $insert_get[0]['code_activation'],':webapp_id' => $insert_get[0]['webapp_id']);
                    $heure = $db->getRow($sql, $args);


                    if ($retour['device_active'] == '0' || $retour['compteur'] == '0') {
                        $result = array('status' => -1, 'msg' => _('ERROR INVALID CODE'));
                        //  print_r($retour);
                    } else  if ($retour['device_active'] == '1' || $retour['compteur'] != '0') {
                        $heure['day_Start'] =   isset($heure['day_Start']) ? $heure['day_Start'] : '';
                        $heure['day_End'] =   isset($heure['day_End']) ? $heure['day_End'] : '';
                       // print_r ($heure) ;
                        if ($heure['day_Start'] > 0 &&  $heure['day_End'] < 0 || $heure['day_Start'] > 0 && $heure['day_End'] == '') {
                            $result = array('status' => 1, 'msg' => _('VALIDATE'));


                            $sql = 'SELECT  sysdate() as lastUpdate ,device_id from devices where device_uuid=:device_uuid ';

                            $args = array(':device_uuid'=> $insert_get[0]['device_uuid']);
                            $meta = $db->getRow($sql, $args);

                            device_orange_meta($meta,$insert_get[0]);


                         










                        } else 
                         if ($heure['day_Start'] > 0 &&  $heure['day_End'] > 0 )
                        {
                            $result = array('status' => 1, 'msg' => _('Campaign_Stat'), 'TIME_END' => _( $heure['day_End'] ));
                        }
                        if ($heure['day_Start'] < 0 ){
                            $result = array('status' => 1, 'msg' => _('Campaign_Stat'), 'TIME_START' => _( $heure['day_Start'] ));
                        }

                    }
                } else {
                    $result = array('status' => -2, 'msg' => _('Code non recus'));
                }
            }
            break;


        case 'insert_get':

            $insert_get = isset($_GET['insert_get']) ? $_GET['insert_get'] : '';
            $insert_get = urldecode($insert_get);
            // {"device_uuid":"fa78aac60a04e996","code_activation":"5556566","webapp_id":"19"}
            $insert_get = json_decode($insert_get, 1);
            $insert_get[0] = $insert_get;
            writeLog('device_orange_api.php', 'device_uuid:' . $insert_get[0]['device_uuid'] . ',web_app:' . $insert_get[0]['webapp_id']);
            if ($insert_get[0] != '') {
                if ($insert_get[0]['code_activation'] != '') {
                    $args = array(':code_activation' => $insert_get[0]['code_activation'], ':webapp_id' => $insert_get[0]['webapp_id']);
                    //verifie si le code_d'activation est deja attribué 
                    $sql = "SELECT COUNT(*) as compteur FROM `devices` where code_activation =:code_activation and device_uuid ='' and webapp_id =(SELECT webapp_id FROM webapps WHERE webapp_id =:webapp_id) ";
                    $retour = $db->getRow($sql, $args);








                    if ($retour['compteur'] == 0) {
                        //si retour compteur = 0 alors ERROR Code deja validé
                        $result = array('status' => -1, 'msg' => _('ERROR INVALID CODE'));
                        break;
                    } 





                    
                    


                    $args = array(':device_uuid' => $insert_get[0]['device_uuid'], ':code_activation' => $insert_get[0]['code_activation']);
                    //permet de valider le code de validation en mettant a jour le device de l'appareil envoye dans l'api et en mettant egalement a jour le device active en le passant a  1
                    $sql = "update devices set device_uuid=:device_uuid ,device_active=1 WHERE code_activation=:code_activation";
                    $retour = $db->getRow($sql, $args);
                }
                $result = array('status' => -2, 'msg' => _('AVOID CODE'));
            } else {
                $result = array('status' => -2, 'msg' => _('RIEN RECUS'));
            }
            break;
        default:
            break;
    }
}
echo json_encode($result);



/*requette pour calculer si une campagne a commencé
SELECT TIMESTAMPDIFF(DAY, campaign_start_date , sysdate()) AS jour 
,TIMESTAMPDIFF(hour, campaign_start_date , sysdate()) AS heure 
, device_id, device_uuid, device_active, code_activation, devices.webapp_id, meta_id, webapp_name,
 webapp_link, type_id, client_id, campaign_id, campaign_link, campaign_nbclicks, campaign_start_date,
  campaign_end_date, campaign_name FROM devices , webapps ,campaigns 
  WHERE devices.webapp_id=webapps.webapp_id and campaigns.webapp_id=webapps.webapp_id
  */