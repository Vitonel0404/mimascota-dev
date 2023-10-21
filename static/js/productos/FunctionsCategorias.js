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
//var cboAnimal=document.querySelector('#id_id_animal');
var inpDescripcionCategoria =document.querySelector('#id_descripcion')

const btnGuardarCategoria= document.querySelector('#btn-guardar-categoria');
const btnModificarCategoria=document.querySelector('#btn-modificar-categoria')

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////

const btnModalMascota=document.querySelector('#btn-modal-categoria');
btnModalMascota.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarCategorias();
});
///////////////////////////////////////////////////////////////////////////
async function listarCategorias(){
    try {
        const response = await fetch("/producto/listar_categorias/");
        const result = await response.json();
        let resultado=JSON.parse(result.categorias);
        console.log(resultado);
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            //fila += `<td>${resultado[i][4]}</td>`;
            fila += `<td>${resultado[i].fields.descripcion}</td>`;
            if(resultado[i].fields.estado){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            }
            
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModalForm" onclick="cargarDatos(
                                        ${resultado[i].pk},'${resultado[i].fields.descripcion}',
                                        ${resultado[i].fields.estado}
                                    )">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarCategoria(${resultado[i].pk})">
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
btnGuardarCategoria.addEventListener('click',registrarCategoria);
async function registrarCategoria(){
    const form = new FormData(document.querySelector('#form-categorias'));
    form.set('descripcion',form.get('descripcion').trim())
    try {
        if (form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/producto/categorias/',{
                method:'POST',
                body:form,
                headers:{'X-CSRFToken':getCookie('csrftoken')}
            });
            const result = await response.json()
            console.log(result)
            const {status} = result;
            const {mensaje} = result;
            if (status){
                listarCategorias();
                imprimirMessage('Éxito',mensaje,'success');
                cleanData();
            }else{
                const {error}=result;
                contentError.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage('Sistmea',mensaje,'info');
            }
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-categorias').classList.add('was-validated');
        }
        
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
var categoria_id=0;
function cargarDatos(pk,descripcion,estado){
    document.querySelector('#form-categorias').classList.remove('was-validated');
    contentError.innerHTML='';
    categoria_id=pk;
    //cboAnimal.value=id_animal;
    inpDescripcionCategoria.value=descripcion;

    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnModificarCategoria.disabled=false;
    btnGuardarCategoria.disabled=true;
}

btnModificarCategoria.addEventListener('click',modificarCategoria);
//////////////////////////////////////////////////////////////////////////
async function modificarCategoria(){
    try {
        const form = new FormData(document.querySelector('#form-categorias'));
        form.set('descripcion',form.get('descripcion').trim());
        if (form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch("/producto/modificar_categoria/"+categoria_id+"/",{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });

            const result = await response.json();

            const {status}=result;
            const {mensaje}=result;
            if (status){
                listarCategorias();
                imprimirMessage("Éxito",mensaje,'success');
                cleanData();

            }else{
                const {error}=result;
                contentError.innerHTML='';
                Object.entries(error).forEach(([key, value]) => {
                    contentError.innerHTML+=`<p> -> ${value}</p>`
                });
                imprimirMessage("Sistema",mensaje,'info');
            }
        }else{
            imprimirMessage('Sistema','Complete los campos necesarios para modificar','info')
            document.querySelector('#form-categorias').classList.add('was-validated');
        }

    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al modificar categoria",'error');
    }
}
//////////////////////////////////////////////////////////////////////////

function eliminarCategoria(id) {

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
        const response = await fetch("/producto/eliminar_categoria/"+id+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarCategorias();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar categoria","error");
    }
}
//////////////////////////////////////////////////////////////////////////
function cleanData(){
    document.querySelector('#form-categorias').classList.remove('was-validated');
    contentError.innerHTML='';
    btnModificarCategoria.disabled=true;
    btnGuardarCategoria.disabled=false;
    categoria_id=0;
    //cboAnimal.value='';
    inpDescripcionCategoria.value='';
    $("#id_estado").prop('checked', true);
}
//////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}