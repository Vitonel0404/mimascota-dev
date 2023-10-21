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

const inptBuscadorProducto=document.querySelector('#buscador-producto');
inptBuscadorProducto.addEventListener('keyup',buscarProducto);

const divSearchResult=document.querySelector('#list-search-2');

const btnLimpiarBuscador=document.querySelector('#btn-borrarBuscador-compra');
btnLimpiarBuscador.addEventListener('click',borrarBuscador);

const btnGuardarCompra=document.querySelector('#btn-guardar-compra');
btnGuardarCompra.addEventListener('click', guardarCompra);


let inpProveedor=document.querySelector('#id_id_proveedor');
let inptTipoDoc=document.querySelector('#id_id_tipo_comprobante');
let inpSerie=document.querySelector('#id_serie');
let inptNumero=document.querySelector('#id_numero');
let inptImpuesto=document.querySelector('#id_impuesto');
let inptMontoTotal=document.querySelector('#id_monto_total');
let dateFecha=document.querySelector('#id_fecha');


let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    
    $('#dataTable-productos-compras').DataTable({
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
        lengthMenu: [3, 5, 10],
    })
    
})
///////////////////////////////////////////////////////////////////////////////////////////
function buscarProducto(){
    
    let producto=(inptBuscadorProducto.value).trim();
    if(producto.length>0 ){
        try {
            fetch("/compras/buscar_producto_compra/"+producto+"/").then(
                function (response){
                    return response.json()
                }
            ).then(
                function(result){
                    const {status}=result;
                    const productos=result.productos;
                    if(status){
                        divSearchResult.innerHTML=''
                        for(let i=0; i<productos.length; i++){
                            
                            divSearchResult.innerHTML+=`                       
                                    <a href="javascript:añadirProductos(${productos[i][5]},'${productos[i][8]}',${productos[i][1]})" style="word-wrap: break-word"  class="list-group-item dropdown-item " >
                                        ${productos[i][8]}                   
                                    </a>
                                `
                        }    
                    }
                }
            ).catch(
                function(error){
                    console.log(error)
                    imprimirMessage('Error', 'Error de consulta al servidor', 'error')
                }
            )
        } catch (error) {
            console.log(error)
            
        }
    }else{
        divSearchResult.innerHTML=''
    }
}
///////////////////////////////////////////////////////////////////////////////////////////
var listaProductos=[]
function añadirProductos(pk, nombre){
    let variable_guia=false;
    let posicion=0;
    if (listaProductos.length > 0) {
        for(let i=0; i<listaProductos.length;i++){
            if(listaProductos[i].id==pk){
                variable_guia=true;
                posicion=i;
            }
        }
        if(variable_guia){
            //listaProductos[posicion]['cant_min']=listaProductos[posicion]['cant_min']+1
        }else{
            listaProductos.push({ 'id': pk, 'nombre': nombre,'precio':0.0 ,'cant_min': 1,'subtotal':0.0 });  
        }
        listarProductosAñadidos(listaProductos);

    } else {
        listaProductos.push({ 'id': pk, 'nombre': nombre,'precio':0.0 ,'cant_min': 1,'subtotal':0.0});
        listarProductosAñadidos(listaProductos);
    }

    //calcularMontoTotal(listaProductos);
    //let btn_añadir=document.querySelector('#'+descripcion.split(" ").join(""));
    //btn_añadir.disabled=true;

}
///////////////////////////////////////////////////////////////////////////////////////////

function removerProducto(id){
    for (let i=0;i<listaProductos.length;i++){
        if (listaProductos[i]['id']==id){
            
            index=listaProductos.indexOf(listaProductos[i])
            listaProductos.splice(index,1);
            listarProductosAñadidos(listaProductos);
            //let btn_añadir2=document.querySelector('#'+descripcion);
            //btn_añadir2.disabled=false;
        }
        
    }
    //calcularMontoTotal(listaProductos);
    
}
///////////////////////////////////////////////////////////////////////////////////////////

