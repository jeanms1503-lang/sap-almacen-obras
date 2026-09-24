import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'OK', system: 'SAP WMS Obra Backend', timestamp: new Date() });
});

app.get('/api/equipos/:serie', (req: Request, res: Response) => {
  const { serie } = req.params;
  res.json({
    numero_serie: serie,
    material: 'Rotomartillo DeWalt 20V',
    estado: 'DISPONIBLE',
    ubicacion: 'ALM1-RACK-A02'
  });
});

app.post('/api/movimientos/despacho', (req: Request, res: Response) => {
  const { trabajador_id, elemento_pep, items } = req.body;
  const docSap = `DOC-2026-${Math.floor(1000 + Math.random() * 9000)}`;
  res.json({
    success: true,
    documento_sap: docSap,
    mensaje: 'Despacho registrado correctamente'
  });
});

app.post('/api/movimientos/devolucion', (req: Request, res: Response) => {
  const { numero_serie, condicion } = req.body;
  res.json({
    success: true,
    mensaje: `Devolución de serie ${numero_serie} procesada como ${condicion}`
  });
});

app.listen(PORT, () => {
  console.log(`Servidor SAP WMS escuchando en puerto ${PORT}`);
});
