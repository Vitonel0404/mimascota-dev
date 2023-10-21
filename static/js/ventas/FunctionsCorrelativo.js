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

let btnModificarCorrelativo=document.querySelector("#btn-modificar-correlativo");
let contentError=document.querySelector('.content-errors');

const btnModalCorrelativo=document.querySelector('#btn-modal-correlativo');
btnModalCorrelativo.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){

    listarCorrelativo();
});
///////////////////////////////////////////////////////////////////////////


async function listarCorrelativo() {
    try {
        const response = await fetch("/ventas/listar_correlativo/");
        const result = await response.json();
        let resultado = result.correlativos
        if ($.fn.DataTable.isDataTable('#dataTable-correlativo')) {
            $('#dataTable-correlativo').DataTable().destroy();
        }
        $('#dataTable-correlativo tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i][2] + `</td>`;
            fila += `<td>` + resultado[i][3] + `</td>`;
            fila += `<td>` + resultado[i][4] + `</td>`;
            (resultado[i][5]) != null ? fila += `<td>` + resultado[i][5] + `</td>`:fila += `<td>-</td>`;
            
            fila += `<td>` + resultado[i][6] + `</td>`;
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos(${resultado[i][0]},${resultado[i][1]},'${resultado[i][3]}',${resultado[i][4]},${resultado[i][5]},${resultado[i][6]})">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarCorrelativo(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-correlativo tbody').append(fila);
        }
        $('#dataTable-correlativo').DataTable({
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
const btnGuardarCorrelativo=document.querySelector("#btn-guardar-correlativo");
btnGuardarCorrelativo.addEventListener('click',guardarCorrelativo);

async function guardarCorrelativo(){
    const formulario = document.querySelector('#form-correlativo');
    const form = new FormData(formulario);
    try {
        if (form.get('id_tipo_comprobante')!=''&&form.get('serie')!=''&&form.get('primer_numero')!=''&&form.get('max_correlativo')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/ventas/correlativo/',{
                method : 'POST',
                body: form,
                headers : {"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const {status} = result;
            const {mensaje} = result;
            if (status) {
                listarCorrelativo();
                imprimirMessage('Éxito',mensaje,'success');
                cleanData()
            } else {
                const {error}=result;
                contentError.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info');
            }
            
        
        } else {
            formulario.classList.add('was-validated');
        }
        
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////
var id=0;
function cargarDatos(id_correlativo, id_tipo_comprobante, serie, primer_numero, ultimo_numero, max_correlativo){
    id=id_correlativo;
    document.querySelector('#id_id_tipo_comprobante').value=id_tipo_comprobante;
    document.querySelector('#id_serie').value=serie;
    document.querySelector('#id_primer_numero').value=primer_numero;
    document.querySelector('#id_ultimo_numero_registrado').value=ultimo_numero;
    document.querySelector('#id_max_correlativo').value=max_correlativo;
    btnModificarCorrelativo.disabled = false;
    btnGuardarCorrelativo.disabled = true;
    document.querySelector('#form-correlativo').classList.remove('was-validated');
}
///////////////////////////////////////////////////////////////////////////

btnModificarCorrelativo.addEventListener('click',modificarCorrelativo);
async function modificarCorrelativo(){
    const formulario = document.querySelector('#form-correlativo');
    const form = new FormData(formulario);
    try {
        if (form.get('id_tipo_comprobante')!=''&&form.get('serie')!=''&&form.get('primer_numero')!=''&&form.get('max_correlativo')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/ventas/modificar_correlativo/'+id+'/',{
                method : 'POST',
                body: form,
                headers : {"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const {status} = result;
            const {mensaje} = result;
            if (status) {
                listarCorrelativo();
                imprimirMessage('Éxito',mensaje,'success');
                cleanData()
            } else {
                const {error}=result;
                contentError.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistema',mensaje,'info');
            }
        }
    } catch (error) {
        console.log(error);
    }
}
//////////////////////////////////////////////////////////////////////////

function eliminarCorrelativo(id) {

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
        const response = await fetch('/ventas/eliminar_correlativo/'+id+'/');
        const result = await response.json();
        const {status}=result;
        const{mensaje}=result;
        if (status){
            
            listarCorrelativo();
            imprimirMessage("Éxito",mensaje,"success");
        }else{
            imprimirMessage("Sistema",mensaje,"info");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar correlativo","error");
    }
}
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    id=0;
    document.querySelector('#form-correlativo').reset();
    document.querySelector('#form-correlativo').classList.remove('was-validated');
    contentError.innerHTML='';
    btnModificarCorrelativo.disabled = true;
    btnGuardarCorrelativo.disabled = false;
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
