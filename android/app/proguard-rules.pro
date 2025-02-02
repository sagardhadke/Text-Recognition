# Keep general text recognition classes for ML Kit
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.**$* { *; }

# Keep specific language recognizer classes (Devanagari for Indian languages)
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# Exclude unnecessary language models (Chinese, Japanese, Korean)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# In case the missing warnings for Chinese/Japanese/Korean are a result of unused dependencies:
# Remove unnecessary dependencies from your build.gradle file.
