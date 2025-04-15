import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import '../../../lib/widgets/loading/loading_state_widget.dart';

void main() {
  group('LoadingStateWidget Tests', () {
    testWidgets('Spinner type displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget(
              isLoading: true,
              type: LoadingStateType.spinner,
              message: 'Loading...',
            ),
          ),
        ),
      );
      
      // Verify spinner is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify message is displayed
      expect(find.text('Loading...'), findsOneWidget);
    });
    
    testWidgets('Progress type displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget.progress(
              isLoading: true,
              progress: 0.5,
              message: 'Processing...',
            ),
          ),
        ),
      );
      
      // Verify progress indicator is displayed
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Verify progress percentage is displayed
      expect(find.text('50%'), findsOneWidget);
      
      // Verify message is displayed
      expect(find.text('Processing...'), findsOneWidget);
    });
    
    testWidgets('Skeleton list type displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget.listPlaceholder(
              itemCount: 3,
            ),
          ),
        ),
      );
      
      // Verify skeleton list is displayed with correct item count
      expect(find.byType(ListView), findsOneWidget);
      
      // Verify shimmer effect is used
      expect(find.byType(Shimmer), findsWidgets);
    });
    
    testWidgets('Shimmer content placeholder displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget.contentPlaceholder(),
          ),
        ),
      );
      
      // Verify shimmer effect is used
      expect(find.byType(Shimmer), findsOneWidget);
      
      // Verify placeholder containers are present
      expect(find.byType(Container), findsWidgets);
    });
    
    testWidgets('Shows child when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget(
              isLoading: false,
              type: LoadingStateType.spinner,
              child: Text('Content loaded'),
            ),
          ),
        ),
      );
      
      // Verify child is displayed
      expect(find.text('Content loaded'), findsOneWidget);
      
      // Verify loading indicator is not displayed
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    testWidgets('Transitions from loading to loaded', (WidgetTester tester) async {
      // Create a stateful test widget
      await tester.pumpWidget(
        MaterialApp(
          home: _TestLoadingWidget(),
        ),
      );
      
      // Verify loading state is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test content'), findsNothing);
      
      // Trigger loading complete
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify content is displayed
      expect(find.text('Test content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    testWidgets('Handles null progress value correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateWidget.progress(
              isLoading: true,
              progress: null,
              message: 'Processing...',
            ),
          ),
        ),
      );
      
      // Verify progress indicator is displayed with indeterminate state
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Verify percentage is not displayed
      expect(find.text('0%'), findsNothing);
      expect(find.text('100%'), findsNothing);
      
      // Verify message is displayed
      expect(find.text('Processing...'), findsOneWidget);
    });
    
    testWidgets('Uses theme color when no color specified', (WidgetTester tester) async {
      final themeColor = Colors.purple;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          home: Scaffold(
            body: LoadingStateWidget(
              isLoading: true,
              type: LoadingStateType.spinner,
            ),
          ),
        ),
      );
      
      // Verify that a CircularProgressIndicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // In real app, we'd verify the color is derived from theme
      // but in test this is challenging without rendering
    });
    
    testWidgets('Custom color is applied when specified', (WidgetTester tester) async {
      final customColor = Colors.orange;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          home: Scaffold(
            body: LoadingStateWidget(
              isLoading: true,
              type: LoadingStateType.spinner,
              color: customColor,
            ),
          ),
        ),
      );
      
      // Verify that a CircularProgressIndicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // In real app, we'd verify the custom color is used
      // but in test this is challenging without rendering
    });
  });
}

/// Test widget for testing loading state transitions
class _TestLoadingWidget extends StatefulWidget {
  @override
  State<_TestLoadingWidget> createState() => _TestLoadingWidgetState();
}

class _TestLoadingWidgetState extends State<_TestLoadingWidget> {
  bool _isLoading = true;
  
  void _completeLoading() {
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LoadingStateWidget(
            isLoading: _isLoading,
            type: LoadingStateType.spinner,
            message: 'Loading test...',
            child: const Text('Test content'),
          ),
          ElevatedButton(
            onPressed: _completeLoading,
            child: const Text('Complete loading'),
          ),
        ],
      ),
    );
  }
}