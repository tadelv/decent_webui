import { writable } from 'svelte/store';

const machine = writable({});

const socket = new WebSocket('ws://localhost:9900/log/me', 's');

// Connection opened
socket.addEventListener('open', function (event) {
    console.log("It's open");
});

// Listen for messages
socket.addEventListener('message', function (event) {
    machine.set(event.data);
});

socket.addEventListener('ping', function (event) {
  socket.send('pong');
});

export default {
	subscribe: machine.subscribe,
}

