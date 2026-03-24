"""
Scanner module for NetProbe.
Handles all socket connections and banner grabbing.
"""

import concurrent.futures
import socket

from utils import randomize_port_list, resolve_hostname, sleep_delay


def check_port(ip: str, port: int, interface: str = None) -> bool:
    """Checks if a specific TCP port is open."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            if interface:
                sock.bind((interface, 0))
            sock.settimeout(1.0)
            sock.connect((ip, port))
            return True
    except Exception:
        return False


def scan_udp(ip: str, port: int, interface: str = None) -> bool:
    """Scans a UDP port to check if it's Open/Filtered."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            if interface:
                sock.bind((interface, 0))
            sock.settimeout(2.0)
            sock.sendto(b"", (ip, port))
            try:
                sock.recvfrom(1024)
                return True
            except socket.timeout:
                return True
            except (ConnectionRefusedError, OSError):
                return False
    except Exception:
        return False


def ping_sweep(subnet: str) -> list:
    """Scans a /24 subnet to identify active hosts."""
    active_hosts = []
    ips = [f"{subnet}.{i}" for i in range(1, 255)]

    def scan_ip(ip: str) -> str:
        if check_port(ip, 80):
            return ip
        return ""

    with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
        results = executor.map(scan_ip, ips)

    for res in results:
        if res:
            active_hosts.append(res)
    return active_hosts


def get_banner(ip: str, port: int, interface: str = None) -> str:
    """Retrieves a service banner from a port."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            if interface:
                sock.bind((interface, 0))
            sock.settimeout(2.0)
            sock.connect((ip, port))

            try:
                banner = sock.recv(1024).decode('utf-8', 'ignore').strip()
                if banner:
                    return banner
            except socket.timeout:
                pass

            sock.sendall(b"HEAD / HTTP/1.0\r\n\r\n")
            banner = sock.recv(1024).decode('utf-8', 'ignore').strip()

            if banner:
                return banner.split('\n')[0].strip()
            return "Unknown"
    except Exception:
        return "Unknown"


def guess_service(port: int) -> str:
    """Guesses the service based on standard port numbers."""
    common_ports = {
        21: "FTP", 22: "SSH", 80: "HTTP",
        443: "HTTPS", 3306: "MySQL"
    }
    service = common_ports.get(port)
    if service:
        return f"{service} (Guessed)"
    return "Unknown"


def get_service_info(ip: str, port: int, interface: str = None) -> str:
    """Gets service info via banner grabbing or deep HTTP inspection."""
    if port == 80:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                if interface:
                    sock.bind((interface, 0))
                sock.settimeout(2.0)
                sock.connect((ip, port))

                req = f"GET / HTTP/1.1\r\nHost: {ip}\r\n\r\n"
                sock.sendall(req.encode('utf-8'))

                resp = sock.recv(4096).decode('utf-8', 'ignore')
                for line in resp.split('\r\n'):
                    if line.lower().startswith("server:"):
                        server_val = line.split(":", 1)[1].strip()
                        return f"HTTP ({server_val})"
            return "HTTP"
        except Exception:
            return "HTTP"

    banner = get_banner(ip, port, interface)
    if banner == "Unknown" or not banner:
        return guess_service(port)
    return banner


def check_vulnerability(banner: str) -> str:
    """Checks for known vulnerable signatures."""
    bad_signatures = ["vsftpd 2.3.4", "Apache 2.2.8"]
    for sig in bad_signatures:
        if sig in banner:
            return "[VULNERABLE]"
    return ""


def scan_ports(
    ip: str, start_port: int, end_port: int,
    delay: float = 0.0, randomize: bool = False, interface: str = None
) -> list:
    """Scans a range of ports concurrently."""
    if interface:
        print(f"[INFO] Scanning from source IP: {interface}")

    hostname = resolve_hostname(ip)
    if hostname:
        print(f"Target: {ip} ({hostname})")
    else:
        print(f"Target: {ip}")

    ports_list = list(range(start_port, end_port + 1))
    if randomize:
        print("Scanning ports randomly...")
        ports_list = randomize_port_list(ports_list)
    else:
        print(f"Scanning {ip} from {start_port} to {end_port}...")

    results = []

    def scan_single_port(port: int):
        if check_port(ip, port, interface):
            banner = get_service_info(ip, port, interface)
            vuln = check_vulnerability(banner)

            display_banner = f"{banner} {vuln}".strip()
            print(f"[+] Port {port} Open: {display_banner}")

            return {
                "port": port,
                "state": "open",
                "service": banner,
                "vulnerability": "YES" if vuln else "NO"
            }
        return None

    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        futures = []
        for port in ports_list:
            sleep_delay(delay)
            futures.append(executor.submit(scan_single_port, port))

        for future in concurrent.futures.as_completed(futures):
            res = future.result()
            if res:
                results.append(res)

    return sorted(results, key=lambda x: x['port'])
