import 'package:flutter/material.dart';

class MySilverAppBar extends StatelessWidget {
  final Widget child;
  final Widget title;

  const MySilverAppBar({
    Key? key,
    required this.child,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50, // Reduced height
      collapsedHeight: 80, // Reduced collapsed height
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: title, // Use the provided title directly
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(bottom: 20.0), // Adjust padding as needed
          child: child,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16), // Adjust padding as needed
        expandedTitleScale: 1.0, // No scaling of the title
      ),
    );
  }
}
