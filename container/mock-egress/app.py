"""Mock external API for egress simulation (Module D)."""
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/api/v1/status")
def status():
    return jsonify({"service": "external-partner-api", "status": "UP"})


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)
