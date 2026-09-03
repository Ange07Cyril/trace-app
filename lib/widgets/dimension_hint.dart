import 'package:flutter/material.dart';
import '../state/dimension_state.dart';

class DimensionHint extends StatelessWidget {
  final DimensionState state;
  const DimensionHint({super.key, required this.state});

  String get _message {
    switch (state.activeTool) {
      case DimensionTool.linearDim:
        return state.awaitingSecondPoint
            ? 'Tap pour définir le point final'
            : 'Tap pour définir le point de départ';
      case DimensionTool.leaderLine:
        return state.awaitingSecondPoint
            ? 'Tap pour placer la flèche'
            : 'Tap pour définir l\'origine';
      case DimensionTool.guideH:
        return 'Tap pour placer un guide horizontal';
      case DimensionTool.guideV:
        return 'Tap pour placer un guide vertical';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.activeTool == DimensionTool.none) return const SizedBox.shrink();
    return Positioned(
      top: 12, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xDD1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF4A9EFF).withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              state.awaitingSecondPoint
                  ? Icons.adjust : Icons.radio_button_unchecked,
              color: const Color(0xFF4A9EFF), size: 14,
            ),
            const SizedBox(width: 8),
            Text(_message, style: const TextStyle(
                color: Color(0xFFCCCCCC), fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: state.cancelTool,
              child: const Icon(Icons.close,
                  color: Color(0xFF666666), size: 14),
            ),
          ]),
        ),
      ),
    );
  }
}