#!/usr/bin/env python3
"""
شبیه‌ساز میکروکنترلر برای تست ارتباط USB Serial با اپ سودان.

سه حالت اجرا:
  1) شبیه‌ساز (پیش‌فرض): روی یک پورت گوش می‌دهد و به درخواست‌های اپ/کلاینت پاسخ می‌دهد.
     python usb_serial_simulator.py COM5

  2) کلاینت تست: روی پورت دیگر (جفت مجازی) درخواست می‌فرستد و پاسخ شبیه‌ساز را چک می‌کند.
     python usb_serial_simulator.py --test COM6

  3) لیست پورت‌ها: نمایش پورت‌های سریال موجود.
     python usb_serial_simulator.py --list

فرمت متن (بدون JSON): جداکننده فیلد | ، هر رکورد یک خط.
- طبقات: هر خط = id|name|order|roomIds (roomIds با کاما)
- اتاق‌ها: هر خط = id|name|order|floorId|icon|deviceIds|isGeneral

نیاز: pip install pyserial
"""

import sys
import time

try:
    import serial
    from serial.tools import list_ports
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
REQUEST_FLOORS_COUNT = "@M_F_C"
REQUEST_ROOMS = "@M_R"
COMMAND_CREATE_FLOOR = "&M_F_N"
COMMAND_UPDATE_FLOOR = "&M_F_U"
COMMAND_DELETE_FLOOR = "&M_F_D"
COMMAND_CREATE_ROOM = "&M_R_N"
COMMAND_UPDATE_ROOM = "&M_R_U"
COMMAND_DELETE_ROOM = "&M_R_D"
FIELD_SEP = "|"
RECORD_SEP = "\n"
LIST_SEP = ","


def _floor_to_line(f):
    """id|name|order|roomIds"""
    rid = f.get("id", "")
    name = f.get("name", "")
    order = f.get("order", 0)
    room_ids = f.get("roomIds", [])
    if isinstance(room_ids, str):
        room_ids = [x.strip() for x in room_ids.split(LIST_SEP) if x.strip()]
    return f"{rid}{FIELD_SEP}{name}{FIELD_SEP}{order}{FIELD_SEP}{LIST_SEP.join(room_ids)}"


def _room_to_line(r):
    """id|name|order|floorId|icon|deviceIds|isGeneral"""
    rid = r.get("id", "")
    name = r.get("name", "")
    order = r.get("order", 0)
    floor_id = r.get("floorId", "")
    icon = r.get("icon", "home")
    device_ids = r.get("deviceIds", [])
    if isinstance(device_ids, str):
        device_ids = [x.strip() for x in device_ids.split(LIST_SEP) if x.strip()]
    is_gen = r.get("isGeneral", False)
    return f"{rid}{FIELD_SEP}{name}{FIELD_SEP}{order}{FIELD_SEP}{floor_id}{FIELD_SEP}{icon}{FIELD_SEP}{LIST_SEP.join(device_ids)}{FIELD_SEP}{1 if is_gen else 0}"


# حالت اولیه (قابل تغییر با دستورات create/update/delete)
FLOORS_LIST = [
    {"id": "floor_1", "name": "طبقه اول", "order": 0, "roomIds": ["room_living", "room_kitchen", "room_bathroom"]},
    {"id": "floor_2", "name": "طبقه دوم", "order": 1, "roomIds": ["room_bedroom"]},
]

ROOMS_LIST = [
    {"id": "room_general", "name": "عمومی", "order": -1, "floorId": "", "icon": "home", "deviceIds": [], "isGeneral": True},
    {"id": "room_living", "name": "اتاق نشیمن", "order": 0, "floorId": "floor_1", "icon": "living", "deviceIds": [], "isGeneral": False},
    {"id": "room_kitchen", "name": "آشپزخانه", "order": 1, "floorId": "floor_1", "icon": "kitchen", "deviceIds": [], "isGeneral": False},
    {"id": "room_bedroom", "name": "اتاق خواب", "order": 0, "floorId": "floor_2", "icon": "bedroom", "deviceIds": [], "isGeneral": False},
]


def get_floors_text():
    return RECORD_SEP.join(_floor_to_line(f) for f in FLOORS_LIST)


def get_rooms_text():
    return RECORD_SEP.join(_room_to_line(r) for r in ROOMS_LIST)


def encode_frame(msg_type: int, data: str) -> bytes:
    """فریم: [STX][Type][Length][Data...][Checksum][ETX]"""
    data_bytes = data.encode("utf-8")
    length = len(data_bytes)
    checksum = (msg_type + length + sum(data_bytes)) & 0xFF
    return bytes([STX, msg_type, length]) + data_bytes + bytes([checksum, ETX])


def send_ack(ser):
    ser.write(bytes([STX, ACK, ETX]))


