package com.example.gwgo_helper;

import android.content.Intent;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  GwgoIntentHelper helper;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    registerCustomPlugin(this);
  }

  /**
   * 注册插件
   * @param registry
   */
  private void registerCustomPlugin(PluginRegistry registry){
    helper = GwgoIntentHelper.registerWith(registry.registrarFor(GwgoIntentHelper.CHANNEL));
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    helper.onActivityResult(requestCode, resultCode, data);
    super.onActivityResult(requestCode, resultCode, data);
  }
}
