import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dice_3d.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class DiceState {
  int value = 1;
  double rotX = 0;
  double rotY = 0;

  double startRotX = 0;
  double startRotY = 0;
  double endRotX = 0;
  double endRotY = 0;
}

class _DiceScreenState extends State<DiceScreen>
    with SingleTickerProviderStateMixin {
  int diceCount = 2;
  bool isRolling = false;
  List<DiceState> diceStates = [];
  List<String> rollHistory = [];
  bool isPair = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _resetDice();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addListener(() {
      setState(() {
        for (var die in diceStates) {
          die.rotX = _lerp(die.startRotX, die.endRotX, _animation.value);
          die.rotY = _lerp(die.startRotY, die.endRotY, _animation.value);
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isRolling = false;
          _handleRollResult();
        });
      }
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _resetDice() {
    diceStates = List.generate(diceCount, (index) => DiceState());
  }

  (double, double) _getRotationForFace(int face) {
    switch (face) {
      case 1:
        return (0.0, 0.0);
      case 2:
        return (-math.pi / 2, 0.0);
      case 3:
        return (0.0, -math.pi / 2);
      case 4:
        return (0.0, math.pi / 2);
      case 5:
        return (math.pi / 2, 0.0);
      case 6:
        return (math.pi, 0.0);
      default:
        return (0.0, 0.0);
    }
  }

  void _roll() {
    if (isRolling) return;

    setState(() {
      isRolling = true;
      isPair = false;
    });

    final random = math.Random();

    for (var die in diceStates) {
      int newValue = random.nextInt(6) + 1;
      die.value = newValue;

      die.startRotX = die.rotX;
      die.startRotY = die.rotY;

      var (targetX, targetY) = _getRotationForFace(newValue);

      double spinsX =
          (random.nextInt(4) + 3) * 2 * math.pi * (random.nextBool() ? 1 : -1);
      double spinsY =
          (random.nextInt(4) + 3) * 2 * math.pi * (random.nextBool() ? 1 : -1);

      die.endRotX = targetX + spinsX;
      die.endRotY = targetY + spinsY;
    }

    _controller.forward(from: 0.0);
  }

  void _handleRollResult() {
    int total = diceStates.fold(0, (sum, d) => sum + d.value);
    Set<int> values = diceStates.map((d) => d.value).toSet();
    isPair = (values.length == 1 && diceStates.length > 1);

    String time =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
    String rolls = diceStates.map((d) => d.value.toString()).join(" + ");
    rollHistory.insert(0, "$time  |  $rolls = $total ${isPair ? '★' : ''}");
    if (rollHistory.length > 10) rollHistory.removeLast();

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int total = isRolling ? 0 : diceStates.fold(0, (sum, d) => sum + d.value);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.5,
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Need a dice ?",
                        style: TextStyle(color: Colors.white60, fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: DropdownButton<int>(
                        dropdownColor: Colors.black87,
                        value: diceCount,
                        items: [1, 2, 3, 4, 5]
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Row(
                                  children: [
                                    const Icon(Icons.casino,
                                        color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text("$e kości",
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
                                )))
                            .toList(),
                        onChanged: (val) {
                          if (val != null && !isRolling) {
                            setState(() {
                              diceCount = val;
                              _resetDice();
                            });
                          }
                        },
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!isRolling)
                const Text("WYNIK",
                    style: TextStyle(color: Colors.white24, fontSize: 14)),
              Text(isRolling ? "..." : "$total",
                  style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w100,
                      color: isPair ? Colors.amber : Colors.white)),
              if (isPair && !isRolling)
                const Text("! PARA !",
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 40,
                    runSpacing: 40,
                    alignment: WrapAlignment.center,
                    children: diceStates.map((die) {
                      return Dice3D(
                        size: 100,
                        rotX: die.rotX,
                        rotY: die.rotY,
                        rotZ: 0,
                        highlightColor:
                            (!isRolling && isPair) ? Colors.amber : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("HISTORIA",
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Expanded(
                            child: ListView.builder(
                              itemCount: rollHistory.length,
                              itemBuilder: (ctx, i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(rollHistory[i],
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: isRolling ? null : _roll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFE65100), Color(0xFFEF6C00)]),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2)
                            ]),
                        child: Text(isRolling ? "..." : "RZUĆ",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
