import 'package:flutter/material.dart';

class LoadingBar extends StatelessWidget {
  final double progress;

  const LoadingBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 178, 173, 173),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
