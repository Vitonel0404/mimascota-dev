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
var inptDniCliente=document.querySelector('#id_numero_documento_cliente');
var slcTipoDoc=document.querySelector('#id_id_tipo_documento');
var inptNombreCliente=document.querySelector('#id_nombre');
var inptApellidoCliente=document.querySelector('#id_apellido');
var inptDomicilioCliente=document.querySelector('#id_domicilio');
var inptCelularCliente=document.querySelector('#id_celular');
var inptCorreoCliente=document.querySelector('#id_correo');
var inptFechaRegistroCliente=document.querySelector('#id_fecha_registro');

let contentError=document.querySelector('.content-errors');

const btnModificarCliente = document.querySelector('#btn-modificar-cliente');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    //btnModificarCliente.disabled=false;
    listarClientes();
});
///////////////////////////////////////////////////////////////////////////
const btnModalCliente=document.querySelector('#btn-modal-cliente');
btnModalCliente.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////

async function listarClientes(){
    try {
        const response = await fetch("/listar_clientes/");
        const result = await response.json();
        let resultado = JSON.parse(result.clientes);
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++){
            let fila = `<tr>`;
            fila += `<td>${resultado[i].fields.numero_documento_cliente} </td>`;
            fila += `<td>${resultado[i].fields.nombre} ${resultado[i].fields.apellido}</td>`;
            fila += `<td>${resultado[i].fields.domicilio}</td>`;
            fila += `<td>${resultado[i].fields.celular}</td>`;
            fila += `<td>${resultado[i].fields.correo}</td>`;
            fila += `<td>${resultado[i].fields.fecha_registro}</td>`;
            if(resultado[i].fields.estado){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;                 
            }  
            fila += `<td>
                        <div class="row">
                            <div class="form-group  col-sm-4">
                                <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos(
                                '${resultado[i].pk}','${resultado[i].fields.id_tipo_documento}','${resultado[i].fields.numero_documento_cliente}',
                                '${resultado[i].fields.nombre}','${resultado[i].fields.apellido}','${resultado[i].fields.domicilio}',
                                '${resultado[i].fields.celular}','${resultado[i].fields.correo}',
                                '${resultado[i].fields.fecha_registro}',${resultado[i].fields.estado})">
                                    <i class="bi bi-pencil-square"></i>
                                </a>                                   
                            </div>
                            <div class="form-group col-sm-4">
                                <a href="#" class="btn-eliminar" onclick="eliminarCliente('${resultado[i].pk}')">
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
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

const btnGuardarCliente=document.querySelector('#btn-guardar-cliente');
btnGuardarCliente.addEventListener('click',registrarCliente)
async function registrarCliente(){
    try {
        const f = new Date();
        const fecha=f.getFullYear()+ "-" + (f.getMonth() +1) + "-" +f.getDate() 
        const form= new FormData(document.querySelector('#form-cliente'));

        form.set('numero_documento_cliente',form.get('numero_documento_cliente').trim());
        form.set('nombre',form.get('nombre').trim());
        form.set('apellido',form.get('apellido').trim());
        form.set('domicilio',form.get('domicilio').trim());
        form.set('celular',form.get('celular').trim());
        form.set('correo',form.get('correo').trim());
        form.append('fecha_registro',fecha.trim())
        if (form.get('id_tipo_documento')!=''&&form.get('numero_documento_cliente')!=''&&form.get('nombre')!=''&&form.get('apellido')!=''
            &&form.get('domicilio')!=''&&form.get('celular')!=''&&form.get('correo')!=''&&form.get('fecha_registro')!=''
        ) {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch("/cliente/",{
                method: 'POST',
                body: form,
                headers:{
                    "X-CSRFToken":getCookie('csrftoken'),
                }
            });
            const result = await response.json();
            const {status} = result;
            const {mensaje} = result;
            if(status){
                imprimirMessage("Éxito",mensaje,"success");
                listarClientes();
                cleanData();
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage("Sistema",mensaje,"info");
            }
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-cliente').classList.add('was-validated');
        }
        
    } catch (error) {
        imprimirMessage("Sistema","Error al registrar Cliente","error");
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////
let fecha="";
let pk_cliente=0;
function cargarDatos(pk,id_tipodoc,dni, nombre,apellido,domicilio,celular,correo, fecha_registro,estado){
    document.querySelector('#form-cliente').classList.remove('was-validated');
    contentError.innerHTML='';        
    pk_cliente=pk;
    slcTipoDoc.value=id_tipodoc;
    inptDniCliente.value=dni;
    inptNombreCliente.value=nombre;
    inptApellidoCliente.value=apellido;
    inptDomicilioCliente.value=domicilio;
    inptCelularCliente.value=celular;
    inptCorreoCliente.value=correo;
    fecha=fecha_registro;
    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnGuardarCliente.disabled=true;
    btnModificarCliente.disabled=false;

}
///////////////////////////////////////////////////////////////////////////
btnModificarCliente.addEventListener('click',modificarCliente);
async function modificarCliente(){
    try {
        const form= new FormData(document.querySelector('#form-cliente'));
        form.set('numero_documento_cliente',form.get('numero_documento_cliente').trim());
        form.set('nombre',form.get('nombre').trim());
        form.set('apellido',form.get('apellido').trim());
        form.set('domicilio',form.get('domicilio').trim());
        form.set('celular',form.get('celular').trim());
        form.set('correo',form.get('correo').trim());
        form.append('fecha_registro',fecha.trim());
        if (form.get('id_tipo_documento')!=''&&form.get('numero_documento_cliente')!=''&&form.get('nombre')!=''&&form.get('apellido')!=''
            &&form.get('domicilio')!=''&&form.get('celular')!=''&&form.get('correo')!=''&&form.get('fecha_registro')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch("/modificar_cliente/"+pk_cliente+"/",{
                method: 'POST',
                body: form,
                headers:{
                    "X-CSRFToken":getCookie('csrftoken'),
                }
            });
            const result= await response.json();     
            const {status}=result;
            const {mensaje}=result;
            if(status){
                btnModificarCliente.disabled=true;
                btnGuardarCliente.disabled=false;
                imprimirMessage("Éxito",mensaje,"success");
                listarClientes();
                cleanData();
            }else{
                const {error}=result;
                contentError.innerHTML='';        
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage("Sistema",mensaje,"info");
            }
        } else {
            imprimirMessage("Sistema",'Complete los campos necesarios para modificar',"info");
            document.querySelector('#form-cliente').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al modificar Cliente","error");

    }
}
///////////////////////////////////////////////////////////////////////////
function eliminarCliente(id_cliente){
        
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
            confirmarEliminar(id_cliente);
        }
    })
}
async function confirmarEliminar(id_cliente){
    try {
        const response = await fetch("/eliminar_cliente/"+id_cliente+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarClientes();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar Cliente","error");
    }
}
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    document.querySelector('#form-cliente').classList.remove('was-validated');
    contentError.innerHTML='';        
    pk_cliente=0;
    slcTipoDoc.value='';
    inptDniCliente.value='';
    inptNombreCliente.value='';
    inptApellidoCliente.value='';
    inptDomicilioCliente.value='';
    inptCelularCliente.value='';
    inptCorreoCliente.value='';
    fecha.value='';
    $("#id_estado").prop('checked', true);
    btnGuardarCliente.disabled=false;
    btnModificarCliente.disabled=true;
}

///////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}