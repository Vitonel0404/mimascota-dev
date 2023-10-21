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
var inpDniCliente=document.querySelector('#id_id_cliente');
var inpNombreCliente=document.querySelector('#nombre_cliente');
var inpNombreMascota=document.querySelector('#id_nombre');
var inpEdad=document.querySelector('#id_edad');
var cboSexo=document.querySelector('#id_sexo');
var cboAnimal=document.querySelector('#id_animal');
var cboRaza=document.querySelector('#id_id_raza');
var inptColor=document.querySelector('#id_color');
var inptPeso=document.querySelector('#id_peso');

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    listarMascotas();
});
///////////////////////////////////////////////////////////////////////////
const btnModalMascota=document.querySelector('#btn-modal-mascota');
btnModalMascota.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
async function listarMascotas(){
    try {
        const response = await fetch("/listar_mascotas/");
        const result = await response.json();
        let resultado=result.mascotas;
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i][1] + `</td>`;
            fila += `<td>` + resultado[i][2] + `</td>`;
            fila += `<td>` + resultado[i][3] + `</td>`;
            fila += `<td>` + resultado[i][4] + `</td>`;
            fila += `<td>` + resultado[i][5] + `</td>`;
            if (resultado[i][6]==1){
                fila += `<td>Macho</td>`;
            }else{
                fila += `<td>Hembra</td>`;
            }
            fila += `<td>` + resultado[i][7] + `</td>`;
            fila += `<td>` + resultado[i][8] + `</td>`;
            if (resultado[i][9]){
                fila += `<td><span class="badge bg-success">Activo</span></td>`;  
            }else{
                fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            } 
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-ver-historial" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="ultimasAtenciones(${resultado[i][0]})">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModalForm" onclick="cargarDatos(
                                        ${resultado[i][0]},'${resultado[i][1]}',
                                        '${resultado[i][2]}','${resultado[i][3]}',
                                        '${resultado[i][4]}',${resultado[i][5]},
                                        '${resultado[i][6]}','${resultado[i][7]}',
                                        ${resultado[i][8]},${resultado[i][9]},
                                        ${resultado[i][10]},${resultado[i][11]},
                                        ${resultado[i][12]},${resultado[i][13]}
                                    )">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarMascota(${resultado[i][0]})">
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
const btnGuardarMascota=document.querySelector('#btn-guardar-mascota');
btnGuardarMascota.addEventListener('click',registrarMascota);

async function obtenerNumeroHistoria(){
    try {
        const response = await fetch('/obtener_nuevo_numero_historia_mascota/');
        const result = await response.json()
        return result.nuevoNumero
    } catch (error) {
        console.log(error);
    }
}

