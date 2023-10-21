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
let cboSucursal=document.querySelector('#id_id_sucursal');
let cboProducto=document.querySelector('#id_id_producto');
let inpPrecio=document.querySelector('#id_precio');
let inpStockactual=document.querySelector('#id_stock');
let inpStockmin=document.querySelector('#id_stock_min');

let contentError=document.querySelector('.content-errors');
const btnGuardarProductoSucursal= document.querySelector('#btn-guardar-producto-sucursal');
const btnModificarProductoSucursal=document.querySelector('#btn-modificar-producto-sucursal'); 

const btnModalProductoSucursal=document.querySelector('#btn-modal-producto-sucursal');
btnModalProductoSucursal.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////

$(document).ready(function(){
    listarProductosSucursal()
});
async function listarProductosSucursal(){
    try {
        const response = await fetch("/producto/listar_productos_sucursal/");
        const result = await response.json();
        let resultado=result.productos;
        if ($.fn.DataTable.isDataTable('#dataTable-productos-sucursal')) {
            $('#dataTable-productos-sucursal').DataTable().destroy();
        }
        $('#dataTable-productos-sucursal tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>${resultado[i][2]}</td>`;
            fila += `<td>${resultado[i][4]}</td>`;
            fila += `<td>${resultado[i][6]}</td>`;
            fila += `<td>${resultado[i][7]}</td>`;
            fila += `<td>${resultado[i][8]}</td>`;
            fila += `<td>${resultado[i][9]}</td>`;
            if(resultado[i][10]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            }
            
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModalForm" onclick="cargarDatos(
                                        ${resultado[i][0]},${resultado[i][11]},'${resultado[i][1]}',${resultado[i][7]},
                                        '${resultado[i][8]}',${resultado[i][9]},${resultado[i][10]}
                                        )">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarProductoSucursal(${resultado[i][0]})">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-productos-sucursal tbody').append(fila);
        }
        $('#dataTable-productos-sucursal').DataTable({
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
btnGuardarProductoSucursal.addEventListener('click',registrarProductoSucursal);
async function registrarProductoSucursal(){
    const form = new FormData(document.querySelector('#form-productos-sucursal'));
    form.set('precio',form.get('precio').trim());
    form.set('stock',form.get('stock').trim());
    form.set('stock_min',form.get('stock_min').trim());
    try {
        if (/*form.get('id_sucursal')!=''&&*/form.get('id_producto')!=''&&form.get('precio')!=''&&form.get('stock')!=''&&form.get('stock_min')!='') {
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch('/producto/productos_sucursal/',{
                method:'POST',
                body:form,
                headers:{'X-CSRFToken':getCookie('csrftoken')}
            });
            const result = await response.json()
            console.log(result)
            const {status} = result;
            const {mensaje} = result;
            if (status){
                listarProductosSucursal();
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
            document.querySelector('#form-productos-sucursal').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error)
    }
}


let pk_ps=0;
function cargarDatos(pk, sucursal,producto,precio,stock,stock_min,estado) {
    pk_ps=pk;
    //cboSucursal.value=sucursal;
    cboProducto.value=producto;
    inpPrecio.value=precio;
    inpStockactual.value=stock;
    inpStockmin.value=stock_min;
    btnModificarProductoSucursal.disabled=false;
    btnGuardarProductoSucursal.disabled=true;
    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    
}
//////////////////////////////////////////////////////////////////////////
btnModificarProductoSucursal.addEventListener('click',modificarProductoSucursal);
async function modificarProductoSucursal(){

    const form = new FormData(document.querySelector('#form-productos-sucursal'));
    form.set('precio',form.get('precio').trim());
    form.set('stock',form.get('stock').trim());
    form.set('stock_min',form.get('stock_min').trim());
    
    try {
        if (/*form.get('id_sucursal')!=''&&*/form.get('id_producto')!=''&&form.get('precio')!=''&&form.get('stock')!=''&&form.get('stock_min')!='') {
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            const response = await fetch("/producto/modificar_producto_sucursal/"+pk_ps+"/",{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });

            const result = await response.json();

            const {status}=result;
            const {mensaje}=result;
            if (status){
                listarProductosSucursal();
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
            document.querySelector('#form-productos-sucursal').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al modificar producto",'error');
    }
}
//////////////////////////////////////////////////////////////////////////

function eliminarProductoSucursal(id) {

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
        const response = await fetch("/producto/eliminar_producto_sucursal/"+id+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarProductosSucursal();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar producto","error");
    }
}

//////////////////////////////////////////////////////////////////////////

function cleanData(){
    document.querySelector('#form-productos-sucursal').classList.remove('was-validated');
    contentError.innerHTML='';
    btnModificarProductoSucursal.disabled=true;
    btnGuardarProductoSucursal.disabled=false;
    document.querySelector('#form-productos-sucursal').reset();
}

//////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}