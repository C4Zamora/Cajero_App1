import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferirPage extends StatefulWidget {
  const TransferirPage({super.key});

  @override
  State<TransferirPage> createState() => _TransferirPageState();
}

class _TransferirPageState extends State<TransferirPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _realizarTransferencia() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final formData = _formKey.currentState!.value;
    final String cuentaDestino = formData['numeroCuenta'];
    final double? monto = double.tryParse(formData['monto']);

    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un monto válido')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uidEmisor = FirebaseAuth.instance.currentUser?.uid;
      if (uidEmisor == null) throw Exception('Usuario no autenticado');

      final refUsuarios = FirebaseFirestore.instance.collection('usuarios');
      final docEmisor = await refUsuarios.doc(uidEmisor).get();
      if (!docEmisor.exists) throw Exception('Emisor no encontrado');

      final datosEmisor = docEmisor.data()!;
      final saldoActual = (datosEmisor['saldo'] ?? 0).toDouble();

      if (monto > saldoActual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo insuficiente')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Buscar usuario receptor por número de cuenta
      final consultaReceptor = await refUsuarios
          .where('numeroCuenta', isEqualTo: cuentaDestino)
          .limit(1)
          .get();

      if (consultaReceptor.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta destino no encontrada')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final docReceptor = consultaReceptor.docs.first;
      final uidReceptor = docReceptor.id;
      final datosReceptor = docReceptor.data();
      final saldoReceptor = (datosReceptor['saldo'] ?? 0).toDouble();

      // Transacción
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final emisorRef = refUsuarios.doc(uidEmisor);
        final receptorRef = refUsuarios.doc(uidReceptor);

        // Actualizar saldos
        transaction.update(emisorRef, {'saldo': saldoActual - monto});
        transaction.update(receptorRef, {'saldo': saldoReceptor + monto});

        // Registrar transacción en ambos historiales
        final now = FieldValue.serverTimestamp();

        transaction.set(emisorRef.collection('transacciones').doc(), {
          'tipo': 'transferencia enviada',
          'monto': monto,
          'fecha': now,
          'aCuenta': cuentaDestino,
          'nombreDestino': datosReceptor['nombre'],
        });

        transaction.set(receptorRef.collection('transacciones').doc(), {
          'tipo': 'transferencia recibida',
          'monto': monto,
          'fecha': now,
          'deCuenta': datosEmisor['numeroCuenta'],
          'nombreOrigen': datosEmisor['nombre'],
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transferencia realizada con éxito')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferir dinero'),
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
                name: 'numeroCuenta',
                decoration: const InputDecoration(
                  labelText: 'Número de cuenta destino',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6),
                ]),
              ),
              const SizedBox(height: 24),
              FormBuilderTextField(
                name: 'monto',
                decoration: const InputDecoration(
                  labelText: 'Monto a transferir',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(1, errorText: 'Debe ser mayor a 0'),
                ]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _realizarTransferencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color.fromRGBO(255, 140, 0, 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isSubmitting ? 'Procesando...' : 'Transferir',
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
