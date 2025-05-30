import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onWithdraw;
  final VoidCallback onDeposit;

  const QuickActions({
    Key? key,
    required this.onWithdraw,
    required this.onDeposit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: onWithdraw,
          icon: Icon(Icons.money_off),
          label: Text("Retirar"),
        ),
        ElevatedButton.icon(
          onPressed: onDeposit,
          icon: Icon(Icons.attach_money),
          label: Text("Consignar"),
        ),
      ],
    );
  }
}
