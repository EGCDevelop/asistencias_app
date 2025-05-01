import 'package:flutter/material.dart';

  class FadeInUp extends StatefulWidget {
    final Duration duration;
    final Duration delay;
    final Widget child;

    const FadeInUp({
      required this.duration,
      required this.delay,
      required this.child,
      super.key
    });

    @override
    State<FadeInUp> createState() => _FadeInUpState();
  }

  class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin{

    late AnimationController _controller;
    late Animation<Offset> _animation;

    @override
    void initState(){
      super.initState();

      _controller = AnimationController(
          vsync: this,
          duration: widget.duration
      );

      _animation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut
      ));

      Future.delayed(widget.delay, () {
        _controller.forward();
      });

    }

    @override
    Widget build(BuildContext context) {
      return SlideTransition(
        position: _animation,
        child: widget.child,
      );
    }
  }