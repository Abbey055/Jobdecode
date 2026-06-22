import 'package:flutter_test/flutter_test.dart';
import 'package:jobdecode/app/jobdecode_app.dart';

void main() {
  testWidgets('JobDecode home screen renders', (tester) async {
    await tester.pumpWidget(const JobDecodeApp());

    expect(find.text('Paste any job link'), findsOneWidget);
    expect(find.text('Analyze Job'), findsOneWidget);
    expect(find.text('Understand any job in seconds'), findsOneWidget);
  });
}
