
$(document).ready(function(){
    allFunctions();
});

var cboSucursal=document.querySelector('#id_sucursal');
cboSucursal.addEventListener('change',allFunctions);
/////////////////////////////////////////////////
async function allFunctions(){
    try {
        GraficoBarrasGananciasVentas();
        GraficoDonaProductosMasVendidos();
        GraficoLineaGananciasAtenciones();
        GraficoDonaServiciosMasSolicitados();
    } catch (error) {
        console.log(error);
    }
}
/////////////////////////////////////////////////


let myChartBar;
async function GraficoBarrasGananciasVentas(){
    const id_sucursal=document.querySelector('#id_sucursal').value;
    try {
        const response = await fetch('/ganancias_ventas_mensuales_sucursal/'+id_sucursal+'/');
        const result = await response.json();
        const {meses}=result;
        const {monto}=result;

        const canvas =document.getElementById('myChart');

        if(myChartBar){
            myChartBar.destroy();
        }


        const labels = meses;
        const data = {
            labels: labels,
            datasets: [{
            label: 'S/. Total mensual',
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(255, 159, 64, 0.2)',
                'rgba(255, 205, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(153, 102, 255, 0.2)',
                'rgba(201, 203, 207, 0.2)',
                'rgba(255, 99, 132, 0.2)',
                'rgba(255, 159, 64, 0.2)',
                'rgba(255, 205, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(54, 162, 235, 0.2)',
            ],
            borderColor: [
                'rgb(255, 99, 132)',
                'rgb(255, 159, 64)',
                'rgb(255, 205, 86)',
                'rgb(75, 192, 192)',
                'rgb(54, 162, 235)',
                'rgb(153, 102, 255)',
                'rgb(201, 203, 207)',
                'rgb(255, 99, 132)',
                'rgb(255, 159, 64)',
                'rgb(255, 205, 86)',
                'rgb(75, 192, 192)',
                'rgb(54, 162, 235)',
            ],
            data: monto,
            borderWidth: 1
            }]
        };
        
        const config = {
            type: 'bar',
            data: data,
            options: {}
        };
        
        myChartBar = new Chart(
            canvas,
            config
        );
    } catch (error) {
        console.log(error);
    }
    
    
}
/////////////////////////////////////////////////////

let myDoughnut;
async function GraficoDonaProductosMasVendidos(){
    const id_sucursal=document.querySelector('#id_sucursal').value;
    try {
        const response = await fetch('/mejores_productos_ventas_sucursal/'+id_sucursal+'/');
        const result = await response.json();
        const {producto}=result;
        const {cantidad}=result;

        const canvas =document.getElementById('myDoughnut');

        if(myDoughnut){
            myDoughnut.destroy();
        }

        const labels = producto;
        const data = {
            labels: labels,
            datasets: [{
            label: 'Productos con mayor salida',
            backgroundColor: [
                'rgb(255, 205, 86)',
                'rgb(255, 99, 132)',
                'rgba(54, 162, 235,2)',
                'rgba(153, 102, 255,2)',
                'rgba(75, 192, 192,2)',
                
            ],
            data: cantidad,
            }]
        };
        
        const config = {
            type: 'doughnut',
            data: data,
        };
        
        myDoughnut = new Chart(
            canvas,
            config
        );
    } catch (error) {
        console.log(error);
    }
    
} 

/////////////////////////////////////////////////////

let myChartLine;
async function GraficoLineaGananciasAtenciones(){
    const id_sucursal=document.querySelector('#id_sucursal').value;
    try {
        const response = await fetch('/ganancia_mensual_antencion_sucursal/'+id_sucursal+'/');
        const result = await response.json();
        const {mes}=result;
        const {monto}=result;
        const canvas =document.getElementById('myChartLine');

        if(myChartLine){
            myChartLine.destroy();
        }


        const labels = mes;
        
        const data = {
        labels: labels,
        datasets: [{
            label: 'S/. Total mensual',
            backgroundColor: 'rgb(0,0,128)',
            borderColor: 'rgb(0,0,128)',
            data: monto,
        }]
        };
    
        const config = {
        type: 'line',
        data: data,
        options: {}
        };
        
        myChartLine = new Chart(
            canvas,
            config
        );
    } catch (error) {
        console.log(error);
    }
    
}

/////////////////////////////////////////////////////

let myDoughnutServicios;
async function GraficoDonaServiciosMasSolicitados() {
    const id_sucursal=document.querySelector('#id_sucursal').value;
    try {
        const response = await fetch('/servicio_solicitados_sucursal/'+id_sucursal+'/');
        const result = await response.json();

        const {mejores_servicios_desc}=result;
        const {mejores_servicios_cant}=result;

        const canvas =document.getElementById('myDoughnutServicios');

        if(myDoughnutServicios){
            myDoughnutServicios.destroy();
        }

        const lables=mejores_servicios_desc;

        const data = {
            labels: lables,
            datasets: [{
                label: 'cantidad',
                data: mejores_servicios_cant,
                backgroundColor: [
                'rgb(255, 99, 132)',
                'rgb(54, 162, 235)',
                'rgb(255, 205, 86)',
                ],
                hoverOffset: 4
            }]
        };
        const config = {
            type: 'doughnut',
            data: data,
        };
        myDoughnutServicios = new Chart(
            canvas,
            config

        );
    } catch (error) {
        console.log(error);
    }
    
}
