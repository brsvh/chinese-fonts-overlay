#!/usr/bin/env python3
"""Check the selected native Fibers HTTP server in owned loopback processes.

Needs Guile 3 and native Fibers in the calling environment. Uses no fixed port,
fetches nothing, and always stops its children. Each read and shutdown is bounded.
"""
from pathlib import Path
import argparse
import http.client
import os
import selectors
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "examples/server.scm"


def ready(process):
    with selectors.DefaultSelector() as selector:
        selector.register(process.stdout, selectors.EVENT_READ)
        if not selector.select(10):
            raise RuntimeError("Server never reported readiness")
    line = process.stdout.readline()
    if not line.startswith("READY "):
        raise RuntimeError("Unexpected readiness: " + line)
    return int(line.split()[1])


def request(port, path, method="GET"):
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
    try:
        connection.request(method, path)
        response = connection.getresponse()
        return response.status, response.read()
    finally:
        connection.close()


def raw_request(port, data):
    with socket.create_connection(("127.0.0.1", port), timeout=5) as peer:
        peer.sendall(data)
        peer.shutdown(socket.SHUT_WR)
        result = bytearray()
        while chunk := peer.recv(65536):
            result.extend(chunk)
        return bytes(result)


def stop(process):
    if process.poll() is None:
        process.send_signal(signal.SIGINT)
    try:
        output, _ = process.communicate(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.communicate()
        raise RuntimeError("Server shutdown timed out; forced kill is not success")
    if process.returncode != 0 or "STOPPED listener-closed" not in output:
        raise RuntimeError("Server did not acknowledge listener cleanup: " + output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    if sys.version_info < (3, 10) or os.name != "posix":
        parser.error("This optional harness requires Python 3.10+ and POSIX signals/pipes")
    try:
        guile = shlex.split(os.environ.get("GUILE", "guile"))
    except ValueError as error:
        parser.error(f"Invalid GUILE: {error}")
    if not guile or shutil.which(guile[0]) is None:
        parser.error("GUILE: executable not found; select an environment with Guile 3 and Fibers")
    env = os.environ | {"GUILE_AUTO_COMPILE": "0"}
    try:
        subprocess.run(guile + ["--no-auto-compile", "-c",
                               "(use-modules (fibers web server))"],
                       check=True, capture_output=True, encoding="utf-8",
                       env=env, timeout=30)
    except subprocess.CalledProcessError as error:
        parser.error("Guile/Fibers dependency check failed: " + error.stderr)
    except (subprocess.SubprocessError, OSError) as error:
        parser.error(f"Guile/Fibers dependency check failed: {error}")
    port = 0
    with tempfile.TemporaryDirectory(prefix="web-skill-check-") as temp:
        for cycle in range(2):
            with (Path(temp) / f"server-{cycle}.log").open("w+", encoding="utf-8") as log:
                process = subprocess.Popen(
                    guile + ["--no-auto-compile", str(SOURCE), str(port)],
                    stdout=subprocess.PIPE, stderr=log, encoding="utf-8",
                    env=env)
                try:
                    port = ready(process)
                    assert request(port, "/") == (200, b"Service available")
                    assert request(port, "/fail")[0] == 500
                    assert request(port, "/", "HEAD") == (200, b"")
                    assert raw_request(port, b"OPTIONS * HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n").startswith(b"HTTP/1.1 204")
                    partial = raw_request(port, b"GET /stream-fail HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n")
                    assert partial.startswith(b"HTTP/1.1 200") and partial.count(b"HTTP/1.1") == 1
                    assert b"Partial response" in partial
                    # A disappearing client must not prevent the next request.
                    with socket.create_connection(("127.0.0.1", port), timeout=5) as peer:
                        peer.sendall(b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n")
                    assert request(port, "/") == (200, b"Service available")
                except BaseException:
                    log.flush(); log.seek(0)
                    print(log.read())
                    raise
                finally:
                    stop(process)
    print("HTTP recovery, HEAD, OPTIONS *, committed failure, disconnect, stop, and same-port restart passed")


if __name__ == "__main__":
    main()
