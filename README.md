# Smart-Indoor-Shopping-Cart-Navigation-using-LoRa-UWB-MATLAB-Simulation-
📌 Project Overview  This project presents a real-world inspired indoor navigation and localization system for smart shopping carts, simulated entirely in MATLAB.
The system combines LoRa-based zone-level localization with UWB-based rack-level ranging, enhanced using noise modeling and Kalman filtering, to guide a shopping cart along the shortest possible path inside a shopping mall.
The project focuses on algorithm design, signal behavior modeling, filtering, and routing logic, making it suitable for scenarios where hardware implementation is constrained.

🎯 Key Objectives
Simulate indoor localization using LoRa and UWB
Model realistic wireless noise and signal fluctuations
Apply Kalman filtering to stabilize noisy distance estimates
Implement grid-based shortest path routing avoiding racks
Provide visual feedback using GUI and live graphs
Demonstrate hardware-feasible logic using coordinate-based simulation

🧠 System Concept (High-Level)
The shopping mall is divided into:
Zones (each with a LoRa node)
Racks (each with a UWB node)
A smart cart:
Uses LoRa for long-range zone detection
Switches to UWB within 30 meters for rack-level proximity
Selects products and computes the shortest aisle-following path
Displays real-time distance values and filtered estimates

🗺️ MATLAB Simulation Architecture
The simulation runs using four coordinated GUI windows:
1️⃣ Mall Layout Window
2D top-down map of the shopping mall
Zones, aisles, racks, and invisible routing grids
A draggable red cart dot represents the shopping cart
Shortest path is drawn only along aisles (grid-based)
2️⃣ Product Selection GUI
Zone-wise product listing
Multiple item selection supported
Automatically maps each product to its correct rack
Initiates shortest-path computation when started
3️⃣ LoRa & UWB Distance Monitor
Displays zone-level distances (LoRa)
Displays rack-level distances (UWB) when cart enters a zone
Shows both noisy and filtered distance values
Mimics real sensor behavior
4️⃣ Distance Analysis Graph Window
Live plots for 6 zones simultaneously
Two graphs:
Raw (Noisy) Distance
Filtered Distance (Kalman Filter)
Helps visualize the effectiveness of filtering
📡 Localization Logic Explained
🔵 LoRa-Based Zone Localization
Each zone has a fixed LoRa node
Cart calculates distance using RSSI-based path-loss model
Noise is added to simulate real wireless conditions
Suitable for coarse, long-range localization

🟢 UWB-Based Rack Localization
Activated when cart is within 30 meters of a zone
Rack-level distance estimation
Higher accuracy than LoRa
Used for precise rack identification

📉 Noise Modeling
Real wireless signals are noisy due to:
Multipath reflection
Interference
Obstacles (acks, walls)
To simulate this:
Gaussian noise is added to distance/RSSI values
Noise level differs for LoRa and UWB
Noise causes overlapping distance readings between zones
This behavior is intentionally introduced to match real-world conditions.

🔍 Filtering Technique (Kalman Filter)
Why Kalman Filter?
Raw RSSI-based distance measurements fluctuate heavily and can cause:
Wrong zone estimation
Incorrect rack detection
What Kalman Filter Does
Predicts the next distance value
Corrects prediction using noisy measurements
Minimizes variance over time
Produces stable and reliable distance estimates
Effect Observed in Simulation
Raw graph: distance curves overlap and fluctuate
Filtered graph: clear separation between zones
Enables confident cart localization

🧭 Shortest Path Routing Logic
Routing Constraints
Cart cannot move diagonally
Cart cannot pass through racks
Movement is restricted to aisles only
Routing Method Used
Invisible grid-based routing
Manhattan distance heuristic
Nearest-neighbor ordering for multiple products

Result
Realistic shopping behavior
Cartoves aisle-to-aisle like a real person

Ensures shortest feasible route
