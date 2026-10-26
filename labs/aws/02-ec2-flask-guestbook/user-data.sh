#!/bin/bash
# ---------------------------------------------------------------
# Demo 2: Live class guestbook on Amazon EC2
#
# Paste this WHOLE file into:
#   EC2 > Launch instance > Advanced details > User data
#
# Tested for: Amazon Linux 2023, t3.micro
# Security group: allow HTTP (80) from anywhere, SSH (22) from My IP
#
# After launch, wait about 2 minutes, then open:
#   http://<your-instance-public-ipv4>
# ---------------------------------------------------------------
set -euxo pipefail

# Change this before the session. Visiting /reset?code=<this> clears all entries.
RESET_CODE="change-me-acm-2026"

# 1) Install Python's package manager and Flask
dnf install -y python3-pip
pip3 install "flask>=3.0,<4"

mkdir -p /opt/guestbook

# 2) Ask the instance metadata service (IMDSv2) where we are running
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-type)

cat > /opt/guestbook/config.env <<EOF
INSTANCE_ID=$INSTANCE_ID
AZ=$AZ
INSTANCE_TYPE=$INSTANCE_TYPE
RESET_CODE=$RESET_CODE
DB_PATH=/opt/guestbook/guestbook.db
PORT=80
EOF

# 3) Write the Flask application
cat > /opt/guestbook/app.py <<'PYEOF'
import os
import sqlite3
from contextlib import closing
from datetime import datetime, timedelta, timezone

from flask import Flask, abort, jsonify, redirect, render_template_string, request

DB_PATH = os.environ.get("DB_PATH", "guestbook.db")
INSTANCE_ID = os.environ.get("INSTANCE_ID", "local-test")
AZ = os.environ.get("AZ", "local")
INSTANCE_TYPE = os.environ.get("INSTANCE_TYPE", "laptop")
RESET_CODE = os.environ.get("RESET_CODE", "")
PORT = int(os.environ.get("PORT", "80"))
PKT = timezone(timedelta(hours=5))  # Pakistan Standard Time

app = Flask(__name__)


def connect():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    with closing(connect()) as conn, conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS entries ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT NOT NULL, message TEXT NOT NULL, created TEXT NOT NULL)"
        )


def all_entries(limit=300):
    with closing(connect()) as conn:
        rows = conn.execute(
            "SELECT name, message, created FROM entries ORDER BY id DESC LIMIT ?",
            (limit,),
        ).fetchall()
        total = conn.execute("SELECT COUNT(*) FROM entries").fetchone()[0]
    return total, [dict(r) for r in rows]


