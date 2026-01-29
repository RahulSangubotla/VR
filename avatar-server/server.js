const http = require("http");
const express = require("express");
const socketIo = require("socket.io"); // v2.5.0
const easyrtc = require("easyrtc");

const app = express();
const server = http.createServer(app);

// Socket.IO v2 style initialization
const io = socketIo.listen(server, {
    origins: "*:*" // Allow connections from localhost:8000
});

const rtc = easyrtc.listen(app, io, null, (err, rtcRef) => {
    console.log("Avatar Server (v2.5) Ready on Port 8081");
});

server.listen(8081, () => {
    console.log("Listening on *:8081");
});