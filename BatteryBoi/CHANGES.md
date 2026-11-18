3. Auto-updates from upstream are disabled, so the original app can't overwrite this build.
4. `.github/workflows/build.yml` builds the app on GitHub (Actions tab → latest run → download "BatteryBoi").
5. Battery-life optimisations:
   - Battery level/charging state is pushed by macOS (IOPSNotificationCreateRunLoopSource) instead of polled every second; 60s fallback.
   - Time remaining read from IOKit instead of launching `pmset` every 6s; only publishes when the value changes.
   - Low Power Mode read via ProcessInfo (and its change notification) instead of `pmset` every 60s.
   - `system_profiler` power details every 30 min (was 60s).
   - Bluetooth device scans every 2 min / 10 min (was both every 15s).
   - App tick timer has 0.5s tolerance so macOS can coalesce wake-ups.
   - Removed the endless charging pulse animation in the menu bar.
