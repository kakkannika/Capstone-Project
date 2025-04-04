package com.example.tourism_app;

import android.app.Application;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;

public class Application extends android.app.Application {
  @Override
  public void onCreate() {
    super.onCreate();
    // FlutterEngine caching is initialized in Application class
    // This is using v2 embedding
  }
} 