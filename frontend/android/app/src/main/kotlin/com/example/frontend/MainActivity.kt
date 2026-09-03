package com.example.frontend

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sheshield/sms"
    private val SMS_PERMISSION_REQUEST = 1001

    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "requestSmsPermission" -> {

                    if (checkSelfPermission(
                            Manifest.permission.SEND_SMS
                        ) == PackageManager.PERMISSION_GRANTED
                    ) {

                        result.success(true)

                    } else {

                        permissionResult = result

                        requestPermissions(
                            arrayOf(Manifest.permission.SEND_SMS),
                            SMS_PERMISSION_REQUEST
                        )
                    }
                }

                "sendSms" -> {

                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    if (phone == null || message == null) {

                        result.error(
                            "INVALID_ARGUMENT",
                            "Phone number or message is missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    if (checkSelfPermission(
                            Manifest.permission.SEND_SMS
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {

                        result.error(
                            "PERMISSION_DENIED",
                            "SMS permission not granted",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    sendSms(
                        phone,
                        message,
                        result
                    )
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSms(
        phone: String,
        message: String,
        result: MethodChannel.Result
    ) {

        try {

            val smsManager = SmsManager.getDefault()

            val parts = smsManager.divideMessage(message)

            if (parts.size > 1) {

                smsManager.sendMultipartTextMessage(
                    phone,
                    null,
                    parts,
                    null,
                    null
                )

            } else {

                smsManager.sendTextMessage(
                    phone,
                    null,
                    message,
                    null,
                    null
                )
            }

            result.success(true)

        } catch (e: Exception) {

            result.error(
                "SMS_FAILED",
                e.message,
                null
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {

        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (requestCode == SMS_PERMISSION_REQUEST) {

            val granted =
                grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED

            permissionResult?.success(granted)

            permissionResult = null
        }
    }
}