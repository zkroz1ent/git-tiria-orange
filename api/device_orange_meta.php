<?php




function device_orange_meta($meta_id,$meta_keys){
    $meta_keys['lastUpdate']=$meta_id['lastUpdate'];
   $db = new dbAccess();

   $i=0;
   foreach ($meta_keys as $meta_key =>$key){
  
    

       
    
    if($meta_key=='num_rue'&& $key=='' ||$meta_key=='rue'&& $key==''||$meta_key=='departement'&& $key==''||$meta_key=='code_activation'&& $key=='' ||$meta_key=='ville'&& $key==''||$meta_key=='device_uuid'&& $key==''){


        $i=1;
    }
   }

if($i==0){
foreach ($meta_keys as $meta_key =>$key){
    
$args = array(':device_id' => $meta_id['device_id'], ':meta_key' => $meta_key,':meta_value'=>$key);
$sql="  INSERT INTO `devices_meta`(`device_id`, `meta_key`, `meta_value`) VALUES (:device_id ,:meta_key ,:meta_value)";
$retour = $db->getRow($sql, $args);





}
}

}








?>