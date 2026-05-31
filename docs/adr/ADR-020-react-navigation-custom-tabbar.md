# ADR-020. React Navigation 6 with Custom Tab Bar

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS handheld application requires complex navigation with 40+ screens, conditional tab visibility, and dynamic tab bar hiding based on route. The app supports store walk, replenishment, product enquiry, and didi store operations across different user roles.

**Current implementation:**
- **React Navigation v6**: `@react-navigation/native-stack` and `@react-navigation/bottom-tabs`
- **Root navigator**: Native-stack with `Login → Main (TabNavigator)` flow
- **Custom tab bar**: `CustomTabBar` component replaces default bottom-tabs tab bar
- **Conditional tab visibility**: StoreWalk tab hidden when Didi store is active (`isDidiCanShow()`)
- **Manual tab bar hiding**: Auto-hidden on 30+ specific screens via nested route name checking (hardcoded allowlist)
- **Dashboard stack**: Nested stack navigator (`DashboardStackNavigator`) with 40+ screens

## Decision

We use **React Navigation v6** with a **custom tab bar architecture**:

1. **Native-stack for root**: `Login` screen and `Main` tab container use native-stack navigator
2. **Bottom-tabs for main flow**: 4 tabs (Dashboard, StoreWalk, Product, More) with custom `CustomTabBar`
3. **Conditional visibility**: Tab items dynamically shown/hidden based on store type and user permissions
4. **Manual tab bar hiding**: Tab bar explicitly hidden on screens that require full-screen focus (scanning, picking)
5. **Nested stacks**: Dashboard uses its own stack navigator for 40+ sub-screens

## Consequences

**Positive:**
- Native-stack provides platform-native transitions and gesture handling
- Custom tab bar allows WingYip-branded styling and dynamic visibility logic
- Conditional tab visibility keeps navigation relevant to user's current store type
- Nested stacks prevent root navigator pollution with 40+ screen definitions

**Negative:**
- **Manual tab bar hiding is brittle**: Hardcoded allowlist of 25+ route names breaks when new screens are added
- **Deep nesting**: Root → Tabs → DashboardStack → Screen creates complex navigation state
- **No drawer navigator**: All navigation must fit within 4 bottom tabs (limited discoverability for less-used features)
- Conditional tab visibility logic (`isDidiCanShow()`) is scattered across components
- React Navigation v6 is not the latest (v7 available) — upgrade path requires refactoring

**Future constraints:**
- New screens must be added to tab-bar-hide allowlist if they need full-screen focus
- Drawer navigator evaluation should occur if feature count exceeds 6 primary navigation items
- Upgrade to React Navigation v7 requires explicit ADR (breaking changes in API)
- Consider `react-native-screens` native integration for performance (already enabled but verify config)

## Related ADRs

- ADR-019: Handheld state management (navigation state is separate from app state)
- ADR-011: Custom WebSocket (navigation receives real-time event notifications)
