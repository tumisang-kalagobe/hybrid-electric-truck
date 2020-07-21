for cycle=3:1:6
    dropping_bars(cycle)
end
    
dbn = importdata("Fuel Consumption Data/Routes/Per100km_DBN-JHB.txt");
pe = importdata("Fuel Consumption Data/Routes/Per100km_PE-JHB.txt");
cpt = importdata("Fuel Consumption Data/Routes/Per100km_CPT-JHB.txt");

function dropping_bars(cycle)
%{
Function that plots graphs of the generated fuel consumption data for
the various drive train configurations at differing velocities.

Inputs:
    selection       = number associated with the drive cycle (see 
                      cycle_time)
%}

engines = {'IC Engine', 'Parallel Hybrid', 'Series Hybrid'};

switch cycle
    case 3
        pic_rate = "Fuel Consumption Data/Drive Cycles/bars_rate.png";
        pic_total = "Fuel Consumption Data/Drive Cycles/bars.png";
        
        file_total = "Fuel Consumption Data/Drive Cycles/total.txt";
        file_rate = "Fuel Consumption Data/Drive Cycles/per100km.txt";
    case 4
        pic_rate = "Fuel Consumption Data/Routes/bars_rate_DBN-JHB.png";
        pic_total = "Fuel Consumption Data/Routes/bars_DBN-JHB.png";
        
        file_total = "Fuel Consumption Data/Routes/Total_DBN-JHB.txt";
        file_rate = "Fuel Consumption Data/Routes/Per100km_DBN-JHB.txt";
    case 5 
        pic_rate = "Fuel Consumption Data/Routes/bars_rate_PE-JHB.png";
        pic_total = "Fuel Consumption Data/Routes/bars_PE-JHB.png";
        
        file_total = "Fuel Consumption Data/Routes/Total_PE-JHB.txt";
        file_rate = "Fuel Consumption Data/Routes/Per100km_PE-JHB.txt";
    case 6
        pic_rate = "Fuel Consumption Data/Routes/bars_rate_CPT-JHB.png";
        pic_total = "Fuel Consumption Data/Routes/bars_CPT-JHB.png";
        
        file_total = "Fuel Consumption Data/Routes/Total_CPT-JHB.txt";
        file_rate = "Fuel Consumption Data/Routes/Per100km_CPT-JHB.txt";
    otherwise
        disp('No Drive Cyce Selected. Run again and select a cycle.')
end
total_import = importdata(file_total);
total = total_import.data;

per100km_import = importdata(file_rate);
per100km = per100km_import.data;

if cycle == 4 || cycle == 5 || cycle == 6
    groups = categorical({'60km/h','70km/h','80km/h', '90km/h', '100km/h'});
else 
    groups = categorical({'Cruise', 'Transient', 'Creep'});
end

bar(groups, total)
ylabel('Fuel Consumption (l)')
legend(engines, 'Location', 'best')
print(gcf,pic_total,'-dpng','-r600')
close all;

bar(groups, per100km)
ylabel('Fuel Consumption per 100km (l/100km)')
legend(engines, 'Location', 'best')
print(gcf,pic_rate,'-dpng','-r600')
close all;

end 