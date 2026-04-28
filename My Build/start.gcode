; Start macro: Heat bed and nozzle simultaneously.
M104 S200                                        ; Preheat nozzle to 200°C (non-blocking).
M140 S[bed_temperature_initial_layer_single]     ; Set bed target temperature (non-blocking).
M190 S[bed_temperature_initial_layer_single]     ; Wait for bed to reach target temperature.
M109 S200                                        ; Wait for nozzle to reach 200°C.
PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer_single]
