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

///////////////////////////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarRecordatorios();
    btnModificarRecordatorio.disabled=true;
})
///////////////////////////////////////////////////////////////////////////////////////////////
const btnModalRecordatorio=document.querySelector('#btn-modal-recordatorio');
btnModalRecordatorio.addEventListener('click',cleanData);

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////////////////////////

async function listarRecordatorios(){
    try {
        const response = await fetch('/listar_recordatorio/');
        const result = await response.json();
        let resultado = result.recordatorios;
        if ($.fn.DataTable.isDataTable('#dataTable-recordatorios')) {
            $('#dataTable-recordatorios').DataTable().destroy();
        }
        $('#dataTable-recordatorios tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i][0] + `</td>`;
            fila += `<td>` + resultado[i][1] + `</td>`;
            fila += `<td>` + resultado[i][2] + `</td>`;
            fila += `<td>` + resultado[i][3] + `</td>`;
            fila += `<td>` + resultado[i][4] + `</td>`;
            if (resultado[i][5]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Realizado</span></td>`;
            } 
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal"
                                    onclick="cargarDatos(
                                        ${resultado[i][0]},'${resultado[i][1]}',
                                        '${resultado[i][3]}','${resultado[i][4]}',
                                        ${resultado[i][6]},${resultado[i][7]},${resultado[i][8]}
                                    )">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarRecordatorio(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-recordatorios tbody').append(fila);
        }
        $('#dataTable-recordatorios').DataTable({
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
///////////////////////////////////////////////////////////////////////////////////////////////
var id_mascota=0;
const btnBuscarMascotaRecordatorio=document.querySelector('#btn-buscar-mascota-recordatorio')
btnBuscarMascotaRecordatorio.addEventListener('click',buscarMascota)
async function buscarMascota(){
    try {
        const numeroHistoria=document.querySelector('#id_numero_historia');
        if (numeroHistoria.value!=''){
            const response = await fetch("/buscar_mascota/"+numeroHistoria.value+"/");
            const result = await response.json();
            const {status} = result;
            if(status){
                let resultado = JSON.parse(result.mascota);
                document.querySelector("#nombre_mascota_id").value=resultado[0].fields.nombre;
                id_mascota = resultado[0].pk;
                const resultServices=JSON.parse(result.servicios)
                let slctServicio= document.querySelector('#id_servicio_id');
                slctServicio.innerHTML='';
                slctServicio.innerHTML+=`<option value='' selected>---------</option>`;   
                for (i = 0; i < resultServices.length; i++) {
                    slctServicio.innerHTML+=`<option value=${resultServices[i].pk}>${resultServices[i].fields.descripcion}</option>`;   
                }

            }else{
                const {mensaje}=result;
                imprimirMessage('Sistema',mensaje,'info');
            }
        }else{
            imprimirMessage('Sistema','Ingrese un número de historia a buscar','info');
        }
        
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
const btnGuardarRecordatorio=document.querySelector('#btn-guardar-recordatorio');
btnGuardarRecordatorio.addEventListener('click', guardarRecordatorio);

async function guardarRecordatorio(){
    try {
        const form = new FormData(document.querySelector('#form-recordatorio'));
        if (id_mascota != 0) {
            if (form.get('numero_historia')!=''&&form.get('id_servicio')!=''&&form.get('fecha')!='') {
                form.append('usuario',document.querySelector('#id_user').textContent);
                form.append('estado',true);
                form.append('id_empresa',document.querySelector('#id_empresa').textContent);
                form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
                form.append('id_mascota',id_mascota);
                const response = await fetch('/recordatorio/',{
                    method:'POST',
                    body:form,
                    headers:{"X-CSRFToken":getCookie('csrftoken')}
                });
                const result = await response.json();
                const {status}=result;
                const {mensaje}=result;
                if (status){
                    listarRecordatorios();
                    imprimirMessage('Éxito',mensaje,'success');
                    cleanData();
                }else{
                    const {error}=result;
                    contentError.innerHTML='';        
                    Object.entries(error).forEach(([key, value]) => {
                        contentError.innerHTML+=`<p> -> ${value}</p>`
                    });
                    imprimirMessage('Sistema',mensaje,'info');
                }
            } else {
                imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
                document.querySelector('#form-recordatorio').classList.add('was-validated');
            }
        } else {
            imprimirMessage('Sistema','Error al obtener código de mascota','Error')
        }

        
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
var id_recordatorio_g=0;
async function cargarDatos(id_recordatorio,mascota,fecha,comentario,numero_historia,id_servicio,id_mascota){
    document.querySelector('#form-recordatorio').classList.remove('was-validated');
    contentError.innerHTML='';
    btnGuardarRecordatorio.disabled=true;
    btnModificarRecordatorio.disabled=false;
    id_recordatorio_g=id_recordatorio;
    document.querySelector('#id_numero_historia').value=numero_historia;
    document.querySelector('#fecha_id').value=fecha;
    document.querySelector('#id_comentario').value=comentario;
    await buscarMascota();
    //document.querySelector('#nombre_mascota_id').value=mascota;
    let cboServicio=document.querySelector('#id_servicio_id');
    cboServicio.value=id_servicio;
    id_mascota=id_mascota;

}

///////////////////////////////////////////////////////////////////////////
const btnModificarRecordatorio=document.querySelector('#btn-modificar-recordatorio');
btnModificarRecordatorio.addEventListener('click',modificarRecordatorio);
async function modificarRecordatorio(){
    try {
        
        const form = new FormData(document.querySelector('#form-recordatorio'));
        if (form.get('numero_historia')!=''&&form.get('id_servicio')!=''&&form.get('fecha')!='') {
            form.append('usuario',document.querySelector('#id_user').textContent);
            form.append('estado',true);
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            form.append('id_mascota',id_mascota);
            const response = await fetch('/modificar_recordatorio/'+id_recordatorio_g+'/',{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const {status}=result;
            const {mensaje}=result;
            if (status){
                listarRecordatorios();
                imprimirMessage('Éxito',mensaje,'success');
                cleanData();
            }else{
                imprimirMessage('Sistema',mensaje,'info');
            }
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para modificar','info')
            document.querySelector('#form-recordatorio').classList.add('was-validated');
        }

    } catch (error) {
        console.log(error);
    }
} 
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    document.querySelector('#form-recordatorio').classList.remove('was-validated');
    contentError.innerHTML='';
    btnGuardarRecordatorio.disabled=false;
    btnModificarRecordatorio.disabled=true;
    id_recordatorio_g=0;
    document.querySelector('#id_numero_historia').value='';
    id_mascota=0
    
    document.querySelector('#nombre_mascota_id').value='';
    document.querySelector('#fecha_id').value='';
    document.querySelector('#id_comentario').value='';
    document.querySelector('#id_servicio_id').innerHTML=`<option value>------------</option>`;
}
///////////////////////////////////////////////////////////////////////////

function eliminarRecordatorio(id) {

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
        const response = await fetch("/eliminar_recordatorio/"+id+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarRecordatorios();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar recordatorio","error");
    }
}

///////////////////////////////////////////////////////////////////////////
function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}