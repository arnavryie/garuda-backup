#!/usr/bin/env python3
"""
Life OS — Permanent Pinned Desktop Widget (Garuda / KDE Plasma)
Frameless, transparent, borderless, pinned directly to the desktop at the right-most edge.
Runs silently with no top bar, no close buttons, and no taskbar icon.
"""

import sys
import os
from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout
from PyQt6.QtGui import QColor, QDesktopServices, QKeySequence, QShortcut
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineProfile, QWebEngineSettings, QWebEnginePage, QWebEngineScript

CONFIG_DIR = os.path.expanduser("~/.config/life-os-desktop")
STORAGE_DIR = os.path.join(CONFIG_DIR, "webprofile")

TARGET_URL = "https://life-os-omega-tan.vercel.app/?transparent=true"

def ensure_config_dir():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    os.makedirs(STORAGE_DIR, exist_ok=True)

class LifeOSExternalPopupPage(QWebEnginePage):
    """Intercepts target='_blank' or window.open links. Routes external links to default browser."""
    def __init__(self, profile, main_window, parent=None):
        super().__init__(profile, parent)
        self.main_window = main_window

    def acceptNavigationRequest(self, url, nav_type, is_main_frame):
        url_str = url.toString()
        if ("localhost:3000" in url_str or "life-os-omega-tan.vercel.app" in url_str):
            if self.main_window and hasattr(self.main_window, "view"):
                self.main_window.view.load(url)
            self.deleteLater()
            return False

        QDesktopServices.openUrl(url)
        self.deleteLater()
        return False

class LifeOSWebPage(QWebEnginePage):
    """Custom WebEnginePage that allows internal navigation while opening external links outside."""
    def __init__(self, profile, main_window, parent=None):
        super().__init__(profile, parent)
        self.main_window = main_window

    def acceptNavigationRequest(self, url, nav_type, is_main_frame):
        url_str = url.toString()

        if ("localhost:3000" in url_str or 
            "life-os-omega-tan.vercel.app" in url_str or
            url_str.startswith("data:") or 
            url_str.startswith("about:blank") or
            url_str.startswith("blob:")):
            return super().acceptNavigationRequest(url, nav_type, is_main_frame)

        QDesktopServices.openUrl(url)
        return False

    def createWindow(self, _type):
        return LifeOSExternalPopupPage(self.profile(), self.main_window, self)

