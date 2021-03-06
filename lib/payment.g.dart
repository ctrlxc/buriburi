// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return Payment(
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
    json['money'] as int?,
    json['memo'] as String?,
  );
}

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'money': instance.money,
      'memo': instance.memo,
    };
