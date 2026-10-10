/// The shape of the popover's arrow and corners.
enum PopoverArrowStyle {
  /// A sharp triangle and plain rounded corners.
  triangle,

  /// The shape iOS and iPadOS draw: an arrow with a rounded tip that flows
  /// into the body, and continuous corners.
  apple,

  /// [apple] on iOS, iPadOS and macOS, [triangle] everywhere else.
  adaptive,
}
