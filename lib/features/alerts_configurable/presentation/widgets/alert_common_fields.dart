import 'package:flutter/material.dart';
import 'alert_form_field.dart';
import 'alert_input_field.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class AlertCommonFields extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const AlertCommonFields({
    super.key,
    required this.dateController,
    required this.timeController,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AlertFormField(
                  label: AppLocalizations.of(context)?.t('alerts.form.date') ?? 'Date',
                child: GestureDetector(
                  key: const Key('date_field'),
                  onTap: onSelectDate,
                  child: AbsorbPointer(
                    child: AlertInputField(
                        hintText: AppLocalizations.of(context)?.t('alerts.form.date_hint') ?? 'DD/MM/YYYY',
                      controller: dateController,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AlertFormField(
                  label: AppLocalizations.of(context)?.t('alerts.form.time') ?? 'Time',
                child: GestureDetector(
                  key: const Key('time_field'),
                  onTap: onSelectTime,
                  child: AbsorbPointer(
                    child: AlertInputField(
                        hintText: AppLocalizations.of(context)?.t('alerts.form.time_hint') ?? 'HH:MM',
                      controller: timeController,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
