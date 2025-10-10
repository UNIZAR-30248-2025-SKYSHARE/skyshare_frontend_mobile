import 'package:flutter/material.dart';

class PhaseLunarMoreInfo extends StatelessWidget {
  final double distance = 384.400 ;
  final String description;

  const PhaseLunarMoreInfo({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('More info'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mock details:\n- Distance: $distance\n- Phase description: $description',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
