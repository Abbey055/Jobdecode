import 'package:flutter_test/flutter_test.dart';
import 'package:jobdecode/app/jobdecode_app.dart';

void main() {
  testWidgets('JobDecode splash opens the home screen', (tester) async {
    await tester.pumpWidget(const JobDecodeApp());

    expect(find.text('Hi there'), findsOneWidget);
    expect(find.text("Let's go"), findsOneWidget);

    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle();

    expect(find.text('Paste any job link'), findsOneWidget);
    expect(find.text('Analyze Job'), findsOneWidget);
    expect(find.text('Understand any job in seconds'), findsOneWidget);
  });
}
