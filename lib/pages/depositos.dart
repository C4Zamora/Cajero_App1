import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepositoPage extends StatefulWidget {
  const DepositoPage({super.key});

  @override
  State<DepositoPage> createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _realizarDeposito() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final monto = double.tryParse(formData['monto']);

      if (monto == null || monto <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese un monto válido')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception("Usuario no autenticado");

        final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(uid);
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) throw Exception("Usuario no encontrado");

        final saldoActual = (userSnapshot.data()?['saldo'] ?? 0).toDouble();
        final nuevoSaldo = saldoActual + monto;

        // Actualizar saldo
        await userDoc.update({'saldo': nuevoSaldo});

        // Registrar transacción en subcolección "transacciones"
        await userDoc.collection('transacciones').add({
          'tipo': 'depósito',
          'monto': monto,
          'fecha': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Depósito realizado exitosamente')),
        );

        Navigator.pop(context); // Volver a la pantalla anterior

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depósito'),
        backgroundColor:  Color.fromRGBO(255, 140, 0, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              FormBuilderTextField(
                name: 'monto',
                decoration: const InputDecoration(
                  labelText: 'Monto a depositar',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(1, errorText: 'Debe ser mayor a 0'),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _realizarDeposito,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isSubmitting ? 'Procesando...' : 'Depositar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
