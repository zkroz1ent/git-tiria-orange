<!-- Individual column searching (selects) -->
<div class="content">
    <!-- header_page start -->
    <div class="panel panel-flat ">
        <div class="panel-body ">
            <div class="btn-group">
            <a href="device" class="btn border-slate  btn-flat text-grey" ><i class="icon-reply-all"></i>retour</a>
            <a href="tests" class="btn border-slate  btn-flat text-grey" ><i class="icon-hour-glass"></i>code valable</a>
            </div>
            <label class="text-semibold"><?php echo $textSuccess; ?></label>
            <input type="hidden" value="<?php echo $opt; ?>" name="campaignsCondition" id="campaignsCondition">
        </div>
    </div>
    <!-- /header_page end -->
    <!-- List of users start-->
    <div class="panel panel-flat ">
        <div class="panel-heading ">
            <h5 class="panel-title ">
                <p><?php echo $compteur['compteur'] ?> WEB_APP(S) disponible</p>
            </h5>
            <div class="heading-elements">
                </thead>
            </div>
        </div>
    </div>
    <div class="panel panel-flat ">

        <div class="panel-body ">
            <div class="d-block form-text  text-center ">
                <h1>Generateur de code pour application</h1>
            </div>
            <tbody>
                <div class="d-block form-text text-center ">
                    <form action="tes" method="post">
                        <p> <label for="webaps">webaps</label></p>
                        <select class="selectboxit selectbox border-lg border-slate selectboxit-enabled selectboxit-btn" name="webapps" id="webapps">
                            <?php
                            $rows = $retour;
                            foreach ($rows as $row) {
                                echo  '  <option value="' . $row['webapp_id'] . '">' . $row['webapp_name'] . '</option>';
                            }
                            ?>
                        </select>



                </div>
        </div>
    </div>
    </tbody>
    <tfoot>
        <div class="panel-footer ">
            <div class="d-block form-text text-center ">
                <div class="panel panel-flat  ">


                    <div class="form-group ">

                        <label for="number" class="label-flat">Saisir le nombre de code </label><br>
                        <input type="number" value="" id="number" name="number" class="border-slate">
                    </div>

                </div>

            </div>
            <div class="d-block form-text text-center">
                <input class="btn border-slate  btn-flat text-grey" type="submit" name="submit" value="Envoyer" />&nbsp;<input class='btn border-slate  btn-flat text-grey' type="reset" value="Réinitialiser" />
            </div>
        </div>
        </form>
    </tfoot>


</div>

<!--Liste of users end-->
<!-- list contacts choices -->
<!-- /Gains_form end -->