def find_frame(buf: bytearray):
    """
    پیدا کردن اولین فریم کامل.
    برگشت: (msg_type, data_str) یا ("ack", "") برای ACK/NAK؛ یا None و بافر جدید.
    """
    start = -1
    for i in range(len(buf)):
        if buf[i] == STX:
            start = i
            break
    if start == -1:
        return None, bytearray()

    # ACK/NAK: [STX, control, ETX]
    if start + 3 <= len(buf) and buf[start + 2] == ETX:
        control = buf[start + 1]
        if control == ACK or control == 0x15:
            return ("ack", ""), buf[start + 3 :]

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


# --- حالت ۱: شبیه‌ساز (سرور) ---


def _parse_floor_line(line: str):
    parts = line.strip().split(FIELD_SEP)
    if len(parts) < 4:
        return None
    room_ids = [x.strip() for x in parts[3].split(LIST_SEP) if x.strip()]
    return {"id": parts[0], "name": parts[1], "order": int(parts[2]) if parts[2].isdigit() else 0, "roomIds": room_ids}


def _parse_room_line(line: str):
    parts = line.strip().split(FIELD_SEP)
    if len(parts) < 7:
        return None
    device_ids = [x.strip() for x in parts[5].split(LIST_SEP) if x.strip()]
    return {
        "id": parts[0],
        "name": parts[1],
        "order": int(parts[2]) if parts[2].lstrip("-").isdigit() else 0,
        "floorId": parts[3] or "",
        "icon": parts[4] or "home",
        "deviceIds": device_ids,
        "isGeneral": parts[6].strip() in ("1", "true", "True"),
    }


def _handle_command(ser, data: str):
    if RECORD_SEP not in data:
        print(f"Command (no newline): {data[:60]}...")
        return
    first_line, rest = data.split(RECORD_SEP, 1)
    payload = rest.strip()

    if first_line.strip() == COMMAND_CREATE_FLOOR and payload:
        f = _parse_floor_line(payload)
        if f:
            FLOORS_LIST.append(f)
            FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
            print(f"Create floor: id={f['id']} name={f['name']} order={f['order']} roomIds={f['roomIds']}")
        else:
            print(f"Command: {data[:80]}...")
    elif first_line.strip() == COMMAND_UPDATE_FLOOR and payload:
        f = _parse_floor_line(payload)
        if f:
            for i, existing in enumerate(FLOORS_LIST):
                if existing.get("id") == f["id"]:
                    FLOORS_LIST[i] = f
                    FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
                    print(f"Update floor: id={f['id']} name={f['name']}")
                    return
            FLOORS_LIST.append(f)
            FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
            print(f"Update floor (new): id={f['id']}")
        else:
            print(f"Command: {data[:80]}...")
    elif first_line.strip() == COMMAND_DELETE_FLOOR and payload:
        floor_id = payload.strip().split()[0] if payload.strip() else ""
        before = len(FLOORS_LIST)
        FLOORS_LIST[:] = [x for x in FLOORS_LIST if x.get("id") != floor_id]
        if len(FLOORS_LIST) < before:
            print(f"Delete floor: {floor_id}")
        else:
            print(f"Delete floor (not found): {floor_id}")
    elif first_line.strip() == COMMAND_CREATE_ROOM and payload:
        r = _parse_room_line(payload)
        if r:
            ROOMS_LIST.append(r)
            ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
            print(f"Create room: id={r['id']} name={r['name']} floorId={r['floorId']}")
        else:
            print(f"Command: {data[:80]}...")
    elif first_line.strip() == COMMAND_UPDATE_ROOM and payload:
        r = _parse_room_line(payload)
        if r:
            for i, existing in enumerate(ROOMS_LIST):
                if existing.get("id") == r["id"]:
                    ROOMS_LIST[i] = r
                    ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
                    print(f"Update room: id={r['id']} name={r['name']}")
                    return
            ROOMS_LIST.append(r)
            ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
            print(f"Update room (new): id={r['id']}")
        else:
            print(f"Command: {data[:80]}...")
    elif first_line.strip() == COMMAND_DELETE_ROOM and payload:
        room_id = payload.strip().split()[0] if payload.strip() else ""
        before = len(ROOMS_LIST)
        ROOMS_LIST[:] = [x for x in ROOMS_LIST if x.get("id") != room_id]
        if len(ROOMS_LIST) < before:
            print(f"Delete room: {room_id}")
        else:
            print(f"Delete room (not found): {room_id}")
    elif first_line.strip().startswith(COMMAND_CREATE_FLOOR) or (FIELD_SEP in data and data.strip().startswith("floor_")):
        # Legacy create floor
        line = payload if payload else data.strip()
        if FIELD_SEP in line:
            parts = line.split(FIELD_SEP)
            if len(parts) >= 4:
                print(f"Create floor (legacy): id={parts[0]} name={parts[1]} order={parts[2]} roomIds={parts[3]}")
            else:
                print(f"Command: {data[:80]}...")
        else:
            print(f"Command: {data[:80]}...")
    else:
        print(f"Command: {data[:80]}...")


