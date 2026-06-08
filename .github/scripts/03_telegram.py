#!/usr/bin/env python3
"""
DumperX Pro - Telegram Bot Integration
Token: 8727385860:AAEmuxNgv4fG7J6hNFXLJri-qpyyJ4eN-ao
Features: Live updates, Inline keyboards, Status tracking
"""
import os
import sys
import json
import urllib.request
import urllib.error

TOKEN = "8727385860:AAEmuxNgv4fG7J6hNFXLJri-qpyyJ4eN-ao"
CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID", "")
MSG_FILE = os.environ.get("TG_MSG_FILE", "/tmp/tg_msg_id")

def api_call(method, data=None):
    url = f"https://api.telegram.org/bot{TOKEN}/{method}"
    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode("utf-8") if data else None,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"Telegram API error: {e}", file=sys.stderr)
        return {"ok": False}

def save_msg_id(msg_id):
    with open(MSG_FILE, "w") as f:
        f.write(str(msg_id))

def load_msg_id():
    if os.path.exists(MSG_FILE):
        with open(MSG_FILE) as f:
            return f.read().strip()
    return None

def send_message(text, keyboard=None):
    if not CHAT_ID:
        print("No TELEGRAM_CHAT_ID set", file=sys.stderr)
        return None
    data = {
        "chat_id": CHAT_ID,
        "text": text,
        "parse_mode": "Markdown",
        "disable_web_page_preview": True
    }
    if keyboard:
        data["reply_markup"] = keyboard
    resp = api_call("sendMessage", data)
    if resp.get("ok") and resp.get("result", {}).get("message_id"):
        save_msg_id(resp["result"]["message_id"])
    return resp

def edit_message(msg_id, text, keyboard=None):
    if not CHAT_ID or not msg_id:
        return None
    data = {
        "chat_id": CHAT_ID,
        "message_id": int(msg_id),
        "text": text,
        "parse_mode": "Markdown",
        "disable_web_page_preview": True
    }
    if keyboard:
        data["reply_markup"] = keyboard
    return api_call("editMessageText", data)

def build_keyboard(run_url, dump_url, tree_url=None):
    buttons = [
        [{"text": "📊 View Run", "url": run_url}],
        [{"text": "📁 View Dump", "url": dump_url}]
    ]
    if tree_url:
        buttons.append([{"text": "🌳 View Trees", "url": tree_url}])
    return {"inline_keyboard": buttons}

def notify_start(title, detail, run_url):
    keyboard = {
        "inline_keyboard": [
            [{"text": "🚀 View Live Run", "url": run_url}],
            [{"text": "📖 Instructions", "url": "https://github.com/Il103/Stock-rom-dumber#readme"}]
        ]
    }
    text = f"{title}\n\n{detail}\n\n_Status: 🔄 Running..._"
    return send_message(text, keyboard)

def notify_step(step, status, detail=""):
    emoji = {"running": "🔄", "done": "✅", "failed": "❌", "warning": "⚠️"}.get(status, "⏳")
    text = f"*DumperX Pro*\n\n*Step:* {step}\n*Status:* {emoji} {status}"
    if detail:
        text += f"\n*Detail:* {detail}"
    text += f"\n_Time: {os.popen('date +%H:%M:%S').read().strip()}_"

    msg_id = load_msg_id()
    if msg_id:
        return edit_message(msg_id, text)
    else:
        return send_message(text)

def notify_final(title, brand, code, branch, run_url, dump_url):
    keyboard = build_keyboard(run_url, dump_url)
    text = f"{title}\n\n"
    text += f"📱 *Device:* `{brand}` / `{code}`\n"
    text += f"🌿 *Branch:* `{branch}`\n"
    text += f"☁️ *Dump URL:* [Click Here]({dump_url})\n"
    text += f"📊 *Run URL:* [Click Here]({run_url})"
    return send_message(text, keyboard)

def main():
    if len(sys.argv) < 2:
        print("Usage: telegram.py <command> [args...]")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "start":
        notify_start(sys.argv[2], sys.argv[3], sys.argv[4])
    elif cmd == "step":
        detail = sys.argv[4] if len(sys.argv) > 4 else ""
        notify_step(sys.argv[2], sys.argv[3], detail)
    elif cmd == "final":
        notify_final(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7])
    else:
        print(f"Unknown command: {cmd}")

if __name__ == "__main__":
    main()
