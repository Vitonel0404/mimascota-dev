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

let cboCategoria=document.querySelector('#id_id_categoria');
let cboUnidadMedida=document.querySelector('#id_id_unidad_medida');
let inpNombre=document.querySelector('#id_nombre');
// let inpPrecio=document.querySelector('#id_precio');
// let inpStockActual=document.querySelector('#id_stock');
// let inpStockMin=document.querySelector('#id_stock_min');
let inptDescripcion=document.querySelector('#id_descripcion');

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////

const btnGuardarProducto= document.querySelector('#btn-guardar-producto');
const btnModificarProducto=document.querySelector('#btn-modificar-producto'); 
///////////////////////////////////////////////////////////////////////////
const btnModalProducto=document.querySelector('#btn-modal-producto');
btnModalProducto.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////

$(document).ready(function(){
    listarProductos()
});
async function listarProductos(){
    try {
        const response = await fetch("/producto/listar_productos/");
        const result = await response.json();
        let resultado=result.productos;
        console.log(resultado);
        if ($.fn.DataTable.isDataTable('#dataTable-productos')) {
            $('#dataTable-productos').DataTable().destroy();
        }
        $('#dataTable-productos tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>${resultado[i][1]}</td>`;
            fila += `<td>${resultado[i][6]}</td>`;
            fila += `<td>${resultado[i][7]}</td>`;
            if(resultado[i][5]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            }
            
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModalForm" onclick="cargarDatos(
                                        ${resultado[i][0]},'${resultado[i][1]}',${resultado[i][3]},
                                        ${resultado[i][4]},'${resultado[i][2]}',${resultado[i][5]}
                                        )">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarProducto(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-productos tbody').append(fila);
        }
        $('#dataTable-productos').DataTable({
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
btnGuardarProducto.addEventListener('click',registrarProducto);
async function registrarProducto(){
    const form = new FormData(document.querySelector('#form-productos'));
    form.set('nombre',form.get('nombre').trim());
    form.set('descripcion',form.get('descripcion').trim());
    try {
        if (form.get('nombre')!=''&&form.get('id_categoria')!=''&&form.get('id_unidad_medida')!=''&&form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch('/producto/productos/',{
                method:'POST',
                body:form,
                headers:{'X-CSRFToken':getCookie('csrftoken')}
            });
            const result = await response.json()
            console.log(result)
            const {status} = result;
            const {mensaje} = result;
            if (status){
                listarProductos();
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
            document.querySelector('#form-productos').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error)
    }
}
var id_producto=0;
//////////////////////////////////////////////////////////////////////////
function cargarDatos(pk, nombre,categoria,unidad_medida,descripcion,estado){
    document.querySelector('#form-productos').classList.remove('was-validated');
    contentError.innerHTML='';
    id_producto=pk;
    inpNombre.value=nombre;
    cboCategoria.value=categoria;
    cboUnidadMedida.value=unidad_medida;
    // inpPrecio.value=precio;
    // inpStockActual.value=stock;
    // inpStockMin.value=stock_min;
    inptDescripcion.value=descripcion;
    if(estado){
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnModificarProducto.disabled=false;
    btnGuardarProducto.disabled=true;
    
}
//////////////////////////////////////////////////////////////////////////
btnModificarProducto.addEventListener('click',modificarProducto);
//////////////////////////////////////////////////////////////////////////
async function modificarProducto(){
    const form = new FormData(document.querySelector('#form-productos'));
    form.set('nombre',form.get('nombre').trim());
    form.set('descripcion',form.get('descripcion').trim());
    
    try {
        if (form.get('nombre')!=''&&form.get('id_categoria')!=''&&form.get('id_unidad_medida')!=''&&form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            const response = await fetch("/producto/modificar_producto/"+id_producto+"/",{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });

            const result = await response.json();

            const {status}=result;
            const {mensaje}=result;
            if (status){
                listarProductos();
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
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para modificar','info')
            document.querySelector('#form-productos').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al modificar producto",'error');
    }
}
//////////////////////////////////////////////////////////////////////////

function eliminarProducto(id) {

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
        const response = await fetch("/producto/eliminar_producto/"+id+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarProductos();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar producto","error");
    }
}
//////////////////////////////////////////////////////////////////////////
function cleanData(){
    document.querySelector('#form-productos').classList.remove('was-validated');
    contentError.innerHTML='';
    btnModificarProducto.disabled=true;
    btnGuardarProducto.disabled=false;
    cboCategoria.value=''
    cboUnidadMedida.value=''
    inpNombre.value=''
    // inpPrecio.value=''
    // inpStockActual.value=''
    // inpStockMin.value=''
    inptDescripcion.value=''
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