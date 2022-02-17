<!-- Individual column searching (selects) -->
<div class="content">
    <!-- header_page start -->
    <div class="panel panel-flat ">
        <div class="panel-body ">
            <div class="btn-group">
            <a href="device" class="btn border-slate  btn-flat text-grey" ><i class="icon-reply-all"></i>retour</a>
                <a href="tes" class="btn border-slate  btn-flat text-grey"> <i class="icon-hammer-wrench"></i>genenerer des codes</a> 
            </div>
            <label class="text-semibold"><?php echo $textSuccess; ?></label>
            <input type="hidden" value="<?php echo $opt; ?>" name="campaignsCondition" id="campaignsCondition">
        </div>
    </div>
    <!-- /header_page end -->
    <!-- List of users start-->
    <div class="panel panel-flat ">

        <div class="panel-heading ">
            <h5 class="panel-title">
                <p><?php echo count($retour) ?> code(s) disponible</p>
            </h5>
            <div class="heading-elements ">
            </div>
        </div>
        <div class="panel-body">
            <h1>Affichage des codes disponibles</h1>
          
                <div class="table-responsive  ">
             
         
            <table class="table datatable datatable-column-search-selects  dataTable no-footer" id="codes_disponibles">
                <thead>
                    <tr>
                        <th>id web apps</th>
                        <th>code_activation</th>
                        <th>name web apps</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $rows = $retour;
                    foreach ($rows as $row) {
                        //
                        echo '<tr><td>' . $row['webappID'] . '</td><td>' . $row['code_activation'] . '</td><td>' . $row['webapp_name'] . '</td> </tr>';
                    }
                    ?>
                </tbody>
                <tfoot>
                </tfoot>
            </table>
        </div>
    </div>
</div>
<!--Liste of users end-->
<!-- list contacts choices -->
</div>
<!-- /Gains_form end -->