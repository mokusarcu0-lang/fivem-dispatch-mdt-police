/* ========================================
   DISPATCH JAVASCRIPT
   ======================================== */

class DispatchSystem {
    constructor() {
        this.activeCalls = [];
        this.selectedCall = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadCalls();
    }

    setupEventListeners() {
        // Auto-refresh every 30 seconds
        setInterval(() => this.loadCalls(), 30000);
    }

    loadCalls() {
        postNUI('getDispatchCalls', {});
    }

    acceptCall(callId) {
        postNUI('acceptCall', { callId });
        this.showNotification('Hívás elfogadva!', 'success');
    }

    closeCall(callId) {
        postNUI('closeCall', { callId });
        this.showNotification('Hívás lezárva!', 'success');
    }

    showNotification(message, type) {
        console.log(`[${type}] ${message}`);
    }
}

// Initialize dispatch system
const dispatchSystem = new DispatchSystem();
