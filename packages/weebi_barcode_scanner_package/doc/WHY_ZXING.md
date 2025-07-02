ZXING

Supports most standard barcode formats, including:
UPC/EAN extensions
MaxiCode
RSS/DataBar symbologies
Industrial formats like ITF, Code 93, etc.

## Google ML Kit

Still lacks support for:
UPC/EAN extensions
MaxiCode
RSS/DataBar formats1

***

ML Kit SDK does collect metadata for diagnostics and usage analytics

It tracks usage patterns (e.g., how often barcode detection is triggered)
Logs device and app metadata
May associate this with a per-installation ID
This is a concern in regulated environments (e.g., healthcare, defense, enterprise) where any telemetry is considered a risk—even if anonymized.

📦 Collected Data Includes :
- Device Information:
    - Manufacturer, model, OS version, build
    - Available ML hardware accelerators

- Application Information:
    - Package name
    - App version
    - Identifiers:
    - Per-installation identifiers (not tied to a user or physical device)
    - Used for diagnostics and analytics

- Performance Metrics:
    - Latency
    - Input/output size
    - API configuration (e.g., image format, resolution)

- Event Types:
    - Feature initializations
    - Model downloads
    - Detection events
    - Resource releases