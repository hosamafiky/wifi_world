# Example App Structure

This document describes the refactored architecture of the wifi_world example app.

## 📁 Folder Structure

```
example/lib/
├── main.dart                          # App entry point
├── models/
│   └── info_row.dart                  # Data model for displaying label-value pairs
├── screens/
│   └── network_demo_page.dart         # Main demo screen with state management
├── utils/
│   └── network_ui_helpers.dart        # UI helper functions (icons, colors)
└── widgets/
    ├── connection_card.dart           # Connection status card widget
    ├── info_card.dart                 # Reusable info display card
    ├── signal_strength_indicator.dart # Signal strength progress bar widget
    ├── status_chip.dart               # Boolean status chip widget
    └── tabs/
        ├── wifi_info_tab.dart         # Wi-Fi information tab
        ├── network_info_tab.dart      # Network connectivity tab
        └── scan_tab.dart              # Network scanner tab
```

## 📄 File Descriptions

### Entry Point

#### `main.dart` (29 lines)
- App configuration and theme setup
- Navigation to main screen
- Material 3 with dark mode support

### Models

#### `models/info_row.dart` (7 lines)
- Simple data class for label-value pairs
- Used for displaying structured information

### Screens

#### `screens/network_demo_page.dart` (157 lines)
- Main demo screen with tab controller
- State management for Wi-Fi and network data
- Stream subscription setup
- API calls and error handling
- Delegates rendering to tab widgets

### Utilities

#### `utils/network_ui_helpers.dart` (20 lines)
- `getWifiIcon(quality)` - Returns appropriate Wi-Fi icon based on signal quality
- `getSignalColor(quality)` - Returns color based on signal quality
- Pure functions with no side effects

### Widgets

#### `widgets/connection_card.dart` (68 lines)
**Purpose**: Displays current connection status with visual indicators
- Color-coded background (green/orange/red)
- Connection icon
- SSID or status text
- Internet availability status

#### `widgets/info_card.dart` (66 lines)
**Purpose**: Reusable card for displaying labeled information
- Title with bold text
- List of label-value pairs
- Consistent formatting
- Used for network details, signal info, etc.

#### `widgets/signal_strength_indicator.dart` (51 lines)
**Purpose**: Visual progress bar for signal strength
- Linear progress indicator
- Dynamic color based on quality
- Large percentage display
- Card layout

#### `widgets/status_chip.dart` (47 lines)
**Purpose**: Boolean status indicator chip
- Active/inactive states
- Green (active) or grey (inactive) colors
- Check icon for active state
- Used for quick status checks

### Tab Widgets

#### `widgets/tabs/wifi_info_tab.dart` (89 lines)
**Purpose**: Displays comprehensive Wi-Fi connection details
- Connection status card
- Network details (SSID, BSSID, IP, Gateway, DNS)
- Signal information (strength, quality, speed, frequency)
- Signal strength indicator
- Pull-to-refresh support

#### `widgets/tabs/network_info_tab.dart` (75 lines)
**Purpose**: Shows general network connectivity information
- Network type and status
- Internet availability
- Metered connection detection
- Quick status chips for common checks
- Pull-to-refresh support

#### `widgets/tabs/scan_tab.dart` (119 lines)
**Purpose**: Network scanner interface
- Scan button with loading state
- List of discovered networks
- Network details (SSID, signal, security, frequency)
- Color-coded signal strength icons
- Empty state messaging
- Platform-aware (disabled on iOS)

## 🔄 Component Interactions

```
main.dart
  └─> NetworkDemoPage (screen)
       ├─> WifiInfoTab (tab)
       │    ├─> ConnectionCard (widget)
       │    ├─> InfoCard (widget)
       │    └─> SignalStrengthIndicator (widget)
       │
       ├─> NetworkInfoTab (tab)
       │    ├─> InfoCard (widget)
       │    └─> StatusChip (widget)
       │
       └─> ScanTab (tab)
            └─> NetworkUIHelpers (utils)
```

## 🎯 Design Principles

### 1. **Separation of Concerns**
- State management in screen
- UI components in widgets
- Utilities for reusable functions
- Models for data structures

### 2. **Reusability**
- `InfoCard` used in multiple tabs
- `ConnectionCard` reused across views
- Utility functions shared across components

### 3. **Single Responsibility**
- Each widget has one clear purpose
- Tab widgets only handle rendering
- Screen handles all state logic

### 4. **Composition Over Inheritance**
- Small, focused widgets
- Composed into larger interfaces
- Easy to test and modify

## 📊 Code Metrics

| Component | Lines of Code | Complexity |
|-----------|---------------|------------|
| Main Entry | 29 | Low |
| Models | 7 | Low |
| Screens | 157 | Medium |
| Utils | 20 | Low |
| Widgets (Core) | 232 | Low-Medium |
| Widgets (Tabs) | 283 | Medium |
| **Total** | **728** | **Medium** |

## 🚀 Benefits of This Structure

1. **Maintainability**: Easy to find and modify specific components
2. **Testability**: Each widget can be tested independently
3. **Reusability**: Widgets can be used in other parts of the app
4. **Scalability**: Easy to add new tabs or features
5. **Readability**: Clear file naming and organization
6. **Collaboration**: Team members can work on different components
7. **Performance**: Widgets rebuild only when needed

## 🔧 Adding New Features

### Adding a New Tab

1. Create widget in `widgets/tabs/your_tab.dart`
2. Import it in `screens/network_demo_page.dart`
3. Add tab controller count
4. Add tab to TabBar
5. Add widget to TabBarView

### Adding a New Widget

1. Create file in `widgets/your_widget.dart`
2. Define widget with clear props
3. Import where needed
4. Use composition to build UIs

### Adding Utility Functions

1. Add to existing `utils/network_ui_helpers.dart`
2. Or create new file in `utils/` for different concerns
3. Keep functions pure (no side effects)
4. Document parameters and return values
