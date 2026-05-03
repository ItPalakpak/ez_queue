import 'dart:async';
import 'package:flutter/material.dart';

class AutoLoopCarousel extends StatefulWidget {
  final List<Widget> items;
  final Duration interval;
  final double height;

  const AutoLoopCarousel({
    super.key,
    required this.items,
    this.interval = const Duration(seconds: 5),
    this.height = 200,
  });

  @override
  State<AutoLoopCarousel> createState() => _AutoLoopCarouselState();
}

class _AutoLoopCarouselState extends State<AutoLoopCarousel> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start at a high number so user can swipe backwards without hitting 0 immediately
    _pageController = PageController(initialPage: widget.items.isEmpty ? 0 : widget.items.length * 1000);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (widget.items.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteraction() {
    // Restart the timer when the user manually swipes
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AutoLoopCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.items.length == 1) {
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: widget.items.first,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: GestureDetector(
        onPanDown: (_) => _timer?.cancel(),
        onPanEnd: (_) => _onUserInteraction(),
        onPanCancel: () => _onUserInteraction(),
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            final itemIndex = index % widget.items.length;
            return Padding(
              // Allow some breathing room horizontally if they want to peek, though viewport is 1.0 by default
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: widget.items[itemIndex],
            );
          },
        ),
      ),
    );
  }
}
