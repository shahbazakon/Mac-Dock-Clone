# Flutter MacOS-Style Dock Widget

A highly customizable dock widget for Flutter that mimics the iconic macOS dock behavior and animations. This widget provides smooth animations, intuitive drag-and-drop functionality, and responsive hover effects.

## Features

### 1. Dynamic Hover Animations
- Items scale up smoothly on hover (1.5x for hovered item)
- Adjacent items scale proportionally (1.3x for immediate neighbors)
- Secondary adjacent items scale slightly (1.1x for items two positions away)
- Smooth animation transitions using `TweenAnimationBuilder`

### 2. Intelligent Drag and Drop
- Visual spacing indicator shows exact drop location
- Spacing width matches item size for consistency
- Constrained drag area to prevent unwanted vertical expansion
- Semi-transparent placeholder during drag operations
- Smooth animations when items are reordered

### 3. Visual Feedback
- Item spacing adjusts dynamically during drag operations
- Visual indicators show potential drop locations
- Opacity changes for dragged items
- Smooth scaling transitions


## Basic Usage

```dart
Dock<IconData>(
  items: const [
    Icons.person,
    Icons.message,
    Icons.call,
  ],
  builder: (item) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      child: Center(child: Icon(item, color: Colors.white)),
    );
  },
)
```

## Customization

### Item Builder
The `builder` property allows complete customization of item appearance:

```dart
builder: (item) {
  return YourCustomWidget(
    // Customize as needed
  );
}
```

### Animation Timing
Adjust animation durations and curves:

```dart
const Duration hoverDuration = Duration(milliseconds: 150);
const Duration dragDuration = Duration(milliseconds: 200);
const Curve animationCurve = Curves.easeOutCubic;
```

## Implementation Details

### Hover Animation
The hover animation is implemented using a scale transform:
```dart
double _getScale(int index) {
  if (_hoveredIndex == null) return 1.0;
  final distance = (index - _hoveredIndex!).abs();
  if (distance == 0) return 1.5;      // Hovered item
  if (distance == 1) return 1.3;      // Adjacent items
  if (distance == 2) return 1.1;      // Secondary adjacent items
  return 1.0;                         // Other items
}
```

### Drag and Drop
The drag area is constrained to the dock's height using:
```dart
SizedBox(
  height: 64, // Fixed height for drag target
  child: DragTarget<T>(
    // Drag target implementation
  ),
)
```

## Tips for Best Results

1. **Item Sizing**
   - Keep items reasonably sized (recommended 48-64px)
   - Use consistent item sizes for smooth animations

2. **Performance**
   - Avoid heavy computations during animations
   - Use `const` widgets where possible
   - Consider using `RepaintBoundary` for complex items

3. **Visual Design**
   - Use appropriate padding/margin for spacing
   - Consider adding background blur effects
   - Implement subtle shadows for depth

## Known Limitations

1. Maximum scale factor is fixed at 1.5x
2. Drag preview is limited to item size
3. No bounce animations on drop (planned for future)


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
