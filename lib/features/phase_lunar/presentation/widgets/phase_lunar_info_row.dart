import 'package:flutter/material.dart';

class PhaseLunarInfoRow extends StatelessWidget {
  final String rise;
  final String set;
  final String illumination;

  const PhaseLunarInfoRow({Key? key, required this.rise, required this.set, required this.illumination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Icon(Icons.nights_stay, size: 20),
              const SizedBox(height: 6),
              Text('Rise\n$rise', textAlign: TextAlign.center),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.wb_twighlight, size: 20),
              const SizedBox(height: 6),
              Text('Set\n$set', textAlign: TextAlign.center),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.light_mode, size: 20),
              const SizedBox(height: 6),
              Text('Illum.\n$illumination', textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}
