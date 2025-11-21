#import "template.typ": *

#import "authors.typ": authors

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Project Title",
  authors: authors,
  team-number: "Team Number: 21"
)

// = <section>
// #link(<video-link>)[#strong[Video link 2];]

// #link(
//   <team-member-work-distribution>,
// )[#strong[Team Member Work Distribution 2];]

// #link(<system-level-block-diagram>)[#strong[System Level Block Diagram 2];]

// #link(<system-description>)[#strong[System Description 2];]

// #link(
//   <system-design-details-and-validation>,
// )[#strong[System Design Details and Validation 2];]

// #quote(block: true)[
//   #link(<top-level-architecture>)[Top Level Architecture 2]

//   #link(
//     <block-1-design-details-name-of-block-owner>,
//   )[Block 1 Design Details, Name of Block Owner 3]

//   #link(
//     <block-2-design-details-name-of-block-owner>,
//   )[Block 2 Design Details, Name of Block Owner 3]

//   #link(
//     <block-3-design-details-name-of-block-owner>,
//   )[Block 3 Design Details, Name of Block Owner 3]

//   #link(
//     <block-4-voltage-regulator-ncp-1117-or-other-7805s>,
//   )[Block 4 Voltage Regulator (NCP 1117 or other 7805s) 3]
// ]

// #link(
//   <system-level-interface-validation-table>,
// )[#strong[System Level Interface Validation Table 3];]

// #link(
//   <engineering-requirements>,
// )[#strong[List of Engineering Requirements 4];]

// #link(<verification-process>)[#strong[Verification Process 4];]

// #link(<artifacts>)[#strong[Artifacts 4];]

// #link(<references>)[#strong[References 4];]

#v(2em)

#outline(title: none)

#pagebreak()

= Video link <video-link>
{Put the link to the demonstration video here. Ensure it has sharing settings that allow the instructional team to view it}

= Team Member Work Distribution <team-member-work-distribution>
#figure(table(
  columns: (33.33%, 33.33%, 33.33%),
  align: left,
  table.header(
    [Name {Put the name of each member and their ID number in the cells below.}], table.cell(
          align: left,
        )[Contributions {Put a brief description of what tasks each member contributed to in the cells below.}], table.cell(
          align: left,
        )[Hours worked (total) {Estimate and include the total hours worked by each team member on the team in the cells below.}], table.cell(align: left)[Yahir Raygoza Cortez, ID: 934-524-855], table.cell(align: left)[Built the power aspect of the hardware.], table.cell(align: left)[TBA], table.cell(align: left)[Oliver Siemens, ID: 934-512-106], table.cell(align: left)[Built the sensor block.], table.cell(align: left)[TBD], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[],
      ), table.hline(),
    )
)

= System Level Block Diagram <system-level-block-diagram>
#figure(
  align(
    center,
  )[#table(
      columns: (100%), align: (auto,), table.header(
        table.cell(
          align: center,
        )[{Create a system level block diagram with all system level interfaces labeled.}], table.cell(
          align: center,
        )[Fig. 1: System level block diagram for the portable sensor.],
      ), table.hline(),
    )], kind: table,
)

= System Description <system-description>
{Describe what the system does, make sure to include the names and functions of all system level interfaces. Make sure the system level interfaces are created directly from the functionality described in the engineering requirements.}

= System Design Details and Validation <system-design-details-and-validation>
== Top Level Architecture <top-level-architecture>
#figure(
  align(
    center,
  )[#table(
      columns: (100%), align: (auto,), table.header(
        table.cell(
          align: center,
        )[{Insert figure here of the top-level architecture associated with your project. Make sure it includes the system level interfaces AND any internal interfaces.}.], table.cell(
          align: center,
        )[{Make sure to label all figures and include a thorough description of each.}],
      ), table.hline(),
    )], kind: table,
)

