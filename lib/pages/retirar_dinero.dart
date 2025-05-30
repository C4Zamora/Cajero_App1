import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RetirosPage extends StatefulWidget {
  const RetirosPage({super.key});

  @override
  State<RetirosPage> createState() => _RetirosPageState();
}

class _RetirosPageState extends State<RetirosPage> {
  final TextEditingController montoController = TextEditingController();
  double saldo = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarSaldo();
  }

  Future<void> cargarSaldo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          saldo = doc['saldo']?.toDouble() ?? 0.0;
          loading = false;
        });
      }
    }
  }

  Future<void> retirarDinero(double monto) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    double saldoActual = snapshot['saldo']?.toDouble() ?? 0.0;

    if (monto > saldoActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente')),
      );
      return;
    }

    double nuevoSaldo = saldoActual - monto;

    await docRef.update({'saldo': nuevoSaldo});

    await docRef.collection('transacciones').add({
      'tipo': 'retiro',
      'monto': monto,
      'fecha': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Has retirado \$${monto.toStringAsFixed(2)}')),
    );

    setState(() {
      saldo = nuevoSaldo;
    });
  }

  void seleccionarMonto(double monto) {
    setState(() => montoController.text = monto.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirar Dinero'),
        backgroundColor:  Color.fromRGBO(255, 140, 0, 1),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo disponible'),
                          Text('\$${saldo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: montoController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Monto a retirar',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Seleccione una cantidad:'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var cantidad in [10000, 20000, 50000, 100000, 150000, 200000])
                                SizedBox(
                                  width: 100,
                                  child: OutlinedButton(
                                    onPressed: () => seleccionarMonto(cantidad.toDouble()),
                                    child: Text('\$${cantidad.toString()}'),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:  Color.fromRGBO(255, 140, 0, 1),
                                padding: const EdgeInsets.all(16),
                              ),
                              onPressed: () {
                                double monto =
                                    double.tryParse(montoController.text) ?? 0.0;
                                if (monto > 0) {
                                  retirarDinero(monto);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Ingrese un monto válido')),
                                  );
                                }
                              },
                              child: const Text('Continuar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                          'Los retiros están sujetos a un límite diario. Para cambiar sus límites, contacte a servicio al cliente o visite su sucursal más cercana.'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
