#!/usr/bin/env python
"""
Log multi axis movement (multi joint values)
"""
import serial
import struct
import sys
from subprocess import Popen, PIPE, STDOUT
import threading
import os
from timeit import default_timer as timer
from time import sleep

SERIAL_PORT_DEFAULT = '/dev/ttyS2'
BAUD_RATE_DEFAULT = 56800
PIPE_DIR = "/tmp/quad/pipes/"
DEFAULT_DATA_FOLDER = "data"
AXIS_TRAJECTORY_FILE_GAIT = "Trajectory/walking/gait_data_Mon_24_Feb_20_ 4_14_14_PM.txt"
AXIS_TRAJECTORY_FILE_ADJ = "Trajectory/walking/adj_data_Mon_24_Feb_20_ 4_14_14_PM.txt"
NUM_GAIT_TRAJS = 20

# Indices of arguments passed to the script from terminal
MAX_TIME_INDEX = 1      # Maximum time for logging
RX_FILE_NAME_INDEX = 2  # File to store the received values in
TX_FILE_NAME_INDEX = 3  # File to store the transmitted values in
SERIAL_PORT_INDEX = 4   # Serial port name (default SERIAL_PORT_DEFAULT)
SERIAL_BARD_RATE_INDEX = 5  # Serial baud rate (default BAUD_RATE_DEFAULT)
# Parameter configurations
argv = list(sys.argv)   # Convert arguments passed to list
full_filename = str(sys.argv[0])
pwd = "/".join(full_filename.split('/')[:-1]) + "/" # Present working directory

def flush_serial(con):
    """
        Flush the serial connection (the incoming feed is read and cleared)
    """
    junk = con.read(con.in_waiting)

class serialReader(threading.Thread):
    """
        The purpose of this class is to read the serial and print to a terminal console (separate from the main).
        It also logs data to a text file (with time stamp). Uses serial_protocol_v1

        Initialize the serial reader.

            Arguments:
                serial_con: Serial object (note that it must be initialized, opened and closed externally by the user)
                file_name: The file name to be used to log data
                pipe_file_name: The name of the pipe file to use for handling written text to the terminal 
                                (in conjunction with PIPE_DIR, so the pipe file is at PIPE_DIR + pipe_file_name)
                start_time: Time instance at the start of data logging (all time is relative to this)
                log_timeout: The timeout duration to be used (for data logging). If -1, then data logging is indefinite
    """
    def __init__(self, serial_con, file_name, pipe_file_name, start_time, log_timeout):
        """
            Initialize the serial reader.

            Arguments:
                serial_con: Serial object (note that it must be initialized, opened and closed externally by the user)
                file_name: The file name to be used to log data
                pipe_file_name: The name of the pipe file to use for handling written text to the terminal 
                                (in conjunction with PIPE_DIR, so the pipe file is at PIPE_DIR + pipe_file_name)
                start_time: Time instance at the start of data logging (all time is relative to this)
                log_timeout: The timeout duration to be used (for data logging). If -1, then data logging is indefinite
        """
        # Call the threading constructor
        threading.Thread.__init__(self)
        self.name = "Thread_serialReader"   # Thread name
        self.serial_con = serial_con
        self.start_time = start_time
        self.log_timeout = log_timeout
        self.enable_logging = True
        if self.log_timeout == 0:
            self.enable_logging = False
        self.log_fname = file_name
        self.term_fname = PIPE_DIR + pipe_file_name
        self.thread_can_run = True
        self.pre_check()
        # Terminal designed to echo pipe
        self.term_process = Popen(['gnome-terminal', '-e', 'tail -f "%s"' % self.term_fname],
                                stdout=PIPE,
                                stderr=STDOUT)
        # File handler
        self.log_fhdlr = open(self.log_fname, 'w')
        print("Initialized serial receiver")

    def __del__(self):
        """
            Destructor. Calls the terminate_thread()
        """
        self.terminate_thread()
    
    def pre_check(self):
        """
            Performs a precheck of parameters, to ensure that files are existing. 
            If they're not existing, then this function creates them.
        """
        # Check for PIPE_DIR to be an existing directory, make it if it doesn't exist
        print("Checking %s" % self.term_fname)
        if not os.path.exists(PIPE_DIR):
            os.makedirs(PIPE_DIR)
            print("Created %s" % PIPE_DIR)
        if not os.path.exists(self.term_fname):
            os.mkfifo(self.term_fname)
            print("Created %s" % self.term_fname)
        # Make the data logging file if it doesn't exist
        print("Checking %s" % self.log_fname)
        if not os.path.exists(self.log_fname):
            os.system("touch %s" % self.log_fname)
            print("Created %s" % self.log_fname)

    def terminal_writeln(self, txt):
        """
            Writes a line on the piped terminal.

            Arguments:
                txt: The text to be printed on the terminal
        """
        # Write line to pipe
        self.fhdlr = open(self.term_fname, 'w')
        self.fhdlr.write(txt + '\n')
        self.fhdlr.close()

    def terminate_thread(self):
        """
            Terminate the object. Closes the log files, kills the thread and processes, and deletes the pipe (for memory efficiency)
        """
        # Terminate the thread
        self.thread_can_run = False
        self.log_fhdlr.close()  # Close log file
        self.terminal_writeln("Closing the process under this terminal")
        self.term_process.kill()
        self.terminal_writeln("Deleting the pipe %s ... This terminal can now be closed" % self.term_fname)
        os.remove(self.term_fname)

    def run(self):
        """
            The thread for this function is executed here. It runs main_code() and returns on any exception
        """
        try:
            self.main_code()
        except Exception as err:
            self.terminal_writeln("Error: %s" % (err))
            self.terminal_writeln("Thread %s is ending" % self.name)

    def main_code(self):
        """
            Main function of the serialReader class. This is run on a separate thread and outputs values on a different terminal.
            Expects the serial to respond using the serial_protocol_v1
        """
        # Main task of reading from serial, writing to file and printing to console (in a loop)
        while(self.thread_can_run):
            while (not self.serial_con.in_waiting):
                # Wait till something is received on serial
                pass
            recv_len = self.serial_con.in_waiting   # Didn't use this
            data_raw = self.serial_con.read(1)  # Read 1 byte
            while (self.serial_con.in_waiting < 4):
                # Wait for 4 bytes of data to be received
                pass
            fdata_ba = self.serial_con.read(4)
            curr_time = timer()
            flush_serial(self.serial_con)   # Transmission done
            fdata_ba = bytearray(fdata_ba)
            fdata = struct.unpack("<f", fdata_ba)
            fdata = fdata[0]
            self.terminal_writeln("Received %s" % (fdata))
            if type(fdata) == float:
                time_diff = curr_time - self.start_time
                if self.enable_logging:
                    if time_diff > self.log_timeout and self.log_timeout != -1:
                        self.enable_logging = False
                        self.terminal_writeln("Logging to file has stopped due to timeout")
                    else:
                        self.log_fhdlr.write("%s, %d, %s\r\n" % (time_diff, 1, fdata))

