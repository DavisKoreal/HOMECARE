import 'package:flutter/material.dart';

class ModernStat extends StatelessWidget {
  final String title;
  final String value;
  final double percent;
  final Color color;
  final IconData icon;
  final Animation<double> animation;

  const ModernStat({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(
                            milliseconds:
                                1000 + (animation.value * 500).round()),
                        tween:
                            Tween(begin: 0.0, end: percent * animation.value),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: color.withOpacity(0.1),
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation(color),
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<int>(
                  duration: Duration(
                      milliseconds: 1000 + (animation.value * 500).round()),
                  tween: IntTween(begin: 0, end: int.parse(value)),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}