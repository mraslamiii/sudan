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

  4) شبیه‌ساز TCP (برای دیباگ تبلت با یک کابل به لپ‌تاپ + adb reverse):
     python usb_serial_simulator.py --tcp 9999
     سپس روی لپ‌تاپ: adb reverse tcp:9999 tcp:9999
     در اپ روی تبلت گزینه «اتصال دیباگ» را بزنید.

فرمت متن (بدون JSON): جداکننده فیلد | ، هر رکورد یک خط.
- طبقات: هر خط = id|name|order|roomIds (roomIds با کاما)
- اتاق‌ها: هر خط = id|name|order|floorId|icon|deviceIds|isGeneral

نیاز: pip install pyserial
"""

import socket
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
MSG_TYPE_HEARTBEAT = 0x04
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
    {"id": "room_bathroom", "name": "سرویس بهداشتی", "order": 2, "floorId": "floor_1", "icon": "bathroom", "deviceIds": [], "isGeneral": False},
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
    # Handle commands with or without newline separator
    if RECORD_SEP in data:
        first_line, rest = data.split(RECORD_SEP, 1)
        payload = rest.strip()
    else:
        # Try to parse command without newline (legacy format or malformed)
        data_stripped = data.strip()
        if data_stripped.startswith(COMMAND_CREATE_FLOOR):
            first_line = COMMAND_CREATE_FLOOR
            payload = data_stripped[len(COMMAND_CREATE_FLOOR):].strip()
        elif data_stripped.startswith(COMMAND_UPDATE_FLOOR):
            first_line = COMMAND_UPDATE_FLOOR
            payload = data_stripped[len(COMMAND_UPDATE_FLOOR):].strip()
        elif data_stripped.startswith(COMMAND_DELETE_FLOOR):
            first_line = COMMAND_DELETE_FLOOR
            payload = data_stripped[len(COMMAND_DELETE_FLOOR):].strip()
        elif data_stripped.startswith(COMMAND_CREATE_ROOM):
            first_line = COMMAND_CREATE_ROOM
            payload = data_stripped[len(COMMAND_CREATE_ROOM):].strip()
        elif data_stripped.startswith(COMMAND_UPDATE_ROOM):
            first_line = COMMAND_UPDATE_ROOM
            payload = data_stripped[len(COMMAND_UPDATE_ROOM):].strip()
        elif data_stripped.startswith(COMMAND_DELETE_ROOM):
            first_line = COMMAND_DELETE_ROOM
            payload = data_stripped[len(COMMAND_DELETE_ROOM):].strip()
        else:
            print(f"[SIM] COMMAND (unknown format): {data[:60]}...")
            return

    if first_line.strip() == COMMAND_CREATE_FLOOR and payload:
        f = _parse_floor_line(payload)
        if f:
            FLOORS_LIST.append(f)
            FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
            print(f"[SIM] COMMAND createFloor id={f['id']} name={f['name']} order={f['order']} roomIds={f['roomIds']}")
        else:
            print(f"[SIM] COMMAND: {data[:80]}...")
    elif first_line.strip() == COMMAND_UPDATE_FLOOR and payload:
        f = _parse_floor_line(payload)
        if f:
            for i, existing in enumerate(FLOORS_LIST):
                if existing.get("id") == f["id"]:
                    FLOORS_LIST[i] = f
                    FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
                    print(f"[SIM] COMMAND updateFloor id={f['id']} name={f['name']}")
                    return
            FLOORS_LIST.append(f)
            FLOORS_LIST.sort(key=lambda x: x.get("order", 0))
            print(f"[SIM] COMMAND updateFloor (new) id={f['id']}")
        else:
            print(f"[SIM] COMMAND: {data[:80]}...")
    elif first_line.strip() == COMMAND_DELETE_FLOOR and payload:
        floor_id = payload.strip()  # floorId is sent as a single line, no need to split
        before = len(FLOORS_LIST)
        FLOORS_LIST[:] = [x for x in FLOORS_LIST if x.get("id") != floor_id]
        if len(FLOORS_LIST) < before:
            print(f"[SIM] COMMAND deleteFloor floorId={floor_id}")
        else:
            print(f"[SIM] COMMAND deleteFloor (not found) floorId={floor_id}")
    elif first_line.strip() == COMMAND_CREATE_ROOM and payload:
        r = _parse_room_line(payload)
        if r:
            ROOMS_LIST.append(r)
            ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
            print(f"[SIM] COMMAND createRoom id={r['id']} name={r['name']} floorId={r['floorId']}")
        else:
            print(f"[SIM] COMMAND: {data[:80]}...")
    elif first_line.strip() == COMMAND_UPDATE_ROOM and payload:
        r = _parse_room_line(payload)
        if r:
            for i, existing in enumerate(ROOMS_LIST):
                if existing.get("id") == r["id"]:
                    ROOMS_LIST[i] = r
                    ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
                    print(f"[SIM] COMMAND updateRoom id={r['id']} name={r['name']}")
                    return
            ROOMS_LIST.append(r)
            ROOMS_LIST.sort(key=lambda x: (x.get("floorId") or "", x.get("order", 0)))
            print(f"[SIM] COMMAND updateRoom (new) id={r['id']}")
        else:
            print(f"[SIM] COMMAND: {data[:80]}...")
    elif first_line.strip() == COMMAND_DELETE_ROOM and payload:
        room_id = payload.strip()  # roomId is sent as a single line, no need to split
        before = len(ROOMS_LIST)
        ROOMS_LIST[:] = [x for x in ROOMS_LIST if x.get("id") != room_id]
        if len(ROOMS_LIST) < before:
            print(f"[SIM] COMMAND deleteRoom roomId={room_id}")
        else:
            print(f"[SIM] COMMAND deleteRoom (not found) roomId={room_id}")
    else:
        print(f"[SIM] COMMAND (unknown): {data[:80]}...")


class _TcpTransport:
    """Minimal write/read interface so TCP socket can be used like serial in the simulator loop."""

    def __init__(self, sock):
        self._sock = sock

    def write(self, data: bytes):
        try:
            self._sock.sendall(data)
        except (ConnectionResetError, BrokenPipeError, OSError) as e:
            print(f"[SIM] ⚠️ Write failed (connection closed?): {e}")
            raise  # دوباره raise کن تا loop بدونه اتصال بسته شده

    def read(self, size: int = 256) -> bytes:
        try:
            self._sock.settimeout(0.1)
            return self._sock.recv(size)
        except socket.timeout:
            return b""
        except (ConnectionResetError, BrokenPipeError, OSError) as e:
            print(f"[SIM] ⚠️ Read failed (connection closed?): {e}")
            raise  # دوباره raise کن تا loop بدونه اتصال بسته شده
        except Exception as e:
            print(f"[SIM] ⚠️ Read error: {e}")
            return b""


def _req_name(data: str) -> str:
    """Return a short readable name for the request/command for logging."""
    if data == REQUEST_FLOORS:
        return "REQUEST_FLOORS"
    if data == REQUEST_FLOORS_COUNT:
        return "REQUEST_FLOORS_COUNT"
    if data == REQUEST_ROOMS:
        return "REQUEST_ROOMS"
    if data.startswith(COMMAND_CREATE_FLOOR):
        return "COMMAND_CREATE_FLOOR"
    if data.startswith(COMMAND_UPDATE_FLOOR):
        return "COMMAND_UPDATE_FLOOR"
    if data.startswith(COMMAND_DELETE_FLOOR):
        return "COMMAND_DELETE_FLOOR"
    if data.startswith(COMMAND_CREATE_ROOM):
        return "COMMAND_CREATE_ROOM"
    if data.startswith(COMMAND_UPDATE_ROOM):
        return "COMMAND_UPDATE_ROOM"
    if data.startswith(COMMAND_DELETE_ROOM):
        return "COMMAND_DELETE_ROOM"
    return data[:40] if len(data) > 40 else data


def _run_simulator_loop(transport, label="Serial"):
    """Shared loop: read from transport, handle frames, write responses. transport must have write(data) and read(size)."""
    buf = bytearray()
    try:
        while True:
            try:
                chunk = transport.read(256)
                if chunk:
                    buf.extend(chunk)
                while True:
                    result, buf = find_frame(buf)
                    if result is None:
                        break
                    msg_type, data = result
                    if msg_type == "ack":
                        continue
                    type_name = {
                        MSG_TYPE_REQUEST: "REQUEST",
                        MSG_TYPE_COMMAND: "COMMAND",
                        MSG_TYPE_RESPONSE: "RESPONSE",
                        MSG_TYPE_HEARTBEAT: "HEARTBEAT",
                    }.get(msg_type, str(msg_type))
                    name = _req_name(data)
                    preview = f"{data[:60]}{'...' if len(data) > 60 else ''}"
                    if msg_type != MSG_TYPE_HEARTBEAT:
                        print(f"[SIM] 📥 RX {type_name} {name} | {preview}")
                try:
                    if msg_type == MSG_TYPE_HEARTBEAT:
                        send_ack(transport)
                        # بدون لاگ تا ترمینال شلوغ نشود؛ اتصال زنده می‌ماند
                    elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_FLOORS:
                        send_ack(transport)
                        body = get_floors_text()
                        transport.write(encode_frame(MSG_TYPE_RESPONSE, body))
                        lines = body.strip().split(RECORD_SEP) if body.strip() else []
                        print(f"[SIM] 📤 TX RESPONSE requestFloors count={len(lines)} | {body[:50]}...")
                    elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_FLOORS_COUNT:
                        send_ack(transport)
                        body = str(len(FLOORS_LIST))
                        transport.write(encode_frame(MSG_TYPE_RESPONSE, body))
                        print(f"[SIM] 📤 TX RESPONSE requestFloorsCount value={body}")
                    elif msg_type == MSG_TYPE_REQUEST and data == REQUEST_ROOMS:
                        send_ack(transport)
                        body = get_rooms_text()
                        transport.write(encode_frame(MSG_TYPE_RESPONSE, body))
                        lines = body.strip().split(RECORD_SEP) if body.strip() else []
                        print(f"[SIM] 📤 TX RESPONSE requestRooms count={len(lines)} | {body[:50]}...")
                    elif msg_type == MSG_TYPE_COMMAND:
                        send_ack(transport)
                        print(f"[SIM] 📤 TX ACK command")
                        _handle_command(transport, data)
                    elif msg_type == MSG_TYPE_REQUEST:
                        send_ack(transport)
                        print(f"[SIM] 📤 TX ACK only (unknown request)")
                except (ConnectionResetError, BrokenPipeError, OSError) as e:
                    # اگر نوشتن شکست خورد (مثلاً socket بسته شده)، loop را exit کن
                    print(f"[SIM] ⚠️ Write failed, connection closed: {e}")
                    raise
            except Exception as e:
                # خطاهای جزئی (مثلاً parsing) را لاگ کن ولی اتصال را نگه دار
                print(f"[SIM] ⚠️ Error in loop (continuing): {e}")
                time.sleep(0.1)
            time.sleep(0.02)
    except (ConnectionResetError, BrokenPipeError, OSError) as e:
        print(f"\n[SIM] Client disconnected: {e}")
        raise  # دوباره raise کن تا run_simulator_tcp بدونه اتصال بسته شده
    except KeyboardInterrupt:
        print("\n[SIM] Exiting.")
        raise


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
    try:
        _run_simulator_loop(ser)
    finally:
        ser.close()


def run_simulator_tcp(tcp_port: int = 9999):
    """Run simulator over TCP. One client. For tablet debug: adb reverse tcp:9999 tcp:9999, then app connects to 127.0.0.1:9999."""
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind(("0.0.0.0", tcp_port))
        server.listen(1)
        server.settimeout(1.0)
    except Exception as e:
        print(f"Error binding TCP port {tcp_port}: {e}")
        sys.exit(1)

    print(f"TCP simulator listening on 0.0.0.0:{tcp_port}")
    print("On laptop run: adb reverse tcp:9999 tcp:9999")
    print("Then in the app on tablet use 'Debug connection (tablet->laptop)'.")
    print("--- Data exchange log (RX = received, TX = sent) ---\n")

    try:
        while True:
            try:
                conn, addr = server.accept()
            except socket.timeout:
                continue
            # فعال کردن keepalive برای جلوگیری از timeout
            conn.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
            # در ویندوز TCP_KEEPIDLE و TCP_KEEPINTVL ممکن است موجود نباشد
            try:
                # Linux: TCP_KEEPIDLE = 20, TCP_KEEPINTVL = 3
                if hasattr(socket, 'TCP_KEEPIDLE'):
                    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPIDLE, 20)
                if hasattr(socket, 'TCP_KEEPINTVL'):
                    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPINTVL, 3)
            except Exception:
                pass  # در ویندوز ممکن است موجود نباشد
            print(f"[SIM] Client connected from {addr}")
            try:
                _run_simulator_loop(_TcpTransport(conn))
            except Exception as e:
                print(f"[SIM] Error in simulator loop: {e}")
            finally:
                try:
                    conn.close()
                    print("[SIM] Connection closed, waiting for next client...")
                except Exception:
                    pass
    except KeyboardInterrupt:
        print("\n[SIM] Exiting.")
    finally:
        server.close()


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
    elif args and args[0] == "--tcp":
        args.pop(0)
        tcp_port = int(args[0]) if args else 9999
        run_simulator_tcp(tcp_port)
    else:
        port = args[0] if args else "COM5"
        run_simulator(port)


if __name__ == "__main__":
    main()
