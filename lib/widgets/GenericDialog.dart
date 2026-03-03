import 'package:flutter/material.dart';

class GenericDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final Color confirmColor;
  final Future<bool> Function()? onConfirm;

  const GenericDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.confirmColor = Colors.black,
    this.onConfirm,
  });

  @override
  State<GenericDialog> createState() => _GenericDialogState();
}

class _GenericDialogState extends State<GenericDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.content,
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(color: Colors.indigo),
                ),
            ],
          ),
        ),
      ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.onConfirm == null ? 'Cerrar' : 'Cancelar',
                    style: TextStyle(color: Colors.red[800])),
              ),
              // Solo muestra el botón si existe una función de confirmación
              if (widget.onConfirm != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.confirmColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    bool success = await widget.onConfirm!();
                    if (mounted) setState(() => _isLoading = false);
                    if (success) Navigator.pop(context);
                  },
                  child: Text(widget.confirmText,
                      style: const TextStyle(color: Colors.white)),
                ),
            ],
    );
  }
}
