import 'dart:async';

import 'package:flutter/material.dart';

/// A mixin that automatically disposes registered disposable resources
mixin AutoDisposeMixin<T extends StatefulWidget> on State<T> {
  /// List of timers to dispose
  final List<Timer> _timers = [];
  
  /// List of stream subscriptions to dispose
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  
  /// List of animation controllers to dispose
  final List<AnimationController> _animationControllers = [];
  
  /// List of change notifiers to dispose
  final List<ChangeNotifier> _changeNotifiers = [];
  
  /// List of focus nodes to dispose
  final List<FocusNode> _focusNodes = [];

  /// Register a timer for auto-disposal
  Timer registerTimer(Timer timer) {
    _timers.add(timer);
    return timer;
  }
  
  /// Register a stream subscription for auto-disposal
  StreamSubscription<T> registerSubscription<T>(StreamSubscription<T> subscription) {
    _subscriptions.add(subscription);
    return subscription;
  }
  
  /// Register an animation controller for auto-disposal
  AnimationController registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
    return controller;
  }
  
  /// Register a change notifier for auto-disposal
  ChangeNotifier registerChangeNotifier(ChangeNotifier notifier) {
    _changeNotifiers.add(notifier);
    return notifier;
  }
  
  /// Register a focus node for auto-disposal
  FocusNode registerFocusNode(FocusNode focusNode) {
    _focusNodes.add(focusNode);
    return focusNode;
  }
  
  /// Create and register a timer for auto-disposal
  Timer createTimer(Duration duration, void Function() callback) {
    final timer = Timer(duration, callback);
    return registerTimer(timer);
  }
  
  /// Create and register a periodic timer for auto-disposal
  Timer createPeriodicTimer(Duration duration, void Function(Timer) callback) {
    final timer = Timer.periodic(duration, callback);
    return registerTimer(timer);
  }
  
  /// Create and register an animation controller for auto-disposal
  AnimationController createAnimationController({
    required TickerProvider vsync,
    Duration? duration,
    Duration? reverseDuration,
    double? value,
    double? lowerBound,
    double? upperBound,
    AnimationBehavior? animationBehavior,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      value: value,
      lowerBound: lowerBound ?? 0.0,
      upperBound: upperBound ?? 1.0,
      animationBehavior: animationBehavior ?? AnimationBehavior.normal,
    );
    
    return registerAnimationController(controller);
  }
  
  /// Create and register a focus node for auto-disposal
  FocusNode createFocusNode() {
    final focusNode = FocusNode();
    return registerFocusNode(focusNode);
  }
  
  @override
  void dispose() {
    // Dispose all registered resources
    for (final timer in _timers) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    
    for (final notifier in _changeNotifiers) {
      notifier.dispose();
    }
    
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    
    // Clear all lists
    _timers.clear();
    _subscriptions.clear();
    _animationControllers.clear();
    _changeNotifiers.clear();
    _focusNodes.clear();
    
    super.dispose();
  }
}