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
const bnt_a=document.querySelector('#id_report');
bnt_a.addEventListener('click',validatedSendData)
///////////////////////////////////////////////////////////////////////////

$(document).ready(function(){
    listarAtenciones();
})

///////////////////////////////////////////////////////////////////////////

async function listarAtenciones(){
    try {
        const response = await fetch('/listar_atenciones/');
        const result = await response.json();
        let resultado = result.atenciones;
        if ($.fn.DataTable.isDataTable('#dataTable')) {
            $('#dataTable').DataTable().destroy();
        }
        $('#dataTable tbody').html("");
        
        for (i = 0; i < resultado.length; i++) {
            let dateEntrada = new Date(resultado[i][5]);
            let fila = `<tr>`;
            fila += `<td>` + resultado[i][1] + `</td>`;
            fila += `<td>` + resultado[i][2] + `</td>`;
            fila += `<td>` + resultado[i][3] + `</td>`;
            fila += `<td>` + resultado[i][4] + `</td>`;
            fila += `<td>` +dateEntrada.getDate() +'/'+(dateEntrada.getMonth()+1)+'/'+dateEntrada.getUTCFullYear()+' a las '+dateEntrada.getHours()+':'+dateEntrada.getMinutes()+':'+dateEntrada.getSeconds()+`</td>`;
            if (resultado[i][6]==null){
                fila += `<td> - </td>`;

                if (resultado[i][7]){
                    fila += `<td><span class="badge bg-danger">Terminado</span></td>`;  
                }else{
                    fila += `<td><span class="badge bg-warning">En curso</span></td>`;
                }                   
                fila += `<td>
                                <div class="row">
                                    <div class="form-group col-sm-4">
                                        <a href="" style="color:green" class="btn-ver" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="visualizarDetalle('${resultado[i][0]}')" >
                                            <i class="bi bi-arrow-up-right-square"></i>
                                        </a>                                   
                                    </div>
                                    <div class="form-group col-sm-4">
                                        <a href="#" style="color:red" class="a-finalizar" onclick="finalizarAtencion('${resultado[i][0]}')">
                                            <i class="bi bi-check2-square"></i>
                                        </a>
                                    </div>
                                </div>
                       </td>`;




            }else{
                let dateSalida = new Date(resultado[i][6]);
                fila += `<td>` +dateSalida.getDate() +'/'+(dateSalida.getMonth()+1)+'/'+dateSalida.getUTCFullYear()+' a las '+dateSalida.getHours()+':'+dateSalida.getMinutes()+':'+dateSalida.getSeconds()+`</td>`;
                if (resultado[i][7]){
                    fila += `<td><span class="badge bg-danger">Terminado</span></td>`;  
                }else{
                    fila += `<td><span class="badge bg-warning">En curso</span></td>`;
                }                   
                fila += `<td>
                                <div class="row">
                                    <div class="form-group col-sm-4">
                                        <a href="" style="color:green" class="btn-ver" data-bs-toggle="modal" data-bs-target="#exampleModal" onclick="visualizarDetalle('${resultado[i][0]}')" >
                                            <i class="bi bi-arrow-up-right-square"></i>
                                        </a>                                   
                                    </div>
                                    
                                </div>
                       </td>`;
            }       
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
            aaSorting:[]
            
        })
    } catch (error) {
        console.log(error);
    }
} 
///////////////////////////////////////////////////////////////////////////////////////
const span=document.querySelector('#numero-atencion-id');
async function visualizarDetalle(atencion){
    try {
        console.log(atencion);
        const response = await fetch('/consultar_detalle_atencion/'+atencion+'/');
        const result = await response.json();
        const {status} = result;
        if (status){
            span.textContent=atencion;
            let resultado=result.detalle;
            $('#tabla-detalle tbody').html("");
            for(let i=0;i<resultado.length;i++){
                let fila = `<tr>`;
                fila += `<td>` + parseInt(i+1) + `</td>`;
                fila += `<td>` + resultado[i][0] + `</td>`;
                fila += `<td>` + resultado[i][1] + `</td>`;
                fila += `</tr>`;
                $('#tabla-detalle tbody').append(fila);
            }
        }else{
            span.textContent='Sin resultados';
        }
        
    } catch (error) {
        console.log(error); 
    }
}
///////////////////////////////////////////////////////////////////////////////////////
async function finalizarAtencion(atencion){
    try {
        const response = await fetch('/finalizar_atencion/'+atencion+'/');
        const result = await response.json();
        
        const {status}=result;
        if(status){
            const {mensaje}=result;
            imprimirMessage('Éxito', mensaje,'success');
            listarAtenciones();
        }
    } catch (error) {
        console.log(error);   
    }
}
///////////////////////////////////////////////////////////////////////////////////////

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
        ab.setAttribute("href",`/export_atenciones_pdf/${form.get('fecha_inicio')}/${form.get('fecha_fin')}/`);
        document.querySelector('#form-reporte').reset();
        document.querySelector('#form-reporte').classList.remove('was-validated');
    }else{
        ab.removeAttribute("href");
        document.querySelector('#form-reporte').classList.add('was-validated');
    }
}


