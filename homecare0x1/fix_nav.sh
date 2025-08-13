#!/bin/bash

cont=(
  "lib/providers/care_note_provider.dart"
  "lib/providers/medication_record_provider.dart"
  "lib/providers/payment_provider.dart"
  "lib/providers/shift_assignment_provider.dart"
  "lib/providers/task_provider.dart"
  "lib/providers/user_provider.dart"
  "lib/services/auth_service.dart"
  "lib/firebase_options.dart"
  "lib/models/audit_log.dart"
  "lib/models/care_note.dart"
  "lib/models/client.dart"
  "lib/models/medication_record.dart"
  "lib/models/message.dart"
  "lib/models/payment.dart"
  "lib/models/task.dart"
  "lib/models/user.dart"
)

touch outppp.txt

for file in "${cont[@]}"; do
  echo "===== $file =====" >> outppp.txt
  cat "$file" >> outppp.txt
  echo "" >> outppp.txt
done