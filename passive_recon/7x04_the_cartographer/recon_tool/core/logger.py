#!/usr/bin/python3
"""
Traceability logger for The Cartographer.
"""
import logging


def get_logger(name="Cartographer"):
    logger = logging.getLogger(name)
    if not logger.handlers:
        logger.setLevel(logging.INFO)
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(asctime)s - [%(levelname)s] - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    return logger

def log_info(msg):
    get_logger().info(msg)

def log_error(msg):
    get_logger().error(msg)
