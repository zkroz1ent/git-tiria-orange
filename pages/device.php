<!-- Individual column searching (selects) -->
<div class="content">
    <!-- header_page start -->
    <div class="panel panel-flat ">
        <div class="panel-body ">
            <div class="btn-group">
                <a href="tests" class="btn border-slate  btn-flat text-grey"><i class="icon-hour-glass"></i>code valable</a>
                <a href="tes" class="btn border-slate  btn-flat text-grey"> <i class="icon-hammer-wrench"></i>genenerer des codes</a>
            </div>
        </div>
    </div>
    <!-- /header_page end -->
    <!-- List of users start-->
    <div class="panel panel-flat ">
        <div class="panel-heading ">
            <h5 class="panel-title ">
                <p><?php echo $compteur['compteur'] ?> appareil(s)</p>
            </h5>
        </div>
    </div>
   
    <!-- /Gains_form end -->
   
    <div class="panel panel-default ">
        <div class="panel-heading ">
            <h5 class="panel-title ">Affichage des appareils</h5>
        </div>
        <table id="tblEmployee2" class="table datatable-column-search-selects ">
            <thead>
                <tr>
                    <th>device_uuid</th>
                    <th>code_activation</th>
                    <th>WebAPP_id</th>
                    <th>WebAPP_name</th>
                    <th>État</th>
                    <th>Info +</th>
                </tr>
            </thead>
        </table>
    </div>

    <div class="modal fade " id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog " role="document">
            <div class="modal-content">
                <div class="modal-header bg-grey-800">
                    <h5 class="modal-title" id="exampleModalLabel">New message</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>

                </div>
                <div class="modal-body bg-grey-400">
                    <form>
                        <div class="num_rue">
                            <label for="recipient-name" class="col-form-label">num_rue:</label>
                            <input type="text" class="form-control" id="num_rue-name" disabled>
                        </div>
                        <div class="rue">
                            <label for="recipient-name" class="col-form-label">rue:</label>
                            <input type="text" class="form-control" id="rue-name" disabled>
                        </div>

                        <div class="ville">
                            <label for="recipient-name" class="col-form-label">ville:</label>
                            <input type="text" class="form-control" id="ville-name" disabled>
                        </div>
                        <div class="departement">
                            <label for="recipient-name" class="col-form-label">departement:</label>
                            <input type="text" class="form-control" id="departement-name" disabled>
                        </div>
                        <div class="localisation">
                            <label for="recipient-name" class="col-form-label">localisation:</label>
                            <input type="text" class="form-control" id="localisation-name" disabled>
                        </div>
                    </form>
                </div>
                <div class="modal-footer bg-grey-800">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>

                </div>
            </div>
        </div>
    </div>