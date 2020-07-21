clc; clear;
%{
Author          :   Tumisang Kalagobe (800363)
Supervisor      :   Professor Frank Kienhoffer
Date finalised  :   27/08/2019
Matlab Version  :   R2018b v9.5.0.1049112
Course          :   Mechanical Engineering Research Project (MECN4006)
Description     :   Quasistatic Fuel Consumption Prediction of Various
                    Drive Trains for a Semi Truck Trailer Logistics
                    Operation. More Information on how the models were 
                    developed can be found in "800363.pdf"
%}

tic 
%% Simulation parameters and required files
n = 100;                                 % no. of data points for maps
[elevation, gradients, t_stop, distance, selection, txt_file] ...
    = cycle_time();

% Data files %
engine_file = 'Drive_Train_Data/Mack_MP8_505HP.txt';        % engine data
gearbox_file = 'Drive_Train_Data/Genta_Example.txt';        % gearbox data
motor_file = 'Drive_Train_Data/Siemens_Simotics_8288.txt';  % motor data

% Model files %
ic_engine_model = 'truck.slx';          % ic engine
parallel_model = 'parallel.slx';        % parallel
series_model = 'series.slx';            % series

%% Conversion factors
unitToKilo = 1/1000;                    % unit to kilo
mpsToKPH = 3.6;                         % m/s to km/h
rpsToRPM = 60/(2*pi);                   % radians per second to rpm
lbftToNm = 1.35581795;                  % N.m = ft-lb * lb_ftToN_m

%% Gearbox Data
gearbox = importdata(gearbox_file);
gear_ratios = gearbox.data;             %  data for the selected gearbox
shift_up_rpm = 1600/rpsToRPM;           %  rad/s for gear shift up
shift_down_rpm = 850/rpsToRPM;          %  rad/s for gear shift down                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
gearRatio_differential = 4.263;         %  differential gear ratio (WH:GB)

series_gear_ratio = 4.263;              %  series single gear ratio
                                                                                                                                                                                            
%% Fuel and environment data                                                         
fuel_density = 837;                     % kg/m^3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
fuel_LHV = 42.72e6;                     % J/kg
g = 9.81;                               % m/s^2
air_density_sea_level = 1.225;          % kg/m^3

%% Truck data
mass_truck = 7150;                      % kg
mass_trailor = 32000;                   % kg
total_mass = mass_truck + mass_trailor; % kg
frontal_area = 5.14;                    % m^2

momentOfInertia_wheel = 2.5;            % kg.m^2
momentOfInertia_transmission = 1.1;     % kg.m^2
momentOfInertia_engine = 2.55;          % kg.m^2

wheels_truck = 4;
wheels_trailor = 12;
wheels = wheels_truck + wheels_trailor; % total number of wheels
radius_wheel = 0.46; % m

rolling_resistance = 0.008;             % rolling resistance coefficient
drag_coeff = 0.65;                      % drag coefficient

%% Electric Motor data
motor_data = importdata(motor_file);
motor = motor_data.data;
motor_efficiency = motor(1);            % -
motor_rated_torque = motor(2);          % N.m
motor_rated_rpm = motor(3);             % rpm
motor_rated_power = motor(4);           % kW
regeneration_efficiency = 0.75;         % kinetic energy recovery eff.

%% Battery data 
battery_SoC = 0.95;                     % initial state of charge (%)
battery_efficiency = 0.8;               % -           % sec
battery_capacity = 24.5;                % kWh 
battery_v = 144;                        % Volts
battery_max_i = 160;                    % Amps (maximum recharge current)
battery_max_power_flow = battery_v*battery_max_i; % Watts
battery_no_of_modules = 15;             % number of battery modules

%% IC engine data
engine_efficiency = 0.37;               % -

engine = importdata(engine_file);
engine_torque = lbftToNm.*engine.data(:,1); % N.m
engine_rpm = engine.data(:,2);          % rpm
engine_rad = engine_rpm./rpsToRPM;

idling_speed = 600;                     % rpm
idling_speed_rad = idling_speed/rpsToRPM;
idling_torque = interp1(engine_rpm(1:2),engine_torque(1:2),idling_speed,...
                  'linear','extrap'); % extrapolated torque at idling speed

% Engine torque and rpm for max fuel efficiency %
engine_optimum_torque = max(engine_torque);
engine_optimum_index = find(engine_torque==engine_optimum_torque,1);
engine_optimum_rad = engine_rad(engine_optimum_index);              
                    
