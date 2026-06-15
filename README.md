
# SPI Slave — RTL-to-GDSII Physical Design
### SkyWater 130nm PDK · OpenROAD Automated PnR Flow

A complete RTL-to-GDSII implementation of a custom SPI (Serial Peripheral Interface) Slave Node, executed using the open-source SkyWater 130nm process and the OpenROAD automated physical design suite.

---

## Overview

SPI is a synchronous, full-duplex serial communication protocol fundamental to embedded systems — enabling data exchange between a master controller and peripheral devices such as sensors, ADCs, displays, and flash memory. This project implements the slave-side silicon block from behavioral RTL through to a fully routed, sign-off-clean GDSII layout.

---

## Toolchain

| Stage | Tool |
|---|---|
| RTL Synthesis | Yosys |
| Floorplanning / Placement / Routing | OpenROAD |
| Clock Tree Synthesis | TritonCTS |
| DRC Sign-off | Magic |
| LVS Sign-off | Netgen |
| Process Node | SkyWater SKY130B (130nm) |

---

## Repository Structure

```
spi-slave-sky130/
├── rtl/
│   └── spi_slave.v                  # Behavioral Verilog source
├── constraints/
│   └── spi_slave.sdc                # Timing constraints (SDC)
├── config/
│   └── config.json                  # OpenROAD flow configuration
├── results/
│   ├── synthesis/
│   │   └── spi_slave.synth.v        # Post-synthesis netlist
│   ├── floorplan/
│   ├── placement/
│   ├── cts/
│   ├── routing/
│   └── final/
│       ├── spi_slave.gds            # Final GDSII layout
│       └── spi_slave.lef            # Layout Exchange Format
├── reports/
│   ├── timing/
│   │   ├── setup.rpt                # STA setup slack report
│   │   └── hold.rpt                 # STA hold slack report
│   ├── drc.rpt                      # Magic DRC report
│   ├── lvs.rpt                      # Netgen LVS report
│   └── utilization.rpt              # Core utilization report
├── screenshots/
│   ├── gds_full.png                 # Full die layout view
│   └── gds_zoomed.png               # Zoomed cell-level view
└── README.md
```

---

## Implementation Details

### Synthesis & Floorplanning
Behavioral Verilog was synthesized and mapped to the Sky130 standard cell library using Yosys. The physical core was constrained to a **42 × 42 µm** bounding box, achieving **54% core utilization** — a density that balances area efficiency with sufficient routing track headroom to avoid congestion during detailed routing.

### Clock Tree Synthesis
TritonCTS constructed a balanced clock distribution network using dedicated `__clkbuf_` cells, minimizing skew across all pipeline registers and maintaining pulse integrity at sequential element inputs.

### Power Distribution Network
A structured PDN was implemented with VDD/VSS straps across metal layers, keeping IR drop within acceptable margins throughout the core area.

---

## Post-Layout Results

### Physical Sign-off

| Check | Result |
|---|---|
| DRC (Magic) | ✅ Clean — 0 violations |
| LVS (Netgen) | ✅ Clean — layout matches schematic |
| Core Utilization | 54% |
| Die Area | 42 × 42 µm |

### Static Timing Analysis — Worst-Case Corner

| Metric | Value | Notes |
|---|---|---|
| Target Clock Period | 10.00 ns (100 MHz) | SDC constraint |
| Setup Slack (WNS) | **+8.37 ns** | ~4.7× timing headroom over target |
| Hold Slack | **+0.15 ns** | Met without aggressive buffer insertion |
| Total Negative Slack (TNS) | **0.00 ns** | Zero violations across full netlist |
| Estimated Fmax | ~500 MHz | Near Sky130 process ceiling |

---

## Layout

### Full Die View
![GDS Full Layout](screenshots/gds_full.png)

### Zoomed Cell-Level View
![GDS Zoomed](screenshots/gds_zoomed.png)

*Red: M2/M3 routing layers · Green: M1 / local interconnect · Blue: diffusion / poly · Scale bar: 0–4 µm*

---

## How to Reproduce

### Prerequisites
- [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts)
- SkyWater SKY130B PDK (via `volare` or manual install)
- Yosys, Magic, Netgen

### Run the Flow
```bash
git clone https://github.com/<your-username>/spi-slave-sky130
cd spi-slave-sky130

# From your OpenROAD-flow-scripts installation
make DESIGN_CONFIG=./config/config.json
```

### View the Layout
```bash
# Open final GDS in Magic
magic -T $PDK_ROOT/sky130A/libs.tech/magic/sky130A.tech \
      results/final/spi_slave.gds
```

---

## Key Learnings

Getting clean timing closure out of OpenROAD demands precise alignment between SDC constraints, Liberty timing files, and floorplan decisions simultaneously — the automated flow surfaces problems in each of these layers independently, and debugging them iteratively is where the real learning happens. The 54% utilization figure was not accidental; it was arrived at through multiple floorplan iterations to find the density that allowed the router to close timing without congestion detours inflating path delays.

---

## Author

**Dhruv** — Electrical & Electronics Engineering, VIT, Vellore (Batch 2024–2028)  
Electrical & Embedded Systems Engineer, Team RoverX · RTL / FPGA / ASIC Design

[LinkedIn](https://www.linkedin.com/in/dhruvp546/) · [GitHub](https://github.com/dhruv050406)
