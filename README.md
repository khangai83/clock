# 🌬️ Breathing App (Timer)

Flutter-ээр хийсэн breathing дасгалын timer аппликейшн.

## 🌐 Web хаяг

Таны апп дараах хаягаар нээгдэнэ:
**https://khangai83.github.io/clock/**

## 📱 Онцлогууд

- Цикл тохируулах (нэр, үргэлжлэх хугацаа)
- Дууссан цагийг тохируулах
- TTS (Text-to-Speech) дуудлага
- Beep дуугаралт
- Dark/Light theme
- Web, Android, iOS дээр ажилладаг

## 🚀 VS Code - Товчлуур дарж команд ажиллуулах

VS Code дээр дараах товчлууруудыг дарж командуудыг шууд ажиллуулах боломжтой:

| Товчлуур | Команд | Тайлбар |
|----------|--------|---------|
| **Ctrl+Shift+B** | Flutter Build Web | Web апп build хийх |
| **Ctrl+Shift+R** | Flutter Run Web | Web апп run хийх (Chrome нээгдэнэ) |
| **Ctrl+Shift+A** | Flutter Build APK | Android APK build хийх |
| **Ctrl+Shift+C** | Flutter Clean | Clean хийгээд pub get |
| **Ctrl+Shift+D** | Deploy to GitHub Pages | GitHub Pages руу deploy хийх |

**Mac дээр:** Ctrl-ийн оронд **Cmd** ашиглана уу.

### Хэрхэн ажилладаг вэ?

1. `.vscode/tasks.json` файлд командууд тодорхойлогдсон
2. `.vscode/keybindings.json` файлд товчлуурууд тохируулагдсан
3. VS Code автоматаар эдгээр файлыг таньж, тохиргоог хэрэглэнэ

## 🌐 Утаснаасаа ажиллуулах (Web Deploy)

### Арга 1: GitHub Actions (Автомат)

1. GitHub дээр repository үүсгээд кодоо push хийх
2. GitHub Repository Settings → Pages → Source: **GitHub Actions** сонгох
3. `main` branch руу push хийх бүрт автоматаар deploy болно
4. Таны апп: `https://YOUR_USERNAME.github.io/YOUR_REPO/` хаягаар нээгдэнэ

### Арга 2: Deploy скрипт (Гараар)

```bash
# deploy.sh файлыг өөрийн repository-гаар тохируулах
# REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git" гэсэн мөрийг өөрчлөх

chmod +x deploy.sh
./deploy.sh
```

### Арга 3: VS Code товчлуур

VS Code дээр **Ctrl+Shift+D** дарж шууд deploy хийх (эхлээд `tasks.json` дахь repository URL-аа тохируулах).

### Арга 4: Firebase Hosting

```bash
# Firebase CLI суулгах
npm install -g firebase-tools

# Firebase руу deploy
firebase init hosting
firebase deploy --only hosting
```

### Арга 5: Netlify

1. `flutter build web --release` ажиллуулах
2. `build/web` фолдерыг Netlify руу drag & drop хийх
3. Эсвэл GitHub repository-г Netlify-тай холбох

## 📦 Build хийх заавар

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web дээр локалаар турших
flutter run -d chrome
```

## 🛠️ Шаардлагатай

- Flutter SDK 3.12+
- Dart SDK 3.12+
- Chrome (web туршихад)
- Android Studio (Android build хийхэд)
- Xcode (iOS build хийхэд, Mac дээр)

## 📄 Лайценз

MIT
