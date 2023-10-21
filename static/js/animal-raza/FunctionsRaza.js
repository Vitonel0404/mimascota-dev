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

var cboAnimal=document.querySelector('#id_id_animal');
const btnModificarRaza=document.querySelector("#btn-modificar-raza");
var inpDescripcionRaza=document.querySelector('#id_descripcion');

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    btnModificarRaza.disabled=true;
    listarRazas();
});
///////////////////////////////////////////////////////////////////////////
const btnModalRaza=document.querySelector('#btn-modal-raza');
btnModalRaza.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////
async function listarRazas(){
    try {
        const response = await fetch("/listar_raza/");
        const result = await response.json();
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for(i=0;i<result.razas.length;i++){    
            let fila = `<tr>`;
            fila += `<td>` + result.razas[i][2] +`</td>`;
            fila += `<td>` + result.razas[i][3] + `</td>`;
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#"  class="btn-cargarDatosRaza-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos('${result.razas[i][0]}','${result.razas[i][1]}','${result.razas[i][3]}')">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarRaza('`+ result.razas[i][0] + `')">
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

const btnGuardarRaza= document.querySelector('#btn-guardar-raza');
btnGuardarRaza.addEventListener('click',guardarFormRaza);

function guardarFormRaza(){
    try {
        const form= new FormData(document.querySelector('#form-raza'));
        form.set('descripcion',form.get('descripcion').trim())
        if (form.get('id_animal')!='' && form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            fetch("/raza/",{
                method:'POST',
                body:form,
                headers:{
                    "X-CSRFToken":getCookie('csrftoken'),
                }
            }).then(
                function(response){
                    return response.json()
                }
            ).then(
                function(result){
                    const {status}=result;
                    const {mensaje}=result;
                    if (status){
                        listarRazas();
                        imprimirMessage("Éxito", mensaje,"success");
                        cleanData();
                    }else{
                        const {error}=result;
                        contentError.innerHTML='';        
                        Object.entries(error).forEach(([key, value]) => {
                            contentError.innerHTML+=`<p> -> ${value}</p>`
                        });
                        imprimirMessage("Sistema", mensaje,"info");
                    }
                }
            )
        }else{
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-raza').classList.add('was-validated');
        }
    } catch (error) {
        console.log(error);
        imprimirMessage("Sistema", "Error al registrar Raza","error");
    }
}

///////////////////////////////////////////////////////////////////////////

var id_g=0;

function cargarDatos(id_raza,id_animal, raza){
    document.querySelector('#form-raza').classList.remove('was-validated');
    contentError.innerHTML='';
    id_g=id_raza;
    cboAnimal.value=id_animal;
    inpDescripcionRaza.value=raza
    btnModificarRaza.disabled=false;
    btnGuardarRaza.disabled=true;
    
}

///////////////////////////////////////////////////////////////////////////


btnModificarRaza.addEventListener('click',modificarRaza)

function modificarRaza(){
    try {
        if(id_g!=0){
            const form= new FormData(document.querySelector('#form-raza'));
            form.set('descripcion',form.get('descripcion').trim())
            if (form.get('id_animal')!='' && form.get('descripcion')!=''){
                form.append('id_empresa',document.querySelector('#id_empresa').textContent);
                fetch("/modificar_raza/"+id_g+"/",{
                    method:'POST',
                    body:form,
                    headers:{
                        "X-CSRFToken":getCookie('csrftoken'),
                    }
                }).then(
                    function (response){
                        return response.json();
                    }
                ).then(
                    function (result){
                        const {status}=result;
                        const {mensaje}=result;
                        if (status){                         
                            imprimirMessage("Éxito",mensaje,"success");
                            listarRazas();
                            cleanData();
                        }else{
                            contentError.innerHTML='';
                            const {error}=result;
                            Object.entries(error).forEach(([key, value]) => {
                                console.log(key)
                                console.log(value)
                                contentError.innerHTML+=`<p> -> ${value}</p>`
                            });
                            imprimirMessage("Sistema",mensaje,"info");
                        }
                    }
                )
            }else{
                imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
                document.querySelector('#form-raza').classList.add('was-validated');
            }
            
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Erro al modificar raza","error");
    }
}
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    id_g=0;
    cboAnimal.value='';
    inpDescripcionRaza.value='';
    btnModificarRaza.disabled=true;
    btnGuardarRaza.disabled=false;
    document.querySelector('#form-raza').classList.remove('was-validated');
    contentError.innerHTML='';
}
///////////////////////////////////////////////////////////////////////////

function eliminarRaza(id) {

    Swal.fire({
        "title": "¿Estás seguro?",
        "text": "Esta acción no se puede revertir",
        "icon": "question",
        "showCancelButton": true,
        "cancelButtonText": "No, cancelar",
        "confirmButtonText": "Sí, eliminar",
        "confirmButtonColor": "#dc3545"
    }).then(function (result){
        if (result.isConfirmed){
            confirmarEliminar(id);
        }
    })
}
async function confirmarEliminar(id){
    try {
        console.log(id)
        const response = await fetch("/eliminar_raza/" + id + "/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarRazas();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar raza","error");
    }
}
//////////////////////////////////////////////////////////////////////////

function imprimirMessage(title, message, icon) {
    Swal.fire({
        "title": title,
        "text": message,
        "icon": icon
    })
}
