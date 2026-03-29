@tool
extends EditorPlugin

const PLUGIN_NAME = "PixelLakeGodotPlugin"

var _export_plugin: AndroidExportPlugin

func _enter_tree() -> void:
	_register_project_settings()
	_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(_export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null

func _register_project_settings() -> void:
	_add_setting("pixellake/admob/app_id_android", TYPE_STRING, "", PROPERTY_HINT_NONE, "AdMob App ID for Android")
	_add_setting("pixellake/admob/app_id_ios", TYPE_STRING, "", PROPERTY_HINT_NONE, "AdMob App ID for iOS")
	_add_setting("pixellake/billing/google_play_public_key", TYPE_STRING, "", PROPERTY_HINT_NONE, "Google Play Billing RSA Public Key (Base64)")

func _add_setting(name: String, type: int, default_value, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default_value)
	ProjectSettings.set_initial_value(name, default_value)
	ProjectSettings.add_property_info({
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	})


class AndroidExportPlugin extends EditorExportPlugin:
	const PLUGIN_NAME = "PixelLakeGodotPlugin"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["res://addons/PixelLakeGodotPlugin/bin/debug/PixelLakeGodotPlugin-debug.aar"])
		else:
			return PackedStringArray(["res://addons/PixelLakeGodotPlugin/bin/release/PixelLakeGodotPlugin-release.aar"])

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"com.unity3d.ads-mediation:mediation-sdk:9.2.0",
			"com.unity3d.ads-mediation:unityads-adapter:5.3.0",
			"com.unity3d.ads:unity-ads:4.16.4",
			"com.unity3d.ads-mediation:admob-adapter:5.3.0",
			"com.google.android.gms:play-services-ads:24.8.0",
			"com.android.billingclient:billing-ktx:7.1.1",
			"com.google.android.play:review-ktx:2.0.1",
			"com.google.android.gms:play-services-games-v2:21.0.0",
			"org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3",
			"com.google.code.gson:gson:2.10.1"
		])

	func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"https://android-sdk.is.com/"
		])

	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		var contents := ""

		# AdMob requires the App ID in the manifest
		var admob_app_id := ProjectSettings.get_setting("pixellake/admob/app_id_android", "") as String
		if not admob_app_id.is_empty():
			contents += '<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="%s"/>' % admob_app_id

		# Google Play Billing public key for purchase verification
		var billing_key := ProjectSettings.get_setting("pixellake/billing/google_play_public_key", "") as String
		if not billing_key.is_empty():
			contents += '<meta-data android:name="com.pixellake.billing.PUBLIC_KEY" android:value="%s"/>' % billing_key

		return contents

	func _get_name() -> String:
		return PLUGIN_NAME
