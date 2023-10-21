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
let contentError=document.querySelector('.content-errors');
const btnGuardarTipoComprobante = document.querySelector('#btn-guardar-tipo-comprobante');
const btnModificarTipoComprobante = document.querySelector('#btn-modificar-tipo-comprobante');
const btnModalTipoComprobante = document.querySelector('#btn-modal-tipo-comprobante');

btnModalTipoComprobante.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarTipoComprobantes();
});
///////////////////////////////////////////////////////////////////////////
async function listarTipoComprobantes() {
    try {
        const response = await fetch("/ventas/listar_tipo_comprobante/");
        const result = await response.json();
        let resultado = JSON.parse(result.tipocomprobantes)
        console.log(resultado);
        if ($.fn.DataTable.isDataTable('#dataTable-tipo-comprobante')) {
            $('#dataTable-tipo-comprobante').DataTable().destroy();
        }
        $('#dataTable-tipo-comprobante tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i].fields.descripcion + `</td>`;
            (resultado[i].fields.estado) ? fila += `<td><span class="badge bg-success">Activo</span></td>`: fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="javascript:" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos(${resultado[i].pk},'${resultado[i].fields.descripcion}',${resultado[i].fields.estado})">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="javascript:eliminarTipoComprobante(${resultado[i].pk})" class="btn-eliminar">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-tipo-comprobante tbody').append(fila);
        }
        $('#dataTable-tipo-comprobante').DataTable({
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
btnGuardarTipoComprobante.addEventListener('click',registrarTipoComprobante);

async function registrarTipoComprobante(){
    try {
        const form= new FormData(document.querySelector('#form-tipo-comprobante'));

        if (form.get('id_descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);

            const response = await fetch("/ventas/tipo_comprobante/",{
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
                listarTipoComprobantes();
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
            document.querySelector('#form-tipo-comprobante').classList.add('was-validated');
        }
        
    } catch (error) {
        imprimirMessage("Sistema","Error al registrar tipo de comprobante","error");
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

var pk_tipo_comprobante=0;
///////////////////////////////////////////////////////////////////////////
function cargarDatos(pk,descripcion,estado){
    document.querySelector('#form-tipo-comprobante').classList.remove('was-validated');
    contentError.innerHTML='';        
    pk_tipo_comprobante=pk;
    document.querySelector('#id_descripcion').value=descripcion;
    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnGuardarTipoComprobante.disabled=true;
    btnModificarTipoComprobante.disabled=false;

}

///////////////////////////////////////////////////////////////////////////
btnModificarTipoComprobante.addEventListener('click',modificarTipoComprobante);

async function modificarTipoComprobante(){
    try {
        const form= new FormData(document.querySelector('#form-tipo-comprobante'));

        if (form.get('id_descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);

            const response = await fetch("/ventas/modificar_tipo_comprobante/"+pk_tipo_comprobante+"/",{
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
                listarTipoComprobantes();
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
            document.querySelector('#form-tipo-comprobante').classList.add('was-validated');
        }
        
    } catch (error) {
        imprimirMessage("Sistema","Error al modificar tipo de comprobante","error");
        console.log(error);
    }
}
//////////////////////////////////////////////////////////////////////////

function eliminarTipoComprobante(id) {

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
        const response = await fetch('/ventas/eliminar_tipo_comprobante/'+id+'/');
        const result = await response.json();
        const {status}=result;
        const{mensaje}=result;
        if (status){
            
            listarTipoComprobantes();
            imprimirMessage("Éxito",mensaje,"success");
        }else{
            imprimirMessage("Sistema",mensaje,"info");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar tipo de comprobante","error");
    }
}
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    pk_tipo_comprobante=0;
    document.querySelector('#form-tipo-comprobante').reset();
    document.querySelector('#form-tipo-comprobante').classList.remove('was-validated');
    contentError.innerHTML='';
    btnModificarTipoComprobante.disabled = true;
    btnGuardarTipoComprobante.disabled = false;
}

///////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}
///////////////////////////////////////////////////////////////////////////