import json
import socket
import serial
import time
import threading
import os

def check_wifi_connection(interface="wlan0"):
    """
    Check if the specified interface has an IP address assigned to it.
    
    :param interface: Network interface to check, defaults to 'wlan0'
    :return: True if the interface has an IP, False otherwise
    """
    try:
        # Use 'ip addr show' to check if the interface has an IP address
        file = open("/sys/class/net/wlan0/operstate","r")
        output = file.readline()
        print(output)
        file.close()
        if output == "up\n":
             print(True)
             return True
        else:
             print(False)
             return False
    except Exception as e:
        print(f"Error checking WiFi connection: {e}")
        return False

ser = serial.Serial ("/dev/serial0", 115200)

# Get current host ip address

HOST = os.popen('hostname -I').read().split()[0]
PORT = 12345

# Create a socket for listening
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))
sock.settimeout(0.10)
data = bytes("<0,0,0>", "utf-8")


try:  
    print("Ready!")
    while True:
            """
            if not check_wifi_connection():
                # If there's no WiFi connection, send "<0,0,0,0>" to the serial
                print("WiFi connection lost. Sending <0,00> to serial.")
                ser.write(b"<0,0,0>")
                time.sleep(0.1)  # Add a delay to prevent flooding the serial port
                continue  # Skip the rest of the loop
            """
            try:
                data, addr = sock.recvfrom(300)
            except socket.timeout:
                 continue
            value = data.decode()
            print(f"Received value: {value}")

            #value is JSON string, parse it
            value = json.loads(value)
            #value is now dictionary
            print(value["updateVehicleDecision"]["message"])

            ser.write(value["updateVehicleDecision"]["message"].encode()) #Send data via serial
except KeyboardInterrupt:
    # Cleanup when the program is terminated
    sock.close()
    ser.close()
    print("Done")





