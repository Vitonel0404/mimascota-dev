function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
///////////////////////////////////////////////////////////////////////////

const btn_a=document.querySelector('#id_report');
btn_a.addEventListener('click',validatedSendData)
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarVentas();
});
///////////////////////////////////////////////////////////////////////////////////////////

async function listarVentas(){
    try {
        const response = await fetch('/ventas/listar_ventas/');
        const result = await response.json();
        console.log(result)
        let resultado=result.ventas;
        if ($.fn.DataTable.isDataTable('#dataTable-venta')) {
            $('#dataTable-venta').DataTable().destroy();
        }
        $('#dataTable-venta tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>${resultado[i][1]}</td>`;
            fila += `<td>${resultado[i][2]}</td>`;
            fila += `<td>${resultado[i][3]}</td>`;
            fila += `<td>${resultado[i][4]}</td>`;
            fila += `<td>${resultado[i][5]}</td>`;
            fila += `<td>${resultado[i][6]}</td>`;
            if(resultado[i][7]==1){
                fila += `<td><span class="badge bg-success">Realizada</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Anulada</span></td>`;
            }
            
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="verDetalle(${resultado[i][0]})">
                                        <i class="bi bi-arrow-up-right-square"></i>
                                    </a>
                                                                 
                                </div>
                                <div class="form-group col-sm-4">
                                    
                                    <a class="btn-anular" onclick="anularVenta(${resultado[i][0]})">
                                        <i class="bi bi-dash-circle"></i>
                                    </a>
                                                                 
                                </div>
                                <div class="form-group col-sm-4">
                                    <a  class="btn-eliminar" onclick="eliminarVenta(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-venta tbody').append(fila);
        }
        $('#dataTable-venta').DataTable({
            language: {
                decimal: "",
                emptyTable: "No hay información",
                info: "Mostrando _START_ a _END_ de _TOTAL_ Entradas",
                infoEmpty: "Mostrando 0 to 0 of 0 Entradas",
                infoFiltered: "(Filtrado de _MAX_ total entradas)",
                infoPostFix: "",
                thousands: ",",
                lengthMenu: "Mostrar _MENU_ Entradas",
                loadingRecords: "Cargando...",
                processing: "Procesando...",
                search: "Buscar:",
                zeroRecords: "Sin resultados encontrados",
                paginate: {
                    first: "Primero",
                    last: "Ultimo",
                    next: "Siguiente",
                    previous: "Anterior",
                },
            },
            lengthMenu: [5, 10, 20],
        })
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////
function eliminarVenta(id_venta){
        
    Swal.fire({
        "title":"¿Estás seguro?",
        "text":"Esta acción no se puede revertir. Se eliminarán los detalles de esta venta",
        "icon":"question",
        "showCancelButton":true,
        "cancelButtonText":"No, cancelar",
        "confirmButtonText":"Sí, eliminar",
        "confirmButtonColor":"#dc3545"
    })
    .then(function(result){
        if(result.isConfirmed){
            confirmarEliminar(id_venta);
        }
    })
}
async function confirmarEliminar(id_venta){
    try {
        const response = await fetch("/ventas/eliminar_venta/"+id_venta+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarVentas();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar venta","error");
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////

async function verDetalle(id_venta){
    try {
        const response = await fetch('/ventas/buscar_detalle_venta/'+id_venta+'/');
        const result = await response.json()
        const {status}= result;
        if (status) {
            document.querySelector('#span_numero_venta').textContent=id_venta;
            let resultado = result.detalle;
            $('#table-detalle-venta tbody').html("");
            for (let i = 0; i < resultado.length; i++) {
                let fila = `<tr class="text-center">`;
                fila += `<td>` + parseInt(i+1) + `</td>`;
                fila += `<td>` + resultado[i][1] + `</td>`;
                fila += `<td>` + resultado[i][2] + `</td>`;
                fila += `<td>` + resultado[i][3] + `</td>`;
                fila += `<td>` + resultado[i][4] + `</td>`;
                fila += `</tr>`;
                $('#table-detalle-venta tbody').append(fila);
            }
        }
        
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////
function anularVenta(id_venta){
    Swal.fire({
        "title":"¿Estás seguro?",
        "text":'Esta acción no se puede revertir. Escriba el motivo de anulación',
        'input': 'text',
        'inputPlaceholder': 'Escribe aquí',
        "icon":"question",
        "showCancelButton":true,
        "cancelButtonText":"No, cancelar",
        "confirmButtonText":"Sí, anular",
        "confirmButtonColor":"#dc3545",
        

    })
    .then(function(result){
        if(result.isConfirmed && result.value.trim()!=''){
            console.log(result.value)
            confirmarAnular(id_venta, result.value.trim());
        }else{
            imprimirMessage('Ops', 'Complete el campo requerido','info');
        }
    })
}
async function confirmarAnular(id_venta,motivo){
    try {
        const form = new FormData();
        form.append('id_venta',id_venta);
        form.append('motivo_anulacion',motivo);
        form.append('id_usuario_anulador',(document.querySelector('#id_user').textContent).trim());
        const response = await fetch("/ventas/anular_venta/",{
            method:'POST',
            body:form,
            headers:{"X-CSRFToken":getCookie('csrftoken')}
        });
        const result = await response.json();
        const {status}=result;
        const{mensaje}=result;
        if (status){
            listarVentas();
            imprimirMessage("Éxito",mensaje,"success");
        }else{
            imprimirMessage("Sistema",mensaje,"info");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al anular venta","error");
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////
function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}
///////////////////////////////////////////////////////////////////////////////////////////////

function validatedSendData(){
    const form = new FormData(document.querySelector('#form-reporte'));
    let ab=document.querySelector('#id_report');
    if (form.get('fecha_inicio')!='' && form.get('fecha_fin')!='') {
        ab.setAttribute("href",`/ventas/export_ventas_pdf/${form.get('fecha_inicio')}/${form.get('fecha_fin')}/`);
        document.querySelector('#form-reporte').reset();
        document.querySelector('#form-reporte').classList.remove('was-validated');
    }else{
        ab.removeAttribute("href");
        document.querySelector('#form-reporte').classList.add('was-validated');
    }
}