function listarProductosAñadidos(listaProductos){
    if ($.fn.DataTable.isDataTable('#dataTable-productos-compras')) {
        $('#dataTable-productos-compras').DataTable().destroy();
    }
    $('#dataTable-productos-compras tbody').html("");
    
    if (listaProductos.length>0){
        //btnGuardarVenta.disabled=false;
        for (i = 0; i < listaProductos.length; i++) {
            let fila = `<tr class="text-center">`;
            fila += `<td>
                        <button type="button" class="btn btn-danger btn-sm rounded-circle" value="${listaProductos[i].id}" onclick="removerProducto(${listaProductos[i].id})"> 
                            <i class="bi bi-x"></i>
                        </button>
                    </td>`;
            fila += `<td>` + listaProductos[i].nombre + `</td>`;
            fila += `<td> <input type="number" class="form-control" id="id_pcp_${listaProductos[i].id}" > </td>`;
            fila += `<td> <input type="number" class="form-control dc" id="id_cantidad" value="${parseInt(listaProductos[i].cant_min)}"> </td>`;
            fila += `<td> <input type="number" class="form-control" id="id_subtotal"> </td>`
            fila += `</tr>`;
            $('#dataTable-productos-compras tbody' ).append(fila);
        }
    }else{
        //btnGuardarVenta.disabled=true;
    }
    $('#dataTable-productos-compras').DataTable({
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
        lengthMenu: [3, 5, 10],

    })
    
    
    

}
///////////////////////////////////////////////////////////////////////////////////////////

function borrarBuscador(){
    inptBuscadorProducto.value='';
    divSearchResult.innerHTML='';
}

function cargarDatosDetalleVenta(){
    
    $(document).on("click", ".btn-agregar-detalle", function(){
        let fila = $(this).closest("tr");                 
        let codigo = fila.find('td:eq(0)').text(); //capturo el ID
        let descripcion = fila.find('td:eq(1)').text();
        let precio = fila.find('td:eq(2)').text();


        document.getElementById('codigo_medicamento').value=codigo;
        document.getElementById('descripcion_medicamento').value=descripcion;
        document.getElementById('precio').value=precio;
        
    })
}

function obtenerDatosDetalleCompra(){
    $('#dataTable-productos-compras tbody tr').each(function(){
        let fila = $(this).closest("tr");                 
        let codigo = fila.find('td:eq(0)').children().val(); //capturo el ID
        let precio = fila.find('td:eq(2)').children().val();
        let cantidad = fila.find('td:eq(3)').children().val();
        let subtotal = fila.find('td:eq(4)').children().val();
        
        let variable_guia=false;
        let posicion=0;
        if (listaProductos.length > 0) {
            for(let i=0; i<listaProductos.length;i++){
                if(listaProductos[i].id==codigo){
                    variable_guia=true;
                    posicion=i;
                }
            }
            if(variable_guia){
                listaProductos[posicion]['cant_min']=cantidad;
                listaProductos[posicion]['precio']=precio;
                listaProductos[posicion]['subtotal']=subtotal;
            }
        } 
    })

}
///////////////////////////////////////////////////////////////////////////////////////////

