# Changes from upstream BatteryBoi (thebarbican19/BatteryBoi, GPL-3.0)

1. Menu bar icon: Apple-style outlined battery whose fill animates and empties
   smoothly with the charge level (green + bolt when charging, red at 20% or below).
   - Code: `AppleBatteryIcon` / `AppleBatteryContainer` in Views/Component/BBMenuView.swift
   - Menu bar item now resizes to fit the label (BatteryBoiApp.swift)
2. Pop-up notification shrunk to 72% of the original size.
   - Change `WindowManager.hudScale` in Objects/BBWindowManager.swift to adjust.
