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
var txtPropietario=document.querySelector('#txtPropietario')
var inpNombreMascota=document.querySelector('#nombre_mascota');
const btnRecordatorioAtencion=document.querySelector('#btn-recordatorio-atencion');
let divContentPayCard=document.querySelector('#content-paycard');

//let btnPayCard=document.querySelector('#btn-paycard');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    $('#dataTable-servicio').DataTable({
        info:false,
        searching:false,
        language: {
            decimal: "",
            emptyTable: "Busque una mascota para listar sus servicios",
            infoEmpty: "",
            infoFiltered: "(Filtrado de _MAX_ total entradas)",
            thousands: ",",
            lengthMenu: "Mostrar _MENU_ Entradas",
            loadingRecords: "Cargando...",
            processing: "Procesando...",
            zeroRecords: "Sin resultados encontrados",
            paginate: {
                first: "Primero",
                last: "Ultimo",
                next: "Siguiente",
                previous: "Anterior",
            },
        },
        lengthMenu: [3, 5, 10],
        
    });
    $('#servicios-añadidos').DataTable({
        info:false,
        searching:false,
        language: {
            decimal: "",
            emptyTable: "Añada servicios para listarlo aquí",
            infoEmpty: "",
            infoFiltered: "(Filtrado de _MAX_ total entradas)",
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
        
    });

    txtPropietario.disabled=true;
    inpNombreMascota.disabled=true;
    btnRecordatorioAtencion.disabled=true;
    //btnPayCard.disabled=true;
    slctTipoPago.value='';
    //slctTipoPago.disabled=true;
   
})



///////////////////////////////////////////////////////////////////////////
const btnBuscarMascota=document.querySelector('#btn-buscar-mascota');
btnBuscarMascota.addEventListener('click',buscarMascotaXnumero);

