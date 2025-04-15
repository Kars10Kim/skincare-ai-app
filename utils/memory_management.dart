import 'dart:async';

import 'package:flutter/material.dart';

/// A mixin that helps manage disposable resources
mixin AutoDisposeMixin<T extends StatefulWidget> on State<T> {
  /// List of disposables to be disposed when the widget is disposed
  final List<Object> _disposables = [];
  
  /// Add a disposable object to be disposed when the widget is disposed
  void addDisposable(Object disposable) {
    _disposables.add(disposable);
  }
  
  /// Dispose all registered disposables
  void disposeAll() {
    for (final disposable in _disposables) {
      _disposeObject(disposable);
    }
    _disposables.clear();
  }
  
  /// Dispose a single object
  void _disposeObject(Object disposable) {
    if (disposable is StreamSubscription) {
      disposable.cancel();
    } else if (disposable is TextEditingController) {
      disposable.dispose();
    } else if (disposable is AnimationController) {
      disposable.dispose();
    } else if (disposable is ScrollController) {
      disposable.dispose();
    } else if (disposable is FocusNode) {
      disposable.dispose();
    } else if (disposable is PageController) {
      disposable.dispose();
    } else if (disposable is Timer) {
      disposable.cancel();
    } else if (disposable is Disposable) {
      disposable.dispose();
    } else {
      throw UnsupportedError(
        'Object of type ${disposable.runtimeType} is not disposable',
      );
    }
  }
  
  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }
}

/// A disposable object
abstract class Disposable {
  /// Dispose the object
  void dispose();
}

/// A dispose bag for managing multiple disposables
class DisposeBag implements Disposable {
  /// List of disposables
  final List<Object> _disposables = [];
  
  /// Add a disposable object
  void add(Object disposable) {
    _disposables.add(disposable);
  }
  
  /// Add a callback to be called when the bag is disposed
  void addCallback(VoidCallback callback) {
    _disposables.add(_CallbackDisposable(callback));
  }
  
  @override
  void dispose() {
    for (final disposable in _disposables) {
      if (disposable is StreamSubscription) {
        disposable.cancel();
      } else if (disposable is TextEditingController) {
        disposable.dispose();
      } else if (disposable is AnimationController) {
        disposable.dispose();
      } else if (disposable is ScrollController) {
        disposable.dispose();
      } else if (disposable is FocusNode) {
        disposable.dispose();
      } else if (disposable is PageController) {
        disposable.dispose();
      } else if (disposable is Timer) {
        disposable.cancel();
      } else if (disposable is Disposable) {
        disposable.dispose();
      } else {
        throw UnsupportedError(
          'Object of type ${disposable.runtimeType} is not disposable',
        );
      }
    }
    _disposables.clear();
  }
}

/// A private class that wraps a callback in a disposable
class _CallbackDisposable implements Disposable {
  /// The callback to be called when disposed
  final VoidCallback _callback;
  
  /// Create a callback disposable
  _CallbackDisposable(this._callback);
  
  @override
  void dispose() {
    _callback();
  }
}

/// Extension for StreamSubscription
extension StreamSubscriptionExt<T> on StreamSubscription<T> {
  /// Add this subscription to a dispose bag
  void addTo(DisposeBag bag) {
    bag.add(this);
  }
}

/// Extension for Disposable
extension DisposableExt on Disposable {
  /// Add this disposable to a dispose bag
  void addTo(DisposeBag bag) {
    bag.add(this);
  }
}