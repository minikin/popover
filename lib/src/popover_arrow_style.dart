/// The shape of the popover's arrow and corners.
enum PopoverArrowStyle {
  /// A sharp triangle and plain rounded corners.
  triangle,

  /// The native shape: an arrow with a rounded tip that flows into the body,
  /// and continuous corners. macOS gets the `NSPopover` outline, every other
  /// platform the iOS one.
  apple,

  /// [apple] on iOS, iPadOS and macOS, [triangle] everywhere else.
  adaptive,
}
