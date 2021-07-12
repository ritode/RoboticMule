!!! README outdated, please refer the folders directly

Upload "Master" to Master controller for motion. It is the Slave in UART and Master in CAN.
Upload "Slave" to Slave controller for individual motor. It is the slave in CAN.
Run the python program 

Send floating point numbers and see the motor turn by that angle.

Things to note:
- All angles in degrees
- Slave starts at 0 degrees
- All angles sent are absolute angles (not relative, but w.r.t. 0 degrees)
