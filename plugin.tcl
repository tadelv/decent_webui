
package require de1_machine 1.2
package require json
package require de1_profile 2.0
package require de1_vars 1.0
package require de1_utils 1.1
# Change package name for you extension / plugin
set plugin_name "decent_webui"

namespace eval ::plugins::${plugin_name} {

    # These are shown in the plugin selection page
    variable author "Vid"
    variable contact "vid@tadel.net"
    variable version 1.0
    variable description "Fluid DE1 web interface"
    variable name "Decent WebUI"

    proc on_espresso_end {old new} {
        popup "espresso ended"
    }

    proc on_function_called {call code result op} {
        popup "start_sleep called!"
    }
		proc ::compile_json {spec data} {
				while [llength $spec] {
						set type [lindex $spec 0]
						set spec [lrange $spec 1 end]
						
						switch -- $type {
								dict {
										lappend spec * string
										
										set json {}
										foreach {key val} $data {
												foreach {keymatch valtype} $spec {
														if {[string match $keymatch $key]} {
																lappend json [subst {"$key":[
																		compile_json $valtype $val]}]
																break
														}
												}
										}
										return "{[join $json ,]}"
								}
								list {
										if {![llength $spec]} {
												set spec string
										} else {
												set spec [lindex $spec 0]
										}
										set json {}
										foreach {val} $data {
	lappend json [compile_json $spec $val]
										}
										return "\[[join $json ,]\]"
								}
								string {
										if {[string is double -strict $data]} {
												return $data
										} else {
												return "\"$data\""
										}
								}
								default {error "Invalid type"}
						}
				}
		}
		proc ::shot_update_received { update } {
			global openSockets
			foreach s $openSockets {
				::websocket::send $s text "[::compile_json dict $update]"
			}
		}

		proc ::round_float { num } {
			return [expr [expr {floor([expr $num * 100])} / 100]]		
		}

