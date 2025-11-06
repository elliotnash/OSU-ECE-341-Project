#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Project Title",
  authors: (
    "Elliot Nash",
  ),
  team-number: "TEAM_NUMBER"
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
#figure(
  align(
    center,
  )[#table(
      columns: (33.33%, 33.33%, 33.33%), align: (auto, auto, auto,), table.header(
        table.cell(
          align: left,
        )[Name {Put the name of each member and their ID number in the cells below.}], table.cell(
          align: left,
        )[Contributions {Put a brief description of what tasks each member contributed to in the cells below.}], table.cell(
          align: left,
        )[Hours worked (total) {Estimate and include the total hours worked by each team member on the team in the cells below.}], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[], table.cell(align: left)[],
      ), table.hline(),
    )], kind: table,
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

== Block 2 Design Details, Name of Block Owner <block-2-design-details-name-of-block-owner>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

== Block 3 Design Details, Name of Block Owner <block-3-design-details-name-of-block-owner>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

== Block 4 Voltage Regulator (NCP 1117 or other 7805s) <block-4-voltage-regulator-ncp-1117-or-other-7805s>
{Insert Block Design Document details for block 1 here.Include at a minimum the block diagram, description, interface validation table, and artifacts.}

= System Level Interface Validation Table <system-level-interface-validation-table>
{Be sure to include only system-level interfaces. System-level interface values and properties must match their corresponding block-level interfaces.}

#figure(
  align(
    center,
  )[#table(
      columns: (24.04%, 37.82%, 38.14%), align: (auto, auto, auto,), table.header(
        table.cell(align: center)[#quote(block: true)[
            #strong[Interface Property]
          ]

        ], table.cell(align: center)[#quote(block: true)[
            #strong[Why is this interface this value?]
          ]

        ], table.cell(
          align: center,
        )[#quote(
            block: true,
          )[
            #strong[Why do you know that your #underline[system] design details]

            #strong[meet or exceed each property (reference block details as needed)?]
          ]

        ], table.cell(colspan: 3)[#quote(block: true)[
            #strong[outside\_???\_dcpwr: Input]
          ]

        ], [#quote(block: true)[
            Vmin: {enter voltage here} V
          ]

        ], [], [], [#quote(block: true)[
            Vmax: {enter voltage here} V
          ]

        ], [], [], [#quote(block: true)[
            Inominal: {enter current here} mA
          ]

        ], [], [], [#quote(block: true)[
            Ipeak: {enter current here} mA
          ]

        ], [], [], table.cell(colspan: 3)[#quote(block: true)[
            #strong[???\_outside\_???: Output]
          ]

        ], [#quote(block: true)[
            ???: ???
          ]

        ], [], [],
      ), table.hline(),
    )], kind: table,
)

= Engineering Requirements <engineering-requirements>
+ The system must be battery operated.

+ {List your ERs here.}

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
