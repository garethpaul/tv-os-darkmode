import unittest

from scripts.select_tvos_destination import select_destination


class SelectTVOSDestinationTests(unittest.TestCase):
    def test_uses_matching_device_from_newest_available_runtime(self):
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.tvOS-18-5": [
                    {
                        "name": "Apple TV 4K (3rd generation)",
                        "udid": "OLDER",
                        "isAvailable": True,
                    }
                ],
                "com.apple.CoreSimulator.SimRuntime.tvOS-26-0": [
                    {
                        "name": "Apple TV 4K (3rd generation)",
                        "udid": "NEWER",
                        "isAvailable": True,
                    }
                ],
            },
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                },
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-26-0",
                    "version": "26.0",
                    "isAvailable": True,
                },
            ],
            "devicetypes": [],
        }

        destination = select_destination(payload, create_device=lambda *_: self.fail())

        self.assertEqual(destination, "platform=tvOS Simulator,id=NEWER")

    def test_creates_matching_device_when_runtime_has_no_device(self):
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.tvOS-18-5": [],
            },
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                }
            ],
            "devicetypes": [
                {
                    "name": "Apple TV 4K (3rd generation)",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
                }
            ],
        }
        calls = []

        destination = select_destination(
            payload,
            create_device=lambda name, device_type, runtime: calls.append(
                (name, device_type, runtime)
            )
            or "CREATED",
        )

        self.assertEqual(destination, "platform=tvOS Simulator,id=CREATED")
        self.assertEqual(
            calls,
            [
                (
                    "tv-os-darkmode CI",
                    "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
                    "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                )
            ],
        )

    def test_ignores_matching_device_with_blank_udid_and_creates_replacement(self):
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.tvOS-18-5": [
                    {
                        "name": "Apple TV 4K (3rd generation)",
                        "udid": "  ",
                        "isAvailable": True,
                    }
                ],
            },
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                }
            ],
            "devicetypes": [
                {
                    "name": "Apple TV 4K (3rd generation)",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
                }
            ],
        }

        destination = select_destination(
            payload,
            create_device=lambda *_: "REPLACEMENT",
        )

        self.assertEqual(destination, "platform=tvOS Simulator,id=REPLACEMENT")

    def test_ignores_matching_device_with_non_string_udid(self):
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.tvOS-18-5": [
                    {
                        "name": "Apple TV 4K (3rd generation)",
                        "udid": 123,
                        "isAvailable": True,
                    }
                ],
            },
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                }
            ],
            "devicetypes": [
                {
                    "name": "Apple TV 4K (3rd generation)",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
                }
            ],
        }

        destination = select_destination(
            payload,
            create_device=lambda *_: "REPLACEMENT",
        )

        self.assertEqual(destination, "platform=tvOS Simulator,id=REPLACEMENT")

    def test_rejects_invalid_created_device_udid(self):
        payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.tvOS-18-5": [],
            },
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.tvOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                }
            ],
            "devicetypes": [
                {
                    "name": "Apple TV 4K (3rd generation)",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-3rd-generation-4K",
                }
            ],
        }

        for invalid_udid in (" \n", 123):
            with self.subTest(invalid_udid=invalid_udid):
                with self.assertRaisesRegex(RuntimeError, "created simulator returned no UDID"):
                    select_destination(payload, create_device=lambda *_: invalid_udid)

    def test_rejects_missing_available_tvos_runtime(self):
        payload = {
            "devices": {},
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-18-5",
                    "version": "18.5",
                    "isAvailable": True,
                }
            ],
            "devicetypes": [],
        }

        with self.assertRaisesRegex(RuntimeError, "available tvOS simulator runtime"):
            select_destination(payload, create_device=lambda *_: self.fail())


if __name__ == "__main__":
    unittest.main()
