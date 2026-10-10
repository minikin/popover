/// The outline a popover is painted with, resolved from `PopoverArrowStyle`
/// and the platform.
enum PopoverShape {
  /// A sharp triangle and plain rounded corners.
  triangle,

  /// The iOS 26 popover, see `ApplePopoverPath`.
  ios,

  /// The macOS 26 popover, see `MacPopoverPath`.
  macos,
}