== Block 1 Design Details, Name of Block Owner <block-1-design-details-name-of-block-owner>
{Insert Block Design Document details for block 1 here. Include at a minimum the block diagram, description, interface validation table, and artifacts.}

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.cell(colspan: 3)[*outside\_power\_dcpwr: Input*],
  [Vmin: 4.75V], [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  [Vmax: 5.25V], [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  [Inominal: 425mA], [The standard charging rate of our 850mAh battery is 0.5C @lipo_battery_803035], [We set our battery charging board to charge our 850mAh battery at 0.5C],
  [Ipeak: 500mA], [The maximum current draw for high power usb 1.0 decives is 500mA @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  table.cell(colspan:3)[*regulator_mcu_dcpwr: Output*],
  [Vmin: 4.9V], [The minimum voltage output of the ncp1117 voltage regulator is 5v - 2% @ncp1117_datasheet], [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 4.9V minimum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  [Vmax: 5.1V], [The maximum voltage output of the ncp1117 voltage regulator is 5v + 2% @ncp1117_datasheet], [The voltage regulator utilizes an NCP1117 IC that takes an input voltage of 6.5V to 12V which will convert it to a fixed output voltage of 5.1V maximum. This was verified through testing and is also specified in the datasheet @ncp1117_datasheet],
  [Inominal: 100mA], [The esp32 board draws an average current of 100mA @esp32_wroom_32_datasheet], [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA], 
  [Ipeak: 500mA], [The esp32 board draws a maximum current of 500mA @esp32_wroom_32_datasheet], [The ncp1117 can supply a maximum current of 800mA @ncp1117_datasheet, and the lipo battery can supply a maximum of 1C of discharge (850mA) @lipo_battery_803035, which will be used by the buck converter to increase the voltage from 5v to 7v, and decrease the current by the same ratio (1.4), so the power block supplies 600mA]
))

== Block 2 Design Details, Name of Block Owner <block-2-design-details-name-of-block-owner>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.cell(colspan: 3)[*regulator_mcu_dcpwr: Input*],
  [],[],[],
  table.cell(colspan: 3)[*sensor_mcu_sda_comm: Input*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_sensor_dcpwr: Output*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_sensor_scl_comm: Output*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_display_sda_comm: Output*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_display_scl_comm: Output*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_display_dcpwr: Output*],
  [],[],[],
))

== Block 3 Design Details, Name of Block Owner <block-3-design-details-name-of-block-owner>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.cell(colspan: 3)[*mcu_display_dcpwr: Input*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_display_scl_comm: Input*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_display_sda_comm: Input*],
  [],[],[],
))

== Block 4 Voltage Regulator (NCP 1117 or other 7805s) <block-4-voltage-regulator-ncp-1117-or-other-7805s>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  table.cell(colspan: 3)[*mcu_sensor_dcpwr: Input*],
  [],[],[],
  table.cell(colspan: 3)[*mcu_sensor_scl_comm: Input*],
  [],[],[],
  table.cell(colspan: 3)[*sensor_mcu_sda_comm: Output*],
  [],[],[],
))

= System Level Interface Validation Table <system-level-interface-validation-table>
{Be sure to include only system-level interfaces. System-level interface values and properties must match their corresponding block-level interfaces.}

#figure(table(
  columns: 3,
  table.header(
    [*Interface Property*],
    [*Why is this interface this value?*],
    [*Why do you know that your #underline[system] design details meet or exceed each property (reference block details as needed)?*]
  ),
  
  table.cell(colspan: 3)[*outside\_power\_dcpwr: Input*],
  [Vmin: 4.75V], [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  [Vmax: 5.25V], [The tolerance range for input voltages of usb 1.0 is 5v +/- 5% @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  [Inominal: 425mA], [The standard charging rate of our 850mAh battery is 0.5C @lipo_battery_803035], [We set our battery charging board to charge our 850mAh battery at 0.5C],
  [Ipeak: 500mA], [The maximum current draw for high power usb 1.0 decives is 500mA @usb_spec_1_0], [This is a well-verified property of the usb 1.0 standard @usb_spec_1_0],
  table.cell(colspan:3)[*outside_sensor_envin*],
  [Maximum distance: 1200mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 1.2m away],
  [Minimum distance: 100mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 100cm away],
  table.cell(colspan:3)[*display\_outside\_usrout: Output*],
  [Units: mm, cm, m, ft, in], [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  [Maximum distance: 1200mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 1.2m away],
  [Minimum distance: 100mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 100cm away],
  table.cell(colspan:3)[*dashboard_outside_usrout: Output*],
  [Units: mm, cm, m, ft, in], [These are common units the user may want the distance displayed in], [Our code allows for the distance to be displayed in these units],
  [Maximum distance: 1200mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 1.2m away],
  [Minimum distance: 100mm], [The project instructions document specified an engineering requirement that the device must measure distances from 0.1m-1.2m @esp32_project_instructions], [Our device can accurately measure distances 100cm away],
  )
))

= Engineering Requirements <engineering-requirements>
+ The system must be battery operated.

+ The system must sense distances from 0.1m to 0.2m with a margin of error no greater than $plus.minus 10%$ margin of error.

= Verification Process <verification-process>
+ {Enumerate a verification process here that any junior in the class could follow. Be as specific and expository as possible. Use prior lab documentation to guide your verification process. Imagine this process was handed to another team to complete who did not design your system. Write instructions they could follow}

= Artifacts <artifacts>
{Populate this section with the miscellaneous but important findings that got you to your final system. This can be prior lab work, examples found online, reference schematics, pseudocode, previous or prior version block diagrams, etc.}

= References <references>
#block[
  #set enum(numbering: "1.", start: 1)
  + Include all relevant IEEE citations.

  + Cite everything you did not create yourself for this document. This includes but is not limited to diagrams, schematics, pseudocode/code, pinout visuals, etc.
]

#bibliography("references.yaml", title: none)
