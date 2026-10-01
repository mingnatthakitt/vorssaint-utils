// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct GeminiLiveStrings {
    let title = "Gemini Live"
    let description: String
    let keyLabel: String
    let save: String
    let remove: String
    let getKey: String
    let share: String
    let stop: String
    let connecting: String
    let active: String
    let unmute: String
    let mute: String
    let privacy: String
    let keyRequired: String
    let keychainFailed: String
    let microphoneDenied: String
    let audioFailed: String
    let connectionFailed: String
    let captureFailed: String
    let sessionEnded: String
}

extension FeatureStrings {
    static func geminiLive(_ language: AppLanguage) -> GeminiLiveStrings {
        switch language {
        case .enUS:
            return GeminiLiveStrings(
                description: "Talk about a screen or window with Gemini 3.8 Live",
                keyLabel: "Personal Gemini API key",
                save: "Save key",
                remove: "Remove key",
                getKey: "Get an API key",
                share: "Share screen",
                stop: "Stop sharing",
                connecting: "Connecting…",
                active: "Screen sharing is active",
                unmute: "Turn microphone on",
                mute: "Mute microphone",
                privacy: "Your selected screen and enabled microphone are sent directly to Google using your key. Google API charges may apply. The key stays in this Mac’s Keychain and is excluded from settings backups. Use headphones. You can speak to interrupt Gemini. Leaving this page ends sharing.",
                keyRequired: "Enter your Gemini API key first.",
                keychainFailed: "Could not access Keychain. Try again.",
                microphoneDenied: "Microphone access is denied. Allow Vorssaint in System Settings → Privacy & Security → Microphone.",
                audioFailed: "Could not start audio. Check your input and output devices.",
                connectionFailed: "Could not connect to Gemini. Check your API key, model access, quota and network, then try again.",
                captureFailed: "Screen sharing ended or could not start. Choose a screen or window again.",
                sessionEnded: "The Gemini session ended. Start a new session.")
        case .ptBR:
            return GeminiLiveStrings(
                description: "Converse sobre uma tela ou janela com Gemini 3.8 Live",
                keyLabel: "Sua chave de API Gemini",
                save: "Salvar chave",
                remove: "Remover chave",
                getKey: "Obter uma chave de API",
                share: "Compartilhar tela",
                stop: "Parar compartilhamento",
                connecting: "Conectando…",
                active: "Compartilhamento de tela ativo",
                unmute: "Ativar microfone",
                mute: "Silenciar microfone",
                privacy: "A tela selecionada e o microfone ativado são enviados diretamente ao Google com sua chave. A API do Google pode ter custos. A chave fica nas Chaves deste Mac, fora dos backups de ajustes. Use fones. Você pode falar para interromper o Gemini. Sair desta página encerra o compartilhamento.",
                keyRequired: "Insira sua chave de API Gemini primeiro.",
                keychainFailed: "Não foi possível acessar as Chaves. Tente novamente.",
                microphoneDenied: "Acesso ao microfone negado. Permita o Vorssaint em Ajustes do Sistema → Privacidade e Segurança → Microfone.",
                audioFailed: "Não foi possível iniciar o áudio. Verifique os dispositivos de entrada e saída.",
                connectionFailed: "Não foi possível conectar ao Gemini. Verifique a chave, o acesso ao modelo, a cota e a rede.",
                captureFailed: "O compartilhamento terminou ou não iniciou. Escolha uma tela ou janela novamente.",
                sessionEnded: "A sessão do Gemini terminou. Inicie uma nova sessão.")
        case .es:
            return GeminiLiveStrings(
                description: "Habla sobre una pantalla o ventana con Gemini 3.8 Live",
                keyLabel: "Tu clave de API Gemini",
                save: "Guardar clave",
                remove: "Eliminar clave",
                getKey: "Obtener una clave de API",
                share: "Compartir pantalla",
                stop: "Dejar de compartir",
                connecting: "Conectando…",
                active: "La pantalla se está compartiendo",
                unmute: "Activar micrófono",
                mute: "Silenciar micrófono",
                privacy: "La pantalla elegida y el micrófono activado se envían directamente a Google con tu clave. La API de Google puede tener costes. La clave queda en el Llavero de este Mac, fuera de las copias de ajustes. Usa auriculares. Puedes hablar para interrumpir a Gemini. Salir de esta página termina el uso compartido.",
                keyRequired: "Introduce primero tu clave de API Gemini.",
                keychainFailed: "No se pudo acceder al Llavero. Inténtalo de nuevo.",
                microphoneDenied: "Acceso al micrófono denegado. Permite Vorssaint en Ajustes del Sistema → Privacidad y seguridad → Micrófono.",
                audioFailed: "No se pudo iniciar el audio. Revisa los dispositivos de entrada y salida.",
                connectionFailed: "No se pudo conectar a Gemini. Revisa la clave, el acceso al modelo, la cuota y la red.",
                captureFailed: "No se pudo iniciar o terminó el uso compartido. Elige una pantalla o ventana otra vez.",
                sessionEnded: "La sesión de Gemini terminó. Inicia una nueva.")
        case .fr:
            return GeminiLiveStrings(
                description: "Discutez d’un écran ou d’une fenêtre avec Gemini 3.8 Live",
                keyLabel: "Votre clé API Gemini",
                save: "Enregistrer la clé",
                remove: "Supprimer la clé",
                getKey: "Obtenir une clé API",
                share: "Partager l’écran",
                stop: "Arrêter le partage",
                connecting: "Connexion…",
                active: "Partage d’écran actif",
                unmute: "Activer le microphone",
                mute: "Couper le microphone",
                privacy: "L’écran choisi et le microphone activé sont envoyés directement à Google avec votre clé. L’API Google peut être payante. La clé reste dans le Trousseau de ce Mac, hors des sauvegardes de réglages. Utilisez un casque. Vous pouvez parler pour interrompre Gemini. Quitter cette page arrête le partage.",
                keyRequired: "Saisissez d’abord votre clé API Gemini.",
                keychainFailed: "Impossible d’accéder au Trousseau. Réessayez.",
                microphoneDenied: "Accès au microphone refusé. Autorisez Vorssaint dans Réglages Système → Confidentialité et sécurité → Microphone.",
                audioFailed: "Impossible de démarrer l’audio. Vérifiez vos périphériques d’entrée et de sortie.",
                connectionFailed: "Impossible de joindre Gemini. Vérifiez la clé, l’accès au modèle, le quota et le réseau.",
                captureFailed: "Le partage est terminé ou n’a pas démarré. Choisissez à nouveau un écran ou une fenêtre.",
                sessionEnded: "La session Gemini est terminée. Démarrez une nouvelle session.")
        case .de:
            return GeminiLiveStrings(
                description: "Besprich einen Bildschirm oder ein Fenster mit Gemini 3.8 Live",
                keyLabel: "Dein Gemini-API-Schlüssel",
                save: "Schlüssel speichern",
                remove: "Schlüssel entfernen",
                getKey: "API-Schlüssel erstellen",
                share: "Bildschirm teilen",
                stop: "Teilen beenden",
                connecting: "Verbindung wird hergestellt…",
                active: "Bildschirmfreigabe aktiv",
                unmute: "Mikrofon einschalten",
                mute: "Mikrofon stummschalten",
                privacy: "Der gewählte Bildschirm und das eingeschaltete Mikrofon werden mit deinem Schlüssel direkt an Google gesendet. Google kann API-Gebühren berechnen. Der Schlüssel bleibt im Schlüsselbund dieses Macs, außerhalb der Einstellungssicherungen. Nutze Kopfhörer. Du kannst Gemini unterbrechen, indem du sprichst. Beim Verlassen dieser Seite endet die Freigabe.",
                keyRequired: "Gib zuerst deinen Gemini-API-Schlüssel ein.",
                keychainFailed: "Kein Zugriff auf den Schlüsselbund. Versuche es erneut.",
                microphoneDenied: "Mikrofonzugriff verweigert. Erlaube Vorssaint unter Systemeinstellungen → Datenschutz & Sicherheit → Mikrofon.",
                audioFailed: "Audio konnte nicht gestartet werden. Prüfe Ein- und Ausgabegeräte.",
                connectionFailed: "Keine Verbindung zu Gemini. Prüfe Schlüssel, Modellzugriff, Kontingent und Netzwerk.",
                captureFailed: "Die Freigabe wurde beendet oder konnte nicht starten. Wähle erneut einen Bildschirm oder ein Fenster.",
                sessionEnded: "Die Gemini-Sitzung wurde beendet. Starte eine neue Sitzung.")
        case .it:
            return GeminiLiveStrings(
                description: "Parla di uno schermo o una finestra con Gemini 3.8 Live",
                keyLabel: "La tua chiave API Gemini",
                save: "Salva chiave",
                remove: "Rimuovi chiave",
                getKey: "Ottieni una chiave API",
                share: "Condividi schermo",
                stop: "Interrompi condivisione",
                connecting: "Connessione…",
                active: "Condivisione schermo attiva",
                unmute: "Attiva microfono",
                mute: "Disattiva microfono",
                privacy: "Lo schermo scelto e il microfono attivato vengono inviati direttamente a Google con la tua chiave. L’API Google può avere costi. La chiave resta nel Portachiavi di questo Mac, fuori dai backup delle impostazioni. Usa cuffie. Puoi parlare per interrompere Gemini. Uscire da questa pagina interrompe la condivisione.",
                keyRequired: "Inserisci prima la tua chiave API Gemini.",
                keychainFailed: "Impossibile accedere al Portachiavi. Riprova.",
                microphoneDenied: "Accesso al microfono negato. Consenti Vorssaint in Impostazioni di Sistema → Privacy e sicurezza → Microfono.",
                audioFailed: "Impossibile avviare l’audio. Controlla i dispositivi di ingresso e uscita.",
                connectionFailed: "Impossibile connettersi a Gemini. Controlla chiave, accesso al modello, quota e rete.",
                captureFailed: "La condivisione è terminata o non è partita. Scegli di nuovo uno schermo o una finestra.",
                sessionEnded: "La sessione Gemini è terminata. Avvia una nuova sessione.")
        case .ja:
            return GeminiLiveStrings(
                description: "Gemini 3.8 Liveと画面やウインドウについて話す",
                keyLabel: "個人のGemini APIキー",
                save: "キーを保存",
                remove: "キーを削除",
                getKey: "APIキーを取得",
                share: "画面を共有",
                stop: "共有を停止",
                connecting: "接続中…",
                active: "画面を共有しています",
                unmute: "マイクをオン",
                mute: "マイクをミュート",
                privacy: "選択した画面とオンにしたマイクは、あなたのキーでGoogleに直接送信されます。Google APIの料金が発生する場合があります。キーはこのMacのキーチェーンに保存され、設定バックアップには含まれません。ヘッドフォンを使用してください。話しかけるとGeminiの応答を中断できます。このページを離れると共有が終了します。",
                keyRequired: "先にGemini APIキーを入力してください。",
                keychainFailed: "キーチェーンにアクセスできません。再試行してください。",
                microphoneDenied: "マイクへのアクセスが拒否されました。システム設定 → プライバシーとセキュリティ → マイクでVorssaintを許可してください。",
                audioFailed: "音声を開始できません。入出力デバイスを確認してください。",
                connectionFailed: "Geminiに接続できません。キー、モデルへのアクセス、割り当て、ネットワークを確認してください。",
                captureFailed: "画面共有が終了したか開始できませんでした。画面やウインドウを再度選択してください。",
                sessionEnded: "Geminiセッションが終了しました。新しいセッションを開始してください。")
        case .ko:
            return GeminiLiveStrings(
                description: "Gemini 3.8 Live와 화면이나 창에 대해 대화하기",
                keyLabel: "개인 Gemini API 키",
                save: "키 저장",
                remove: "키 삭제",
                getKey: "API 키 발급",
                share: "화면 공유",
                stop: "공유 중지",
                connecting: "연결 중…",
                active: "화면 공유 중",
                unmute: "마이크 켜기",
                mute: "마이크 음소거",
                privacy: "선택한 화면과 켜진 마이크는 내 키로 Google에 직접 전송됩니다. Google API 요금이 발생할 수 있습니다. 키는 이 Mac의 키체인에 보관되며 설정 백업에 포함되지 않습니다. 헤드폰을 사용하세요. 말을 시작하면 Gemini의 응답을 중단할 수 있습니다. 이 페이지를 떠나면 공유가 종료됩니다.",
                keyRequired: "먼저 Gemini API 키를 입력하세요.",
                keychainFailed: "키체인에 접근할 수 없습니다. 다시 시도하세요.",
                microphoneDenied: "마이크 접근이 거부되었습니다. 시스템 설정 → 개인정보 보호 및 보안 → 마이크에서 Vorssaint를 허용하세요.",
                audioFailed: "오디오를 시작할 수 없습니다. 입출력 기기를 확인하세요.",
                connectionFailed: "Gemini에 연결할 수 없습니다. 키, 모델 접근, 할당량 및 네트워크를 확인하세요.",
                captureFailed: "화면 공유가 종료되었거나 시작하지 못했습니다. 화면이나 창을 다시 선택하세요.",
                sessionEnded: "Gemini 세션이 종료되었습니다. 새 세션을 시작하세요.")
        case .zhHans:
            return GeminiLiveStrings(
                description: "与 Gemini 3.8 Live 讨论屏幕或窗口",
                keyLabel: "个人 Gemini API 密钥",
                save: "保存密钥",
                remove: "删除密钥",
                getKey: "获取 API 密钥",
                share: "共享屏幕",
                stop: "停止共享",
                connecting: "正在连接…",
                active: "正在共享屏幕",
                unmute: "开启麦克风",
                mute: "麦克风静音",
                privacy: "所选屏幕和启用的麦克风将使用你的密钥直接发送给 Google。Google API 可能产生费用。密钥保存在此 Mac 的钥匙串中，不包含在设置备份中。请使用耳机。你可以开口打断 Gemini。离开此页面将结束共享。",
                keyRequired: "请先输入 Gemini API 密钥。",
                keychainFailed: "无法访问钥匙串。请重试。",
                microphoneDenied: "麦克风访问被拒绝。请在系统设置 → 隐私与安全性 → 麦克风中允许 Vorssaint。",
                audioFailed: "无法启动音频。请检查输入和输出设备。",
                connectionFailed: "无法连接 Gemini。请检查密钥、模型访问权限、配额和网络。",
                captureFailed: "屏幕共享已结束或无法启动。请重新选择屏幕或窗口。",
                sessionEnded: "Gemini 会话已结束。请开始新会话。")
        case .zhTW:
            return GeminiLiveStrings(
                description: "與 Gemini 3.8 Live 討論螢幕或視窗",
                keyLabel: "個人 Gemini API 金鑰",
                save: "儲存金鑰",
                remove: "移除金鑰",
                getKey: "取得 API 金鑰",
                share: "分享螢幕",
                stop: "停止分享",
                connecting: "正在連線…",
                active: "正在分享螢幕",
                unmute: "開啟麥克風",
                mute: "麥克風靜音",
                privacy: "所選螢幕和啟用的麥克風將使用你的金鑰直接傳送給 Google。Google API 可能產生費用。金鑰儲存在此 Mac 的鑰匙圈中，不包含在設定備份中。請使用耳機。你可以開口打斷 Gemini。離開此頁面將結束分享。",
                keyRequired: "請先輸入 Gemini API 金鑰。",
                keychainFailed: "無法存取鑰匙圈。請重試。",
                microphoneDenied: "麥克風存取遭拒。請在系統設定 → 隱私權與安全性 → 麥克風中允許 Vorssaint。",
                audioFailed: "無法啟動音訊。請檢查輸入和輸出裝置。",
                connectionFailed: "無法連線 Gemini。請檢查金鑰、模型存取權限、配額和網路。",
                captureFailed: "螢幕分享已結束或無法啟動。請重新選擇螢幕或視窗。",
                sessionEnded: "Gemini 工作階段已結束。請開始新的工作階段。")
        case .zhHK:
            return GeminiLiveStrings(
                description: "與 Gemini 3.8 Live 討論螢幕或視窗",
                keyLabel: "個人 Gemini API 金鑰",
                save: "儲存金鑰",
                remove: "移除金鑰",
                getKey: "取得 API 金鑰",
                share: "分享螢幕",
                stop: "停止分享",
                connecting: "正在連線…",
                active: "正在分享螢幕",
                unmute: "開啟咪高風",
                mute: "咪高風靜音",
                privacy: "所選螢幕和啟用的咪高風會使用你的金鑰直接傳送給 Google。Google API 可能產生費用。金鑰儲存在此 Mac 的鑰匙圈中，不包含在設定備份中。請使用耳機。你可以開口打斷 Gemini。離開此頁面會結束分享。",
                keyRequired: "請先輸入 Gemini API 金鑰。",
                keychainFailed: "無法存取鑰匙圈。請重試。",
                microphoneDenied: "咪高風存取遭拒。請在系統設定 → 私隱與保安 → 咪高風中允許 Vorssaint。",
                audioFailed: "無法啟動音訊。請檢查輸入和輸出裝置。",
                connectionFailed: "無法連線 Gemini。請檢查金鑰、模型存取權限、配額和網絡。",
                captureFailed: "螢幕分享已結束或無法啟動。請重新選擇螢幕或視窗。",
                sessionEnded: "Gemini 工作階段已結束。請開始新的工作階段。")
        case .ru:
            return GeminiLiveStrings(
                description: "Обсудите экран или окно с Gemini 3.8 Live",
                keyLabel: "Ваш ключ API Gemini",
                save: "Сохранить ключ",
                remove: "Удалить ключ",
                getKey: "Получить ключ API",
                share: "Поделиться экраном",
                stop: "Остановить показ",
                connecting: "Подключение…",
                active: "Показ экрана активен",
                unmute: "Включить микрофон",
                mute: "Выключить микрофон",
                privacy: "Выбранный экран и включённый микрофон передаются напрямую Google с вашим ключом. За API Google может взиматься плата. Ключ хранится в Связке ключей этого Mac и не входит в резервные копии настроек. Используйте наушники. Вы можете прервать Gemini, начав говорить. Уход со страницы завершает показ.",
                keyRequired: "Сначала введите ключ API Gemini.",
                keychainFailed: "Нет доступа к Связке ключей. Повторите попытку.",
                microphoneDenied: "Доступ к микрофону запрещён. Разрешите Vorssaint в Системных настройках → Конфиденциальность и безопасность → Микрофон.",
                audioFailed: "Не удалось запустить звук. Проверьте устройства ввода и вывода.",
                connectionFailed: "Не удалось подключиться к Gemini. Проверьте ключ, доступ к модели, квоту и сеть.",
                captureFailed: "Показ завершён или не запустился. Выберите экран или окно ещё раз.",
                sessionEnded: "Сеанс Gemini завершён. Начните новый сеанс.")
        case .uk:
            return GeminiLiveStrings(
                description: "Обговоріть екран або вікно з Gemini 3.8 Live",
                keyLabel: "Ваш ключ API Gemini",
                save: "Зберегти ключ",
                remove: "Видалити ключ",
                getKey: "Отримати ключ API",
                share: "Поділитися екраном",
                stop: "Зупинити показ",
                connecting: "Підключення…",
                active: "Показ екрана активний",
                unmute: "Увімкнути мікрофон",
                mute: "Вимкнути мікрофон",
                privacy: "Вибраний екран та увімкнений мікрофон передаються безпосередньо Google з вашим ключем. API Google може бути платним. Ключ зберігається у В’язці ключів цього Mac і не входить до резервних копій налаштувань. Використовуйте навушники. Ви можете перервати Gemini, почавши говорити. Вихід зі сторінки завершує показ.",
                keyRequired: "Спочатку введіть ключ API Gemini.",
                keychainFailed: "Немає доступу до В’язки ключів. Спробуйте ще раз.",
                microphoneDenied: "Доступ до мікрофона заборонено. Дозвольте Vorssaint у Системних параметрах → Приватність і безпека → Мікрофон.",
                audioFailed: "Не вдалося запустити звук. Перевірте пристрої введення та виведення.",
                connectionFailed: "Не вдалося підключитися до Gemini. Перевірте ключ, доступ до моделі, квоту та мережу.",
                captureFailed: "Показ завершено або не запущено. Виберіть екран чи вікно ще раз.",
                sessionEnded: "Сеанс Gemini завершено. Почніть новий сеанс.")
        case .sk:
            return GeminiLiveStrings(
                description: "Hovorte o obrazovke alebo okne s Gemini 3.8 Live",
                keyLabel: "Váš kľúč API Gemini",
                save: "Uložiť kľúč",
                remove: "Odstrániť kľúč",
                getKey: "Získať kľúč API",
                share: "Zdieľať obrazovku",
                stop: "Zastaviť zdieľanie",
                connecting: "Pripájanie…",
                active: "Zdieľanie obrazovky je aktívne",
                unmute: "Zapnúť mikrofón",
                mute: "Stlmiť mikrofón",
                privacy: "Vybraná obrazovka a zapnutý mikrofón sa odosielajú priamo Googlu s vaším kľúčom. API Googlu môže byť spoplatnené. Kľúč ostáva v Kľúčenke tohto Macu, mimo záloh nastavení. Používajte slúchadlá. Gemini môžete prerušiť tým, že začnete hovoriť. Odchod z tejto stránky ukončí zdieľanie.",
                keyRequired: "Najprv zadajte kľúč API Gemini.",
                keychainFailed: "Prístup ku Kľúčenke zlyhal. Skúste to znova.",
                microphoneDenied: "Prístup k mikrofónu zamietnutý. Povoľte Vorssaint v Systémových nastaveniach → Súkromie a bezpečnosť → Mikrofón.",
                audioFailed: "Zvuk sa nepodarilo spustiť. Skontrolujte vstupné a výstupné zariadenia.",
                connectionFailed: "Pripojenie ku Gemini zlyhalo. Skontrolujte kľúč, prístup k modelu, kvótu a sieť.",
                captureFailed: "Zdieľanie sa skončilo alebo nespustilo. Znova vyberte obrazovku alebo okno.",
                sessionEnded: "Relácia Gemini sa skončila. Začnite novú reláciu.")
        case .tr:
            return GeminiLiveStrings(
                description: "Gemini 3.8 Live ile bir ekran veya pencere hakkında konuşun",
                keyLabel: "Kişisel Gemini API anahtarı",
                save: "Anahtarı kaydet",
                remove: "Anahtarı kaldır",
                getKey: "API anahtarı al",
                share: "Ekranı paylaş",
                stop: "Paylaşımı durdur",
                connecting: "Bağlanıyor…",
                active: "Ekran paylaşımı etkin",
                unmute: "Mikrofonu aç",
                mute: "Mikrofonu sustur",
                privacy: "Seçilen ekran ve açılan mikrofon, anahtarınızla doğrudan Google’a gönderilir. Google API ücretleri uygulanabilir. Anahtar bu Mac’in Anahtar Zinciri’nde kalır ve ayar yedeklerine dahil edilmez. Kulaklık kullanın. Konuşmaya başlayarak Gemini’nin sözünü kesebilirsiniz. Bu sayfadan ayrılmak paylaşımı sonlandırır.",
                keyRequired: "Önce Gemini API anahtarınızı girin.",
                keychainFailed: "Anahtar Zinciri’ne erişilemedi. Tekrar deneyin.",
                microphoneDenied: "Mikrofon erişimi reddedildi. Sistem Ayarları → Gizlilik ve Güvenlik → Mikrofon bölümünde Vorssaint’e izin verin.",
                audioFailed: "Ses başlatılamadı. Giriş ve çıkış aygıtlarını kontrol edin.",
                connectionFailed: "Gemini’ye bağlanılamadı. Anahtarı, model erişimini, kotayı ve ağı kontrol edin.",
                captureFailed: "Ekran paylaşımı sona erdi veya başlayamadı. Yeniden ekran ya da pencere seçin.",
                sessionEnded: "Gemini oturumu sona erdi. Yeni bir oturum başlatın.")
        }
    }
}
