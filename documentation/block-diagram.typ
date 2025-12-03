#import "@preview/cetz:0.3.2": draw
#import "@preview/circuiteria:0.2.0": *

#let hw-color = red
#let rf-color = blue

#let dashboard-block = (x, y) => {
  element.block(
    id: "dashboard",
    w: 10,
    h: 6,
    x: x,
    y: y,
    name: [Dashboard #v(8em) ],
    ports: (
      west: (
        (id: "rf", name: [mcu_dashboard_rf]),
        (id: "usrin", name: [outside_dashboard_usrin]),
      ),
      east: (
        (id: "usrout", name: [dashboard_outside_usrout]),
      )
    ),
    fill: util.colors.green
  )
}

#let dashboard-diagram = circuit({
  dashboard-block(0,0)
  wire.wire("dashboard-to-outside", ("dashboard-port-usrout", (rel: (1,0), to: "dashboard-port-usrout")), directed: true)
  wire.wire("outside-to-dashboard", ((rel: (-1,0), to: "dashboard-port-usrin"), "dashboard-port-usrin"), directed: true)
  wire.wire("mcu-to-dashboard", ((rel: (-1,0), to: "dashboard-port-rf"), "dashboard-port-rf"), directed: true)
  draw.mark((rel: (-1.1,0), to: "dashboard-port-rf"), (rel: (-2,0), to: "dashboard-port-rf"), symbol: ">", fill: black)
})

#let power-block = (x, y) => {
  element.block(
    id: "power",
    w: 10,
    h: 4,
    x: x,
    y: y,
    name: [Power #v(4em)],
    ports: (
      west: (
        (id: "dc-in", name: [outside_power_dcpwr]),
      ),
      east: (
        (id: "dc-out", name: [power_mcu_dcpwr]),
      )
    ),
    ports-margins: (
      west: (25%, 0%),
      east: (25%, 0%),
    ),
    fill: util.colors.purple
  )
}

#let power-diagram = circuit({
  power-block(0,0)
  wire.wire("outside-to-power", ((rel: (-1,0), to: "power-port-dc-in"), "power-port-dc-in"), directed: true)
  wire.wire("power-to-mcu", ("power-port-dc-out", (rel: (1,0), to: "power-port-dc-out")), directed: true)
})

#let distance-block = (x, y) => {
  element.block(
    id: "distance",
    w: 9,
    h: 5,
    x: x,
    y: y,
    name: [Distance Sensor #v(6em)],
    ports: (
      west: (
        (id: "dc-in", name: [mcu_distance_dcpwr]),
        (id: "comm", name: [mcu_distance_comm]),
        (id: "envin", name: [outside_distance_envin]),
      ),
    ),
    ports-margins: (
      west: (20%, 0%),
    ),
    fill: util.colors.orange
  )
}

#let distance-diagram = circuit({
  distance-block(0,0)
  wire.wire("mcu-to-distance-dcpwr", ((rel: (-1,0), to: "distance-port-dc-in"), "distance-port-dc-in"), directed: true)
  wire.wire("mcu-to-distance-comm", ((rel: (-1,0), to: "distance-port-comm"), "distance-port-comm"), directed: true)
  draw.mark((rel: (-1.1,0), to: "distance-port-comm"), (rel: (-2,0), to: "distance-port-comm"), symbol: ">", fill: black)
  wire.wire("outside-to-distance-envin", ((rel: (-1,0), to: "distance-port-envin"), "distance-port-envin"), directed: true)
})

#let display-block = (x, y) => {
  element.block(
    id: "display",
    w: 10,
    h: 5,
    x: x,
    y: y,
    name: [Display #v(6em)],
    ports: (
      west: (
        (id: "dc-in", name: [mcu_display_dcpwr]),
        (id: "comm", name: [mcu_display_comm]),
      ),
      east: (
        (id: "usrout", name: [display_outside_usrout]),
      )
    ),
    ports-margins: (
      west: (20%, 0%),
      east: (46.666%, 0%),
    ),
    fill: util.colors.pink
  )
}

#let display-diagram = circuit({
  display-block(0,0)
  wire.wire("mcu-to-display-dcpwr", ((rel: (-1,0), to: "display-port-dc-in"), "display-port-dc-in"), directed: true)
  wire.wire("mcu-to-display-comm", ((rel: (-1,0), to: "display-port-comm"), "display-port-comm"), directed: true)
  draw.mark((rel: (-1.1,0), to: "display-port-comm"), (rel: (-2,0), to: "display-port-comm"), symbol: ">", fill: black)
  wire.wire("display-to-outside", ("display-port-usrout", (rel: (1,0), to: "display-port-usrout")), directed: true)
})

#let mcu-block = (x, y) => {
  element.block(
    id: "mcu",
    w: 10,
    h: 6,
    x: x,
    y: y,
    name: [MCU #v(8em)],
    ports: (
      west: (
        (id: "dc-in", name: [power_mcu_dcpwr]),
        (id: "rf", name: [mcu_dashboard_rf]),
      ),
      east: (
        (id: "disp-dcpwr", name: [mcu_display_dcpwr]),
        (id: "disp-comm", name: [mcu_display_comm]),
        (id: "dist-dcpwr", name: [mcu_distance_dcpwr]),
        (id: "dist-comm", name: [mcu_distance_comm]),
      )
    ),
    ports-margins: (
      west: (15%, 0%),
      east: (15%, 0%),
    ),
    fill: util.colors.blue
  )
}