async function guardarCompra(){
    const f = new Date();
    const fecha=f.getFullYear()+ "-" + (f.getMonth() +1) + "-" +f.getDate();
    try {
        obtenerDatosDetalleCompra();
        const form = new FormData(document.querySelector('#form-registrar-compra'));
        form.set('serie',form.get('serie').trim());
        form.set('numero',form.get('numero').trim());
        form.set('impuesto',form.get('impuesto').trim());
        form.set('monto_total',form.get('monto_total').trim());
        form.append('usuario',(document.querySelector('#id_user').textContent).trim());
        form.append('fecha_registro',fecha);

        let appendProductos = {};
        let productos_ready={}
        for (let i = 0; i < listaProductos.length; i++) {
            let formDetalleCompra = {};
            //formDetalleVenta['id_venta'] = id_venta;
            formDetalleCompra['id_producto'] = listaProductos[i]['id'];
            formDetalleCompra['precio'] = listaProductos[i]['precio'];
            formDetalleCompra['cantidad'] = listaProductos[i]['cant_min'];
            formDetalleCompra['subtotal'] = listaProductos[i]['subtotal'];
            //registrarDetalleAtencion(formDetalleVenta);
            appendProductos[i]=formDetalleCompra
        }
        productos_ready['productos']=appendProductos
        form.append('detalle_compra',JSON.stringify(productos_ready))
        if (listaProductos.length>0){
            if (form.get('id_proveedor')!=''&&form.get('id_tipo_documento')!=''&&form.get('serie')!=''
            &&form.get('numero')!=''&&form.get('monto_total')!=''&&form.get('impuesto')!=''&&form.get('fecha')!='') {
                const response = await fetch('/compras/registrar_compra/',{
                    method:'POST',
                    body: form,
                    headers:{"X-CSRFToken":getCookie('csrftoken')}
                });
                const result = await response.json();
                const {status}= result;
                const {mensaje}=result;
                const {id_compra}=result;
                if (status){
                    imprimirMessage("Éxito",mensaje,'success');
                    traspasoProductos(form.get('fecha'),id_compra);
                    cleanData();
                }else{
                    const {error}=result;
                    contentError.innerHTML='';        
                    Object.entries(error).forEach(([key, value]) => {
                        contentError.innerHTML+=`<p> -> ${key}: ${value}</p>`
                    });              
                    imprimirMessage("Sistema",mensaje,'info');
                }
            } else {
                imprimirMessage('Sistema','Complete o seleccione los campos necesarios para registrar la compra','info')
                document.querySelector('#form-registrar-compra').classList.add('was-validated');   
            }
            
        }else{
            imprimirMessage("Sistema", "Añada productos para registrar su compra","info");

        }
    } catch (error) {
        console.log(error);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}

function cleanData(){
    document.querySelector('#form-registrar-compra').classList.remove('was-validated');   
    contentError.innerHTML='';
    inpProveedor.value='';
    inptTipoDoc.value='';
    inpSerie.value='';
    inptNumero.value='';
    inptImpuesto.value='';
    inptMontoTotal.value='';
    dateFecha.value='';
    listaProductos=[]
    borrarBuscador();
    if ($.fn.DataTable.isDataTable('#dataTable-productos-compras')) {
        $('#dataTable-productos-compras').DataTable().destroy();
    }
    $('#dataTable-productos-compras tbody').html("");
    $('#dataTable-productos-compras').DataTable({
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
        lengthMenu: [3, 5, 10],
    })
}
///////////////////////////////////////////////////////////////////////////////////////////
function traspasoProductos(fecha_llegado,id_compra){
    const f = new Date();
    let mes =(f.getMonth() +1);
    if (parseInt(f.getMonth() +1)<10){
        mes = '0'+mes;
    }
    const hoy = f.getFullYear()+ "-" + mes + "-" +f.getDate();
    
    if (fecha_llegado==hoy) {
        Swal.fire({
            "title": "Entrada de productos",
            "text": "La fecha de compra ingresada coincide con la de hoy. ¿Desea traspasar los productos de esta compra a su inventario?",
            "icon": "question",
            "showCancelButton": true,
            "cancelButtonText": "No, cancelar",
            "confirmButtonText": "Sí, traspasar",
            "confirmButtonColor": "#3CB371"
        }).then(function (result){
            if (result.isConfirmed){
                confirmarTraspasoProductos(id_compra);
            }else{
                imprimirMessage("Éxito","Compra registrada correctamente","success");
            }
        })
    }
}

async function confirmarTraspasoProductos(id){
    try {
        const response = await fetch("/compras/actualizar_stock_compra/" + id + "/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error actualizar stock","error");
    }
}