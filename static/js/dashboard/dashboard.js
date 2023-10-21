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
$(document).ready(function(){
  document.querySelector('#spinner-id').classList.add('invisible')
   
});
const f = new Date();
const fecha=f.getFullYear()+ "-" + (f.getMonth() +1) + "-" +f.getDate()
///////////////////////////////////////////////////////////////////////////
const btnEnviarCorreo = document.querySelector('#btn-enviar-correo');
btnEnviarCorreo.addEventListener('click',sendEmail);

async function sendEmail(){
  document.querySelector('#spinner-id').classList.remove('invisible')
  const form = new FormData();
  form.append('fecha',fecha)
  try {
    const response = await fetch('/dashboard/',{
      method:'POST',
      body:form,
      headers:{
        "X-CSRFToken":getCookie('csrftoken'),
      }
    });
    const result = await response.json();
    const {status} = result;
    const {mensaje} = result;
    if(status){
      const {mensaje} = result;
      imprimirMessage('Éxito',mensaje,'success');
    }else{
      imprimirMessage('Sistema',mensaje,'info');
    }
  } catch (error) {
    console.log(error);
    imprimirMessage('Error',error,'error');
  }finally{
    document.querySelector('#spinner-id').classList.add('invisible');
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