		proc ::machine_update_received { args } {
			global lastUpdate
			set now [clock clicks -milliseconds]
			if { [expr $now - $lastUpdate] < 300 } {
				return
			}
			set lastUpdate $now
			#msg [namespace current] "Machine update received $args"
			#msg [namespace current] "Machine update received $::de1"
			set update [list head_temp [::round_float $::de1(head_temperature)] mix_temp [::round_float $::de1(mix_temperature)]]
			lappend update steam_temp [::round_float $::de1(steam_heater_temperature)] \
			  state $::de1_num_state($::de1(state)) \
				substate $::de1_substate_types($::de1(substate)) \
        flow [::round_float $::de1(flow)] \
				pressure [::round_float $::de1(pressure)] \
				total_weight [::round_float $::de1(scale_sensor_weight)] \
				weight_flow [::round_float $::de1(scale_weight_rate)] \
				flow_goal [::round_float $::de1(goal_flow)] \
				pressure_goal [::round_float $::de1(goal_pressure)] \
				temp_goal [::round_float $::de1(goal_temperature)] \
				group_pressure [::round_float $::de1(GroupPressure)] \
				profile $::settings(profile) \
				water_level [::round_float $::de1(water_level)] \
				water_level_percent $::de1(water_level_percent) \
				water_level_ml [water_tank_level_to_milliliters $::de1(water_level)]


			global openSockets
			foreach s $openSockets {
				::websocket::send $s text "[::compile_json dict $update]"
				#::websocket::send $s text "[::compile_json dict [array get ::de1]]"
			}
		}
    # This file will be sourced to display meta-data. Dont put any code into the
    # general scope as there are no guarantees about when it will be run.
    # For security reasons it is highly unlikely you will find the plugin in the
    # official distribution if you are not beeing run from your main
    # REQUIRED
    proc main {} {
        variable settings

        msg [namespace current] "Accessing loaded settings: $settings(amazing_feature)"
        msg [namespace current] "Changing settings"
        set settings(amazing_feature) 3
        msg [namespace current] "Saving settings"
        save_plugin_settings "example"
        msg [namespace current] "Dumping settings:"
        msg [array get settings]

		#::de1::event::listener::on_shotvalue_available_add \
		#	shot_update_received
		trace add variable ::de1 write \
			machine_update_received

     package require websocket

 proc ::handler { sock type msg } {
         switch -glob -nocase -- $type {
                 co* {
                         puts "Connected on $sock"
                 }
                 te* {
                         puts "RECEIVED: $msg"
                         foreach s $::openSockets {
                                 ::websocket::send $s $type  ">$msg"
                         }
                 }
                 cl* -
                 dis* -
                 error {
                         set idx [ lsearch $::openSockets $sock ]
                         if { $idx >= 0 } { 
                                 set ::openSockets [lreplace $::openSockets $idx $idx ]
                         }
                         catch { close $sock } 
                 }
                 default {
                         puts "$type"
                 } 
     }
 }
 proc ::readline { fd handler } {
         set line [ gets $fd ]
         if { [eof $fd ] } {
                 catch { close $fd } 
         }
         uplevel #0 $handler \"$line\"
 } 
 proc ::test { sock line } {
     ::websocket::send $sock text $line
 }
 proc ::closeapp { sock } {
         ::websocket::close $sock 1000 "normal close"
         after  1000 {
                 exit 0
         }
 }

 proc ::readAll { sock  } {
         global servSock
         set count  0
         array set data {}
         set mode request
         while { [gets $sock line ] != -1 } {
                 if { $line eq "\n" || $line eq "" } { continue; } 
            if { $count > 0 } {
                    set mode headers
            }
                 append data($mode) "$line\n"
                 incr count 
         }
         lassign $data(request) method url proto
         set header [ dict create  ]
         foreach line [split $data(headers) \n ] {
                  set idx [string first ":" $line ]
                  if { $idx == -1 } { continue; } 
                 set key [string range $line 0 $idx-1 ] 
                 set value [string trim [ string range $line $idx+1 end ] ]
                 puts "'$key' | '$value'"
                 dict set header $key $value
         }
         if { $url  eq "/log/me" } {
                 puts "got a websocket request : $url"
                   puts "header: $header" 
                 set wtest [::websocket::test $::servSock $sock /log/me $header ]
                 if { $wtest } {
                         ::websocket::upgrade $sock
                         ::websocket::takeover $sock handler 1
                         puts "[::websocket::conninfo $sock type] from [::websocket::conninfo $sock sockname] to [::websocket::conninfo $sock peername]"
                         fileevent $sock readable
                         lappend ::openSockets $sock
                 } else {
                         puts "did not get a valid  web socket request: url : $url" 
                         set reply "$proto 404 Not Found\r\nContentType: text/html\r\n\r\n<html><head><head><p>Not a web server!</p><body</body></html>"
                         puts $sock $reply
                         catch { close $sock} 
                 }
         } else {
                 puts "did not get a web socket request: url : $url" 
                 set reply "$proto 404 Not Found\r\nContentType: text/html\r\n<html><head><head><p>Not a web server!</p><body</body></html>"
                 puts $sock $reply
                 catch { close $sock} 
         }
 }
 ::websocket::loglevel debug
 proc ::Server {startTime channel clientaddr clientport} {
     msg "Connection from $clientaddr registered"
     set now [clock seconds]
     fconfigure $channel -blocking 0 -buffering line
         fileevent $channel read [list readAll  $channel ] 
 }
global lastUpdate
set ::lastUpdate [clock clicks -milliseconds]
 global openSockets
 set ::openSockets {} 
 set ::servSock [ socket -server [list Server [clock seconds]] 9900 ]
 ::websocket::server $::servSock
 ::websocket::live $::servSock /log/me  handler
source "[homedir]/[plugin_directory]/decent_webui/server.tcl"
::webui_server::setup
		}
 }
}