PAGE = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ACM Cloud Guestbook</title>
<style>
  :root { --navy:#0E1A2B; --navy2:#16263D; --line:#24395A; --cream:#F6F4EE;
          --text:#C9D4E3; --orange:#FF9A1F; --blue:#5AA9FF; }
  * { box-sizing:border-box; }
  body { margin:0; font-family:system-ui,-apple-system,"Segoe UI",Roboto,Arial,sans-serif;
         background:var(--navy); color:var(--text); line-height:1.5; }
  .wrap { max-width:880px; margin:0 auto; padding:32px 16px 48px; }
  .eyebrow { color:var(--orange); font-weight:700; letter-spacing:3px;
             text-transform:uppercase; font-size:13px; margin:0; }
  h1 { color:var(--cream); font-size:clamp(32px,6vw,52px); line-height:1.1; margin:8px 0 12px; }
  h1 span { color:var(--orange); }
  .meta { display:flex; flex-wrap:wrap; gap:8px; margin:0 0 24px; }
  .pill { background:var(--navy2); border:1px solid var(--line); border-radius:999px;
          padding:6px 14px; font-size:14px; }
  .pill b { color:var(--cream); }
  form { background:var(--navy2); border:1px solid var(--line); border-radius:16px;
         padding:20px; display:grid; gap:12px; margin-bottom:28px; }
  input, textarea { width:100%; padding:14px; border-radius:10px; border:1px solid var(--line);
                    background:var(--navy); color:var(--cream); font-size:16px; font-family:inherit; }
  textarea { resize:vertical; min-height:80px; }
  button { padding:14px; border:0; border-radius:10px; background:var(--orange);
           color:var(--navy); font-weight:700; font-size:17px; cursor:pointer; }
  .count { color:var(--cream); font-size:22px; margin:0 0 12px; }
  .count b { color:var(--orange); font-size:34px; }
  ul { list-style:none; padding:0; margin:0; display:grid; gap:10px; }
  li { background:var(--navy2); border:1px solid var(--line); border-radius:14px; padding:14px 16px; }
  li strong { color:var(--cream); font-size:18px; }
  li time { float:right; color:#8A9AB0; font-size:13px; }
  li p { margin:6px 0 0; word-wrap:break-word; }
  footer { margin-top:32px; color:#8A9AB0; font-size:13px; text-align:center; }
</style>
</head>
<body>
<div class="wrap">
  <p class="eyebrow">Superior ACM Society · Cloud Computing on AWS</p>
  <h1>Live from <span>Amazon EC2</span> 🚀</h1>
  <div class="meta">
    <span class="pill">Instance <b>{{ instance_id }}</b></span>
    <span class="pill">Zone <b>{{ az }}</b></span>
    <span class="pill">Type <b>{{ instance_type }}</b></span>
  </div>

  <form method="post" action="/sign">
    <input name="name" maxlength="40" placeholder="Your name (e.g. Ayesha, BSCS 5th)" required>
    <textarea name="message" maxlength="140" placeholder="One line: what will you build on AWS?"></textarea>
    <button type="submit">Sign the guestbook ✍️</button>
  </form>

  <p class="count"><b id="count">{{ total }}</b> people have signed</p>
  <ul id="list">
    {% for e in entries %}
    <li><strong>{{ e.name }}</strong><time>{{ e.created }}</time><p>{{ e.message }}</p></li>
    {% endfor %}
  </ul>

  <footer>Served by a Python Flask app on one EC2 instance. This list refreshes every 3 seconds.</footer>
</div>
<script>
  async function refresh() {
    try {
      const res = await fetch('/api/entries', { cache: 'no-store' });
      const data = await res.json();
      document.getElementById('count').textContent = data.total;
      const list = document.getElementById('list');
      list.replaceChildren();
      data.entries.forEach(function (e) {
        const li = document.createElement('li');
        const name = document.createElement('strong');
        name.textContent = e.name;
        const time = document.createElement('time');
        time.textContent = e.created;
        const msg = document.createElement('p');
        msg.textContent = e.message;
        li.append(name, time, msg);
        list.append(li);
      });
    } catch (err) { /* server busy or offline; try again next tick */ }
  }
  setInterval(refresh, 3000);
</script>
</body>
</html>
"""


@app.get("/")
def home():
    total, entries = all_entries()
    return render_template_string(
        PAGE,
        total=total,
        entries=entries,
        instance_id=INSTANCE_ID,
        az=AZ,
        instance_type=INSTANCE_TYPE,
    )


@app.post("/sign")
def sign():
    name = (request.form.get("name") or "").strip()[:40]
    message = (request.form.get("message") or "").strip()[:140]
    if name:
        created = datetime.now(PKT).strftime("%I:%M %p")
        with closing(connect()) as conn, conn:
            conn.execute(
                "INSERT INTO entries (name, message, created) VALUES (?, ?, ?)",
                (name, message or "Hello, cloud! ☁️", created),
            )
    return redirect("/", code=303)


@app.get("/api/entries")
def api_entries():
    total, entries = all_entries()
    return jsonify(total=total, entries=entries)


@app.get("/reset")
def reset():
    if not RESET_CODE or request.args.get("code") != RESET_CODE:
        abort(403)
    with closing(connect()) as conn, conn:
        conn.execute("DELETE FROM entries")
    return redirect("/", code=303)


@app.get("/health")
def health():
    return "ok"


init_db()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT, threaded=True)
PYEOF

# 4) Run the app as a systemd service so it survives reboots and crashes
cat > /etc/systemd/system/guestbook.service <<'EOF'
[Unit]
Description=ACM Cloud Guestbook (Flask)
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=/opt/guestbook/config.env
WorkingDirectory=/opt/guestbook
ExecStart=/usr/bin/python3 /opt/guestbook/app.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now guestbook

echo "Guestbook is running on port 80"
