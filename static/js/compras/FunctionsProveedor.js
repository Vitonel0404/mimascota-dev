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
const btnGuardarProveedor=document.querySelector('#btn-guardar-proveedor');
const btnModificarProveedor=document.querySelector('#btn-modificar-proveedor');
const btnModalProveedor=document.querySelector('#btn-modal-proveedor');

var slctTipoDocuemento= document.querySelector('#id_id_tipo_documento');
var inpNumeroDocumento= document.querySelector('#id_numero_documento_proveedor');
var inpRazonSocial= document.querySelector('#id_razon_social');
var inpTelefono= document.querySelector('#id_telefono_proveedor');
var inpTelefonoContacto= document.querySelector('#id_telefono_contacto');
var inpDireccion= document.querySelector('#id_direccion');

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarProveedores();
})

btnModalProveedor.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////////////////////////
async function listarProveedores(){
    try {
        const response = await fetch('/compras/listar_proveedores/');
        const result = await response.json();
        const resultado=result.proveedores;
        console.log(resultado)
        if ($.fn.DataTable.isDataTable('#dataTable-proveedor')) {
            $('#dataTable-proveedor').DataTable().destroy();
        }
        $('#dataTable-proveedor tbody').html("");
        for (i = 0; i < resultado.length; i++){
            let fila = `<tr>`;
            fila += `<td>${resultado[i][1]} </td>`;
            fila += `<td>${resultado[i][2]}</td>`;
            (resultado[i][3]!=null)? fila += `<td>${resultado[i][3]}</td>`: fila += `<td></td>`;
            (resultado[i][4]!=null)? fila += `<td>${resultado[i][4]}</td>`: fila += `<td></td>`;
            (resultado[i][5]!=null)? fila += `<td>${resultado[i][5]}</td>`: fila += `<td></td>`;
            (resultado[i][6])?fila += `<td><span class="badge bg-success">Activo</span></td>`:fila += `<td><span class="badge bg-danger">Inactivo</span></td>`; 
            fila += `<td>
                        <div class="row">
                            <div class="form-group  col-sm-4">
                                <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos(
                                    ${resultado[i][0]},'${resultado[i][1]}','${resultado[i][2]}',
                                    '${resultado[i][3]}','${resultado[i][4]}','${resultado[i][5]}',
                                    ${resultado[i][6]},${resultado[i][7]}
                                    )">
                                    <i class="bi bi-pencil-square"></i>
                                </a>                                   
                            </div>
                            <div class="form-group col-sm-4">
                                <a href="#" class="btn-eliminar" onclick="eliminarProveedor('${resultado[i][0]}')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-proveedor tbody').append(fila);
        }
        $('#dataTable-proveedor').DataTable({
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
btnGuardarProveedor.addEventListener('click',registrarProveedor);
async function registrarProveedor(){
    try {
        const form = new FormData(document.querySelector('#form-proveedor'));

        form.set('numero_documento_proveedor',form.get('numero_documento_proveedor').trim());
        form.set('razon_social',form.get('razon_social').trim());
        form.set('telefono_proveedor',form.get('telefono_proveedor').trim());
        form.set('telefono_contacto',form.get('telefono_contacto').trim());
        form.set('direccion',form.get('direccion').trim());
        console.log(form.get('id_tipo_documento'))
        if (form.get('id_tipo_documento')!=''&&form.get('numero_documento_proveedor')!=''&&form.get('razon_social')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/compras/proveedores/',{
                method:'POST',
                body:form,
                headers:{'X-CSRFToken':getCookie('csrftoken')}
            })
            const result = await response.json();
            const {status} = result;
            const {mensaje} = result;
            if(status){
                imprimirMessage('Éxito',mensaje,'success');
                listarProveedores();
                cleanData()
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info')
            }
            
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-proveedor').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage('Error','error al registrar proveedor','error')
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////
var id_proveedor=0;
function cargarDatos(pk, doc, razon,tel1, tel2, direccion, estado,tipodoc){
    document.querySelector('#form-proveedor').classList.remove('was-validated');
    contentError.innerHTML='';
    id_proveedor=pk;
    slctTipoDocuemento.value=tipodoc;
    inpNumeroDocumento.value= doc;
    inpRazonSocial.value= razon;
    (tel1!='null')?inpTelefono.value= tel1:inpTelefono.value='';
    (tel2!='null')?inpTelefonoContacto.value= tel2:inpTelefonoContacto.value='';
    (direccion!='null')?inpDireccion.value= direccion:inpDireccion.value='';
    if(estado){
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnGuardarProveedor.disabled=true;
    btnModificarProveedor.disabled=false;
}
///////////////////////////////////////////////////////////////////////////////////////////////
btnModificarProveedor.addEventListener('click',modificarProveedor);
async function modificarProveedor(){
    try {
        const form = new FormData(document.querySelector('#form-proveedor'));
        form.append('id_proveedor',id_proveedor);
        form.set('numero_documento_proveedor',form.get('numero_documento_proveedor').trim());
        form.set('razon_social',form.get('razon_social').trim());
        form.set('telefono_proveedor',form.get('telefono_proveedor').trim());
        form.set('telefono_contacto',form.get('telefono_contacto').trim());
        form.set('direccion',form.get('direccion').trim());
        if (form.get('id_tipo_documento')!=''&&form.get('numero_documento_proveedor')!=''&&form.get('razon_social')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/compras/modificar_proveedor/',{
                method:'POST',
                body:form,
                headers:{'X-CSRFToken':getCookie('csrftoken')}
            })
            const result = await response.json();
            const {status} = result;
            const {mensaje} = result;
            if(status){
                imprimirMessage('Éxito',mensaje,'success');
                listarProveedores();
                cleanData()
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info')
            }   
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-proveedor').classList.add('was-validated');
        }
        
        
    } catch (error) {
        console.log(error);
        imprimirMessage('Error','Error al modificar proveedor','error')
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////

function cleanData(){
    document.querySelector('#form-proveedor').classList.remove('was-validated');
    contentError.innerHTML='';
    slctTipoDocuemento.value='';
    inpNumeroDocumento.value= '';
    inpRazonSocial.value= '';
    inpTelefono.value= '';
    inpTelefonoContacto.value=''; 
    inpDireccion.value= '';
    $("#id_estado").prop('checked', true);
    btnGuardarProveedor.disabled=false;
    btnModificarProveedor.disabled=true;
}
///////////////////////////////////////////////////////////////////////////
function eliminarProveedor(id_proveedor){
        
    Swal.fire({
        "title":"¿Estás seguro?",
        "text":"Esta acción no se puede revertir",
        "icon":"question",
        "showCancelButton":true,
        "cancelButtonText":"No, cancelar",
        "confirmButtonText":"Sí, eliminar",
        "confirmButtonColor":"#dc3545"
    })
    .then(function(result){
        if(result.isConfirmed){
            confirmarEliminar(id_proveedor);
        }
    })
}
async function confirmarEliminar(id_proveedor){
    try {
        const response = await fetch("/compras/eliminar_proveedor/"+id_proveedor+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarProveedores();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar proveedor","error");
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