% Engine fuel consumption map %
torque_axes = linspace(min(engine_torque),max(engine_torque),n);
rps_axes = linspace(min(engine_rad),max(engine_rad),n);
fuel_map = (3.6e6/(engine_efficiency*fuel_LHV*fuel_density))*...
           (rps_axes'*torque_axes);% litres per hour

%% Power Split for Parallel
v_motor_max = 20; % Max velocity supplied exclusively by motor (km/h)
v_cruise = 65; % Cruise velocity - ie when IC drive only (km/h)

slopes = ones(n,n).*linspace(0,max(gradients),n);
velocities = ones(n,n).*linspace(v_motor_max,v_cruise,n);

m_v = 1/(v_motor_max - v_cruise);
m_a = 1/(max(gradients));

u = m_a.*slopes + m_v.*(velocities' - v_cruise); % power split ratio map

%% Simulink Executions
t_sample = 0.1;                             % simulation sample time (s)
constant_velocity = 60;                     % constant velocity (km/h)

if selection > 3
    fuel_cons = zeros(5,3);
    fuel_cons_per100km = zeros(5,3);
    i = 1;
    for constant_velocity = 60:10:100
        % Conventional IC Engine %
        disp('Running IC Engine...')
        sim(ic_engine_model);
        fuel_baseline = sum(fuel_consumption_baseline);
        baseline_per100km = 100*fuel_baseline/max(distance);
        disp('IC Engine Complete. Running Parallel...')

        % Parallel Hybrid %
        sim(parallel_model);
        fuel_parallel = sum(fuel_consumption_parallel);
        parallel_per100km = 100*fuel_parallel/max(distance);
        disp('Parallel Complete. Running Series...')

        % Series Hybrid %
        sim(series_model);
        fuel_series = sum(fuel_consumption_series);
        series_per100km = 100*fuel_series/max(distance);
        disp('Series Complete.')
        clc;

        fuel_cons(i,:) = [fuel_baseline, fuel_parallel, fuel_series];
        fuel_cons_per100km(i,:) = [baseline_per100km,parallel_per100km,...
                                    series_per100km];

        i = i + 1;

        disp(constant_velocity + "km/h run complete.")
    end 

else 
    % Conventional IC Engine %
    disp('Running IC Engine...')
    sim(ic_engine_model);
    fuel_baseline = sum(fuel_consumption_baseline);
    baseline_per100km = 100*fuel_baseline/max(distance);
    disp('IC Engine Complete. Running Parallel...')

    % Parallel Hybrid %
    sim(parallel_model);
    fuel_parallel = sum(fuel_consumption_parallel);
    parallel_per100km = 100*fuel_parallel/max(distance);
    disp('Parallel Complete. Running Series...')

    % Series Hybrid %
    sim(series_model);
    fuel_series = sum(fuel_consumption_series);
    series_per100km = 100*fuel_series/max(distance);
    disp('Series Complete.')
end

disp('Simulation Complete!')
toc

%% Functions
function [elevation, gradients, t_stop, distance, selection, fuel_file]...
    = cycle_time()
%{
Function that requests a user input for the desired drive cycle. If the
desired cycle is "Creep", "Transient" or "Cruise" then the user must ensure
that the drive cycle source in "{truck/series/parallel}.slx > Driving 
Profile > Standard Drie Cycle on flat terrain" matches the selected drive
cycle. 
%}
    
    drive_cycle = {'Cruise', 'Transient', 'Creep', 'DBN-JHB', 'PE-JHB',... 
        'CPT-JHB'};
    selection = listdlg('ListString', drive_cycle);
    if selection > 3
        if selection == 4 
            geo_file = 'Elevation Matrices/DBN-JHB.txt';
            fuel_file = "DBN-JHB.txt";
        elseif selection == 5
            geo_file = 'Elevation Matrices/PE-JHB.txt';
            fuel_file = "PE-JHB.txt";
        else
            geo_file = 'Elevation Matrices/CPT-JHB.txt';
            fuel_file = "CPT-JHB.txt";
        end 
    else 
        geo_file = 'Elevation Matrices/DBN-JHB.txt'; 
        fuel_file = 0;
    end 
    
    route = importdata(geo_file);
    elevation = route.data(:,3); % m
    distance = route.data(:,4); % km
    gradients = (pi/400).*route.data(:,5); % rad
    for i=1:length(gradients)
        if isnan(gradients(i)) || gradients(i) == Inf
            gradients(i) = 0;
        end
    end
    
    % setting simulation times and distances
    if selection == 1
        t_stop = 2083;
        distance = 37.12;% km
    elseif selection == 2 
        t_stop = 668;
        distance = 4.51;% km
    elseif selection == 3
        t_stop = 253;
        distance = 0.20;% km
    else
        t_stop = length(distance);
    end 
end