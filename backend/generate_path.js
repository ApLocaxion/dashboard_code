// function publishPose() {
//   const dt = INTERVAL_MS / 1000.0;
//   time += dt;

//   // --- X-Axis State Update (Ornstein–Uhlenbeck Process for realistic speed variation) ---
//   // dV = -relaxation * (V - mean) * dt + noise * sqrt(dt) * rand
//   velocityX += -RELAX_RATE * (velocityX - BASE_SPEED_X) * dt + PROCESS_NOISE * Math.sqrt(dt) * gaussian();
//   positionX += velocityX * dt;
//   // Add independent measurement noise
//   const measuredX = positionX + gaussian(0, NOISE_STD);

//   // --- Y-Axis State Update ---
//   velocityY += -RELAX_RATE * (velocityY - BASE_SPEED_Y) * dt + PROCESS_NOISE * Math.sqrt(dt) * gaussian();
//   positionY += velocityY * dt;
//   // Add independent measurement noise
//   const measuredY = positionY + gaussian(0, NOISE_STD);


//   // === Full SLAM payload ===
//   const payload = {
//     pose: {
//       x: measuredX, // X position is moving
//       y: measuredY, // Y position is moving
//       z: 0,         // Z is constant (2D)
//       qx: 0,
//       qy: 0,
//       qz: 0,
//       qw: 1, // Unit quaternion, representing no rotation (constant orientation)
//       reference_frame: "map",
//       timestamp: new Date().toISOString()
//     }
//   };

//   const payloadString = JSON.stringify(payload);
//   console.log(`[${payload.pose.timestamp}] X=${measuredX.toFixed(3)}, Y=${measuredY.toFixed(3)} | Sent to ${wss.clients.size} clients`);

//   // Broadcast the payload to all connected clients
//   wss.clients.forEach(client => {
//     if (client.readyState === WebSocket.OPEN) {
//       client.send(payloadString);
//     }
//   });
// }


// function startSim(){
//     setInterval(publishPose, 1000);
// }


// module.exports = { startSim };