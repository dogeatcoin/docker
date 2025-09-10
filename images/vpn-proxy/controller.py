import os, json, fcntl, subprocess, time
from flask import Flask, request, jsonify

app = Flask(__name__)

LOCK_PATH = "/tmp/vpn.lock"
PROXY_PORT = int(os.environ.get("PROXY_PORT", "8080"))

class Locker:
    def __enter__(self):
        self.f = open(LOCK_PATH, "w")
        fcntl.flock(self.f, fcntl.LOCK_EX)
        return self
    def __exit__(self, exc_type, exc, tb):
        fcntl.flock(self.f, fcntl.LOCK_UN)
        self.f.close()

def sh(cmd):
    proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return proc.returncode, proc.stdout.strip() + ("\n" + proc.stderr.strip() if proc.stderr else "")

@app.get("/status")
def status():
    code, out = sh("expressvpn status")
    return jsonify({"ok": code==0, "status": out}), (200 if code==0 else 500)

@app.post("/connect")
def connect():
    data = request.get_json(force=True, silent=True) or {}
    geo = (data.get("geo") or "").strip()
    if not geo:
        return jsonify({"ok": False, "error": "geo required"}), 400
    with Locker():
        code, out = sh(f"expressvpn connect {json.dumps(geo)}")
        ok = (code == 0)
        return jsonify({"ok": ok, "output": out}), (200 if ok else 500)

@app.post("/disconnect")
def disconnect():
    with Locker():
        code, out = sh("expressvpn disconnect")
        ok = (code == 0)
        return jsonify({"ok": ok, "output": out}), (200 if ok else 500)

@app.post("/request")
def do_request():
    """
    Body:
      {
        "geo": "Spain",             # optional – if provided, will reconnect first (serialized)
        "url": "https://api.ipify.org",
        "method": "GET",
        "headers": {"Accept":"*/*"},
        "body": "raw body or json str",
        "timeout": 30
      }
    """
    data = request.get_json(force=True, silent=True) or {}
    url = data.get("url")
    if not url:
        return jsonify({"ok": False, "error": "url required"}), 400
    method = (data.get("method") or "GET").upper()
    headers = data.get("headers") or {}
    body = data.get("body")
    timeout = int(data.get("timeout") or 30)
    geo = (data.get("geo") or "").strip()

    with Locker():
        if geo:
            c, o = sh(f"expressvpn connect {json.dumps(geo)}")
            if c != 0:
                return jsonify({"ok": False, "error": "vpn connect failed", "output": o}), 500

        # Build curl
        hdrs = " ".join([f"-H {json.dumps(k+': '+v)}" for k,v in headers.items()])
        data_flag = f"--data-raw {json.dumps(body)}" if body is not None else ""
        cmd = f"curl -sS -x http://127.0.0.1:{PROXY_PORT} -X {method} {hdrs} --max-time {timeout} {data_flag} {json.dumps(url)}"
        c, o = sh(cmd)
        ok = (c == 0)
        return jsonify({"ok": ok, "status": 200 if ok else 500, "body": o})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("CONTROL_PORT", "8088")))