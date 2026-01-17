from PyQt6.QtCore import QTimer, Qt
from PyQt6.QtGui import QColor, QPainter
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton, QVBoxLayout, QWidget


from PyQt6.QtCore import QTimer, Qt
from PyQt6.QtGui import QColor, QPainter, QFont
from PyQt6.QtWidgets import QLabel, QWidget


class CircleLoading(QWidget):
    """加载动画 + 文本提示"""
    def __init__(self, size=20, color=QColor(229, 46, 55), clockwise=True, parent=None):
        super().__init__(parent)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)   # 背景透明
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint
            | Qt.WindowType.BypassWindowManagerHint
            | Qt.WindowType.Tool
            | Qt.WindowType.WindowStaysOnTopHint
        )
        self.setFixedSize(size + 200, size + 80)  # 给文字留空间

        self.angle = 0
        self.clockwise = clockwise
        self.color = color
        self.delta = 36

        # 添加文字提示标签
        self.label = QLabel("EcoAmp is Starting...", self)
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.setStyleSheet("""
            QLabel {
                color: rgb(229, 46, 55);                  /* 红色字体 */
                background-color: rgba(0, 0, 0, 160);     /* 半透明黑色背景 */
                border-radius: 10px;                      /* 圆角背景 */
                padding: 0px 6px;                        /* 内边距 */
            }
        """)
        font = QFont()
        font.setBold(True)  # 加粗
        font.setPointSize(12)  # 设置字体大小
        self.label.setFont(font)
        self.label.adjustSize()
        self.label.move(
            (self.width() - self.label.width()) // 2,
            self.height() - self.label.height() - 10
        )

        self._timer = QTimer(self, timeout=self.update)

    def start(self):
        self._timer.start(100)
        self.show()

    def stop(self):
        self._timer.stop()
        self.close()

    def paintEvent(self, _):
        qp = QPainter(self)
        qp.setRenderHint(QPainter.RenderHint.Antialiasing)
        qp.translate(self.width() / 2, self.height() / 2 - 10)
        side = min(self.width(), self.height()) - 40
        qp.scale(side / 100.0, side / 100.0)
        qp.rotate(self.angle)
        qp.save()
        qp.setPen(Qt.PenStyle.NoPen)
        color = self.color.toRgb()
        for i in range(11):
            color.setAlphaF(i / 10.0)
            qp.setBrush(color)
            qp.drawEllipse(30, -10, 20, 20)
            qp.rotate(36)
        qp.restore()
        self.angle = (self.angle + (self.delta if self.clockwise else -self.delta)) % 360


# 在类外加上
def run_app():
    import sys
    app = QApplication(sys.argv)
    loading = CircleLoading()
    loading.start()

    # 6秒后关闭动画并退出程序
    QTimer.singleShot(8000, lambda: (loading.stop(), app.quit()))

    sys.exit(app.exec())


# 修改原来的 main
if __name__ == "__main__":
    run_app()