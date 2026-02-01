#!/usr/bin/env python3
"""
شبیه‌ساز میکروکنترلر برای تست ارتباط USB Serial با اپ سودان.

نحوه استفاده (وقتی تبلت با مبدل USB-Serial به لپ‌تاپ وصل است):
  1. پورت سریال لپ‌تاپ را مشخص کنید (مثلاً COM3 در ویندوز یا /dev/ttyUSB0 در لینوکس).
  2. این اسکریپت را اجرا کنید: python usb_serial_simulator.py COM3
  3. در اپ روی تبلت به USB متصل شوید و داشبورد را باز کنید؛ لیست اتاق‌ها از این اسکریپت می‌آید.

نیاز: pip install pyserial
"""

import json
import sys
import time

try:
    import serial
except ImportError:
    print("نصب pyserial: pip install pyserial")
    sys.exit(1)

# Protocol constants (same as UsbSerialConstants in Dart)
STX = 0x02
ETX = 0x03
ACK = 0x06
MSG_TYPE_COMMAND = 0x01
MSG_TYPE_REQUEST = 0x02
MSG_TYPE_RESPONSE = 0x03
REQUEST_FLOORS = "@M_F_A"
REQUEST_ROOMS = "@M_R"
ACTION_CREATE_FLOOR = "create_floor"

# Sample floors response (first screen – list of floors)
FLOORS_JSON = json.dumps([
    {"id": "floor_1", "name": "طبقه اول", "order": 0, "roomIds": ["room_living", "room_kitchen", "room_bathroom"], "icon": "layers"},
    {"id": "floor_2", "name": "طبقه دوم", "order": 1, "roomIds": ["room_bedroom"], "icon": "layers"},
])

# Sample rooms response (JSON array)
ROOMS_JSON = json.dumps([
    {"id": "room_general", "name": "عمومی", "order": -1, "floorId": None, "icon": "home", "deviceIds": [], "isGeneral": True},
    {"id": "room_living", "name": "اتاق نشیمن", "order": 0, "floorId": "floor_1", "icon": "living", "deviceIds": [], "isGeneral": False},
    {"id": "room_kitchen", "name": "آشپزخانه", "order": 1, "floorId": "floor_1", "icon": "kitchen", "deviceIds": [], "isGeneral": False},
    {"id": "room_bedroom", "name": "اتاق خواب", "order": 0, "floorId": "floor_2", "icon": "bedroom", "deviceIds": [], "isGeneral": False},
])


def encode_frame(msg_type: int, data: str) -> bytes:
    """Build frame: [STX][Type][Length][Data...][Checksum][ETX]"""
    data_bytes = data.encode("utf-8")
    length = len(data_bytes)
    checksum = (msg_type + length + sum(data_bytes)) & 0xFF
    return bytes([STX, msg_type, length]) + data_bytes + bytes([checksum, ETX])


def send_ack(ser):
    ser.write(bytes([STX, ACK, ETX]))


def find_frame(buf: bytearray):
    """Find first complete frame; returns (msg_type, data_str) or None, and new buffer."""
    start = -1
    for i in range(len(buf)):
        if buf[i] == STX:
            start = i
            break
    if start == -1:
        return None, bytearray()

    # ACK/NACK: 3 bytes [STX, control, ETX]
    if start + 2 < len(buf) and buf[start + 2] == ETX:
        control = buf[start + 1]
        if control == ACK or control == 0x15:  # NACK
            return None, buf[start + 3 :]  # skip this frame

    # Normal frame: [STX, Type, Length, Data..., Checksum, ETX]
    if start + 3 > len(buf):
        return None, buf[start:]
    msg_type = buf[start + 1]
    length = buf[start + 2]
    need = start + 3 + length + 1 + 1  # +checksum +ETX
    if len(buf) < need:
        return None, buf[start:]
    data_bytes = buf[start + 3 : start + 3 + length]
    checksum = buf[start + 3 + length]
    end_etx = buf[start + 3 + length + 1]
    if end_etx != ETX:
        return None, buf[start + 1 :]  # skip bad STX
    calc_checksum = (msg_type + length + sum(data_bytes)) & 0xFF
    if checksum != calc_checksum:
        return None, buf[start + 1 :]
    try:
        data_str = data_bytes.decode("utf-8")
    except Exception:
        return None, buf[start + 1 :]
    return (msg_type, data_str), buf[need:]


def main():
    port = "COM3"
    if len(sys.argv) > 1:
        port = sys.argv[1]
    baud = 9600

    print(f"Opening {port} @ {baud} ...")
    try:
        ser = serial.Serial(port, baud, timeout=0.1)
    except Exception as e:
        print(f"Error opening port: {e}")
        print("Example: python usb_serial_simulator.py COM3")
        sys.exit(1)

    print("Simulator running. @M_F_A = floors (first screen), @M_R = rooms. Ctrl+C to exit.")
    buf = bytearray()
    try:
        while True:
            chunk = ser.read(256)
            if chunk:
                buf.extend(chunk)
            while True:
                result, buf = find_frame(buf)
                if result is None:
                    break
                msg_type, data = result
                if msg_type == MSG_TYPE_REQUEST and data == REQUEST_FLOORS:
                    send_ack(ser)
                    response = encode_frame(MSG_TYPE_RESPONSE, FLOORS_JSON)
                    ser.write(response)
                    print("Sent floors response")
                elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_ROOMS:
                    send_ack(ser)
                    response = encode_frame(MSG_TYPE_RESPONSE, ROOMS_JSON)
                    ser.write(response)
                    print("Sent rooms response")
                elif msg_type == MSG_TYPE_COMMAND:
                    send_ack(ser)
                    try:
                        obj = json.loads(data)
                        if obj.get("action") == ACTION_CREATE_FLOOR:
                            print(f"Create floor received: id={obj.get('id')} name={obj.get('name')} order={obj.get('order')}")
                        else:
                            print(f"Command: {data[:80]}...")
                    except Exception:
                        print(f"Command: {data[:80]}...")
                elif msg_type == MSG_TYPE_REQUEST:
                    send_ack(ser)
                    print(f"Request: {data[:50]}...")
            time.sleep(0.02)
    except KeyboardInterrupt:
        print("\nExiting.")
    finally:
        ser.close()


if __name__ == "__main__":
    main()
