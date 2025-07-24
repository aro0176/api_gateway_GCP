const express = require('express');
const app = express();

app.get('/kaiza', (req, res) => {
  res.send('SALAMA IANAREO AVY ATY AMIN SERVICE CLOUD RUN!');
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`SERVEUR MANDE EO AMIN VARAVARANA ${port}`);
});
