#!/usr/bin/env python3
"""
شبیه‌ساز میکروکنترلر برای تست ارتباط USB Serial با اپ سودان.

فرمت متن (بدون JSON): جداکننده فیلد | ، هر رکورد یک خط.
- طبقات: هر خط = id|name|order|roomIds (roomIds با کاما)
- اتاق‌ها: هر خط = id|name|order|floorId|icon|deviceIds|isGeneral

نحوه استفاده (وقتی تبلت با مبدل USB-Serial به لپ‌تاپ وصل است):
  1. پورت سریال را مشخص کنید (مثلاً COM3 در ویندوز یا /dev/ttyUSB0 در لینوکس).
  2. اجرا: python usb_serial_simulator.py COM3
  3. در اپ به USB متصل شوید؛ لیست طبقات/اتاق‌ها از این اسکریپت می‌آید.

نیاز: pip install pyserial
"""

import sys
import time

try:
    import serial
except ImportError:
    print("نصب pyserial: pip install pyserial")
    sys.exit(1)

# Protocol (هماهنگ با UsbSerialConstants)
STX = 0x02
ETX = 0x03
ACK = 0x06
MSG_TYPE_COMMAND = 0x01
MSG_TYPE_REQUEST = 0x02
MSG_TYPE_RESPONSE = 0x03
REQUEST_FLOORS = "@M_F_A"
REQUEST_ROOMS = "@M_R"
COMMAND_CREATE_FLOOR = "&M_F_N"
FIELD_SEP = "|"
RECORD_SEP = "\n"
LIST_SEP = ","

# پاسخ طبقات: هر خط id|name|order|roomIds
FLOORS_TEXT = "floor_1|طبقه اول|0|room_living,room_kitchen,room_bathroom" + RECORD_SEP + "floor_2|طبقه دوم|1|room_bedroom"

# پاسخ اتاق‌ها: هر خط id|name|order|floorId|icon|deviceIds|isGeneral
ROOMS_TEXT = (
    "room_general|عمومی|-1||home||1" + RECORD_SEP
    + "room_living|اتاق نشیمن|0|floor_1|living||0" + RECORD_SEP
    + "room_kitchen|آشپزخانه|1|floor_1|kitchen||0" + RECORD_SEP
    + "room_bedroom|اتاق خواب|0|floor_2|bedroom||0"
)


def encode_frame(msg_type: int, data: str) -> bytes:
    """فریم: [STX][Type][Length][Data...][Checksum][ETX]"""
    data_bytes = data.encode("utf-8")
    length = len(data_bytes)
    checksum = (msg_type + length + sum(data_bytes)) & 0xFF
    return bytes([STX, msg_type, length]) + data_bytes + bytes([checksum, ETX])


def send_ack(ser):
    ser.write(bytes([STX, ACK, ETX]))


def find_frame(buf: bytearray):
    """پیدا کردن اولین فریم کامل؛ برگشت (msg_type, data_str) یا None و بافر جدید."""
    start = -1
    for i in range(len(buf)):
        if buf[i] == STX:
            start = i
            break
    if start == -1:
        return None, bytearray()

    if start + 2 < len(buf) and buf[start + 2] == ETX:
        control = buf[start + 1]
        if control == ACK or control == 0x15:
            return None, buf[start + 3 :]

    if start + 3 > len(buf):
        return None, buf[start:]
    msg_type = buf[start + 1]
    length = buf[start + 2]
    need = start + 3 + length + 1 + 1
    if len(buf) < need:
        return None, buf[start:]
    data_bytes = buf[start + 3 : start + 3 + length]
    checksum = buf[start + 3 + length]
    end_etx = buf[start + 3 + length + 1]
    if end_etx != ETX:
        return None, buf[start + 1 :]
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

    print("Simulator running. @M_F_A=floors, @M_R=rooms, &M_F_N=create floor. Ctrl+C to exit.")
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
                    ser.write(encode_frame(MSG_TYPE_RESPONSE, FLOORS_TEXT))
                    print("Sent floors response (text)")
                elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_ROOMS:
                    send_ack(ser)
                    ser.write(encode_frame(MSG_TYPE_RESPONSE, ROOMS_TEXT))
                    print("Sent rooms response (text)")
                elif msg_type == MSG_TYPE_COMMAND:
                    send_ack(ser)
                    # Format: &M_F_N\nid|name|order|roomIds
                    if RECORD_SEP in data and data.startswith(COMMAND_CREATE_FLOOR):
                        lines = data.split(RECORD_SEP, 1)
                        if len(lines) >= 2:
                            parts = lines[1].strip().split(FIELD_SEP)
                            if len(parts) >= 4:
                                print(f"Create floor: id={parts[0]} name={parts[1]} order={parts[2]} roomIds={parts[3]}")
                            else:
                                print(f"Command: {data[:80]}...")
                        else:
                            print(f"Command: {data[:80]}...")
                    elif FIELD_SEP in data and data.strip().startswith("floor_"):
                        parts = data.strip().split(FIELD_SEP)
                        if len(parts) >= 3:
                            print(f"Create floor (legacy): id={parts[0]} name={parts[1]} order={parts[2]}")
                        else:
                            print(f"Command: {data[:80]}...")
                    else:
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
