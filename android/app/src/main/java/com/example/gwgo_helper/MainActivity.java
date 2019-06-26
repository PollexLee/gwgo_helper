package com.example.gwgo_helper;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
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
    GwgoIntentHelper.registerWith(registry.registrarFor(GwgoIntentHelper.CHANNEL));
  }
}