async function registrarMascota(){
    try {
        const form = new FormData(document.querySelector('#form-mascota'))
        
        form.set('id_cliente',id_cliente);
        form.set('nombre',form.get('nombre').trim());
        form.set('edad',form.get('edad').trim());
        form.set('color',form.get('color').trim());
        form.set('peso',form.get('peso').trim());
        if (id_cliente!=0) {
            if (form.get('nombre')!=''&&form.get('edad')!=''&&form.get('sexo')!=''&&form.get('id_animal')!=''
            &&form.get('id_raza')!=''&&form.get('color')!=''&&form.get('peso')!=''
            ) {
                let nuevo_numero_historia = await obtenerNumeroHistoria();

                form.append('id_empresa',document.querySelector('#id_empresa').textContent);
                form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
                form.append('numero_historia',nuevo_numero_historia);

                const response = await fetch("/mascota/",{
                    method: 'POST',
                    body:form,
                    headers:{"X-CSRFToken":getCookie('csrftoken'),}
                })
        
                const result = await response.json();
                const {status}=result;
                const {mensaje}=result;
                if (status){
                    imprimirMessage("Éxito",mensaje,"success");
                    listarMascotas();
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
                document.querySelector('#form-mascota').classList.add('was-validated');
            }
            
        } else {
            imprimirMessage("Sistema","Busque un propietario para registrar su mascota","info");
        }
        
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al registrar mascota","error");
    }
}
///////////////////////////////////////////////////////////////////////////
var id_cliente=0;
var id_mascota_g=0;
var numero_historia = 0;
async function cargarDatos(id_mascota,historia, animal, raza,nombre, edad, sexo,color,peso,estado,dni_Cliente,id_animal, id_raza,id_cliente_id){
    document.querySelector('#form-mascota').classList.remove('was-validated');
    contentError.innerHTML='';
    id_cliente=id_cliente_id;
    id_mascota_g=id_mascota;
    numero_historia = historia;
    inpDniCliente.value=dni_Cliente;
    inpNombreCliente.value='';
    inpNombreMascota.value=nombre;
    inpEdad.value=edad;
    cboSexo.value=sexo;
    cboAnimal.value=id_animal;
    await filtraRazaXanimal();
    cboRaza.value=id_raza;
    inptColor.value=color;
    inptPeso.value=peso;
    if(estado) {
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnModificarMascota.disabled=false;
    btnGuardarMascota.disabled=true;
}
///////////////////////////////////////////////////////////////////////////
const btnModificarMascota = document.querySelector('#btn-modificar-mascota')
btnModificarMascota.addEventListener('click',modificarMascota);

async function modificarMascota(){
    try {
        const form = new FormData(document.querySelector('#form-mascota'));
        form.set('id_cliente',id_cliente);
        form.set('nombre',form.get('nombre').trim());
        form.set('edad',form.get('edad').trim());
        form.set('color',form.get('color').trim());
        form.set('peso',form.get('peso').trim());
        if (form.get('nombre')!=''&&form.get('edad')!=''&&form.get('sexo')!=''&&form.get('id_animal')!=''
        &&form.get('id_raza')!=''&&form.get('color')!=''&&form.get('peso')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            form.append('id_sucursal',document.querySelector('#sucursal_id').textContent);
            form.append('numero_historia',numero_historia);
            const response = await fetch("/modificar_mascota/"+id_mascota_g+"/",{
                method:'POST',
                body:form,
                headers:{"X-CSRFToken":getCookie('csrftoken')}
            });
            const result = await response.json();
            const {status}=result;
            const {mensaje}=result;
            if (status){
                listarMascotas();
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
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-mascota').classList.add('was-validated');
        }
        

    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al modificar mascota",'error');
    }
}
///////////////////////////////////////////////////////////////////////////
async function ultimasAtenciones(historia){
    try {       
        const response = await fetch("/ultimas_atenciones_mascota/"+historia+"/");
        const result = await response.json();
        const btnAbrirPDF=document.querySelector('#cont-abrir-pdf');
        const {status}=result;
        if(status){
            let resultado=result.servicios         
            $('#tabla-ultimas-atenciones tbody').html("");           
            for(let i=0;i<resultado.length;i++){
                let fila = `<tr>`;
                fila += `<td>` + resultado[i]['descripcion'] + `</td>`;
                fila += `<td>` + resultado[i]['fecha'] + `</td>`;
                fila += `</tr>`;
                $('#tabla-ultimas-atenciones tbody').append(fila);
                
            } 
            
                btnAbrirPDF.innerHTML='';
                btnAbrirPDF.innerHTML=` <a href="/export_historial_mascota_pdf/${historia}/" target="_blank">
                                    <button type="button" class="btn btn-danger">
                                        Ver historial completo
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-filetype-pdf" viewBox="0 0 16 16">
                                            <path fill-rule="evenodd" d="M14 4.5V14a2 2 0 0 1-2 2h-1v-1h1a1 1 0 0 0 1-1V4.5h-2A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v9H2V2a2 2 0 0 1 2-2h5.5L14 4.5ZM1.6 11.85H0v3.999h.791v-1.342h.803c.287 0 .531-.057.732-.173.203-.117.358-.275.463-.474a1.42 1.42 0 0 0 .161-.677c0-.25-.053-.476-.158-.677a1.176 1.176 0 0 0-.46-.477c-.2-.12-.443-.179-.732-.179Zm.545 1.333a.795.795 0 0 1-.085.38.574.574 0 0 1-.238.241.794.794 0 0 1-.375.082H.788V12.48h.66c.218 0 .389.06.512.181.123.122.185.296.185.522Zm1.217-1.333v3.999h1.46c.401 0 .734-.08.998-.237a1.45 1.45 0 0 0 .595-.689c.13-.3.196-.662.196-1.084 0-.42-.065-.778-.196-1.075a1.426 1.426 0 0 0-.589-.68c-.264-.156-.599-.234-1.005-.234H3.362Zm.791.645h.563c.248 0 .45.05.609.152a.89.89 0 0 1 .354.454c.079.201.118.452.118.753a2.3 2.3 0 0 1-.068.592 1.14 1.14 0 0 1-.196.422.8.8 0 0 1-.334.252 1.298 1.298 0 0 1-.483.082h-.563v-2.707Zm3.743 1.763v1.591h-.79V11.85h2.548v.653H7.896v1.117h1.606v.638H7.896Z">
                                            </path>
                                        </svg>
                                    </button>         
                                </a>`               
        }else{
            btnAbrirPDF.innerHTML='';
            $('#tabla-ultimas-atenciones tbody').html("");   
        }             
    } catch (error) {
        console.log(error);
    }
}
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////

function eliminarMascota(id) {

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
        const response = await fetch("/eliminar_mascota/"+id+"/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarMascotas();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar mascota","error");
    }
}

///////////////////////////////////////////////////////////////////////////
const btnBuscarCliente=document.querySelector('#btn-buscar-cliente');
btnBuscarCliente.addEventListener('click',buscarCliente);

async function buscarCliente(){
    try {
        let divDNI=document.querySelector('#id_id_cliente');
        let dni=divDNI.value;
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
                    const nombre = document.querySelector('#nombre_cliente');
                    nombre.value=nom+' '+ape;
                }else{
                    imprimirMessage("Sistema","El cliente de encuentra de baja",'info');
                }
            }else{
                const {cliente}=result
                imprimirMessage("Sistema",cliente,'info');
                inpNombreCliente.value='';
            }            
        }else{
            imprimirMessage("Sistema","Ingrese un DNI a buscar",'info');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al buscar cliente",'error');
    }
}
///////////////////////////////////////////////////////////////////////////

