import 'package:flutter/material.dart';

/// KainPH page scaffold enforcing the header + flexible scrollable content pattern.
/// Use this on pages to ensure the header is constrained and content is flexible/scrollable.
class KainPHPageScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final EdgeInsetsGeometry padding;

  const KainPHPageScaffold({
    super.key,
    required this.header,
    required this.body,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header is expected to be compact and handle its own responsiveness.
            header,
            // Flexible content area - ensures content can scroll when needed.
            Expanded(
              child: Padding(
                padding: padding,
                child: LayoutBuilder(builder: (context, constraints) {
                  // If body is already scrollable, leave it. Otherwise wrap in SingleChildScrollView.
                  // We detect common scrollable types by checking if body is a ScrollView.
                  if (body is ScrollView) {
                    return body;
                  }

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Align(alignment: Alignment.topCenter, child: body),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
