M104 S0 ; Stops OrcaSlicer from sending temp waits separately.
M140 S0
PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer_single]
