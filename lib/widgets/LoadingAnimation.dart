import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller1 = _createController();
    _controller2 = _createController();
    _controller3 = _createController();

    _animation1 = _createAnimation(_controller1);
    _animation2 = _createAnimation(_controller2);
    _animation3 = _createAnimation(_controller3);

    _startAnimations();
  }

  AnimationController _createController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  Animation<double> _createAnimation(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _controller1.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _controller3.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo negro con transparencia
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedCircle(Colors.yellow, _animation1),
                const SizedBox(width: 15),
                _buildAnimatedCircle(Colors.red, _animation2),
                const SizedBox(width: 15),
                _buildAnimatedCircle(Colors.white, _animation3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCircle(Color color, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
}