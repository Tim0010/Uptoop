import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final StreamController<int> _wheelNotifier = StreamController<int>();
  int _spinsLeft = 2;

  final List<Map<String, dynamic>> _wheelItems = [
    {'label': '100', 'color': Colors.orange.shade300},
    {'label': '2x', 'color': Colors.deepOrange.shade400},
    {'label': '5', 'color': Colors.blue.shade700},
    {'label': '10', 'color': Colors.orange.shade700},
    {'label': '20', 'color': Colors.green.shade600},
    {'label': '50', 'color': Colors.yellow.shade700},
  ];

  void _spinWheel() {
    if (_spinsLeft > 0) {
      setState(() {
        _spinsLeft--;
      });
      _wheelNotifier.add(Fortune.randomInt(0, _wheelItems.length - 1));
    }
  }

  @override
  void dispose() {
    _wheelNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if this screen was pushed (has a route to pop) or is part of bottom nav
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.grey.shade100,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Games & Missions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.yellow.shade600, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow.shade700, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        '180',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!canPop) _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSpinWheelSection(),
                    const SizedBox(height: 24),
                    _buildComingSoonSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Games & Missions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.yellow.shade600, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow.shade700, size: 20),
                const SizedBox(width: 4),
                const Text(
                  '180',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinWheelSection() {
    return Card(
      elevation: 4,
      // ignore: deprecated_member_use
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_outline_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Daily Spin Wheel',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Spin to win cash rewards and bonuses!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: FortuneWheel(
                selected: _wheelNotifier.stream,
                animateFirst: false,
                items: [
                  for (var item in _wheelItems)
                    FortuneItem(
                      child: Text(item['label']!),
                      style: FortuneItemStyle(
                        color: item['color']!,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    ),
                ],
                indicators: const <FortuneIndicator>[
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(color: Colors.deepOrange),
                  ),
                ],
                onAnimationEnd: () {
                  // Handle reward logic here
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _spinsLeft > 0 ? _spinWheel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'SPIN ($_spinsLeft left)',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonSection() {
    return Card(
      elevation: 2,
      // ignore: deprecated_member_use
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          children: [
            Icon(Icons.card_giftcard, color: Colors.blue.shade800, size: 48),
            const SizedBox(height: 16),
            const Text(
              'More Games Coming Soon!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Trivia quizzes, scratch cards, and more ways to earn',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
