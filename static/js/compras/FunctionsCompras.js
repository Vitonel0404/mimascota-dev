
const bnt_a=document.querySelector('#id_report');
bnt_a.addEventListener('click',validatedSendData)
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarCompras();
});
///////////////////////////////////////////////////////////////////////////

async function listarCompras(){
    try {
        const response = await fetch('/compras/listar_compras/');
        const result = await response.json();
        console.log(result.compras);
        const resultado=result.compras
        if ($.fn.DataTable.isDataTable('#dataTable-compra')) {
            $('#dataTable-compra').DataTable().destroy();
        }
        $('#dataTable-compra tbody').html("");
        for (i = 0; i < resultado.length; i++){
            let fila = `<tr>`;
            fila += `<td>${resultado[i][1]} </td>`;
            fila += `<td>${resultado[i][2]}</td>`;
            fila += `<td>${resultado[i][3]}</td>`;
            fila += `<td>${resultado[i][4]}</td>`;
            fila += `<td>${resultado[i][5]}</td>`;
            fila += `<td>${resultado[i][6]}</td>`;
            (resultado[i][7])?fila += `<td><span class="badge bg-success">Inventariado</span></td>`:fila += `<td><span class="badge bg-danger">Sin traspaso</span></td>`; 
            fila += `<td>
                        <div class="row">
                            <div class="form-group  col-sm-4">
                                <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="verDetalle(${resultado[i][0]})">
                                    <i class="bi bi-arrow-up-right-square"></i>
                                </a>                                   
                            </div>
                            <div class="form-group col-sm-4">
                                <a href="javascript:traspasoProductos(${resultado[i][0]})" >
                                    <i class="bi bi-reply-all-fill"></i>
                                </a>
                            </div>
                            <div class="form-group col-sm-4">
                                <a href="#" class="btn-eliminar" onclick="eliminarCompra('${resultado[i][0]}')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                            
                        </div>
                   </td>`;

            fila += `</tr>`;
            $('#dataTable-compra tbody').append(fila);
        }
        $('#dataTable-compra').DataTable({
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
function eliminarCompra(id_compra){
        
    Swal.fire({
        "title":"¿Estás seguro?",
        "text":"Esta acción no se puede revertir. Se eliminarán los detalles de esta compra",
        "icon":"question",
        "showCancelButton":true,
        "cancelButtonText":"No, cancelar",
        "confirmButtonText":"Sí, eliminar",
        "confirmButtonColor":"#dc3545"
    })
    .then(function(result){
        if(result.isConfirmed){
            confirmarEliminar(id_compra);
        }
    })
}
async function confirmarEliminar(id_compra){
    try {
        const response = await fetch("/compras/eliminar_compra/"+id_compra+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarCompras();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar compra","error");
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////

async function verDetalle(id_compra){
    try {
        const response = await fetch('/compras/buscar_detalle_compra/'+id_compra+'/');
        const result = await response.json()
        const {status}= result;
        if (status) {
            document.querySelector('#span_numero_compra').textContent=id_compra;
            let resultado = result.detalle;
            $('#table-detalle-compra tbody').html("");
            for (let i = 0; i < resultado.length; i++) {
                let fila = `<tr class="text-center">`;
                fila += `<td>` + parseInt(i+1) + `</td>`;
                fila += `<td>` + resultado[i][0] + `</td>`;
                fila += `<td>` + resultado[i][1] + `</td>`;
                fila += `<td>` + resultado[i][2] + `</td>`;
                fila += `<td>` + resultado[i][3] + `</td>`;
                fila += `</tr>`;
                $('#table-detalle-compra tbody').append(fila);
            }
        }
        
    } catch (error) {
        console.log(error)
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
///////////////////////////////////////////////////////////////////////////////////////////////sss
function validatedSendData(){
    const form = new FormData(document.querySelector('#form-reporte'));
    let ab=document.querySelector('#id_report');
    if (form.get('fecha_inicio')!='' && form.get('fecha_fin')!='') {
        ab.setAttribute("href",`/compras/export_compras_pdf/${form.get('fecha_inicio')}/${form.get('fecha_fin')}/`);
        document.querySelector('#form-reporte').reset();
        document.querySelector('#form-reporte').classList.remove('was-validated');
    }else{
        ab.removeAttribute("href");
        document.querySelector('#form-reporte').classList.add('was-validated');
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
function traspasoProductos(id_compra){
    Swal.fire({
        "title": "Entrada de productos",
        "text": "¿Desea traspasar los productos de esta compra a su inventario?",
        "icon": "question",
        "showCancelButton": true,
        "cancelButtonText": "No, cancelar",
        "confirmButtonText": "Sí, traspasar",
        "confirmButtonColor": "#3CB371"
    }).then(function (result){
        if (result.isConfirmed){
            confirmarTraspasoProductos(id_compra);
        }
    })
    
}

async function confirmarTraspasoProductos(id){
    try {
        const response = await fetch("/compras/actualizar_stock_compra/" + id + "/");
        const result = await response.json();
        const {status}=result;
        const{mensaje}=result;
        if (status){
            imprimirMessage("Éxito",mensaje,"success");
            listarCompras();
        }else{
            imprimirMessage("Sistema",mensaje,"info");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error actualizar stock","error");
    }
}