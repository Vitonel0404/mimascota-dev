
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

var btnModificarAnimal=document.querySelector("#btn-modificar-animal");
var inpDescripcionAnimal=document.querySelector("#id_descripcion");

let contentError=document.querySelector('.content-errors');
///////////////////////////////////////////////////////////////////////////
$(document).ready(function(){
    btnModificarAnimal.disabled=true;
    listarAnimales();
});
///////////////////////////////////////////////////////////////////////////
const btnModalAnimal=document.querySelector('#btn-modal-animal');
btnModalAnimal.addEventListener('click',cleanData);
///////////////////////////////////////////////////////////////////////////

async function listarAnimales() {
    try {
        const response = await fetch("/listar_animal/");
        const result = await response.json();
        let resultado = JSON.parse(result.animales)
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        for (i = 0; i < resultado.length; i++) {
            let fila = `<tr>`;
            fila += `<td>` + resultado[i].fields.descripcion + `</td>`;
            (resultado[i].fields.estado)? fila += `<td><span class="badge bg-success">Activo</span></td>`:fila += `<td><span class="badge bg-danger">Inactivo</span></td>`;
            fila += `<td>
                            <div class="row">
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-cargarDatos-modificar" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="cargarDatos('${resultado[i].pk}','${resultado[i].fields.descripcion}',${resultado[i].fields.estado})">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>                                   
                                </div>
                                <div class="form-group col-sm-4">
                                    <a href="#" class="btn-eliminar" onclick="eliminarAnimal('${resultado[i].pk}')">
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

const btnGuardarAnimal= document.querySelector('#btn-guardar-animal');
btnGuardarAnimal.addEventListener('click',guardarFormAnimal);

function guardarFormAnimal(){
    try {
        const form= new FormData(document.querySelector('#form-animal'));
        //let lista = document.querySelector('#form-animal')
        form.set('descripcion',form.get('descripcion').trim())
        if (form.get('descripcion')!='') {
            form.append('id_empresa',document.querySelector('#id_empresa').textContent);
            fetch("/animal/",{
                method: 'POST',
                body: form,
                headers:{
                    "X-CSRFToken":getCookie('csrftoken'),
                }
    
            }).then(
                function(response){
                    return response.json()
                }
            ).then(
                function (result){                
                    const {status}=result;
                    const {mensaje}=result;
                    if (status==true){
                        listarAnimales();
                        imprimirMessage("Éxito",mensaje,"success");
                        cleanData();
                    }else{
                        const {error}=result;
                        contentError.innerHTML='';
                        Object.entries(error).forEach(([key, value]) => {
                            contentError.innerHTML+=`<p> -> ${value}</p>`
                        });
                        imprimirMessage("Sistema",mensaje,"info");
                    }
                }
            ).catch(
                function(error){
                    console.log(error)
                }
            )
        } else {
            imprimirMessage('Sistema','Complete los campos necesarios para registrar','info')
            document.querySelector('#form-animal').classList.add('was-validated');
        }
        
    } catch (error) {
        console.log(error)
    }
    
}

///////////////////////////////////////////////////////////////////////////

var id_g=0;
function cargarDatos(id_animal, descripcion,estado){ 
    document.querySelector('#form-animal').classList.remove('was-validated');
    contentError.innerHTML='';
    id_g=id_animal;
    inpDescripcionAnimal.value=descripcion;
    btnModificarAnimal.disabled=false;
    if(estado){
        $("#id_estado").prop('checked', true);
    }else{
        $("#id_estado").prop('checked', false);
    }
    btnGuardarAnimal.disabled=true;
}


btnModificarAnimal.addEventListener('click',modificarAnimal);

async function modificarAnimal(){
    try {
        
        const form= new FormData(document.querySelector('#form-animal'));
        form.set('descripcion',form.get('descripcion').trim())
        if (id_g!=0){
            if (form.get('descripcion')!='') {
                form.append('id_empresa',document.querySelector('#id_empresa').textContent);
                const response = await fetch("/modificar_animal/"+id_g+"/",{
                    method: 'POST',
                    body: form,
                    headers:{
                        "X-CSRFToken":getCookie('csrftoken'),
                    }
                })
                const result = await response.json()
                const {status} = result;
                const {mensaje} = result;
                if (status){
                    listarAnimales();
                    cleanData();
                    imprimirMessage("Éxito",mensaje,"success");
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
                document.querySelector('#form-animal').classList.add('was-validated');
            }
        }  
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al modificar animal","error");
    }
    
}
///////////////////////////////////////////////////////////////////////////
function cleanData(){
    document.querySelector('#form-animal').classList.remove('was-validated');
    id_g=0;
    inpDescripcionAnimal.value='';
    btnModificarAnimal.disabled=true
    btnGuardarAnimal.disabled=false;
    contentError.innerHTML='';
    $("#id_estado").prop('checked', true);
}
///////////////////////////////////////////////////////////////////////////

function eliminarAnimal(id) {

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
        const response = await fetch("/eliminar_animal/" + id + "/");
        const result = await response.json();
        const {status}=result;
        if (status){
            const{mensaje}=result;
            listarAnimales();
            imprimirMessage("Éxito",mensaje,"success");
        }
    } catch (error) {
        console.log(error)
        imprimirMessage("Sistema","Error al eliminar animal","error");
    }
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

