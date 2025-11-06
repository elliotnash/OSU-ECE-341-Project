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
        (id: "sda", name: [i#super[2]c_sda]),
        (id: "scl", name: [i#super[2]c_scl]),
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

  // Sensor to Display
  wire.wire("sensor-dist-to-display-dist", ("sensor-port-distance", "display-port-distance"), style: "zigzag", zigzag-ratio: 1/2-0.05)
  // Network to Display
  wire.wire("network-unit-to-display-unit", ("network-port-unit_signal", "display-port-unit"), style: "zigzag")
  wire.wire("network-alert-to-display-alert", ("network-port-alert_signal", "display-port-alert"), style: "zigzag", zigzag-ratio: 3/2)
  // Sensor to Network
  wire.wire("sensor-dist-to-network", ("sensor-port-distance", "network-port-upd_distance"), style: "dodge", dodge-y: -0.5)
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
      ),
      east: (
        (id: "display_unit", name: [display_unit]),
        (id: "display_alert", name: [display_alert]),
        (id: "display_distance", name: [display_distance]),
        (id: "display_distances", name: [display_distances]),
        (id: "brd_unit", name: [broadcast_unit]),
        (id: "brd_alert", name: [broadcast_alert]),
      )
    ),
    fill: util.colors.purple
  )
}

#let block-diagram = circuit({
  element.group(id: "mcu", name: "Microcontroller", stroke: (dash: "dashed"), {
    software-group(0, 0)
  })

  element.group(id: "mcu", name: "Client", stroke: (dash: "dashed", paint: http-color), {
    dashboard-block(21.5,-7)
  })

  draw.anchor("mcu-port-dashboard", (rel: (9.75,0), to: "network-port-dashboard"))
  // draw.anchor("mcu-port-serve-distances", (rel: (9.75,0), to: "network-port-distances"))
  // draw.anchor("mcu-port-brd-distance", (rel: (9.75,0), to: "network-port-brd_distance"))
  // draw.anchor("mcu-port-brd-unit", (rel: (9.75,0), to: "network-port-brd_unit"))
  // draw.anchor("mcu-port-brd-alert", (rel: (9.75,0), to: "network-port-brd_alert"))
  
  // wire.wire("network-serve-distances-out", ("network-port-distances", "mcu-port-serve-distances"), color: network-color)
  // wire.wire("network-brd-distance-out", ("network-port-brd_distance", "mcu-port-brd-distance"), color: network-color)
  // wire.wire("network-brd-unit", ("network-port-brd_unit", "mcu-port-brd-unit"), color: network-color)
  // wire.wire("network-brd-unit", ("network-port-brd_unit", "mcu-port-brd-unit"), color: network-color)

  // Network to dashboard serve
  wire.wire("network-dashboard-serve1", ("network-port-dashboard", (rel: (10.95,0))), color: http-color)
  wire.wire("network-dashboard-serve2", ((to: "network-port-dashboard", rel: (10.95,0)), (to: "network-port-dashboard", rel: (10.95,3.25))), color: http-color)
  wire.wire("network-dashboard-serve3", ((to: "network-port-dashboard", rel: (10.95,3.25)), "mcu.north"), color: http-color, style: "zigzag", zigzag-ratio: 100%, directed: true)
  
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