class serialWriter:
    """
        The purpose of this class is to handle the transmission part of a serial connection.
        Uses serial_protocol_v1

        Initialize the serial transmitter.
            Arguments:
                serial_con: Serial object (note that it must be initialized, opened and closed externally by the user)
                file_name: Log file to store the transmitted data
                start_time: The start time to use as reference
                log_timeout: Timeout for logging data (indefinite if -1)
    """
    def __init__(self, serial_con, file_name, start_time, log_timeout):
        """
            Initialize the serial transmitter.
            Arguments:
                serial_con: Serial object (note that it must be initialized, opened and closed externally by the user)
                file_name: Log file to store the transmitted data
                start_time: The start time to use as reference
                log_timeout: Timeout for logging data (indefinite if -1)
        """
        self.serial_con = serial_con
        self.log_fname = file_name
        self.start_time = start_time
        self.log_timeout = log_timeout
        self.enable_logging = True
        if self.log_timeout == 0:
            self.enable_logging = False
        self.pre_check()
        self.log_fhdlr = open(self.log_fname, 'w')
        print("Initialized serial transmitter")
    
    def __del__(self):
        """
            Destructor for object
        """
        # Close file handler
        self.log_fhdlr.close()

    def pre_check(self):
        """
            Ensures that the files concerned to the object exist. they're created if they do not exist
        """
        if not os.path.exists(self.log_fname):
            os.system("touch %s" % self.log_fname)
            print("Created %s" % self.log_fname)

    def writeAngle(self, num_angles, j_angles):
        """
            Main function that writes an angle to the serial and logs it in the file.
            This function follows the serial protocol serial_protocol_v1 for transmitting angles

            Arguments:
                angle: The angle value to send 
        """
        print("Sending", j_angles)
        # Send angles through serial
        curr_time = timer()
        self.serial_con.write(struct.pack("<i", num_angles))    # Number of angles
        for ang in j_angles:    # Send each angle
            self.serial_con.write(struct.pack("<f", ang))
        time_diff = curr_time - self.start_time
        # TODO: Fix this, logging is different for joint angles being transmitted
        if self.enable_logging:
            if time_diff > self.log_timeout and self.log_timeout != -1:
                self.enable_logging = False
                print("Logging to file has stopped due to time out")
            else:
                # self.log_fhdlr.write("%s, %d, %s\r\n" % (time_diff, num_angles, ang))
                self.log_fhdlr.write("[%s] ERROR: Joint angles not made public, bug present...\r\n" % (time_diff))    # FIXME: Fix this issue