def run_simulator(port: str, baud: int = 9600):
    print(f"Opening {port} @ {baud} ...")
    try:
        ser = serial.Serial(port, baud, timeout=0.1)
    except Exception as e:
        print(f"Error opening port: {e}")
        print("Example: python usb_serial_simulator.py COM5")
        sys.exit(1)

    print(
        "Simulator running. @M_F_A=floors, @M_R=rooms | &M_F_N/U/D=floor create/update/delete | &M_R_N/U/D=room create/update/delete. Ctrl+C to exit."
    )
    print("--- Data exchange log (RX = received, TX = sent) ---\n")
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
                if msg_type == "ack":
                    continue
                # Log received (RX)
                type_name = {MSG_TYPE_REQUEST: "REQUEST", MSG_TYPE_COMMAND: "COMMAND", MSG_TYPE_RESPONSE: "RESPONSE"}.get(msg_type, str(msg_type))
                print(f"[RX] {type_name}: {data[:80]}{'...' if len(data) > 80 else ''}")
                if msg_type == MSG_TYPE_REQUEST and data == REQUEST_FLOORS:
                    send_ack(ser)
                    body = get_floors_text()
                    ser.write(encode_frame(MSG_TYPE_RESPONSE, body))
                    lines = body.strip().split(RECORD_SEP) if body.strip() else []
                    print(f"[TX] RESPONSE (floors, {len(lines)} lines): {body[:60]}...")
                elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_FLOORS_COUNT:
                    send_ack(ser)
                    body = str(len(FLOORS_LIST))
                    ser.write(encode_frame(MSG_TYPE_RESPONSE, body))
                    print(f"[TX] RESPONSE (floors count): {body}")
                elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_ROOMS:
                    send_ack(ser)
                    body = get_rooms_text()
                    ser.write(encode_frame(MSG_TYPE_RESPONSE, body))
                    lines = body.strip().split(RECORD_SEP) if body.strip() else []
                    print(f"[TX] RESPONSE (rooms, {len(lines)} lines): {body[:60]}...")
                elif msg_type == MSG_TYPE_COMMAND:
                    send_ack(ser)
                    _handle_command(ser, data)
                elif msg_type == MSG_TYPE_REQUEST:
                    send_ack(ser)
                    print(f"[TX] ACK only (unknown request)")
            time.sleep(0.02)
    except KeyboardInterrupt:
        print("\nExiting.")
    finally:
        ser.close()


# --- حالت ۲: کلاینت تست ---


def read_response(ser, timeout_sec=2.0):
    buf = bytearray()
    deadline = time.monotonic() + timeout_sec
    while time.monotonic() < deadline:
        chunk = ser.read(256)
        if chunk:
            buf.extend(chunk)
        while True:
            result, buf = find_frame(buf)
            if result is None:
                break
            msg_type, data = result
            if msg_type == "ack":
                continue
            if msg_type == MSG_TYPE_RESPONSE:
                return data
        time.sleep(0.02)
    return None


def run_test_client(port: str, baud: int = 9600):
    print(f"Connecting to {port} @ {baud} ...")
    try:
        ser = serial.Serial(port, baud, timeout=0.1)
    except Exception as e:
        print(f"Error: {e}")
        print("Usage: python usb_serial_simulator.py --test COM6")
        sys.exit(1)

    ok = 0
    fail = 0

    print("\n1. Request Floors (@M_F_A) ...")
    ser.write(encode_frame(MSG_TYPE_REQUEST, REQUEST_FLOORS))
    response = read_response(ser)
    if response and "floor_" in response and "|" in response:
        print("   OK - Got floors response:")
        for line in response.strip().split("\n"):
            print(f"      {line[:70]}")
        ok += 1
    else:
        print(f"   FAIL - No valid response (got: {response!r})")
        fail += 1

    time.sleep(0.2)

    print("\n2. Request Rooms (@M_R) ...")
    ser.write(encode_frame(MSG_TYPE_REQUEST, REQUEST_ROOMS))
    response = read_response(ser)
    if response and "room_" in response and "|" in response:
        print("   OK - Got rooms response:")
        for line in response.strip().split("\n"):
            print(f"      {line[:70]}")
        ok += 1
    else:
        print(f"   FAIL - No valid response (got: {response!r})")
        fail += 1

    ser.close()
    print(f"\n--- Result: {ok} passed, {fail} failed ---")
    sys.exit(0 if fail == 0 else 1)


# --- لیست پورت‌ها ---


def list_serial_ports():
    """Print available serial ports (English for Windows console)."""
    ports = list(list_ports.comports())
    if not ports:
        print("No serial ports found.")
        return
    print("Available serial ports:")
    for p in ports:
        desc = p.description or "(no description)"
        print(f"  {p.device}  -  {desc}")
    print("\nSimulator: python usb_serial_simulator.py COM5")
    print("Test:     python usb_serial_simulator.py --test COM6")


# --- main ---


def main():
    args = sys.argv[1:]
    if args and args[0] == "--list":
        list_serial_ports()
        sys.exit(0)
    if args and args[0] == "--test":
        args.pop(0)
        port = args[0] if args else "COM6"
        run_test_client(port)
    else:
        port = args[0] if args else "COM5"
        run_simulator(port)


if __name__ == "__main__":
    main()
