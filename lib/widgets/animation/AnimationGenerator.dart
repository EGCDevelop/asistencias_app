import 'package:flutter/material.dart';

class AnimationGenerator extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final Widget child;
  final bool isLeft;
  const AnimationGenerator({
    required this.duration,
    required this.delay,
    required this.child,
    required this.isLeft,
    super.key
  });

  @override
  State<AnimationGenerator> createState() => _AnimationGeneratorState();
}

class _AnimationGeneratorState extends State<AnimationGenerator> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation <Offset> _animation;

  @override
  void initState(){
    super.initState();

    _animationController = AnimationController(
        vsync: this,
        duration:  widget.duration
    );

    _animation = Tween<Offset>(
      begin: widget.isLeft ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, (){
      _animationController.forward();
    });

  }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}