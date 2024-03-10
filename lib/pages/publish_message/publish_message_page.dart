import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:simple_mqtt/core/decorations/app_field_decoration.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';
import 'package:simple_mqtt/widgets/appbar_with_status.dart';
import 'package:simple_mqtt/widgets/snackbar_error.dart';

class PublishMessagePage extends StatefulWidget {
  const PublishMessagePage({super.key});

  @override
  State<PublishMessagePage> createState() => _PublishMessagePageState();
}

class _PublishMessagePageState extends State<PublishMessagePage> {
  final formKey = GlobalKey<FormState>();
  final topicTextField = TextEditingController();
  final messageTextField = TextEditingController();
  final isFormValid = ValueNotifier<bool>(false);

  @override
  void dispose() {
    topicTextField.dispose();
    messageTextField.dispose();
    super.dispose();
  }

  void onPublishTap() {
    final cubit = context.read<MqttCubit>();
    final isSuccess = cubit.publishMessage(
      topic: topicTextField.text.trim(),
      message: messageTextField.text.trim(),
    );
    if (!isSuccess) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithStatus(titleText: 'Publish Message'),
      body: BlocListener<MqttCubit, MqttState>(
        listener: (_, state) {
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
          onChanged: () {
            isFormValid.value = formKey.currentState?.validate() ?? false;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: topicTextField,
                decoration: const AppFieldDecoration(labelText: "Topic"),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageTextField,
                minLines: 3,
                maxLines: 5,
                decoration: const AppFieldDecoration(
                  labelText: "Message",
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: isFormValid,
                builder: (_, isValid, child) {
                  return ElevatedButton(
                    onPressed: isValid ? onPublishTap : null,
                    child: child,
                  );
                },
                child: const Text("Publish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
