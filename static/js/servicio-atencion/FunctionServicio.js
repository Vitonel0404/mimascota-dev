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
const btnRegistarServicio=document.querySelector('#btn-guardar-servicio');
const btnModificarServicio=document.querySelector('#btn-modificar-servicio')

var inpDescripcionServicio=document.querySelector('#id_descripcion');
var cboAnimal=document.querySelector('#id_animal');
var inpPrecio=document.querySelector('#id_precio');


let contentError=document.querySelector('.content-errors');

///////////////////////////////////////////////////////////////////////////


$(document).ready(function(){
    btnModificarServicio.disabled=true;
    listarServicios();
})
///////////////////////////////////////////////////////////////////////////
const btnModalServicio=document.querySelector('#btn-modal-servicio');
btnModalServicio.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////

async function listarServicios(){
    try {
        const response= await fetch('/listar_servicio/');
        const result = await response.json();
        let resultado = result.servicios;
        console.log(resultado)
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i][1] + `</td>`;
            (resultado[i][2]!=null)?fila += `<td>` + resultado[i][2] + `</td>`:fila += `<td>General</td>`;
            fila += `<td>` + resultado[i][3] + `</td>`;
            if (resultado[i][4]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            } 
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos('${resultado[i][0]}','${resultado[i][1]}',
                                                                                                        ${resultado[i][5]},${resultado[i][3]},
                                                                                                         ${resultado[i][4]})">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarServicio('${resultado[i][0]}')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable tbody').append(fila);
        }
        $('#dataTable').DataTable({
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
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////


btnRegistarServicio.addEventListener('click',registrarServicio);

async function registrarServicio(){
    try {
        const form = new FormData(document.querySelector('#form-servicio'));
        form.set('descripcion',form.get('descripcion').trim());
        form.set('precio',form.get('precio').trim());
        if (form.get('id_animal')!=''&&form.get('descripcion')!=''&&form.get('precio')!=''){
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch('/servicio/',{
                method: 'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken'),}
            });
            const result = await response.json();
            const {status} = result;
            const {mensaje}=result;
            if (status){
                imprimirMessage('Éxito',mensaje,'success');
                listarServicios();
                cleanData();
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info');
            }
        }else{
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info');
            document.querySelector('#form-servicio').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
    }
}

///////////////////////////////////////////////////////////////////////////

var id_g=0;
function cargarDatos(id, descripcion, id_animal, precio,estado){
    document.querySelector('#form-servicio').classList.remove('was-validated');
    contentError.innerHTML='';
    id_g=id;
    inpDescripcionServicio.value=descripcion;
    cboAnimal.value=id_animal;
    inpPrecio.value=precio;
    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnRegistarServicio.disabled=true;
    btnModificarServicio.disabled=false;

}

///////////////////////////////////////////////////////////////////////////
btnModificarServicio.addEventListener('click',modificarServicio);
async function modificarServicio(){
    try {
        const form = new FormData(document.querySelector('#form-servicio'));
        if (form.get('id_animal')!=''&&form.get('descripcion')!=''&&form.get('precio')!=''){
            form.set('descripcion',form.get('descripcion').trim());
            form.set('precio',form.get('precio').trim());
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch('/modificar_servicio/'+id_g+'/',{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const {status} =result;
            const {mensaje}=result;
            if (status){
                imprimirMessage("Éxito", mensaje, "success");
                listarServicios();
                cleanData();
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage("Sistema", mensaje, "info");
            }
        }else{
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info');
            document.querySelector('#form-servicio').classList.add('was-validated');
        }
        
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

function eliminarServicio(id) {

    Swal.fire({
        "title": "¿Estás seguro?",
        "text": "Esta acción no se puede revertir",
        "icon": "question",
        "showCancelButton": true,
        "cancelButtonText": "No, cancelar",
        "confirmButtonText": "Sí, eliminar",
        "confirmButtonColor": "#dc3545"
    })
        .then(function (result) {
            if (result.isConfirmed) {
                confirmarEliminar(id);
            }
        })
}

async function confirmarEliminar(id){
    try {
        const response = await fetch('/eliminar_servicio/'+id+'/');
        const result = await response.json();
        const {status} = result;
        if(status){
            const {mensaje} = result;
            imprimirMessage('Éxito', mensaje,'success');
            listarServicios();
        }
        
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al eliminar mascota","error");
    }
}



///////////////////////////////////////////////////////////////////////////

function cleanData(){
    document.querySelector('#form-servicio').classList.remove('was-validated');
    contentError.innerHTML='';
    inpDescripcionServicio.value='';
    cboAnimal.value='';
    inpPrecio.value='';
    id_g=0;
    btnModificarServicio.disabled=true;
    btnRegistarServicio.disabled=false;
    $("#id_estado").prop('checked', true);
}

///////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}