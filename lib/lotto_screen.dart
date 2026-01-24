import 'dart:math';
import 'package:flutter/material.dart';

class LottoScreen extends StatefulWidget {
  const LottoScreen({super.key});

  @override
  State<LottoScreen> createState() => _LottoScreenState();
}

class _LottoScreenState extends State<LottoScreen> {
  List<int> numbers = [];
  bool isAnimating = false;

  void _generateNumbers() async {
    setState(() {
      isAnimating = true;
      numbers = [];
    });

    // Simple animation effect
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        int newNum;
        do {
          newNum = Random().nextInt(49) + 1;
        } while (numbers.contains(newNum));
        numbers.add(newNum);
      });
    }

    // Sort at the end for easier reading
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      numbers.sort();
      isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2B55),
      appBar: AppBar(
        title: const Text('Lotto Generator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: List.generate(6, (index) {
              final number = index < numbers.length ? numbers[index] : null;
              return _buildLottoBall(number, index);
            }),
          ),
          const SizedBox(height: 60),
          ElevatedButton.icon(
            onPressed: isAnimating ? null : _generateNumbers,
            icon: const Icon(Icons.casino),
            label: const Text(
              'LOSUJ LICZBY',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: Colors.amber, // Classic Lotto yellow-ish
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottoBall(int? number, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Colors.yellowAccent,
            Colors.orange,
          ],
          center: Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(5, 5),
          )
        ],
      ),
      child: Center(
        child: number != null
            ? Text(
                '$number',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            : const Icon(Icons.question_mark, color: Colors.black26, size: 30),
      ),
    );
  }
}
