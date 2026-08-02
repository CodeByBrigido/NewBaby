# O Flutter e os plugins deste projeto já trazem as próprias regras via
# consumerProguardFiles. Este arquivo existe para o que é específico daqui.

# O googleapis monta os modelos a partir de JSON por reflexão de nomes;
# manter as classes de modelo evita NoSuchMethodError só no release.
-keep class com.google.api.** { *; }
-dontwarn com.google.api.**

# Anotações usadas pelo Firebase e pelo Play Services.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
