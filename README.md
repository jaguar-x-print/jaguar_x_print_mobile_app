# 🐆 Jaguar x-Print

Application Flutter complète de gestion clients, entretiens, paiements et synchronisation cloud.  
📱 Fonctionne avec authentification Google, notifications programmées, sauvegarde/restauration Google Drive, PDF et bien plus.

---

## 🚀 Fonctionnalités principales

- 🔐 Authentification Google (OAuth 2.0)
- ☁️ Sauvegarde & restauration Google Drive
- 🔔 Notifications programmées sur rappels de paiement
- 📄 Génération et partage de PDF pour les rapports d'entretien
- 🧾 Gestion des fiches client, entretiens, paiements
- 🧠 Architecture BLoC + SQLite locale

---

## 🛠️ Prérequis

| Outil                | Requis |
|----------------------|--------|
| Flutter SDK (v3.0+)  | ✅     |
| Android Studio       | ✅     |
| Git                  | ✅     |
| Compte Google Cloud  | ✅     |
| Appareil Android     | ✅     |

---

## 🧭 Installation et exécution du projet

### 1. Cloner le dépôt
a. Copier le lien du dépôt GitHub
https://github.com/jaguar-x-print/jaguar_x_print_mobile_app.git

b. Ouvrir l’invite de commande ou le terminal
```bash
# Aller dans le dossier où vous voulez placer le projet
cd C:\Users\votre_nom\Documents\FlutterApps

# Cloner le projet
git clone https://github.com/nom-utilisateur/mon-projet-flutter.git
```
c. Entrer dans le dossier du projet
```bash
cd mon-projet-flutter
```

### 2. Installer les dépendances
```bash
flutter pub get
```
📌 Cette commande télécharge tous les packages définis dans le fichier pubspec.yaml.

### 3. ⚙️ Vérifier la configuration Flutter
```bash
flutter doctor
```
Résultat attendu : ✅ pour Flutter, Android SDK, adb, connected device, etc.
Si quelque chose est en rouge, corrige-le selon les recommandations affichées.

### 4. 📱 Connecter le smartphone Android
#### a. Activer les options développeur et le débogage USB :
- Aller dans Paramètres > À propos du téléphone
- Appuyer plusieurs fois sur Numéro de build
- Revenir en arrière → dans Système > Options pour développeurs
- Activer Débogage USB

#### b. Connecter le téléphone avec un câble USB
Puis vérifier que Flutter le reconnaît :
```bash
flutter devices
```
Résultat attendu : ton téléphone apparaît dans la liste (ex. sdk_gphone64_x86_64, Redmi Note 11, etc.)

### 5. ▶️ Lancer l’application sur le smartphone
```bash
flutter run
```
Cela compile et installe l’appli directement sur ton téléphone.

### 6. 🧪 Tester l’application
L’appli se lance automatiquement. Tu peux interagir avec elle et voir les logs dans le terminal.

📦 Générer un APK de production
```bash
flutter build apk --release
```
## 💡 COMMANDES UTILES
| Action                             | Commande                      |
| ---------------------------------- | ----------------------------- |
| Mettre à jour Flutter              | `flutter upgrade`             |
| Nettoyer le projet                 | `flutter clean`               |
| Réinstaller les packages           | `flutter pub get`             |
| Changer de canal (stable/beta/dev) | `flutter channel stable`      |
| Recompiler après modification      | `flutter run`                 |
| Compiler pour production (APK)     | `flutter build apk --release` |
| Compiler pour production (AAB)     | `flutter build appbundle`     |

#### 📦 (Facultatif) Générer un APK installable manuellement
```bash
flutter build apk --release
```
L’APK sera dans :

```swift
build/app/outputs/flutter-apk/app-release.apk
```
Tu peux le transférer manuellement sur ton téléphone et l’installer.

## 🧪 Technologies utilisées
| Technologie                   | Usage                                 |
| ----------------------------- | ------------------------------------- |
| Flutter                       | Développement multiplateforme         |
| SQLite                        | Base de données locale                |
| Google Sign-In                | Authentification                      |
| Google Drive API              | Sauvegarde & restauration             |
| flutter\_local\_notifications | Notifications programmées             |
| pdf & share\_plus             | Génération et partage de fichiers PDF |
| Workmanager                   | Tâches en arrière-plan                |


## 📌 REMARQUES
- Tu peux utiliser Android Studio ou VS Code à la place de l’invite de commande pour faire les mêmes étapes via interface graphique.
- Si tu veux exécuter sur un émulateur, démarre-le depuis Android Studio ou avec :
```bash
flutter emulators
flutter emulators --launch nom_emulateur
```

## 🔐 Configuration Google Sign-In & Drive
Voici ce que tu dois avoir côté Google Cloud Console :

1. Créer un projet Google Cloud
→ https://console.cloud.google.com

2. Activer les API suivantes :
- Google Drive API
- Identity Toolkit API
- OAuth 2.0 Client ID

3. Créer un OAuth 2.0 Client ID :
- Type : Android
- SHA1 + nom du package requis
- Copie le fichier google-services.json dans /android/app

4. Dans AndroidManifest.xml :
Ajoute :

```bash
<uses-permission android:name="android.permission.INTERNET"/>
```
Et dans < application > :
```bash
<meta-data
  android:name="com.google.android.gms.version"
  android:value="@integer/google_play_services_version" />
```


### 🤝 Auteur
Kamela Pierrick Dack
📧 kamelapierrick@gmail.com
🔗 www.linkedin.com/in/pierrick-kamela-79b6a3252