class LifeOSDesktopWidget(QMainWindow):
    def __init__(self):
        super().__init__()
        ensure_config_dir()

        # Window flags: Frameless, stay on desktop bottom forever, tool window (no taskbar item)
        flags = (
            Qt.WindowType.FramelessWindowHint |
            Qt.WindowType.WindowStaysOnBottomHint |
            Qt.WindowType.Tool
        )
        self.setWindowFlags(flags)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground, True)
        self.setWindowTitle("LifeOSDesktop")

        self.init_ui()
        self.init_shortcuts()

    def init_ui(self):
        screen = QApplication.primaryScreen()
        screen_geom = screen.geometry() if screen else None
        screen_w = screen_geom.width() if screen_geom else 1920
        screen_h = screen_geom.height() if screen_geom else 1080

        # Right-most edge: width 940, top margin 46px below KDE status panel (h=44)
        # Height 960px ends at y=1006, cleanly above the bottom taskbar dock (y=1012)
        width = 940
        x = screen_w - width
        y = 46
        height = 960

        self.setGeometry(x, y, width, height)

        self.setStyleSheet("QMainWindow { background-color: transparent; border: none; }")

        central = QWidget(self)
        central.setObjectName("central")
        central.setStyleSheet("QWidget#central { background-color: transparent; border: none; }")
        
        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # WebEngine Profile Setup
        self.profile = QWebEngineProfile("LifeOSDesktopProfile", self)
        self.profile.setPersistentStoragePath(STORAGE_DIR)
        self.profile.setPersistentCookiesPolicy(QWebEngineProfile.PersistentCookiesPolicy.AllowPersistentCookies)
        self.profile.setHttpUserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 LifeOSDesktop/2.0")

        # Inject transparency script at DocumentCreation
        transparency_script = QWebEngineScript()
        transparency_script.setName("LifeOSTransparency")
        transparency_script.setSourceCode("""
            (function() {
                const apply = () => {
                    if (document.documentElement) {
                        document.documentElement.style.backgroundColor = 'transparent';
                        document.documentElement.style.border = 'none';
                        document.documentElement.style.outline = 'none';
                        document.documentElement.classList.add('transparent-widget');
                    }
                    if (document.body) {
                        document.body.style.backgroundColor = 'transparent';
                        document.body.style.border = 'none';
                        document.body.style.outline = 'none';
                        document.body.classList.remove('bg-black');
                        document.body.classList.add('transparent-widget');
                    }
                    if (!document.getElementById('life-os-borderless-fix')) {
                        const target = document.head || document.documentElement;
                        if (target) {
                            const s = document.createElement('style');
                            s.id = 'life-os-borderless-fix';
                            s.textContent = `
                                html, body, .app, .main, .content {
                                    border: none !important;
                                    outline: none !important;
                                    box-shadow: none !important;
                                }
                            `;
                            target.appendChild(s);
                        }
                    }
                };
                apply();
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', apply);
                }
            })();
        """)
        transparency_script.setInjectionPoint(QWebEngineScript.InjectionPoint.DocumentCreation)
        transparency_script.setWorldId(QWebEngineScript.ScriptWorldId.MainWorld)
        transparency_script.setRunsOnSubFrames(False)
        self.profile.scripts().insert(transparency_script)

        # WebEngine View (pure webview, zero header bar, zero border)
        self.view = QWebEngineView(self)
        self.custom_page = LifeOSWebPage(self.profile, self, self.view)
        self.custom_page.setBackgroundColor(QColor(0, 0, 0, 0))
        self.view.setPage(self.custom_page)
        self.view.setStyleSheet("background: transparent; border: none;")

        settings = self.view.settings()
        settings.setAttribute(QWebEngineSettings.WebAttribute.JavascriptEnabled, True)
        settings.setAttribute(QWebEngineSettings.WebAttribute.LocalStorageEnabled, True)
        settings.setAttribute(QWebEngineSettings.WebAttribute.ScrollAnimatorEnabled, True)
        settings.setAttribute(QWebEngineSettings.WebAttribute.WebGLEnabled, True)
        settings.setAttribute(QWebEngineSettings.WebAttribute.Accelerated2dCanvasEnabled, True)

        def on_page_loaded(ok):
            self.view.page().runJavaScript("""
                if (document.documentElement) {
                    document.documentElement.style.backgroundColor = 'transparent';
                    document.documentElement.style.border = 'none';
                    document.documentElement.style.outline = 'none';
                    document.documentElement.classList.add('transparent-widget');
                }
                if (document.body) {
                    document.body.style.backgroundColor = 'transparent';
                    document.body.style.border = 'none';
                    document.body.style.outline = 'none';
                    document.body.classList.remove('bg-black');
                    document.body.classList.add('transparent-widget');
                }
                const target = document.head || document.documentElement;
                if (target && !document.getElementById('life-os-borderless-fix-loaded')) {
                    const s = document.createElement('style');
                    s.id = 'life-os-borderless-fix-loaded';
                    s.textContent = `
                        html, body, .app, .main, .content {
                            border: none !important;
                            outline: none !important;
                            box-shadow: none !important;
                        }
                    `;
                    target.appendChild(s);
                }
            """)
        self.view.loadFinished.connect(on_page_loaded)

        main_layout.addWidget(self.view)
        self.setCentralWidget(central)

        self.view.load(QUrl(TARGET_URL))

    def init_shortcuts(self):
        QShortcut(QKeySequence("Ctrl+R"), self, self.view.reload)
        QShortcut(QKeySequence("F5"), self, self.view.reload)

    def closeEvent(self, event):
        # Ignore close requests so the desktop widget stays active forever
        event.ignore()

def main():
    os.environ["QT_AUTO_SCREEN_SCALE_FACTOR"] = "1"
    os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = (
        "--enable-gpu-rasterization --enable-zero-copy --ignore-gpu-blocklist --canvas-oop-rasterization"
    )
    app = QApplication(sys.argv)
    app.setApplicationName("lifeosdesktop")
    app.setDesktopFileName("life-os")
    app.setQuitOnLastWindowClosed(False)

    window = LifeOSDesktopWidget()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
