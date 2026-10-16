> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS Index](https://github.com/Explore-In-HMOS/hmos-index).

# How to Parse GPX File For Third Party Map API

This codelab covers two different features for developers. The first is obtaining the necessary data to create a route by handling location data in GPX format on smartwatches. The second demonstrates the usability of a map structure other than MapKit by calling a third-party Map API that takes these as a data source.

# Preview

<div>
  <img src="screenshots/1.png" width="25%" />
  <img src="screenshots/2.png" width="25%" />
  <img src="screenshots/3.png" width="25%" />
</div>

# Use Cases
- Learn how to parse GPX data 
- How can a third-party map API be run
- How are the obtained GPX data sent to the map

# Technology

## Stack
- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS SDK 6.0.0(20)
- **Tools**: DevEco Studio Version 6.0.0
- **Libraries**:
    - `@kit.ArkUI`
    - `@kit.ArkTS`
    - `@kit.AbilityKit`
    - `@kit.BasicServicesKit`
    - `@kit.PerformanceAnalysisKit`
    - `@ohos.net.http`
    - `@ohos.web.webview`

## Required Permissions
- ohos.permission.INTERNET

# Directory Structure

```
entry/
├── src/main/ets/
│ │
│ ├── entryability/
│ │ └── EntryAbility.ets
│ │
│ ├── entrybackupability/
│ │ └── EntryBackupAbility.ets
│ │
│ ├── component/
│ │ └── RouteCard.ets
│ │ 
│ ├── model/
│ │ └── RouteModels.ets
│ │
│ ├── pages/
│ │ ├── Index.ets
│ │ ├── MapPage.ets
│ │ └── RouteListPage.ets
│ │
│ ├── util/
│ │ └── GpxParser.ets
```

# Constraints and Restrictions

The app parses GPX files based on its current data requirements.
Parsing behavior may be updated as the app evolves.
The GPX data format required for the current version is as follows:

```
<metadata>
  <name></name>
  <desc></desc>
</metadata>
<trk>
  <trkseg>
    <trkpt lat='...' lon='...'> </trkpt>
    ...
  </trkseg>
</trk>
```

## Supported Devices

* Huawei Watch 5

* Huawei Ultimate 2

* DevEco Studio Emulator

# License (MIT)

**How to Parse GPX File For Third Party Map API** is distributed under the terms of the MIT License. See the [LICENSE](LICENSE) for more information