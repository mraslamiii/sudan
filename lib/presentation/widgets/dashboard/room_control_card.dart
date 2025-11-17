import 'package:flutter/material.dart';

class RoomControlCard extends StatefulWidget {
  final String roomName;
  final IconData icon;

  const RoomControlCard({
    super.key,
    required this.roomName,
    required this.icon,
  });

  @override
  State<RoomControlCard> createState() => _RoomControlCardState();
}

class _RoomControlCardState extends State<RoomControlCard> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isOn
                      ? const Color(0xFF00FF88).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: _isOn ? const Color(0xFF00FF88) : Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.roomName,
                style: const TextStyle(
                  fontFamily: 'IRANYekan',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Switch(
            value: _isOn,
            onChanged: (value) {
              setState(() {
                _isOn = value;
              });
            },
            activeColor: const Color(0xFF00FF88),
          ),
        ],
      ),
    );
  }
}
