# hybrid-electric-truck

This is a model of 3 specific drive trains used in a semi-truck trailer, which are compared in order to assess the potential CO2 emission reduction achieved through hybridization. Each drive train is modelled in Simulink and initialised through a script in Matlab. The three drive trains are namely:

- Conventional Internal Combustion Engine (truck.slx)
- Series/Plug-in Hybrid (series.slx)
- Parallel/Full Hybrid (parallel.slx)

All three of these models go through two distinct drive cycles, namely a constant velocity cycle with varying gradients as experienced on trips between Johannesburg and the 3 major port cities in South Africa (Durban, Port Elizabeth and Cape Town), and constant gradient, Heavy Heavy-Duty Diesel Truck (HHDDT) drive cycles which are standard cycles used to assess fuel consumption. The data used for the former can be found in *Elevation Matrices*, while the latter data can be found in *Drive Schedules*. 

The fuel consumption data is written into *Fuel Consumption Data* for all of the drive trains and the various drive cycles. 

Details of the modelling and the results thereof can be found in "Thesis.pdf".

*Copyright disclaimer: This work may be used for further research, design developments and other projects provided that due credit is given for the initial models and data. Suggested reference: Kalagobe, T. (2019). Reduction of Fuel Consumption and CO2 Emissions using a Hybrid Drive Train in a Truck Logistics Operation.*
