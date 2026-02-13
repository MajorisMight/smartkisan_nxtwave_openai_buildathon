import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// To access the addCrop logic

// This class will hold the icon and the action for a FAB
class FabConfiguration {
  final IconData icon;
  final void Function(BuildContext context) onPressed;
  final Color backgroundColor;
  final Icon child;

  FabConfiguration({required this.icon, required this.onPressed, required this.backgroundColor, required this.child});
}

// This provider returns a MAP that links a route path to a FAB configuration.
final fabProvider = Provider<Map<String, FabConfiguration>>((ref) {
  return {
    // Add an entry for each screen that needs a FAB
    // '/crops': FabConfiguration(
    //   icon: Icons.add,
    //   onPressed: () {
    //     // You can call your notifier logic here.
    //     // For now, we'll just print a message.
    //     // In a real app, you'd call a function to show the 'Add Crop' dialog.
    //     print('Add Crop FAB Tapped!');
    //   }, backgroundColor: null, child: null,
    // ),
    // Community screen manages its own FAB to keep UI and backend flow in one place.
    // Screens like '/home' and '/weather' are not in the map, so they won't have a FAB.
  };
});

    
