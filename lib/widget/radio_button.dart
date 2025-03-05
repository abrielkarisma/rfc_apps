import 'package:flutter/material.dart';

class CustomRadioGroup extends StatefulWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;
  final double boxSize;
  final double borderRadius;

  const CustomRadioGroup({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    this.boxSize = 50.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  _CustomRadioGroupState createState() => _CustomRadioGroupState();
}

class _CustomRadioGroupState extends State<CustomRadioGroup> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: widget.options.map((option) {
        return Expanded(
          child: AnimatedRadioOption(
            label: option,
            selected: widget.selectedValue == option,
            onTap: () => widget.onChanged(option),
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
            animationDuration: widget.animationDuration,
            boxSize: widget.boxSize,
            borderRadius: widget.borderRadius,
          ),
        );
      }).toList(),
    );
  }
}

class AnimatedRadioOption extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;
  final double boxSize;
  final double borderRadius;

  const AnimatedRadioOption({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    this.boxSize = 50.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  _AnimatedRadioOptionState createState() => _AnimatedRadioOptionState();
}

class _AnimatedRadioOptionState extends State<AnimatedRadioOption>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor.withOpacity(0.1),
      end: widget.activeColor.withOpacity(0.2),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedRadioOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    widget.selected ? widget.activeColor : widget.inactiveColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "poppins",
                  color: widget.selected
                      ? widget.activeColor
                      : widget.inactiveColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
