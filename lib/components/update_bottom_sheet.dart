
import 'package:flutter/material.dart';

class UpdateBottomSheet extends StatefulWidget {
  bool loading;
  void Function(BuildContext, String) onPressed;
  String title;
  String initialValue;

  UpdateBottomSheet({
    Key? key,
    required this.loading,
    required this.onPressed,
    required this.title,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  final valueController = TextEditingController();

  @override
  initState() {
    super.initState();
    valueController.text = widget.initialValue;
  }

  @override
  dispose() {
    super.dispose();
    valueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ubahButton = widget.loading
        ? const SizedBox(
      key: ValueKey(1),
      height: 52.0,
      width: 52.0,
      child: CircularProgressIndicator(
        strokeWidth: 6,
      ),
    )
        : SizedBox(
      key: const ValueKey(2),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero
        ),
        child: const Text(
          'Ubah',
        ),
        onPressed: () {
          widget.onPressed(context, valueController.text);
        },
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            decoration: const InputDecoration(contentPadding: EdgeInsets.all(8)),
            minLines: 1,
            maxLines: 6,
            controller: valueController,
            autofocus: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 200), child: ubahButton),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text("Batalkan"),
          ),
        ],
      ),
    );
  }
}