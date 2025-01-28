from flask import Flask, request
import psycopg2
import os

# Flask application
app = Flask(__name__)

# Load database configuration
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_USER = os.getenv("DB_USER", "decoy_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "decoy_password")
DB_NAME = os.getenv("DB_NAME", "coredef")


def log_to_db(ip, port, service):
    """Log connection attempts to the database."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO decoy_events (attacker_ip, port, service, detected_at)
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
            """,
            (ip, port, service)
        )
        conn.commit()
        cur.close()
        conn.close()
        print(f"Logged: {ip} -> {port} ({service})")
    except Exception as e:
        print(f"Failed to log to DB: {e}")


@app.route('/')
def fake_page():
    """Serve a fake webpage."""
    attacker_ip = request.remote_addr
    log_to_db(attacker_ip, 80, "HTTP")
    return "<h1>Welcome to the Decoy System</h1><p>This is a fake page.</p>", 200


if __name__ == '__main__':
    # Start Flask server
    from multiprocessing import Process
    import subprocess

    def start_flask():
        app.run(host="0.0.0.0", port=80)

    def start_samba():
        subprocess.call(["smbd", "-F", "-s", "/app/smb.conf"])

    # Run Flask and Samba in parallel
    flask_process = Process(target=start_flask)
    samba_process = Process(target=start_samba)

    flask_process.start()
    samba_process.start()

    flask_process.join()
    samba_process.join()
