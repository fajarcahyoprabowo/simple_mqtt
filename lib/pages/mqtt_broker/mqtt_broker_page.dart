import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive/hive.dart';
import 'package:simple_mqtt/core/decorations/app_field_decoration.dart';
import 'package:simple_mqtt/core/injection.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/pages/home/home_page.dart';
import 'package:simple_mqtt/widgets/snackbar_error.dart';

class MQTTBrokerPage extends StatefulWidget {
  const MQTTBrokerPage({super.key});

  @override
  State<MQTTBrokerPage> createState() => _MQTTBrokerPageState();
}

class _MQTTBrokerPageState extends State<MQTTBrokerPage> {
  final formKey = GlobalKey<FormState>();
  final urlTextField = TextEditingController();
  final portTextField = TextEditingController();
  final isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = getIt<Box>();
      urlTextField.text = box.get(HiveConfig.URL_KEY)?.toString() ?? "";
      portTextField.text = box.get(HiveConfig.PORT_KEY)?.toString() ?? "1883";
      formKey.currentState?.validate();
    });
    super.initState();
  }

  @override
  void dispose() {
    urlTextField.dispose();
    portTextField.dispose();
    super.dispose();
  }

  void onTapConnect() async {
    final cubit = context.read<MqttCubit>();
    final success = await cubit.connect(
      url: urlTextField.text.trim(),
      port: int.parse(portTextField.text.trim()),
    );
    if (!success || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MQTT Broker"),
      ),
      body: BlocListener<MqttCubit, MqttState>(
        listener: (_, state) {
          if (state is Connecting) {
            isFormValid.value = false;
          } else {
            isFormValid.value = formKey.currentState?.validate() ?? false;
          }

          if (state is Disconnected) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackbarError(
                content: Text(state.errorMessage!),
              ));
            }
          }
        },
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          onChanged: () {
            isFormValid.value = formKey.currentState?.validate() ?? false;
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              TextFormField(
                controller: urlTextField,
                decoration: const AppFieldDecoration(
                  labelText: "URL",
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: portTextField,
                keyboardType: TextInputType.number,
                decoration: const AppFieldDecoration(
                  labelText: "PORT",
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: isFormValid,
                builder: (context, isValid, child) {
                  return ElevatedButton(
                    onPressed: isValid ? onTapConnect : null,
                    child: child,
                  );
                },
                child: BlocBuilder<MqttCubit, MqttState>(
                  builder: (_, state) {
                    return Text(
                      (state is Connecting) ? "Connecting..." : "Connect",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
