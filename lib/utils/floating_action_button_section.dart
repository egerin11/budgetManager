import 'package:flutter/material.dart';
import '../data/bg_data.dart';
import '../utils/animations.dart';

class FloatingActionButtonSection extends StatelessWidget {
  final int selectedIndex;
  final bool showOption;
  final Function(int) onSelect;
  final VoidCallback toggleShowOption;

  const FloatingActionButtonSection({
    super.key,
    required this.selectedIndex,
    required this.showOption,
    required this.onSelect,
    required this.toggleShowOption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 49,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: showOption
                ? ShowUpAnimation(
              delay: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: bgList.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16.0),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onSelect(index),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: selectedIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(bgList[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : const SizedBox(),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: toggleShowOption,
            child: showOption
                ? const Icon(
              Icons.close,
              color: Colors.white,
              size: 25,
            )
                : CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(bgList[selectedIndex]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
