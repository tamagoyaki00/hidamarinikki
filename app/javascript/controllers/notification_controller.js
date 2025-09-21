import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { externalId: String }
  static targets = ["toggle", "settingsForm"]

  connect() {
    // OneSignalの読み込み待ち処理を改善
    this.waitForOneSignal();
  }

  waitForOneSignal() {
    // OneSignalが既に利用可能かチェック
    if (this.isOneSignalReady()) {
      this.setupToggle();
      return;
    }

    // OneSignalの読み込みを待つ（最大10秒）
    let attempts = 0;
    const maxAttempts = 50; // 10秒 (200ms × 50回)
    
    const checkInterval = setInterval(() => {
      attempts++;
      if (this.isOneSignalReady()) {
        clearInterval(checkInterval);
        this.setupToggle();
      } else if (attempts >= maxAttempts) {
        clearInterval(checkInterval);
        this.handleOneSignalError();
      }
    }, 200);
  }

  isOneSignalReady() {
    return typeof OneSignal !== 'undefined' && 
           OneSignal.initialized === true &&
           OneSignal.User && 
           OneSignal.User.PushSubscription &&
           typeof OneSignal.User.PushSubscription.optIn === 'function';
  }

  async setupToggle() {
    try {
      // 現在の購読状態を取得
      const isOptedIn = OneSignal.User.PushSubscription.optedIn;
      
      // トグルボタンの状態を設定
      const toggleElement = this.element.querySelector('[data-notification-target="toggle"]');
      if (toggleElement) {
        toggleElement.checked = isOptedIn;
      } else {
        return;
      }

      this.updateSettingsFormVisibility(isOptedIn);

      // トグルを有効化
      this.enableToggle(true);
    } catch (error) {
      this.enableToggle(false);
    }
  }

  enableToggle(enabled) {
    const toggleElement = this.element.querySelector('[data-notification-target="toggle"]');
    if (toggleElement) {
      toggleElement.disabled = !enabled;
    }
  }

  async toggle() {
    try {
      // OneSignalの準備状態を確認
      if (!this.isOneSignalReady()) {
        this.toggleTarget.checked = !this.toggleTarget.checked;
        this.updateSettingsFormVisibility(this.toggleTarget.checked);
        return;
      }
      
      const isCurrentlyOptedIn = OneSignal.User.PushSubscription.optedIn;
      const newState = this.toggleTarget.checked;
      
      // 状態が変更された場合のみ処理を実行
      if (newState !== isCurrentlyOptedIn) {
        this.toggleTarget.disabled = true; // 処理中は無効化
        
        if (newState) {
          // 通知をONにする
          await OneSignal.User.PushSubscription.optIn();
        } else {
          // 通知をOFFにする
          await OneSignal.User.PushSubscription.optOut();
        }
        
        // 状態を再確認して表示を更新
        const finalState = OneSignal.User.PushSubscription.optedIn;
        this.toggleTarget.checked = finalState;
        this.updateSettingsFormVisibility(finalState);
        
        // サーバーに状態を保存
        await this.saveNotificationState(finalState);
      }
    } catch (error) {
      // エラー時は元の状態に戻す
      const currentState = OneSignal.User.PushSubscription?.optedIn || false;
      this.toggleTarget.checked = currentState;
      this.updateSettingsFormVisibility(currentState);
      
    } finally {
      // トグルを再度有効化
      this.toggleTarget.disabled = false;
    }
  }

  // サーバーに状態を保存するメソッド
  async saveNotificationState(enabled) {
    try {
      await fetch('/notification_setting', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          notification_setting: {
            reminder_enabled: enabled
          }
        })
      });
    } catch (error) {}
  }

  updateSettingsFormVisibility(isEnabled) {
    console.log("updateSettingsFormVisibility called. isEnabled:", isEnabled);
    if (this.hasSettingsFormTarget) {
      console.log("settingsFormTarget found:", this.settingsFormTarget);
      this.settingsFormTarget.classList.toggle("hidden", !isEnabled);
    } else {
      console.warn("settingsFormTarget not found!");
    }
  }
}
