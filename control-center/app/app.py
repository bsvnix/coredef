from flask import Flask, render_template, request, jsonify
import psycopg2
import os
import json

# Flask application
app = Flask(__name__)

# Load configuration from centralized config file
config_path = os.getenv("CONFIG_PATH", "./config.json")
with open(config_path, "r") as f:
    config = json.load(f)

db_config = config["database"]
DB_HOST = db_config["host"]
DB_PORT = db_config["port"]
DB_NAME = db_config["name"]
DB_USER = db_config["users"]["control"]["user"]
DB_PASSWORD = db_config["users"]["control"]["password"]


def get_db_connection():
    """Establish a connection to the database."""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )


@app.route('/')
def index():
    """Main dashboard page."""
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Fetch the last 10 decoy events
        cur.execute("SELECT attacker_ip, port, detected_at FROM decoy_events ORDER BY detected_at DESC LIMIT 10")
        decoy_data = cur.fetchall()

        # Fetch the last 10 discovered IPs from the scanner
        cur.execute("SELECT DISTINCT ip, scanned_at FROM scan_results ORDER BY scanned_at DESC LIMIT 10")
        scanner_ips = cur.fetchall()

        cur.close()
        conn.close()

        return render_template('index.html', decoy_data=decoy_data, scanner_ips=scanner_ips)
    except Exception as e:
        return f"Error fetching data: {e}", 500


@app.route('/scanner/<ip>')
def scanner_details(ip):
    """Drilldown page showing detailed scan results for a specific IP."""
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        # Fetch detailed scan results for the given IP
        cur.execute(
            """
            SELECT ip, system, vulnerabilities, scanned_at
            FROM scan_results
            WHERE ip = %s
            ORDER BY scanned_at DESC
            """,
            (ip,)
        )
        results = cur.fetchall()

        cur.close()
        conn.close()

        return render_template('scanner_details.html', ip=ip, results=results)
    except Exception as e:
        return f"Error fetching details: {e}", 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
