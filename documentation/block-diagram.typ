#import "@preview/cetz:0.3.2": draw
#import "@preview/circuiteria:0.2.0": *

#let hw-color = red
#let ws-color = green
#let http-color = blue

#let sensor-block = (x, y) => {
  element.block(
    id: "sensor",
    w: 9, 
    h: 4, 
    x: x, 
    y: y,
    name: [Sensor],
    ports: (
      north: ((id: "update", clock: true),),
      west: (
        (id: "sda", name: [i#super[2]c_sda_comm]),
        (id: "scl", name: [i#super[2]c_scl_comm]),
      ),
      east: ((id: "distance", name: [distance_signal]),)
    ),
    fill: util.colors.green
  )
  wire.stub("sensor-port-update", "north", name: [update], vertical: true)

  draw.set-style(stroke: hw-color)
  wire.stub("sensor-port-sda", "west")
  wire.stub("sensor-port-scl", "west")
  draw.set-style(stroke: black)
}

#let display-block = (x, y) => {
  element.block(
    id: "display",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [#h(1.5em) Display],
    ports: (
      north: ((id: "update", clock: true),),
      west: (
        (id: "distance", name: [update_distance]),
        (id: "unit", name: [update_unit]),
        (id: "alert", name: [update_alert]),
      ),
      east: (
        (id: "sda", name: [i#super[2]c_sda]),
        (id: "scl", name: [i#super[2]c_scl]),
      )
    ),
    fill: aqua
  )

  wire.stub("display-port-update", "north", name: [update], vertical: true)

  draw.set-style(stroke: red)
  wire.stub("display-port-sda", "east")
  wire.stub("display-port-scl", "east")
  draw.set-style(stroke: black)
}

#let network-block = (x, y) => {
  element.block(
    id: "network",
    w: 9,
    h: 6,
    x: x,
    y: y,
    name: [Network #h(1em)],
    ports: (
      west: (
        (id: "upd_distance", name: [update_distance]),
        (id: "upd_unit", name: [update_unit]),
        (id: "upd_alert", name: [update_alert]),
      ),
      east: (
        (id: "unit_signal", name: [unit_signal]),
        (id: "alert_signal", name: [alert_signal]),
        (id: "dashboard", name: [serve_dashboard]),
        (id: "distances", name: [serve_distances]),
        (id: "brd_distance", name: [broadcast_distance]),
        (id: "brd_unit", name: [broadcast_unit]),
        (id: "brd_alert", name: [broadcast_alert]),
      )
    ),
    fill: util.colors.purple
  )
}

#let software-group = (x, y) => {
  sensor-block(x + 0, y + 0)
  display-block(x + 11, y - 2.5)
  network-block(x + 0, y - 7)

  // Sensor to Network
  wire.wire("sensor-dist-to-network", ("sensor-port-distance", "network-port-upd_distance"), style: "dodge", dodge-y: -0.5)
  // Sensor to Display
  wire.wire("sensor-dist-to-display-dist", ("sensor-dist-to-network.dodge-start", "display-port-distance"), style: "zigzag", zigzag-ratio: 0%)
  wire.intersection("sensor-dist-to-display-dist.zag")
  // Network to Display
  wire.wire("network-unit-to-display-unit", ("network-port-unit_signal", "display-port-unit"), style: "zigzag")
  wire.wire("network-alert-to-display-alert", ("network-port-alert_signal", "display-port-alert"), style: "zigzag", zigzag-ratio: 3/2)
}

#let dashboard-block = (x, y) => {
  element.block(
    id: "dashboard",
    w: 10,
    h: 6,
    x: x,
    y: y,
    name: [Dashboard],
    ports: (
      west: (
        (id: "set_distances", name: [set_distances]),
        (id: "upd_distance", name: [update_distance]),
        (id: "upd_unit", name: [update_unit]),
        (id: "upd_alert", name: [update_alert]),
        (id: "usr-unit", name: [usr_unit]),
        (id: "usr-alert", name: [usr_alert])
      ),
      east: (
        (id: "display_distance", name: [distance_usrout]),
        (id: "display_distances", name: [distance_graph_usrout]),
        (id: "display_unit", name: [unit_usrout]),
        (id: "display_alert", name: [alert_usrout]),
        (id: "alert-triggered-usrout", name: [alert_triggered_usrout]),
        (id: "brd_unit", name: [broadcast_unit]),
        (id: "brd_alert", name: [broadcast_alert]),
      )
    ),
    fill: util.colors.purple
  )
}

#let boost-converter-block = (x, y) => {
  element.block(
    id: "boost-converter",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [Boost Converter \ \ \ ],
    ports: (
      west: (
        (id: "dc-in", name: [bat_dcpwr]),
      ),
      east: (
        (id: "dc-out", name: [9v_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let external-regulator-block = (x, y) => {
  element.block(
    id: "external-regulator",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [External Regulator \ \ \ ],
    ports: (
      west: (
        (id: "dc-in", name: [9v_dcpwr]),
      ),
      east: (
        (id: "dc-out", name: [5v_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let internal-regulator-block = (x, y) => {
  element.block(
    id: "internal-regulator",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [ESP32 Internal Regulator \ \ \ ],
    ports: (
      west: (
        (id: "dc-in", name: [5v_dcpwr]),
      ),
      east: (
        (id: "dc-out", name: [3v3_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let charger-block = (x, y) => {
  element.block(
    id: "charger",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [Li-Po Charger \ \ \ \ ],
    ports: (
      west: (
        (id: "bat-in", name: [bat_dcpwr]),
        (id: "usb-in", name: [usb_dcpwr]),
      ),
      east: (
        (id: "bat-out", name: [bat_charge_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let battery-block = (x, y) => {
  element.block(
    id: "battery",
    w: 7,
    h: 4,
    x: x,
    y: y,
    name: [Li-Po \ \ \ \ ],
    ports: (
      west: (
        (id: "bat-in", name: [bat_charge_dcpwr]),
      ),
      east: (
        (id: "bat-out", name: [bat_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let hw-sensor-block = (x, y) => {
  element.block(
    id: "hw-sensor",
    w: 9,
    h: 4,
    x: x,
    y: y,
    name: [Sensor Board ],
    ports: (
      west: (
        (id: "dc-in", name: [3v3_dcpwr]),
        (id: "distance-in", name: [distance_envin]),
      ),
      east: (
        (id: "sda", name: [i#super[2]c_sda_comm]),
        (id: "scl", name: [i#super[2]c_scl_comm]),
      )
    ),
    fill: util.colors.orange
  )
}

#let hw-display-block = (x, y) => {
  element.block(
    id: "hw-display",
    w: 10,
    h: 4,
    x: x,
    y: y,
    name: [Display Board],
    ports: (
      west: (
        (id: "dc-in", name: [3v3_dcpwr]),
        (id: "sda", name: [i#super[2]c_sda_comm]),
        (id: "scl", name: [i#super[2]c_scl_comm]),
      ),
      east: (
        (id: "display", name: [display_usrout]),
      )
    ),
    ports-margins: (
      east: (33.333%, 0%),
    ),
    fill: util.colors.pink
  )
}

#let hardware-group = (x, y) => {
  element.group(id: "psu", name: [Power Supply], stroke: (dash: "dotted"), {
    boost-converter-block(x,y)
    external-regulator-block(x + 8,y)
    internal-regulator-block(x + 16,y)
    
    charger-block(x + 4,y - 5)
    battery-block(x + 12,y - 5)

    // Battery connections
    wire.wire("charger-to-lipo", ("charger-port-bat-out", "battery-port-bat-in"))
    wire.wire("lipo-to-charger", ("battery-port-bat-out", "charger-port-bat-in"), style: "dodge", dodge-y: y - 0.5, dodge-margins: (0.5, 0.5))
    wire.wire("lipo-to-boost-converter", ("lipo-to-charger.dodge-end", "boost-converter-port-dc-in"), style: "dodge", dodge-y: y - 0.5, dodge-margins: (0.5, 0.5))
    wire.intersection("lipo-to-charger.dodge-end")

    // Regulation connections
    wire.wire("boost-converter-to-external-regulator", ("boost-converter-port-dc-out", "external-regulator-port-dc-in"))
    wire.wire("external-regulator-to-internal-regulator", ("external-regulator-port-dc-out", "internal-regulator-port-dc-in"))
  })

  hw-sensor-block(x + 1, y - 10.5)
  hw-display-block(x + 12, y - 10.5)
}

#let block-diagram = circuit({
  element.group(id: "mcu", name: [Microcontroller Program], stroke: (dash: "dashed"), {
    software-group(0, 0)
  })

  element.group(id: "client", name: [Web Client], stroke: (dash: "dashed", paint: http-color), {
    dashboard-block(21.5,-7)
  })

  element.group(id: "hardware", name: [Hardware], stroke: (dash: "dashed", paint: http-color), {
    hardware-group(0,20)
  })

  // Network to dashboard serve
  wire.wire("network-dashboard-serve1", ("network-port-dashboard", (rel: (10.95,0))), color: http-color)
  wire.wire("network-dashboard-serve2", ((to: "network-port-dashboard", rel: (10.95,0)), (to: "network-port-dashboard", rel: (10.95,3.25))), color: http-color)
  wire.wire("network-dashboard-serve3", ((to: "network-port-dashboard", rel: (10.95,3.25)), "client.north"), color: http-color, style: "zigzag", zigzag-ratio: 100%, directed: true)
  
  // Network to Dashboard
  wire.wire("network-distances-to-dashboard-distances", ("network-port-distances", "dashboard-port-set_distances"), style: "zigzag", zigzag-ratio: 90%, color: http-color)
  wire.wire("network-brd-distance-to-dashboard-upd-distance", ("network-port-brd_distance", "dashboard-port-upd_distance"), style: "zigzag", zigzag-ratio: 92%, color: ws-color)
  wire.wire("network-brd-unit-to-dashboard-upd-unit", ("network-port-brd_unit", "dashboard-port-upd_unit"), style: "zigzag", zigzag-ratio: 94%, color: ws-color)
  wire.wire("network-brd-alert-to-dashboard-upd-alert", ("network-port-brd_alert", "dashboard-port-upd_alert"), style: "zigzag", zigzag-ratio: 96%, color: ws-color)
    
  wire.wire("dashboard-unit-to-network-unit", ("dashboard-port-brd_unit", "network-port-upd_unit"), style: "dodge", dodge-y: -8.75, dodge-margins: (1.75, 1.75), color: ws-color)
  wire.wire("dashboard-alert-to-network-alert", ("dashboard-port-brd_alert", "network-port-upd_alert"), style: "dodge", dodge-y: -8.25, dodge-margins: (1.25, 1.25), color: ws-color)
})


#set page(height: auto, width: auto, margin: 1cm)
#block-diagram
