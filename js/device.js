var devices = {};
$(function () {
	$('.datatable1 ').DataTable();
});
$(document).ready(function () {
	dtDevices = $('#tblEmployee2').DataTable({
		language: globaltranslation.datatables,
		// dom:'<"datatable-header"<"datatable-toolbar"l>><"datatable-scroll"t><"datatable-footer"ip>',
		dom: '<"datatable-header"<"datatable-toolbar"f>><"datatable-scroll"t><"datatable-footer"ip>',
		//responsive:true,
		stateSave: false,
		autoWidth: false,
		pageLength: 100,
		ajax: {
			url: SCRIPT_URL + 'device.php?action=getDevices',
			type: 'POST',
			dataSrc: function (result) {		
				if (result.status) {
					devices = result.devices;
					dtDevices.ajax.reload()
					return result.table;
				}	
				return [];	
			},
			error: function (a, b, c) {
				//xhrError(a,b,c);
			}
		},
		columnDefs: [
			//{targets:'.masked',visible:false},
			{ targets: '_all', searchable: true, orderable: true },
			{ targets: [-1], searchable: false, orderable: false }
		],
		columns: [
			{ data: "device_uuid" },
			{ data: "code_activation" },
			{ data: "webapp_id" },
			{ data: "webapp_name" },
			{
				data: "device", render: function (d) {			
					var tmp = '<button type="button" class="btn ' + (d.active =='1'  ? 'btn-success' : 'btn-danger') + ' activate" data-did="' + d.id + '">' + (d.active =='1'  ? 'actif' : 'inactif') + '</button>';
					return tmp;		
				}
			},
			{
				data: "device", render: function (d) {
					var tmp = '<button type="button" class="btn btn-default device_detail" data-did="' + d.id + '"><i class="icon-eye"></i></button>';
					return tmp;
				}
			}
		],
		initComplete: function () {
		},
		drawCallback: function () {
			//if(typeof dtPosts!='undefined') dtPosts.responsive.recalc();
		},
	});
	$('#tblEmployee2').on('click', '.activate', function () {
	
		var device_id = $(this).data('did');
		$.ajax({
			url: SCRIPT_URL + 'device.php?action=activate&id=' + device_id,
			type: 'GET',
			dataType: 'json',
			success: function (result) {
				dtDevices.ajax.reload() // user paging is not reset on reload
			},
			error: function (a, b, c) {
			}
		})
	});
	$('#tblEmployee2').on('click', '.device_detail', function () {
		var device_id = $(this).data('did');
		var device_detail = devices[device_id];
		$('#num_rue-name').val(device_detail.num_rue);
		$('#rue-name').val(device_detail.rue);
		$('#ville-name').val(device_detail.ville);
		$('#departement-name').val(device_detail.departement);
		$('#localisation-name').val(device_detail.localisation);
		$('#exampleModal').modal('show');
	});
});
