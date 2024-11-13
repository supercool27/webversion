import 'package:flutter/material.dart';

/// The entry point of the application.
void main() {
  runApp(const MyApp());
}

/// A stateless widget that represents the main app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isHovered) {
              // Builds a container with an icon for the dock item.
              final scale = isHovered ? 1.5 : 1.0; // Scale up when hovered.
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: scale),
                duration: const Duration(milliseconds: 300),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 48,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.primaries[
                            icon.hashCode % Colors.primaries.length],
                      ),
                      child: Center(
                        child: Icon(icon, color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A widget that displays a dock with draggable items.
class Dock<T extends Object> extends StatefulWidget {
  /// Creates a new instance of the [Dock] widget.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// A list of items to display in the dock.
  final List<T> items;

  /// A builder function that defines how each item will be displayed in the dock.
  final Widget Function(T, bool) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state for the [Dock] widget, responsible for handling drag-and-drop interactions.
class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList(); // List of items to display in the dock.
  T? _draggedItem; // The item that is currently being dragged.

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildDraggableItem(item, index);
        }).toList(),
      ),
    );
  }

  /// Builds a draggable item in the dock.
  ///
  /// This method creates a draggable widget for each item in the dock. 
  /// It includes the visual representation of the item and handles 
  /// the drag-and-drop logic.
  Widget _buildDraggableItem(T item, int index) {
    return Draggable<T>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: widget.builder(item, true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: widget.builder(item, false),
      ),
      onDragStarted: () {
        setState(() {
          _draggedItem = item;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _draggedItem = null;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggedItem = null;
        });
      },
      child: DragTarget<T>(
        onWillAccept: (draggedItem) {
          return draggedItem != null && draggedItem != item;
        },
        onAccept: (receivedItem) {
          setState(() {
            final draggedIndex = _items.indexOf(receivedItem);
            _items.removeAt(draggedIndex);
            _items.insert(index, receivedItem);
            _draggedItem = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: AnimatedContainer(
              key: ValueKey(item),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(8),
              child: widget.builder(item, candidateData.isNotEmpty),
            ),
          );
        },
      ),
    );
  }
}
