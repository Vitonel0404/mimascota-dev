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
let valorIGV=0;
$(document).ready(function(){
    consultarValorIGV();
    $('#dataTable-buscar-producto').DataTable({
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

let contentError=document.querySelector('.content-errors');

const inptBuscadorProducto=document.querySelector('#buscador-producto');
inptBuscadorProducto.addEventListener('keyup',buscarProducto);

const btnLimpiarBuscador=document.querySelector('#btn-borrarBuscador');
btnLimpiarBuscador.addEventListener('click',borrarBuscador);

const divSearchResult=document.querySelector('#list-search');

const btnBuscarCliente=document.querySelector('#btn-buscar-cliente');
btnBuscarCliente.addEventListener('click',buscarCliente);

const divDNI=document.querySelector('#id_id_cliente');
const nombre = document.querySelector('#id_nombre_cliente');
const cboComprobante=document.querySelector('#id_id_tipo_comprobante');
const cboMetodoPago=document.querySelector('#id_id_metodo_pago');

let txtTotal=document.querySelector('#id_monto_total');
let pIGV=document.querySelector('#id_igv');
let pOperacion_gravada=document.querySelector('#id_operacion_gravada');
///////////////////////////////////////////////////////////////////////////////////////////

function buscarProducto(){
    
    let producto=(inptBuscadorProducto.value).trim();
    if(producto.length>0 ){
        try {
            fetch('/ventas/buscar_producto/'+producto+'/').then(
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
                                    <a href="#" style="word-wrap: break-word"  class="list-group-item dropdown-item " onclick="añadirProductos(${productos[i][5]},'${productos[i][8]}',
                                                                                                ${productos[i][1]})">
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
function añadirProductos(pk, nombre,precio){
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
            listaProductos[posicion]['cant_min']=listaProductos[posicion]['cant_min']+1
        }else{
            listaProductos.push({ 'id': pk, 'nombre': nombre, 'precio': precio, 'cant_min': 1 });  
        }
        listarProductosAñadidos(listaProductos);

    } else {
        listaProductos.push({ 'id': pk, 'nombre': nombre, 'precio': precio, 'cant_min': 1 });
        listarProductosAñadidos(listaProductos);
    }

    calcularMontoTotal(listaProductos);
    //let btn_añadir=document.querySelector('#'+descripcion.split(" ").join(""));
    //btn_añadir.disabled=true;

}

///////////////////////////////////////////////////////////////////////////////////////////


function consultarValorIGV(){
    try {
        fetch('/ventas/consultar_parametro/igv/').then(
            function (response){
                return response.json()
            }
        ).then(
            function(result){
                const {status}=result;
                const parametro=JSON.parse(result.parametro);
                if(status){
                    valorIGV= parseFloat(parametro[0].fields.valor)
                }
            }
        ).catch(
            function(error){
                console.log(error)
                //imprimirMessage('Error', 'Error de consulta al servidor', 'error')
            }
        )
        
    } catch (error) {
        
    }
}

let acumMT=0;
let operacion_gravada=0;
let igv=0;
function calcularMontoTotal(listaProductos){
    acumMT=0;
    operacion_gravada=0;
    igv=0;
    
    for(let i=0;i<listaProductos.length;i++){
        acumMT=acumMT + parseFloat(((listaProductos[i].cant_min)*(listaProductos[i].precio)).toFixed(2));
        igv=parseFloat(((acumMT/100)*valorIGV).toFixed(2));
        operacion_gravada=parseFloat((acumMT-igv).toFixed(2));
    }
    pIGV.textContent='S/.'+igv;
    pOperacion_gravada.textContent='S/.'+operacion_gravada;
    txtTotal.textContent='S/.'+acumMT;
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
    calcularMontoTotal(listaProductos);
    
}
///////////////////////////////////////////////////////////////////////////////////////////

function listarProductosAñadidos(listaProductos){
    if ($.fn.DataTable.isDataTable('#dataTable-buscar-producto')) {
        $('#dataTable-buscar-producto').DataTable().destroy();
    }
    $('#dataTable-buscar-producto tbody').html("");
    
    if (listaProductos.length>0){
        btnGuardarVenta.disabled=false;
        for (i = 0; i < listaProductos.length; i++) {
            let fila = `<tr class="text-center">`;
            fila += `<td>
                        <button type="button" class="btn btn-danger btn-sm rounded-circle" onclick="removerProducto(${listaProductos[i].id})"> 
                            <i class="bi bi-x"></i>
                        </button>
                    </td>`;
            fila += `<td>` + listaProductos[i].nombre + `</td>`;
            fila += `<td>` + listaProductos[i].precio + `</td>`;
            fila += `<td> ${parseInt(listaProductos[i].cant_min)} </td>`;
            fila += `<td>`+ parseFloat((parseInt(listaProductos[i].cant_min)*parseFloat(listaProductos[i].precio)).toFixed(2))+`</td>`
            fila+= `<td>    <a href="#" onclick="disminuirProducto(${listaProductos[i].id})" >
                                <i class="bi bi-dash-circle"></i>
                            </a>
                            <a href="#" onclick="aumentarProducto(${listaProductos[i].id})"    >
                                <i class="bi bi-plus-circle"></i>
                            </a>
                    </td>`;
            fila += `</tr>`;
            $('#dataTable-buscar-producto tbody' ).append(fila);
        }
    }else{
        btnGuardarVenta.disabled=true;
    }
    $('#dataTable-buscar-producto').DataTable({
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
///////////////////////////////////////////////////////////////////////////////////////////

function aumentarProducto(pk){
    for (let i=0;i<listaProductos.length;i++){
        if (listaProductos[i]['id']==pk){
            
            index=listaProductos.indexOf(listaProductos[i])
            //listaProductos.splice(index,1);
            listaProductos[index]['cant_min']=listaProductos[index]['cant_min']+1
            listarProductosAñadidos(listaProductos);
            //let btn_añadir2=document.querySelector('#'+descripcion);
            //btn_añadir2.disabled=false;
        }
        
    }
    calcularMontoTotal(listaProductos);

}
///////////////////////////////////////////////////////////////////////////////////////////

function disminuirProducto(pk){
    for (let i=0;i<listaProductos.length;i++){
        if (listaProductos[i]['id']==pk){
            
            index=listaProductos.indexOf(listaProductos[i])
            if(listaProductos[index]['cant_min']>1){
                listaProductos[index]['cant_min']=listaProductos[index]['cant_min']-1
                listarProductosAñadidos(listaProductos);
            }
        }
        
    }
    calcularMontoTotal(listaProductos);
}
///////////////////////////////////////////////////////////////////////////////////////////
var id_cliente=0;
async function buscarCliente(){
    try {
        
        let dni=divDNI.value.trim();
        if(dni!=''){
            const response=await fetch("/consultar_cliente/"+dni+"/");
            const result = await response.json();
            const {status}=result;
            if (status){
                let resultado = JSON.parse(result.cliente);
                if (resultado[0].fields.estado===true){
                    id_cliente=resultado[0].pk;
                    let nom=resultado[0].fields.nombre;
                    let ape=resultado[0].fields.apellido;
                    nombre.value=nom+' '+ape;
                }else{
                    imprimirMessage("Sistema","El cliente de encuentra de baja",'info');
                    contentError.innerHTML='';
                    divDNI.value='';
                    nombre.value='';
                    cboMetodoPago.value='';
                    cboComprobante.value='';
                    id_cliente=0;
                }
            }else{
                const {cliente}=result
                imprimirMessage("Sistema",cliente,'info');
                contentError.innerHTML='';
                divDNI.value='';
                nombre.value='';
                cboMetodoPago.value='';
                cboComprobante.value='';
                id_cliente=0;
            }            
        }else{
            imprimirMessage("Sistema","Ingrese un DNI a buscar",'info');
            contentError.innerHTML='';
            divDNI.value='';
            nombre.value='';
            cboMetodoPago.value='';
            cboComprobante.value='';
            id_cliente=0;
        }
        
    } catch (error) {
        console.log()
    }
}
///////////////////////////////////////////////////////////////////////////////////////////
const btnGuardarVenta=document.querySelector('#btn-guardar-venta');
btnGuardarVenta.addEventListener('click',registrarVenta);
async function registrarVenta(){
    const f = new Date();
    const fecha=f.getFullYear()+ "-" + (f.getMonth() +1) + "-" +f.getDate();
    try {
        const form = new FormData(document.querySelector('#form-registrar-venta'));
        form.append('id_cliente',id_cliente);
        form.append('usuario',(document.querySelector('#id_user').textContent).trim());
        form.append('monto_total',acumMT);
        form.append('operacion_gravada',operacion_gravada);
        form.append('porcentaje_igv',valorIGV);
        form.append('igv',igv);
        form.append('fecha',fecha.trim());
        //form.append('id_metodo_pago',document.querySelector('#id_metodo_pago').value.trim());
        form.set('monto_total',form.get('monto_total').trim());

        let appendProductos = {};
        let productos_ready={}
        for (let i = 0; i < listaProductos.length; i++) {
            let formDetalleVenta = {};
            //formDetalleVenta['id_venta'] = id_venta;
            formDetalleVenta['id_producto'] = listaProductos[i]['id'];
            formDetalleVenta['precio'] = listaProductos[i]['precio'];
            formDetalleVenta['cantidad'] = listaProductos[i]['cant_min'];
            formDetalleVenta['subtotal'] = parseInt(listaProductos[i]['cant_min']) * parseFloat(listaProductos[i]['precio']);
            //registrarDetalleAtencion(formDetalleVenta);
            appendProductos[i]=formDetalleVenta
            
            
        }
        productos_ready['productos']=appendProductos

        form.append('detalle_venta',JSON.stringify(productos_ready))

        if (listaProductos.length>0){
            if (id_cliente!=0) {
                console.log(form.get('id_cliente'),form.get('id_tipo_comprobante'),form.get('id_metodo_pago'));
                if (form.get('id_cliente').length>=0&&form.get('id_tipo_comprobante')!=''&&form.get('id_metodo_pago')!='') {
                    const response = await fetch('/ventas/registrar_venta/',{
                        method:'POST',
                        body: form,
                        headers:{"X-CSRFToken":getCookie('csrftoken')}
                    });
                    const result = await response.json();
                    const {status}= result;
                    const {mensaje}=result;
                    const {id_venta}=result;
                    if (status){
                        imprimirComprobante(mensaje,'¿Desea imprimir el comprobante de esta venta?','success',id_venta);
                        cleanData();
                    }else{
                        const {error}=result;
                        contentError.innerHTML='';        
                        Object.entries(error).forEach(([key, value]) => {
                            contentError.innerHTML+=`<p> -> ${value}</p>`
                        });
                        imprimirMessage("Sistema",mensaje,'error');
                    }
                } else {
                    imprimirMessage('Sistema','Complete o seleccione los campos necesarios para registrar la venta','info')
                    document.querySelector('#form-registrar-venta').classList.add('was-validated');
                }
            } else {
                imprimirMessage('Sistema','Ingrese un DNI y busque a un cliente','info')
            }
        }else{
            imprimirMessage("Sistema", "Busque y añada productos para registrar una venta","info");

        }
        
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////////////////////
/*
async function registrarDetalleVenta(formDetalleVenta){
    try {
        const arrayReady=JSON.stringify(formDetalleVenta)
        const response = await fetch('/registrar_detalle_venta/',{
            method:'POST',
            body:arrayReady,
            headers:{"X-CSRFToken":getCookie('csrftoken')}
        });
        const result = await response.json();
        const {status} = result;
        const {mensaje} = result;
        if (status){
            imprimirMessage("Éxito", mensaje,"success")
        }else{
            imprimirMessage("Error", mensaje,"error")
        }
    } catch (error) {
        console.log(error)
    }
}*/
///////////////////////////////////////////////////////////////////////////////////////////

function cleanData(){
    document.querySelector('#form-registrar-venta').classList.remove('was-validated');
    contentError.innerHTML='';
    divSearchResult.innerHTML='';
    inptBuscadorProducto.value='';
    divDNI.value='';
    nombre.value='';
    cboMetodoPago.value='';
    cboComprobante.value='';
    txtTotal.textContent='S/.00.00';
    pIGV.textContent='S/.00.00';
    pOperacion_gravada.textContent='S/.00.00';
    listaProductos=[]
    id_cliente=0;
    if ($.fn.DataTable.isDataTable('#dataTable-buscar-producto')) {
        $('#dataTable-buscar-producto').DataTable().destroy();
    }
    $('#dataTable-buscar-producto tbody').html("");
    $('#dataTable-buscar-producto').DataTable({
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

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}

function imprimirComprobante(title='', message='', icon='', id) {

    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon,
        "showCancelButton": true,
        "cancelButtonText": "No, cancelar",
        "confirmButtonText": "Sí, imprimir",
        "confirmButtonColor": "#3CB371"
    })
        .then(function (result) {
            if (result.isConfirmed) {
                confirmarImprimirComprobante(id);
               
            }
        })
}
async function confirmarImprimirComprobante(id){
    
    try {
        const response=await fetch("/ventas/imprimir_comprobante_venta/"+id+"/");
        const result = await response.json();
        imprimirVenta(result) 
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al imprimir","error");
    }
}

function imprimirVenta(ventaData) {
    
    const empresa = JSON.parse(ventaData.empresa);
    const comprobanteDiv = document.createElement('div');
    comprobanteDiv.style.position = 'absolute';
    comprobanteDiv.style.top = '0';

    comprobanteDiv.style.width = '100%';
    const styles = `
    <style>
        @page {
            size: landscape;
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0
        }
        .container-m {
            max-width: 800px;
            margin: 20px auto 0;
            padding: 10px;
        }
        .header-m {
            text-align: center;
        }
        .invoice-details-empresa {
            text-align: left;
            margin-top: 20px;
            width: 50%;
        }
        .invoice-details-numero-doc {
            text-align: right;
            margin-top: 20px;
            width: 50%;
        }
        .invoice-details-empresa p{
            margin: 0px 0;
            font-size:10px
        }
        .invoice-details-numero-doc p{
            margin: 0px 0;
        }
        .negrita {
            font-weight: bold;
        }
        .invoice-details {
            text-align: left;
            margin-top: 10px;
            font-size:13px
        }
        .invoice-details p {
            margin: 0px 0;
        }
        table-imprimir {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #000;
            padding: 8px;
            text-align: left;
        }
        .total {
            margin-top: 20px;
            text-align: left;
            font-size:13px
        }
        .total p{
            margin: 3px 0;
        }

        .flex{
            display:flex;
        }
    </style>
`;

    comprobanteDiv.innerHTML = `
        ${styles}
        <div class="container-m">
            <div class="header-m">

                <div class="flex">

                    <div class="invoice-details-empresa">
                        <h3>${empresa[0].fields.razon_social}</h3>
                        <p> <span class="negrita">${ventaData.data[0][0]} N°:</span> ${ventaData.data[0][1]} </p>
                        <p> <span class="negrita"> RUC:</span> ${empresa[0].fields.ruc} </p>
                        <p> <span class="negrita"> Dirección:</span> ${empresa[0].fields.direccion} - ${empresa[0].fields.ciudad}</p>
                        <p> <span class="negrita"> Teléfono:</span> ${empresa[0].fields.telefono} </p>
                        <p> <span class="negrita"> Correo:</span> ${empresa[0].fields.correo} </p>
                    </div>
                    <div class="invoice-details-numero-doc">
                        <p> <span class="negrita">${ventaData.data[0][0]} DE VENTA</span </p>
                        <p> <span class="negrita">${ventaData.data[0][1]} </span </p>
                    </div>
                </div>
                
            </div>
            

            <div class="invoice-details">
                <p> <span class="negrita">Cliente:</span> ${ventaData.data[0][2]} </p>
                <p> <span class="negrita">DNI:</span> ${ventaData.data[0][2]} </p>
                <p> <span class="negrita">Fecha:</span> ${ventaData.data[0][3]}</p>
                
            </div>

            
            <div class="center">
                <table class="table table-sm text-center">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Unidad</th>
                            <th>Cantidad</th>
                            <th>Precio</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${ventaData.data.map((element,index)=>(
                            `<tr>
                                <td>${element[8]}</td>
                                <td>${element[9]}</td>
                                <td>${element[10]}</td>
                                <td>s/.${element[11]}</td>
                                <td>s/.${element[12]}</td>
                            </tr>`
                        )).join('')}
                        
                    
                    </tbody>
                </table>
            </div>

            <div class="total">
                <p> <span class="negrita">Método de pago:</span> ${ventaData.data[0][4]}</p>
                <p> <span class="negrita">IGV:</span> S/.${ventaData.data[0][5]}</p>
                <p> <span class="negrita">Total:</span> S/.${ventaData.data[0][6]}</p>
            </div>
    `;
    document.body.appendChild(comprobanteDiv);
    window.print();
    document.body.removeChild(comprobanteDiv);
}