-- Create tables
CREATE TABLE IF NOT EXISTS decoy_events (
    id SERIAL PRIMARY KEY,
    attacker_ip TEXT NOT NULL,
    port INTEGER NOT NULL,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS scan_results (
    id SERIAL PRIMARY KEY,
    ip TEXT NOT NULL,
    system TEXT,
    vulnerabilities JSONB,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create roles for different services
CREATE ROLE scanner_user WITH LOGIN PASSWORD 'scanner_password';
CREATE ROLE decoy_user WITH LOGIN PASSWORD 'decoy_password';
CREATE ROLE control_user WITH LOGIN PASSWORD 'control_password';

-- Grant permissions to roles
GRANT INSERT ON decoy_events TO decoy_user;
GRANT INSERT ON scan_results TO scanner_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO control_user;

-- Optional: Grant read-only access to a monitoring role (if needed)
CREATE ROLE monitoring_user WITH LOGIN PASSWORD 'monitoring_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO monitoring_user;
