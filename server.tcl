package require wibble

namespace eval ::webui_server {
	proc ::wibble::serve {state} {
		
		set request_path [dict get $state request path]
		if {$request_path eq "/"} {
			set request_path "/index.html"
		}
		set fp [open "[homedir]/[plugin_directory]/decent_webui/webui/build$request_path" r]
		set file_data [read $fp]
		close $fp
		dict set state response status 200
		#dict set state response header content-type "" application/xhtml
		dict set state response content $file_data
		sendresponse [dict get $state response]
	}

	proc ::wibble::webui {state} {

		set request_path [dict get $state request path]
		msg -INFO "Request path: $request_path"
		msg -INFO "Path: [homedir]/[plugin_directory]/decent_webui/webui/build/$request_path"
		set fp [open "[homedir]/[plugin_directory]/decent_webui/webui/build/$request_path" r]

		set file_data [read $fp]
		close $fp
		dict set state response status 200
		dict set state response header content-type "" application/javascript
		dict set state response content $file_data
		sendresponse [dict get $state response]
	}
	
	proc ::wibble::css {state} {

		set request_path [dict get $state request path]
		set fp [open "[homedir]/[plugin_directory]/decent_webui/webui/build/$request_path" r]

		set file_data [read $fp]
		close $fp
		dict set state response status 200
		dict set state response header content-type "" text/css
		dict set state response content $file_data
		sendresponse [dict get $state response]
	}

	proc setup {} {
		::wibble::handle /_app webui
		::wibble::handle /smui.css css
		::wibble::handle / serve
		catch {
			wibble::listen 8900
		}
	}
}
