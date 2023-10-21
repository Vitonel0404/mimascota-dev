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
const btnModalAñadirUsuario=document.querySelector('#btn-modal-usuario');
btnModalAñadirUsuario.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
const btnRegistarUsuario=document.querySelector('#btn-guardar-usuario');
const btnModificarUsuario=document.querySelector('#btn-modificar-usuario');

let contentErrorUpdate=document.querySelector('.content-errors-update');
let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarUsuarios();
    listarPermisos();
});
///////////////////////////////////////////////////////////////////////////
async function listarUsuarios(){
    try {
        const response = await fetch('/usuarios/listar_usuario/');
        const result = await response.json();
        let resultado = result.usuarios;
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            
            fila += `<td>` + resultado[i][1] + `</td>`;
            fila += `<td>` + resultado[i][2]+' '+resultado[i][3] + `</td>`;
            fila += `<td>` + resultado[i][4] + `</td>`;
            if (resultado[i][5]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            } 
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#update" 
                                        onclick="cargarDatos(${resultado[i][0]},'${resultado[i][1]}','${resultado[i][2]}','${resultado[i][3]}',
                                                            '${resultado[i][4]}',${resultado[i][5]},${resultado[i][6]})">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarUsuario(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" data-bs-toggle="modal" data-bs-target="#staticBackdrop" onclick="cargarPermisos(${resultado[i][0]})">
                                    <i class="bi bi-shield-lock"></i>
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
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////
const btnGuardarUsuario=document.querySelector('#btn-guardar-usuario');
btnGuardarUsuario.addEventListener('click', registrarUsuario);
async function registrarUsuario(){
    const form = new FormData(document.querySelector('#form-usuario'));
    try {
        if (form.get('first_name')!=''&&form.get('last_name')!=''&&form.get('email')!=''&&form.get('username')!=''
        &&form.get('password1')!=''&&form.get('password2')!='' &&form.get('id_sucursal')!=''
        ) {
            const response = await fetch('/usuarios/usuario/',{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const { status } = result;
            const { mensaje } = result;
            if (status) {
                imprimirMessage('Éxito', mensaje, 'success');
                listarUsuarios();
                cleanData();
            }else{
                const {error} = result;
                contentError.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info');
                
            }
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info');
            document.querySelector('#form-usuario').classList.add('was-validated');
        }
        
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

var id_g=0;
function cargarDatos(id, usuario,nombres, apellidos, email,estado,id_sucursal){
    id_g=id;
    document.querySelector('#form-usuario').classList.remove('was-validated');
    document.querySelector('#form-usuario-update').classList.remove('was-validated');
    contentError.innerHTML='';
    contentErrorUpdate.innerHTML='';
    document.querySelector('#id_first_name_update').value=nombres;
    document.querySelector('#id_last_name_update').value=apellidos;
    document.querySelector('#id_email_update').value=email;
    document.querySelector('#id_sucursal_update').value=id_sucursal;
    if(estado) {
        $("#id_is_active_update").prop('checked', true);
    }else{
        $("#id_is_active_update").prop('checked', false);
    }
}
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
btnModificarUsuario.addEventListener('click',modificarUsuario);
async function modificarUsuario(){
    try {
        const form = new FormData(document.querySelector('#form-usuario-update'));
        if (form.get('first_name')!=''&&form.get('last_name')!=''&&form.get('email')!='' &&form.get('id_sucursal')!='') {
            const response = await fetch('/usuarios/modificar_usuario/' + id_g + '/', {
                method: 'POST',
                body: form,
                headers: {"X-CSRFToken": getCookie('csrftoken')}
            });
            const result = await response.json();
            const { status } = result;
            const { mensaje } = result;
            if (status) {
                imprimirMessage("Éxito", mensaje, "success");
                listarUsuarios();
                cleanData()

            } else {
                const {error} = result;
                contentErrorUpdate.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentErrorUpdate.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage("Sistema", mensaje, "info");
            }
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info');
            document.querySelector('#form-usuario-update').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

function cleanData(){
    id_g=0;
    document.querySelector('#form-usuario').classList.remove('was-validated');
    document.querySelector('#form-usuario-update').classList.remove('was-validated');
    contentError.innerHTML='';
    contentErrorUpdate.innerHTML='';
    document.querySelector('#id_first_name').value='';
    document.querySelector('#id_last_name').value='';
    document.querySelector('#id_username').value='';
    document.querySelector('#id_email').value='';
    document.querySelector('#password1').value='';
    document.querySelector('#password2').value='';
    document.querySelector('#id_sucursal_id').value='';
    document.querySelector('#form-usuario-update').reset();
    $("#id_is_active").prop('checked', true);

}
///////////////////////////////////////////////////////////////////////////

function eliminarUsuario(id) {

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

async function confirmarEliminar(usuario){
    try {
        const response = await fetch('/usuarios/eliminar_usuario/'+usuario+'/');
        const result = await response.json();
        const {status} = result;
        const {mensaje} = result;
        if(status){
            imprimirMessage('Éxito', mensaje,'success');
            listarUsuarios();
        }else{
            imprimirMessage('Sistema', mensaje,'error');
        }
        
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al eliminar usuario","error");
    }
}

///////////////////////////////////////////////////////////////////////////

async function cargarPermisos(param){
    id_g = param;
    document.querySelector('#permisos-select').value='';
    const response = await fetch('/usuarios/listar_permisos_usuario/'+param+'/');
    const result = await response.json();
    const {perms} = result
    for (let i = 0; i < perms.length; i++) {
        $(`#permisos-select option[value=${perms[i][0]}]`).prop("selected", true);
    }
}

const btnGuardarPermiso = document.querySelector('#btn-guardar-permiso');
btnGuardarPermiso.addEventListener('click',asignarPermiso);

async function asignarPermiso(){
    let permisos = $('#permisos-select').val();
    const form = new FormData();
    form.append('permisos',permisos);
    const response = await fetch('/usuarios/asignar_permisos/'+id_g+'/',{
        method: 'POST',
        body: form,
        headers: {"X-CSRFToken": getCookie('csrftoken')}
    });
    const result = await response.json();
    const {status} = result
    if (status) {
        const {mensaje} = result
        return imprimirMessage('Éxito',mensaje,'success');
    }

}

///////////////////////////////////////////////////////////////////////////
async function listarPermisos(){
    const response = await fetch('/usuarios/listar_permisos/');
    const result = await response.json();

    const {perms} = result;
    let selectePermisos = document.querySelector('#permisos-select');
    selectePermisos.innerHTML = '';
    for (let i = 0; i < perms.length; i++) {
        selectePermisos.innerHTML += `<option value="${perms[i][0]}">${perms[i][1]}</option> `
        
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