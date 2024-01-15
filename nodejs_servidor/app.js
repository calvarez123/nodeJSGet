const express = require('express')
const multer = require('multer');
const url = require('url');
const axios = require('axios');




const app = express()
const port = process.env.PORT || 3000

// Configurar la rebuda d'arxius a través de POST
const storage = multer.memoryStorage(); // Guardarà l'arxiu a la memòria
const upload = multer({ storage: storage });

// Tots els arxius de la carpeta 'public' estàn disponibles a través del servidor
// http://localhost:3000/
// http://localhost:3000/images/imgO.png
app.use(express.static('public'))

// Configurar per rebre dades POST en format JSON
app.use(express.json());

// Activar el servidor HTTP
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Tancar adequadament les connexions quan el servidor es tanqui
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  process.exit(0);
}

// Configurar direcció tipus 'GET' amb la URL ‘/itei per retornar codi HTML
// http://localhost:3000/ieti
app.get('/ieti', getIeti)
async function getIeti(req, res) {

  // Aquí s'executen totes les accions necessaries
  // - fer una petició a un altre servidor
  // - consultar la base de dades
  // - calcular un resultat
  // - cridar la linia de comandes
  // - etc.

  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end('<html><head><meta charset="UTF-8"></head><body><b>El millor</b> institut del món!</body></html>')
}

// Configurar direcció tipus 'GET' amb la URL ‘/llistat’ i paràmetres URL 
// http://localhost:3000/llistat?cerca=cotxes&color=blau
// http://localhost:3000/llistat?cerca=motos&color=vermell


// Configurar direcció tipus 'POST' amb la URL ‘/data'
// Enlloc de fer una crida des d'un navegador, fer servir 'curl'
// curl -X POST -F "data={\"type\":\"test\"}" -F "file=@package.json" http://localhost:3000/data
// Esto es importate para que se envien los mensajes poco a poco

app.post('/data', upload.single('file'), async (req, res) => {
  const textPost = req.body;
  const uploadedFile = req.file;
  let objPost = {};

  try {
    console.log('textPost.data:', textPost.data);  // Agrega esta línea para imprimir el contenido
    objPost = JSON.parse(textPost.data);
  } catch (error) {
    console.log('Error parsing JSON:', error);  // Agrega esta línea para imprimir el error
    res.status(400).send('Solicitud incorrecta.');
    return;
  }

  if (objPost.type == 'test') {
    try {
      // Realiza la solicitud a la API externa con el mensaje proporcionado
      
      const apiResponse = await axios.post('http://localhost:11434/api/generate', {
        model: 'mistral',
        prompt: 'hola como te llamas?', // Utiliza el texto proporcionado en lugar de 'prompt'
      });

      // Maneja la respuesta de la API según tus necesidades
      console.log('hola')
      console.log('API Response:', apiResponse.data);

      
    } catch (error) {
      console.error('Error al realizar la solicitud a la API:', error);
      res.status(500).send('Error interno del servidor.');
    }
  } else {
    res.status(400).send('Solicitud incorrecta. Se requiere la propiedad "texto".');
  }
});


 /*
    if (objPost.type === 'test') {
      if (uploadedFile) {
        let fileContent = uploadedFile.buffer.toString('utf-8');
        console.log('Contenido del archivo adjunto:');
        
        // Imprimir el contenido del archivo letra por letra
        for (let i = 0; i < fileContent.length; i++) {
          console.log(fileContent.charAt(i));
          // Esperar un tiempo antes de imprimir el siguiente carácter
          await new Promise(resolve => setTimeout(resolve, 100));
        }
      }
    
      // Imprimir los mensajes línea por línea
      const lines = ["POST First line", "POST Second line", "POST Last line"];
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' });
    
      for (const line of lines) {
        res.write(line + '\n');
        // Esperar un tiempo antes de imprimir la siguiente línea
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    
      res.end();
    }
    
*/
  