def get_system_params():
    """
        Gets system parameters (uses defaults if not existing) and returns them as dictionary

        Returns:
            ret_dict: A dictionary with the following keys (type)
            `------ max_time (str): Maximum logging time (float)
            |------ max_time_str (str): String interpretation of maximum time, <indefinite> if -1 (str)
            |------ rx_file_name (str): RX Log file name (str)
            |------ tx_file_name (str): TX Log file name (str)
            |------ serial_port (str): Serial port name (str)
            |------ serial_baud (str): Serial baud rate (int)
            '------ time_stamp (str): Current time stamp as output of `date +"%d_%^b_%Y_%H_%M_%S_%N"`
    """
    # Max logging time
    max_time = 0
    max_time_str = ""
    try:
        max_time = float(argv[MAX_TIME_INDEX])
    except IndexError:
        max_time = -1
    if max_time != -1:
        max_time_str = "%.3f" % (max_time)
    else:
        max_time_str = "<indefinite>"
    # Timestamp for files
    out = Popen(['date', '+"%d_%^b_%Y_%H_%M_%S_%N"'],
                stdout=PIPE,
                stderr=STDOUT)
    [output, error] = out.communicate()
    output = output[1:-2]
    # RX File name
    rx_file_name = ""
    try:
        rx_file_name = str(argv[RX_FILE_NAME_INDEX])
    except IndexError:
        rx_file_name = "%s/RX_%s.txt" % (DEFAULT_DATA_FOLDER, output)
        rx_file_name = pwd + rx_file_name
    # TX File name
    tx_file_name = ""
    try:
        tx_file_name = str(argv[TX_FILE_NAME_INDEX])
    except IndexError:
        tx_file_name = "%s/TX_%s.txt" % (DEFAULT_DATA_FOLDER, output)
        tx_file_name = pwd + tx_file_name
    try:
        os.mkdir(DEFAULT_DATA_FOLDER)
    except OSError:
        pass
    # Serial port
    serial_port = ""
    try:
        serial_port = str(argv[SERIAL_PORT_INDEX])
    except IndexError:
        serial_port = SERIAL_PORT_DEFAULT
    # Serial baud rate
    serial_baud = 0
    try:
        serial_baud = int(argv[SERIAL_BARD_RATE_INDEX])
    except IndexError:
        serial_baud = BAUD_RATE_DEFAULT
    # Return with configurations
    ret_dict = {}
    ret_dict["max_time"] = max_time
    ret_dict["max_time_str"] = max_time_str
    ret_dict["rx_file_name"] = rx_file_name
    ret_dict["tx_file_name"] = tx_file_name
    ret_dict["serial_port"] = serial_port
    ret_dict["serial_baud"] = serial_baud
    ret_dict["time_stamp"] = output
    return ret_dict

def execute_trajectory(jdata_file_name, serial_tx):
    # File handler for serial communication
    traj_fhdlr = open(jdata_file_name, 'r')
    # Start timestamp
    start_time = timer()
    print("Program start time: %s" % (start_time))
    while(1):
        # Read value from the file
        line_raw = traj_fhdlr.readline()
        line = line_raw[:-1]
        if line == "":
            print("Reached EOF for Axis trajectory file")
            break
        # Get values from line
        line_nums = line.split(", ")
        time_val = float(line_nums[0])
        num_joints = int(line_nums[1])
        joint_target = [float(val) for val in line_nums[2:]]
        # Wait for that time value to arrive
        while time_val > timer() - start_time:
            pass
        print("Read", line_nums)
        # Send to serial
        serial_tx.writeAngle(num_joints, joint_target)
    # Close Axis trajectory file
    traj_fhdlr.close()

if __name__ == "__main__":
    print("Program started, configurations are as follows")
    # Get program configurations
    configs = get_system_params()
    max_time = configs["max_time"]
    max_time_str = configs["max_time_str"]
    rx_file_name = configs["rx_file_name"]
    tx_file_name = configs["tx_file_name"]
    serial_port = configs["serial_port"]
    serial_baud = configs["serial_baud"]
    jdata_file_name = AXIS_TRAJECTORY_FILE_GAIT
    pipe_fname = "serial_rxterm"
    # User prompt
    print("Maximum recording time is %s seconds (%f)" % (max_time_str, max_time))
    print("Joint data is being read from file %s" % (jdata_file_name))
    print("Saving received angle data to file %s" % rx_file_name)
    print("Saving transmitted angle data to file %s" % tx_file_name)
    print("Using serial %s for communication, with baud %d" % (serial_port, serial_baud))
    print("Pipe at %s%s" % (PIPE_DIR, pipe_fname))
    # Wait till user starts system and presses enter
    raw_input("Please start the system and press enter to proceed...")
    # Start serial connection
    serial_con = serial.Serial(serial_port, baudrate=serial_baud)
    # Initialize TX for serial
    serial_tx = serialWriter(serial_con, tx_file_name, timer(), max_time)
    # Main program to transmit values through serial
    print("Program started")
    try:
        execute_trajectory(AXIS_TRAJECTORY_FILE_ADJ, serial_tx)
        sleep(0.1)
        raw_input("Press enter to start executing gait motion")
        for i in range(NUM_GAIT_TRAJS):
            execute_trajectory(jdata_file_name, serial_tx)
            sleep(0.1)

    except KeyboardInterrupt:
        print("Termination (Ctrl+C) received, ending program")
    # Close serial connection
    serial_con.close()
    # Inform user about files
    print("Please check the files: \nRX Data: %s\nTX Data: %s" % (rx_file_name, tx_file_name))
    print("Main thread has ended")
