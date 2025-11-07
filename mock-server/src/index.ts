import { createNodeWebSocket } from '@hono/node-ws'
import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import { WSContext } from 'hono/ws';

const app = new Hono()

const { injectWebSocket, upgradeWebSocket } = createNodeWebSocket({ app });

const connectedClients = new Set<WSContext<WebSocket>>();

const wsApp = app.get('/ws', upgradeWebSocket(async () => ({
  onOpen(_, ws) {
    console.log(`Client connected`);
    connectedClients.add(ws);
    return ws.send(JSON.stringify({ event: "data", data: distances }));
  },
  onClose(_, ws) {
    console.log(`Client disconnected`);
    connectedClients.delete(ws);
  },
})))

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

const server = serve({
  fetch: app.fetch,
  port: 3000
}, (info) => {
  console.log(`Server is running on http://localhost:${info.port}`)
})
injectWebSocket(server);


const distances: number[] = Array.from({ length: 100 }, () => 0);

function readDistance() {
  const distance = Math.random() * 20 + 90;
  distances.push(distance);
  if (distances.length > 100) {
    distances.shift();
  }
  connectedClients.forEach((ws) => {
    ws.send(JSON.stringify({ event: "update", data: distance }));
  });
}
setInterval(readDistance, 100);
