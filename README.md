# aahelp
 light version

 Приложение для поиска групп АА, зарегистрированных на aamos.ru в Москве и Московской области.
 В приложении можно задать поиск по имени, району, метро и адресу. А также найти ближайшие группы, задав радиус поиска.
 Список групп можно фильтровать по времени - **Утро, День, Вечер,** и/или на _Сегодня_
 
*Некоммерческий проект. Предложения и замечания присылать на andrey.kovynev@yandex.ru или в группу Телеграм t.me/app_aahelper
![111](https://github.com/user-attachments/assets/1205b095-d227-4b1e-8855-df9cc81ce892)
![222](https://github.com/user-attachments/assets/536cf5ce-7dfd-43c3-92cb-ca1bc9e10145)
![333](https://github.com/user-attachments/assets/84d86c78-1184-42a0-8152-5909f704f41f)
![444](https://github.com/user-attachments/assets/719923ad-4af6-4023-adc7-bffb8ddc06b8)

## Карты

Сейчас проект использует две разные реализации карты:

- `Android`: нативная карта через `yandex_mapkit`
- `web / iOS PWA`: Yandex Maps JavaScript API

### Что нужно для Android

В `android/local.properties` добавьте:

```properties
yandex.mapkitApiKey=YOUR_YANDEX_MAPKIT_API_KEY
```

Минимальная версия Android для native-карты: `minSdk 26`.

### Что нужно для web / PWA

При запуске или сборке web-проекта передавайте JS API ключ:

```bash
flutter run -d chrome --dart-define=YANDEX_WEB_API_KEY=YOUR_YANDEX_JS_API_KEY
flutter build web --dart-define=YANDEX_WEB_API_KEY=YOUR_YANDEX_JS_API_KEY
```

Для mobile MapKit и JavaScript API нужны разные ключи Яндекса.
Для JS API v3 в кабинете Яндекса обязательно заполните ограничение `HTTP Referer`.
Если вы тестируете локально, добавьте `http://localhost` и production-домен, иначе карта может открыться, но при увеличении отдавать пустые тайлы или сетку.



