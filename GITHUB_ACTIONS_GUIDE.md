# Руководство по сборке Telegram iOS IPA в GitHub Actions

В вашем репозитории полностью настроен и оптимизирован пайплайн GitHub Actions для автоматической и ручной сборки `.ipa` файла приложения Telegram для iOS.

---

## 🚀 Что было сделано и исправлено в проекте

1. **Исправлены относительные ссылки в `.gitmodules`**:
   - Сабмодули `rlottie` (`../rlottie.git`) и `tgcalls` (`../tgcalls.git`) при клонировании из стороннего форка (`sheluvsw4g/dgram-ios`) вели на несуществующие репозитории `sheluvsw4g/rlottie` и `sheluvsw4g/tgcalls`.
   - Они перенаправлены на официальные репозитории `https://github.com/TelegramMessenger/rlottie.git` и `https://github.com/TelegramMessenger/tgcalls.git`. Теперь `actions/checkout` с `submodules: 'recursive'` проходит успешно.

2. **Добавлен недостающий профиль инициализации `BroadcastUpload`**:
   - Профиль `BroadcastUpload.mobileprovision` находился в корне `fake-codesigning/`, из-за чего не попадал в каталог `profiles/` и сборка падала при попытке подписать расширение трансляции экрана. Он скопирован в `build-system/fake-codesigning/profiles/BroadcastUpload.mobileprovision`.

3. **Исправлен скрипт `ImportCertificates.py`**:
   - Исправлена ошибка разбора списка существующих связок ключей (`security list-keychains`), где не очищались кавычки и переводы строк, что приводило к сбоям на современных версиях macOS.

4. **Полностью переписан `.github/workflows/build.yml`**:
   - **Современный раннер**: Обновлен с устаревшего Intel `macos-13` до Apple Silicon `macos-14` (M1/ARM64), который поддерживает **Xcode 16.0 / 16.1 / 16.2** и совпадает с версией из `versions.json`.
   - **Триггеры**:
     - Push в ветки `main`, `master` и теги `v*`, `build-*`.
     - Ручной запуск через вкладку **Actions -> Run workflow** (`workflow_dispatch`) с выбором конфигурации (`release_arm64` или `debug_arm64`) и флагом публикации релиза.
   - **Права доступа**: Добавлено `permissions: contents: write` для корректного создания релизов и загрузки артефактов без ошибок 403 Forbidden.
   - **Обновление версий экшенов**:
     - `actions/checkout@v4` (вместо устаревшего v2).
     - `actions/upload-artifact@v4` (загружает готовый IPA и dSYM в артефакты каждого запуска).
     - `softprops/action-gh-release@v2` (заменяет архивные `actions/create-release@v1` и `actions/upload-release-asset@v1`, которые ломались из-за устаревшего Node.js).
   - **Кэширование Bazel**: Добавлен кэш `actions/cache@v4` для каталога `~/telegram-bazel-cache`, что ускоряет последующие сборки.
   - **Надежный поиск IPA**: Поиск артефактов через `find bazel-out bazel-bin -name "Telegram.ipa"` предотвращает сбои из-за изменений путей вывода в Bazel 7.

---

## 📲 Как запустить сборку IPA

### Способ 1: Ручной запуск (Workflow Dispatch)
1. Откройте ваш репозиторий на GitHub.
2. Перейдите во вкладку **Actions**.
3. В левой колонке выберите воркфлоу **Build Telegram iOS IPA**.
4. Нажмите кнопку **Run workflow** справа.
5. При необходимости выберите ветку (например, `main`) и параметры:
   - **Build configuration**: `release_arm64` (по умолчанию)
   - **Create GitHub Release with IPA**: `true`
6. Нажмите **Run workflow**.

### Способ 2: Автоматически при Push
- При каждом пуше в ветку `main` или `master`, либо при создании Git-тега (например, `git tag v11.5.2 && git push --tags`), сборка запустится автоматически.

---

## 📦 Где забрать готовый `.ipa` файл

1. **В GitHub Releases** (если включен Create GitHub Release):
   - Перейдите в раздел **Releases** вашего репозитория.
   - Там появится релиз с прикрепленными файлами `Telegram.ipa` и `Telegram.DSYMs.zip`.
2. **В артефактах сборки (Artifacts)**:
   - Откройте завершенный запуск во вкладке **Actions**.
   - Внизу страницы в блоке **Artifacts** будет доступен архив `Telegram-iOS-v...` с готовым файлом `Telegram.ipa`.

---

## 📱 Установка полученного IPA на iPhone / iPad

Собранный IPA подписан самоподписанными/fake сертификатами Telegram и готов для установки следующими способами:
- **TrollStore** (для поддерживаемых версий iOS — перманентная подпись без ограничений и отзывов).
- **SideStore / AltStore** (свободная установка через свой Apple ID).
- **Esign / Scarlet / Gbox** (установка через личный или корпоративный P12-сертификат).
- **Sideloadly** (через кабель или Wi-Fi с ПК/Mac).

---

## ⚙️ Фиксация изменений в Git

Чтобы применить эти настройки в вашем репозитории, закоммитьте и отправьте изменения на GitHub:

```bash
git add .github/workflows/build.yml .gitmodules build-system/Make/ImportCertificates.py build-system/fake-codesigning/profiles/BroadcastUpload.mobileprovision GITHUB_ACTIONS_GUIDE.md
git commit -m "Configure GitHub Actions workflow for building Telegram iOS IPA"
git push origin main
```