const cboSelect=document.querySelector('#id_animal');
cboSelect.addEventListener('change',filtraRazaXanimal);
async function filtraRazaXanimal(){
    try {
        let animal = document.querySelector('#id_animal');
        let cod_animal=animal.value;
        if (cod_animal!=''){
            const response =await fetch("/consultar_raza/"+cod_animal+"/")
            const result = await response.json();
            let resultado= JSON.parse(result.razas)
            cboRaza.innerHTML='';
            cboRaza.innerHTML+=`<option value='' selected>---------</option>`;
            for(var i=0; i<resultado.length; i++){
                cboRaza.innerHTML+=`<option value=${resultado[i].pk}>${resultado[i].fields.descripcion}</option>`;
            }
        }    
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema","Error al filtrar razas",'error');
    }
}
///////////////////////////////////////////////////////////////////////////

function cleanData(){
    document.querySelector('#form-mascota').classList.remove('was-validated');
    btnModificarMascota.disabled=true;
    btnGuardarMascota.disabled=false;
    id_mascota=0;
    numero_hisotria=0;
    inpDniCliente.value='';
    inpNombreCliente.value='';
    inpNombreMascota.value='';
    inpEdad.value='';
    cboSexo.value='';
    cboAnimal.value='';
    cboRaza.value='';
    inptColor.value='';
    inptPeso.value='';
    id_cliente=0;
    $("#id_estado").prop('checked', true);
    contentError.innerHTML='';
}

///////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}