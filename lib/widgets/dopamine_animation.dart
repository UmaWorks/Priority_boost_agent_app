import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class DopamineAnimation extends StatefulWidget {
  final AnimationController controller;

  const DopamineAnimation({Key? key, required this.controller}) : super(key: key);

  @override
  _DopamineAnimationState createState() => _DopamineAnimationState();
}

class _DopamineAnimationState extends State<DopamineAnimation> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    widget.controller.addListener(() {
      if (widget.controller.isAnimating) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.1,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
        ),
        AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + widget.controller.value * 0.3,
              child: Icon(
                Icons.stars,
                size: 50,
                color: Colors.amber.withOpacity(widget.controller.value),
              ),
            );
          },
        ),
      ],
    );
  }
}