///////////////////////////////////////////////////////////////////////////
var divNumero = document.querySelector('#id_numero_historia');
var id_mascota = 0;
async function buscarMascotaXnumero(){       
    try {
        let numeroHistoria=(divNumero.value).trim();
        if (numeroHistoria!=''){
            const response = await fetch("/buscar_mascota/"+numeroHistoria+"/");
            const result = await response.json();
            const {status} = result;
            if (status){
                let resultado = JSON.parse(result.mascota);
                if (resultado[0].fields.estado) {
                    inpNombreMascota.value=resultado[0].fields.nombre;
                    id_mascota = resultado[0].pk;
                    const {cliente}=result;
                    let resultadoPropietario=JSON.parse(cliente);
                    txtPropietario.value=resultadoPropietario[0].fields.nombre +" "+resultadoPropietario[0].fields.apellido;
                    let resultServices=JSON.parse(result.servicios)

                    verificarRecordatorio();
                

                    if ($.fn.DataTable.isDataTable('#dataTable-servicio')) {
                        $('#dataTable-servicio').DataTable().destroy();
                    }
                    $('#dataTable-servicio tbody').html("");
                    for (i = 0; i < resultServices.length; i++) {
                        let fila = `<tr>`;
                        fila += `<td>` + parseInt(i+1) + `</td>`;
                        fila += `<td>` + resultServices[i].fields.descripcion + `</td>`;
                        fila += `<td>` + resultServices[i].fields.precio + `</td>`;
                        fila += `<td> 
                                    <button type="button" class="btn btn-success btn-sm" id="${(resultServices[i].fields.descripcion).split(" ").join("")}"
                                    onclick="añadirServicios(${resultServices[i].pk},
                                        '${resultServices[i].fields.descripcion}',${resultServices[i].fields.precio}
                                        )"> 
                                        <i class="bi bi-plus-circle"></i>
                                    </button>
                                </td>`;
                        $('#dataTable-servicio tbody').append(fila);
                    }
                    $('#dataTable-servicio').DataTable({
                        info:false,
                        searching:false,
                        language: {
                            decimal: "",
                            emptyTable: "Busque una mascota para listar sus servicios",
                            //info: "Mostrando _START_ a _END_ de _TOTAL_ Entradas",
                        // infoEmpty: "Mostrando 0 to 0 of 0 Entradas",
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
                } else {
                    imprimirMessage('Sistema','La mascota se encuentra de baja. Actualice su estado para continuar','info');
                }
            }else{
                const {mensaje}=result;
                imprimirMessage('Sistema',mensaje,'info');
            }
        }else{
            imprimirMessage('Sistema','Ingrese una historia a buscar','info');
        }
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
var id_recordatorio=0;
async function verificarRecordatorio(){
    const f = new Date();
    const fecha=f.getFullYear()+ "-" + (f.getMonth() +1) + "-" +f.getDate();
    try {
        let numero=(divNumero.value).trim()
        const response= await fetch('/buscar_recordatorio/'+numero+'/'+fecha+'/');
        const result = await response.json();
        
        
        const {status}=result;
        if (status){
            btnRecordatorioAtencion.disabled=false;
            const {recordatorio}=result;
            const {mensaje}=result;
            $('#table-recordatorio tbody').html("");           
            for(let i=0;i<recordatorio.length;i++){
                let fila = `<tr>`;
                fila += `<td>` + recordatorio[i][0] + `</td>`;
                fila += `<td>` + recordatorio[i][2] + `</td>`;
                fila += `<td><button type="button" id="id_${recordatorio[i][3]}" class="btn btn-primary btn-sm" onclick="marcarRecordatorio(${recordatorio[i][3]})" ><i class="bi bi-check-lg"></i></button></td>`;
                fila += `</tr>`;
                $('#table-recordatorio tbody').append(fila);
            }  
            id_recordatorio=recordatorio[0][3];
            imprimirMessage("¡Recordatorio Activo!",mensaje,"success");
        }else{
            btnRecordatorioAtencion.disabled=true;
        }
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
//const btnMarcarRecordatorio=document.querySelector('#btn-marcar-recordatorio-id');

//btnMarcarRecordatorio.addEventListener('click',marcarRecordatorio);
async function marcarRecordatorio(id_recordatorio){
    try {
        const response = await fetch('/marcar_recordatorio/'+id_recordatorio+'/');
        const result = await response.json();
        
        const {mensaje}= result;
        document.querySelector(`#id_${id_recordatorio}`).disabled=true;
        console.log(mensaje);
    } catch (error) {
        console.log(error)
    }
}
///////////////////////////////////////////////////////////////////////////
var listaServicios=[]

function añadirServicios(id, descripcion, precio){
    listaServicios.push({'id':id,'descripcion':descripcion,'precio':precio});

    let btn_añadir=document.querySelector('#'+descripcion.split(" ").join(""));
    btn_añadir.disabled=true;
    listarServiciosAñadidos(listaServicios); 

}
///////////////////////////////////////////////////////////////////////////

var acum=0.0;
var p=document.querySelector('#monto-total');

function listarServiciosAñadidos(listaServicios){
    
    $('#servicios-añadidos').DataTable()
    if ($.fn.DataTable.isDataTable('#servicios-añadidos')) {
        $('#servicios-añadidos').DataTable().destroy();
    }
    $('#servicios-añadidos tbody').html("");
    acum=0.0;
    if (listaServicios.length>0){
        for (i = 0; i < listaServicios.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + parseInt(i+1) + `</td>`;
            fila += `<td>` + listaServicios[i].descripcion + `</td>`;
            fila += `<td>` + listaServicios[i].precio + `</td>`;
            fila += `<td> 
                        <a class="btn btn-danger btn-sm btn-añadir-servicio" onclick="removerServicio(${listaServicios[i].id},'${(listaServicios[i].descripcion).split(" ").join("")}')" >
                        <i class="bi bi-x-circle"></i>
                        </a>
                    </td>`;
            fila += `</tr>`;
            $('#servicios-añadidos').append(fila);
            
            acum=(parseFloat(acum)+parseFloat(listaServicios[i].precio)).toFixed(2);
        }
        
    }/*else{
        acum=0
        btnGenerarAtencion.disabled=true;

        slctTipoPago.value=0;
        slctTipoPago.disabled=true;
        divContentPayCard.innerHTML=""
        divContentPayCard.innerHTML=`
            <button type="button"  id="btn-paycard" class="btn btn-success">
                <i class="bi bi-credit-card"></i>
                Pagar con tarjeta
            </button>
 
        `
        let btnPaycard=document.querySelector('#btn-paycard');   
        btnPaycard.disabled=true;
        
    }*/
    p.textContent=`S/. `+acum;
    
    $('#servicios-añadidos').DataTable({
        info:false,
        searching:false,
        language: {
            decimal: "",
            emptyTable: "Añada servicios para listarlo aquí",
            infoEmpty: "",
            infoFiltered: "(Filtrado de _MAX_ total entradas)",
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

///////////////////////////////////////////////////////////////////////////
function removerServicio(id,descripcion){
    for (let i=0;i<listaServicios.length;i++){
        if (listaServicios[i]['id']==id){
            listaServicios[i]['id']
            index=listaServicios.indexOf(listaServicios[i])
            listaServicios.splice(index,1);
            listarServiciosAñadidos(listaServicios);
            let btn_añadir2=document.querySelector('#'+descripcion);
            btn_añadir2.disabled=false;
        }
        
    }
    
}
///////////////////////////////////////////////////////////////////////////
const btnGenerarAtencion=document.querySelector('#btn-generar-atencion');
btnGenerarAtencion.addEventListener('click',registrarAtencion);
async function registrarAtencion(){
    try {
        const form = new FormData(document.querySelector('#form-atencion'))
        
        form.append('usuario',(document.querySelector('#id_user').textContent).trim());
        form.append('monto_total',acum);
        form.append('id_metodo_pago',document.querySelector('#id_metodo_pago').value.trim());
        form.set('numero_historia',form.get('numero_historia').trim());
        form.set('monto_total',form.get('monto_total').trim());
        form.append('id_mascota',id_mascota);
        let appendServicios = {};
        let servicios_ready={}

        for (let i = 0; i < listaServicios.length; i++) {
            let formDetalleServicio = {};
            //formDetalleVenta['id_venta'] = id_venta;
            formDetalleServicio['id_servicio'] = listaServicios[i]['id'];
            formDetalleServicio['monto'] = listaServicios[i]['precio'];
            //formDetalleServicio['cantidad'] = listaServicios[i]['cant_min'];
            //formDetalleServicio['subtotal'] = parseInt(listaServicios[i]['cant_min']) * parseFloat(listaProductos[i]['precio']);
            //registrarDetalleAtencion(formDetalleVenta);
            appendServicios[i]=formDetalleServicio
              
        }
        servicios_ready['servicios']=appendServicios
        form.append('detalle_atencion',JSON.stringify(servicios_ready));
        
        if(listaServicios.length>0){
            if(form.get('id_metodo_pago')!=''){
                const response = await fetch('/registrar_atencion/',{
                    method:'POST',
                    body: form,
                    headers:{"X-CSRFToken":getCookie('csrftoken')}
                });
                const result = await response.json();
                const {status}= result;
                if (status){
                    const {mensaje}=result;
                    imprimirMessage("Éxito",mensaje,'success')
                    cleanData();
                    // cleanModal();
                    
                }else{
                    const {mensaje}=result;
                    imprimirMessage("Sistema",mensaje,'error')
                }
            }else{
                imprimirMessage("Sistema", "Seleccione un método de pago","info")
            }
        }else{
            imprimirMessage("Sistema", "Añada servicios para registrar la atención","info")

        }
        
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////
let slctTipoPago=document.querySelector("#id_metodo_pago");
//slctTipoPago.addEventListener('change',pruebaPago);
/*function pruebaPago(){
    const tipo=slctTipoPago.value;
    if(tipo==2 && listaServicios.length>0){


        let array=[];
        
        let appendServicios = {};
        let servicios_ready={}
        for(let i=0; i<listaServicios.length; i++){   
            let formDetalleServicio = {};       
            //formDetalleVenta['id_atencion']=id_atencion;
            formDetalleServicio['id_servicio']=listaServicios[i]['id'];
            formDetalleServicio['monto']=listaServicios[i]['precio'];
            //registrarDetalleAtencion(formDetalleVenta);
            
            appendServicios[i]=formDetalleServicio;
        }
        servicios_ready['servicios']=appendServicios;
        let listaAt={}
        let atencion={}
        const form = new FormData(document.querySelector('#form-atencion'))
        listaAt['usuario']=(document.querySelector('#id_user').textContent).trim();
        listaAt['id_metodo_pago']=document.querySelector('#id_metodo_pago').value.trim();
        listaAt['numero_historia']=form.get('numero_historia').trim();
        listaAt['monto_total']=acum;
        atencion['atencion']=listaAt
        //array.push(atencion)
        //array.push(servicios_ready)


        const strAtencion=JSON.stringify(atencion);
        const strservicios=JSON.stringify(servicios_ready);
        console.log(strAtencion)
        console.log(strservicios)
        divContentPayCard.innerHTML=""
        divContentPayCard.innerHTML=`
                
                <a href='/test_pago/${strAtencion}/${strservicios}/'   class="btn btn-success" >
                    <i class="bi bi-credit-card"></i>
                    Pagar con tarjeta
                </a>
                `
        //console.log(`<a href='/test_pago/${arrayReady}/'   class="btn btn-success" >Pagar con tarjeta pex</a>`)
        btnGenerarAtencion.disabled=true;
    }else if(tipo==1 && listaServicios.length>0){
        divContentPayCard.innerHTML=""
        divContentPayCard.innerHTML=`
            <button type="button"  id="btn-paycard" class="btn btn-success">
                <i class="bi bi-credit-card"></i>
                Pagar con tarjeta
            </button>
 
        `
        let btnPaycard=document.querySelector('#btn-paycard');   
        btnPaycard.disabled=true;
        btnGenerarAtencion.disabled=false;
    }else{
        divContentPayCard.innerHTML=""
        divContentPayCard.innerHTML=`
            <button type="button"  id="btn-paycard" class="btn btn-success">
                <i class="bi bi-credit-card"></i>
                Pagar con tarjeta
            </button>
 
        `
        let btnPaycard=document.querySelector('#btn-paycard');   
        btnPaycard.disabled=true;
        btnGenerarAtencion.disabled=true;

    }
}*/
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    id_mascota=0;
    id_recordatorio=0;
    p.textContent=`S/. 00.00`;
    divNumero.value="";
    txtPropietario.value="";
    inpNombreMascota.value=""
    btnRecordatorioAtencion.disabled=true;
    if ($.fn.DataTable.isDataTable('#servicios-añadidos')) {
        $('#servicios-añadidos').DataTable().destroy();
    }
    $('#servicios-añadidos tbody').html("");

    $('#servicios-añadidos').DataTable({
        info:false,
        searching:false,
        language: {
            decimal: "",
            emptyTable: "Añada servicios para listarlo aquí",
            infoEmpty: "",
            infoFiltered: "(Filtrado de _MAX_ total entradas)",
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
        
    });


    if ($.fn.DataTable.isDataTable('#dataTable-servicio')) {
        $('#dataTable-servicio').DataTable().destroy();
    }
    $('#dataTable-servicio tbody').html("");

    $('#dataTable-servicio').DataTable({
        info:false,
        searching:false,
        language: {
            decimal: "",
            emptyTable: "Busque una mascota para listar sus servicios",
            infoEmpty: "",
            infoFiltered: "(Filtrado de _MAX_ total entradas)",
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
        
    });
    acum=0;
    listaServicios=[];
    slctTipoPago.value='';
}
///////////////////////////////////////////////////////////////////////////
function cleanModal(){
    document.querySelector('#servicio-id').value="";
    document.querySelector('#fecha-id').value="";
    document.querySelector('#comentario-id').value="";
    id_recordatorio=0;
    id_mascota=0;
}
///////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}