#let mcu-diagram = circuit({
  mcu-block(0,0)
  wire.wire("power-to-mcu", ((rel: (-1,0), to: "mcu-port-dc-in"), "mcu-port-dc-in"), directed: true)
  wire.wire("mcu-to-rf", ((rel: (-1,0), to: "mcu-port-rf"), "mcu-port-rf"), directed: true)
  draw.mark((rel: (-1.1,0), to: "mcu-port-rf"), (rel: (-2,0), to: "mcu-port-rf"), symbol: ">", fill: black)
  wire.wire("mcu-to-display-dcpwr", ("mcu-port-disp-dcpwr", (rel: (1,0), to: "mcu-port-disp-dcpwr")), directed: true)
  wire.wire("mcu-to-display-comm", ((rel: (1,0), to: "mcu-port-disp-comm"), "mcu-port-disp-comm"), directed: true)
  draw.mark((rel: (1.1,0), to: "mcu-port-disp-comm"), (rel: (2,0), to: "mcu-port-disp-comm"), symbol: ">", fill: black)
  wire.wire("mcu-to-distance-dcpwr", ("mcu-port-dist-dcpwr", (rel: (1,0), to: "mcu-port-dist-dcpwr")), directed: true)
  wire.wire("mcu-to-distance-comm", ((rel: (1,0), to: "mcu-port-dist-comm"), "mcu-port-dist-comm"), directed: true)
  draw.mark((rel: (1.1,0), to: "mcu-port-dist-comm"), (rel: (2,0), to: "mcu-port-dist-comm"), symbol: ">", fill: black)
})

#let hardware-group = (x, y) => {
  power-block(x,y+10)
  distance-block(x + 14,y)
  display-block(x + 14,y + 10)
  mcu-block(x,y+2)

  // Power to MCU connection
  wire.wire("power-to-mcu", ("power-port-dc-out", "mcu-port-dc-in"), style: "dodge", dodge-y: y + 9, directed: true)

  // MCU to Display connections
  wire.wire("mcu-to-display-dcpwr", ("mcu-port-disp-dcpwr", "display-port-dc-in"), style: "zigzag", zigzag-ratio: 25%, directed: true)
  wire.wire("mcu-to-display", ("mcu-port-disp-comm", "display-port-comm"), style: "zigzag", zigzag-ratio: 40%, directed: true)
    draw.mark("mcu-port-disp-comm", (rel: (-1,0)), symbol: ">", fill: black)


  // MCU to Distance connections
  wire.wire("mcu-to-distance-dcpwr", ("mcu-port-dist-dcpwr", "distance-port-dc-in"), style: "zigzag", zigzag-ratio: 55%, directed: true)
  wire.wire("mcu-to-distance", ("mcu-port-dist-comm", "distance-port-comm"), style: "zigzag", zigzag-ratio: 40%, directed: true)
  draw.mark("mcu-port-dist-comm", (rel: (-1,0)), symbol: ">", fill: black)
}

#let system-diagram = circuit({
  element.group(id: "system", name: [System], stroke: (dash: "dashed"), {
    element.group(id: "client", name: [Web Client], stroke: (dash: "dashed", paint: rf-color), padding: (left: 0.75), {
      dashboard-block(7,-9)
    })

    element.group(id: "hardware", name: [Hardware], stroke: (dash: "dashed", paint: hw-color), {
      hardware-group(0,0)
    })

    // MCU to Dashboard connection
    wire.wire("mcu-to-dashboard", ("mcu-port-rf", "dashboard-port-rf"), style: "dodge", dodge-sides: ("west", "west"), dodge-margins: (0.5, 0.5), dodge-y: 1.5, directed: true)
    draw.mark("mcu-port-rf", (rel: (1,0)), symbol: ">", fill: black)
  })

  // Dashboard Outside stubs
  wire.wire("dashboard-to-outside", ("dashboard-port-usrout", (rel: (10,0), to: "dashboard-port-usrout")), directed: true)
  wire.wire("outside-to-dashboard", ((rel: (-10,0), to: "dashboard-port-usrin"), "dashboard-port-usrin"), directed: true)

  // Power Outside stubs
  wire.wire("outside-to-power", ((rel: (-3,0), to: "power-port-dc-in"), "power-port-dc-in"), directed: true)

  // Display Outside stubs
  wire.wire("display-to-outside", ("display-port-usrout", (rel: (3,0), to: "display-port-usrout")), directed: true)
})


#set page(height: auto, width: auto, margin: 1cm)

#let system-black-box-diagram = circuit({
  element.block(
    id: "distance",
    w: 9,
    h: 5,
    x: 0,
    y: 0,
    name: [Distance Sensor #v(6em)],
    ports: (
      west: (
        (id: "dc-in", name: [mcu_distance_dcpwr]),
        (id: "comm", name: [mcu_distance_comm]),
        (id: "envin", name: [outside_distance_envin]),
      ),
    ),
    ports-margins: (
      west: (20%, 0%),
    ),
    fill: util.colors.orange
  )
})

#system-black-box-diagram
#colbreak()

#system-diagram
#colbreak()

#dashboard-diagram
#colbreak()

#power-diagram
#colbreak()

#distance-diagram
#colbreak()

#display-diagram
#colbreak()

#mcu-diagram
