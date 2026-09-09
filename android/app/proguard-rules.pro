# Regles ProGuard/R8 pour l'application CLOSET.
# Requis depuis AGP 9 : la minification release est active par defaut.

# Flutter engine et plugins : conserves car resolus par reflexion au runtime.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Conserve les noms de fichiers et numeros de ligne pour des stack traces lisibles.
-keepattributes SourceFile,LineNumberTable
