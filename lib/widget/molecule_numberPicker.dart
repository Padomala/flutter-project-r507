import 'package:flutter/material.dart';

class AtomNumberPicker extends StatefulWidget {
  final int min;
  final int max;
  final int initial;
  final double width;
  final ValueChanged<int> onChanged;

  const AtomNumberPicker({
    super.key,
    required this.min,
    required this.max,
    required this.initial,
    required this.onChanged,
    this.width = 100,
  });

  @override
  State<AtomNumberPicker> createState() => _AtomNumberPickerState();
}

class _AtomNumberPickerState extends State<AtomNumberPicker> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
  }

  void _increment() {
    setState(() {
      if (value < widget.max) value++;
    });
    widget.onChanged(value);
  }

  void _decrement() {
    setState(() {
      if (value > widget.min) value--;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BOUTON -
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: _decrement,
          ),

          // VALEUR
          Text(
            "$value",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          // BOUTON +
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _increment,
          ),
        ],
      ),
    );
  }
}
