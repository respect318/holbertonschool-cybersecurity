# PySniffer 🕵️‍♂️
![Python](https://img.shields.io/badge/Python-3.8%2B-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Status](https://img.shields.io/badge/Status-Complete-success)

## Description
**PySniffer** is a professional, high-performance network traffic analysis tool built in Python using Scapy. It allows users to capture packets in real-time, apply Berkeley Packet Filters (BPF), perform Deep Packet Inspection (DPI) to search for specific payload strings, and save captures to a PCAP file for further analysis. 

Built with scalability in mind, PySniffer utilizes a decoupled, multithreaded architecture to ensure zero packet drops during high-volume traffic monitoring.

## Features
* **Live Packet Sniffing**: Capture TCP, UDP, ICMP, and IP traffic dynamically.
* **Deep Packet Inspection**: Search for specific strings within packet payloads.
* **BPF Filtering**: Apply standard network filters (e.g., `tcp port 80`).
* **PCAP Export**: Save packet streams seamlessly for analysis in tools like Wireshark.
* **Live Statistics**: Auto-generates a capture summary table upon termination.

## Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/holbertonschool-cybersecurity/python_for_cyber.git](https://github.com/holbertonschool-cybersecurity/python_for_cyber.git)
   cd python_for_cyber/4x04_network_sniffer
