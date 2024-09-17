# Decent WebUI

A plugin for the Decent DE1 app, which exposes a local webserver that can drive a web ui.



Right now it's still a work in progress, everything is hardcoded so substantial modification is required if you wish to
add your own ui. 

## Features

### websocket for machine status
Receive real-time updates with the current machine status as json

### webserver for your WebUI
Add the gui you wish to serve. Currently a SvelteKit app lives there as a single page app with a very rudimental demo of
the websocket capabilities.


## Future

### API 
- shot history
- profiles list/editing
- DYE integration, set/browse through the shots in SDB
