#!/usr/bin/env python3
"""
اجرای خودکار تست USB Serial: پیدا کردن جفت پورت com0com، اجرای شبیه‌ساز و کلاینت تست.

پیش‌نیازها:
  - نصب Python و pip
  - pip install pyserial
  - نصب com0com و ساخت یک جفت پورت (مثلاً COM5 و COM6)
  - درایور com0com بدون خطا (در Device Manager آیکن زرد نباشد)

استفاده:
  python run_all_tests.py              # فقط تست شبیه‌ساز + کلاینت
  python run_all_tests.py --launch-app # بعد از تست، اپ Flutter را هم اجرا می‌کند
  python run_all_tests.py --list       # فقط لیست پورت‌ها و خروج
"""

import re
import subprocess
import sys
import time
from pathlib import Path

try:
    import serial
    from serial.tools import list_ports
except ImportError:
    print("pyserial not installed. Run: pip install pyserial")
    sys.exit(1)

# پوشهٔ اسکریپت و پروژه
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
SIMULATOR_SCRIPT = SCRIPT_DIR / "usb_serial_simulator.py"

# پیش‌فرض پورت‌ها اگر جفت com0com پیدا نشد
DEFAULT_SIMULATOR_PORT = "COM6"
DEFAULT_CLIENT_PORT = "COM5"

# زمان انتظار بعد از استارت شبیه‌ساز (ثانیه)
SIMULATOR_START_DELAY = 3


def _com_number(port_name: str) -> int:
    """استخراج شمارهٔ پورت از 'COM5' -> 5"""
    m = re.match(r"COM(\d+)", port_name, re.IGNORECASE)
    return int(m.group(1)) if m else 9999


def find_com0com_pair():
    """
    پیدا کردن یک جفت پورت com0com.
    برمی‌گرداند (پورت_شبیه‌ساز, پورت_کلاینت/اپ) مثلاً (COM6, COM5).
    """
    ports = list(list_ports.comports())
    com0com_ports = [
        p for p in ports
        if p.description and "com0com" in p.description.lower()
    ]
    if len(com0com_ports) >= 2:
        com0com_ports.sort(key=lambda p: _com_number(p.device))
        # پورت با شمارهٔ کمتر = کلاینت/اپ، بیشتر = شبیه‌ساز
        client_port = com0com_ports[0].device
        sim_port = com0com_ports[1].device
        return sim_port, client_port
    # اگر فقط یک پورت یا هیچ‌کدام نبود، از پیش‌فرض استفاده کن
    return DEFAULT_SIMULATOR_PORT, DEFAULT_CLIENT_PORT


def list_ports_and_exit():
    """Print available ports and suggested pair."""
    ports = list(list_ports.comports())
    if not ports:
        print("No serial ports found.")
        return
    print("Available serial ports:")
    for p in ports:
        desc = p.description or "(no description)"
        print(f"  {p.device}  -  {desc}")
    sim_port, client_port = find_com0com_pair()
    print(f"\nSuggested pair: simulator={sim_port}  client/app={client_port}")


def main():
    args = sys.argv[1:]
    if "--list" in args or "-l" in args:
        list_ports_and_exit()
        sys.exit(0)

    launch_app = "--launch-app" in args or "--app" in args
    args = [a for a in args if a not in ("--launch-app", "--app")]

    if not SIMULATOR_SCRIPT.exists():
        print(f"Simulator script not found: {SIMULATOR_SCRIPT}")
        sys.exit(1)

    sim_port, client_port = find_com0com_pair()
    print(f"Port pair: simulator={sim_port}  client/app={client_port}")
    print("---")

    # 1) Start simulator in background
    print(f"[1/3] Starting simulator on {sim_port} ...")
    sim_proc = subprocess.Popen(
        [sys.executable, str(SIMULATOR_SCRIPT), sim_port],
        cwd=str(SCRIPT_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if sys.platform == "win32" else 0,
    )
    time.sleep(SIMULATOR_START_DELAY)

    # If simulator exited immediately (error), show output
    if sim_proc.poll() is not None:
        out, _ = sim_proc.communicate()
        print((out.decode("utf-8", errors="replace") if out else "").strip())
        print("Simulator could not open port. Ensure com0com is installed and working.")
        sys.exit(1)

    print("Simulator is running.")
    print("---")

    exit_code = 0
    try:
        # 2) Run test client
        print(f"[2/3] Running test client on {client_port} ...")
        result = subprocess.run(
            [sys.executable, str(SIMULATOR_SCRIPT), "--test", client_port],
            cwd=str(SCRIPT_DIR),
            timeout=15,
        )
        exit_code = result.returncode
        if exit_code != 0:
            print("Test client failed.")
        else:
            print("Test client passed.")
        print("---")
    except subprocess.TimeoutExpired:
        print("Test client timed out.")
        exit_code = 1
    finally:
        # Stop simulator
        print("[3/3] Stopping simulator ...")
        try:
            sim_proc.terminate()
            sim_proc.wait(timeout=3)
        except Exception:
            try:
                sim_proc.kill()
            except Exception:
                pass

    # 3) Optional: launch Flutter app
    if launch_app and exit_code == 0:
        print("---")
        print("Launching Flutter app. In the app, select port", client_port, "and connect.")
        flutter_cmd = ["flutter", "run"]
        subprocess.Popen(flutter_cmd, cwd=str(PROJECT_ROOT))

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
