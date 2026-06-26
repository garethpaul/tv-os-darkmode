#!/usr/bin/env python3
"""Select or create a usable Apple TV simulator destination."""

import json
import re
import subprocess
import sys


DEVICE_NAME = "Apple TV 4K (3rd generation)"
CREATED_DEVICE_NAME = "tv-os-darkmode CI"


def version_key(version):
    return tuple(int(component) for component in re.findall(r"\d+", version))


def normalize_udid(value):
    if not isinstance(value, str):
        return None
    normalized = value.strip()
    return normalized or None


def require_object(value, label):
    if not isinstance(value, dict):
        raise RuntimeError(f"simctl list {label} must be an object")
    return value


def require_object_list(value, label):
    if not isinstance(value, list) or any(
        not isinstance(item, dict) for item in value
    ):
        raise RuntimeError(f"simctl list {label} must be an array of objects")
    return value


def select_destination(payload, create_device):
    if not isinstance(payload, dict):
        raise RuntimeError("simctl list response must be an object")

    runtimes = [
        runtime
        for runtime in require_object_list(payload.get("runtimes", []), "runtimes")
        if ".tvOS-" in runtime.get("identifier", "")
        and runtime.get("isAvailable", True)
    ]
    if not runtimes:
        raise RuntimeError("no available tvOS simulator runtime is installed")

    runtime = max(runtimes, key=lambda item: version_key(item.get("version", "0")))
    runtime_identifier = runtime["identifier"]
    devices_by_runtime = require_object(payload.get("devices", {}), "devices")
    devices = require_object_list(
        devices_by_runtime.get(runtime_identifier, []),
        "devices for selected runtime",
    )
    for device in devices:
        if device.get("name") == DEVICE_NAME and device.get("isAvailable", True):
            udid = normalize_udid(device.get("udid"))
            if udid is not None:
                return f"platform=tvOS Simulator,id={udid}"

    device_type = next(
        (
            item["identifier"]
            for item in require_object_list(
                payload.get("devicetypes", []),
                "devicetypes",
            )
            if item.get("name") == DEVICE_NAME
        ),
        None,
    )
    if device_type is None:
        raise RuntimeError(f"simulator device type is unavailable: {DEVICE_NAME}")

    udid = normalize_udid(
        create_device(CREATED_DEVICE_NAME, device_type, runtime_identifier)
    )
    if udid is None:
        raise RuntimeError("created simulator returned no UDID")
    return f"platform=tvOS Simulator,id={udid}"


def create_device(name, device_type, runtime):
    return subprocess.check_output(
        ["xcrun", "simctl", "create", name, device_type, runtime],
        text=True,
    ).strip()


def main():
    try:
        payload = json.loads(
            subprocess.check_output(
                ["xcrun", "simctl", "list", "--json"],
                text=True,
            )
        )
        print(select_destination(payload, create_device=create_device))
    except (json.JSONDecodeError, KeyError, OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"select_tvos_destination.py: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
