if {$event == "open"} {
    set StartDir [pwd]
    set InitDir "$StartDir/init"
    set InfoDir "$StartDir/info"
    if [file exists "$StartDir/procedures.tcl"] {
        source "$StartDir/procedures.tcl"
    }
    if {[info commands updateAllWatchItems] == "updateAllWatchItems"} {
        updateAllWatchItems $name
    }
    readAllWatchItems
}
if [file exists "$StartDir/globals.tcl"] {
        source "$StartDir/globals.tcl"
}
if [file exists "$StartDir/menu.tcl"] {
        source "$StartDir/menu.tcl"
}
