# SDN Data Center on Mininet + POX (Clos/Fat-Tree)

Emulate a small data-center topology on Mininet and control it with a POX OpenFlow app that:
- computes equal-cost **shortest paths** and installs flow rules
- enforces **tenant isolation** via a simple firewall policy
- supports **transparent host/VM migration** with header rewriting

> Recommended environment: use the official Mininet VM. Start POX with `openflow.discovery`, then launch the Mininet fat-tree topology.

---

## Repository structure
sdn-mininet-fattree/
- src/ # pox & topo
- scripts/ # tiny runner scripts
- ext/ # runtime CSV configs
- docs/ # project docs



> **Runtime note:** POX loads modules from `~/pox/ext/`. Keep sources in this repo, but copy `CloudNetController.py`, `firewall_policies.csv`, and `migration_events.csv` into `~/pox/ext/` before running.

---

## Prerequisites

- Mininet (VM image recommended)
- POX controller checked out locally
- Python environment that can run POX and NetworkX

---

## Quick start

1) **Copy controller + configs into POX**

    ~~~bash
    # inside your POX checkout
    cp /path/to/repo/src/pox_controller/CloudNetController.py ./ext/
    cp /path/to/repo/ext/firewall_policies.csv ./ext/
    cp /path/to/repo/ext/migration_events.csv ./ext/
    ~~~

2) **Start POX** (choose a mode)

    ~~~bash
    # routing only
    ./pox.py openflow.discovery CloudNetController --firewall_capability=False --migration_capability=False

    # firewall only
    ./pox.py openflow.discovery CloudNetController --firewall_capability=True --migration_capability=False

    # migration only
    ./pox.py openflow.discovery CloudNetController --firewall_capability=False --migration_capability=True

    # both
    ./pox.py openflow.discovery CloudNetController --firewall_capability=True --migration_capability=True
    ~~~

3) **Launch the fat-tree topology (k=4)**

    ~~~bash
    sudo python /path/to/repo/src/mininet_topos/fattree_topo.py -k 4
    # Wait a few seconds for discovery to converge, then:
    mininet> pingall
    ~~~

---

## Inputs

- **`ext/firewall_policies.csv`** — tenant allow-list (affects ARP + IP).
  
  Example (16 hosts):
  ~~~text
  1,10.0.0.1,10.0.0.3,10.0.0.5,10.0.0.7,10.0.0.9,10.0.0.11,10.0.0.13,10.0.0.15
  2,10.0.0.2,10.0.0.4,10.0.0.6,10.0.0.8,10.0.0.10,10.0.0.12,10.0.0.14,10.0.0.16
  ~~~

- **`ext/migration_events.csv`** — planned events:
  ~~~text
  180,10.0.0.1,10.0.0.5
  ~~~
  Format: `delay_seconds,old_ip,new_ip`.

---

## What the controller does

- **Discovery & graph:** listens to POX `openflow.discovery`, builds a directed graph of switches.
- **Routing:** on a new IP flow, randomly selects one **shortest simple path** and installs rules **from destination toward source**, plus a `PacketOut` to push the first packet.
- **Firewall:** drops ARP/IP traffic across tenants according to the CSV mapping.
- **Migration:** at the scheduled time, deletes flows to the **old IP** and installs forward/reverse migrated paths with IP/MAC rewrites so peers still talk to the old address.

---

## Demo: reproduce the report

1) **Basic connectivity check (your Step 1)**

    ~~~bash
    # Terminal A: start POX (routing only)
    ./pox.py openflow.discovery CloudNetController --firewall_capability=False --migration_capability=False

    # Terminal B: quick mini-topology
    sudo mn --topo single,4 --controller=remote,ip=127.0.0.1,port=6633
    # Show nodes/links/ifconfig in Mininet if you like, then exit and proceed.
    ~~~

2) **Fat-tree routing (k=4)**

    ~~~bash
    # Terminal A: keep POX running (routing only as above)
    # Terminal B:
    sudo python /path/to/repo/src/mininet_topos/fattree_topo.py -k 4
    mininet> pingall
    ~~~

3) **Firewall isolation**

    ~~~bash
    # Terminal A: restart POX with firewall on
    ./pox.py openflow.discovery CloudNetController --firewall_capability=True --migration_capability=False

    # Terminal B: same fat-tree
    sudo python /path/to/repo/src/mininet_topos/fattree_topo.py -k 4
    # Expect odd↔odd and even↔even to pass, cross-tenant to fail.
    ~~~

4) **Migration**

    ~~~bash
    # Terminal A: restart POX with migration on (or both on)
    ./pox.py openflow.discovery CloudNetController --firewall_capability=False --migration_capability=True

    # Terminal B: fat-tree again
    sudo python /path/to/repo/src/mininet_topos/fattree_topo.py -k 4

    # In Mininet, start a continuous ping to the old IP (e.g., h7 -> 10.0.0.1)
    # After ~180s the controller migrates 10.0.0.1 to 10.0.0.5; traffic keeps flowing.
    ~~~

---

## Scripts (optional)

- `scripts/run_pox.sh`
    ~~~bash
    #!/usr/bin/env bash
    cd ~/pox
    ./pox.py openflow.discovery CloudNetController --firewall_capability=False --migration_capability=False
    ~~~

- `scripts/run_topo_k4.sh`
    ~~~bash
    #!/usr/bin/env bash
    sudo python "$(git rev-parse --show-toplevel)/src/mininet_topos/fattree_topo.py" -k 4
    ~~~

- `scripts/run_all_demo.sh`
    ~~~bash
    #!/usr/bin/env bash
    gnome-terminal -- bash -lc 'cd ~/pox && ./pox.py openflow.discovery CloudNetController --firewall_capability=True --migration_capability=True'
    gnome-terminal -- bash -lc 'sudo python "$(git rev-parse --show-toplevel)/src/mininet_topos/fattree_topo.py" -k 4'
    ~~~

---

## Troubleshooting

- Wait a few seconds after starting the topology so discovery can finish before pings.
- If you see unexpected loss in firewall/migration demos, double-check timing and rule installs.
- Keep the CSV files in `~/pox/ext/` exactly named as in this repo.

---

## License

- Your code: MIT (see `LICENSE`).

---

## References

- Mininet “Download/Get Started” (VM recommended).  
- POX manual/wiki and discovery component.  
- NetworkX `all_shortest_paths` and shortest-paths overview.

(Links: https://mininet.org/download/ • https://noxrepo.github.io/pox-doc/html/ • https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.shortest_paths.generic.all_shortest_paths.html • https://networkx.org/documentation/stable/reference/algorithms/shortest_paths.html)







