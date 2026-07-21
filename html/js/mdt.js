/* ========================================
   MDT JAVASCRIPT
   ======================================== */

let mdtOpen = false;
let currentVehicle = null;
let currentPlayer = null;

// Initialize MDT
document.addEventListener('DOMContentLoaded', function() {
    setupTabs();
    setupEventListeners();
    setupNUICallbacks();
});

// ========================================
// TAB SYSTEM
// ========================================

function setupTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            
            // Remove active class
            tabBtns.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            
            // Add active class
            this.classList.add('active');
            document.getElementById(tabName + '-tab').classList.add('active');
        });
    });
}

// ========================================
// EVENT LISTENERS
// ========================================

function setupEventListeners() {
    // Close MDT
    document.getElementById('close-mdt').addEventListener('click', function() {
        closeMDT();
    });

    // Vehicle Search
    document.getElementById('search-vehicle').addEventListener('click', searchVehicle);
    document.getElementById('vehicle-plate').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') searchVehicle();
    });

    // Player Search
    document.getElementById('search-player').addEventListener('click', searchPlayer);
    document.getElementById('player-search').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') searchPlayer();
    });

    // Refresh Calls
    document.getElementById('refresh-calls').addEventListener('click', loadDispatchCalls);

    // Add Note
    document.getElementById('add-note').addEventListener('click', addNote);

    // Wanted Search
    document.getElementById('search-wanted').addEventListener('click', searchWanted);
    document.getElementById('wanted-search').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') searchWanted();
    });

    // Load initial data
    loadDispatchCalls();
}

// ========================================
// VEHICLE SEARCH
// ========================================

function searchVehicle() {
    const plate = document.getElementById('vehicle-plate').value.trim();
    
    if (!plate) {
        showNotification('Írd be a rendszámot!', 'error');
        return;
    }

    postNUI('searchVehicle', { plate: plate });
}

// ========================================
// PLAYER SEARCH
// ========================================

function searchPlayer() {
    const searchTerm = document.getElementById('player-search').value.trim();
    
    if (!searchTerm) {
        showNotification('Írd be a játékos nevét!', 'error');
        return;
    }

    postNUI('searchPlayers', { name: searchTerm });
}

function selectPlayer(identifier) {
    postNUI('searchPlayer', { identifier: identifier });
}

// ========================================
// DISPATCH CALLS
// ========================================

function loadDispatchCalls() {
    postNUI('getDispatchCalls', {});
}

function acceptCall(callId) {
    postNUI('acceptCall', { callId: callId });
}

function closeCall(callId) {
    postNUI('closeCall', { callId: callId });
}

// ========================================
// NOTES
// ========================================

function addNote() {
    const noteText = document.getElementById('notes-input').value.trim();
    
    if (!noteText) {
        showNotification('Írj be egy megjegyzést!', 'error');
        return;
    }

    if (!currentPlayer) {
        showNotification('Válassz ki egy játékost!', 'error');
        return;
    }

    postNUI('addNote', {
        citizenId: currentPlayer.identifier,
        note: noteText
    });

    document.getElementById('notes-input').value = '';
}

// ========================================
// DISPATCH DISPLAY
// ========================================

function displayDispatchCalls(calls) {
    const list = document.getElementById('dispatch-list');
    
    if (!calls || calls.length === 0) {
        list.innerHTML = '<p class="placeholder">Nincsenek aktív hívások...</p>';
        return;
    }

    list.innerHTML = calls.map(call => `
        <div class="call-item">
            <div class="call-type">${call.call_type}</div>
            <div class="call-description">${call.description}</div>
            <div class="call-meta">
                <span>📍 Koordináta: ${call.coords}</span>
                <span>👤 ${call.created_by}</span>
            </div>
            <div style="display: flex; gap: 10px; margin-top: 10px;">
                <button onclick="acceptCall(${call.id})" class="add-btn" style="flex: 1; padding: 8px;">Elfogadom</button>
                <button onclick="closeCall(${call.id})" class="add-btn" style="flex: 1; padding: 8px;">Lezárom</button>
            </div>
        </div>
    `).join('');
}

// ========================================
// VEHICLE DISPLAY
// ========================================

function displayVehicleInfo(vehicle) {
    const box = document.getElementById('vehicle-info');
    
    if (!vehicle) {
        box.innerHTML = '<p class="placeholder">Jármű nem található...</p>';
        return;
    }

    currentVehicle = vehicle;

    box.innerHTML = `
        <div class="info-item">
            <div class="info-label">Rendszám</div>
            <div class="info-value">${vehicle.plate}</div>
        </div>
        <div class="info-item">
            <div class="info-label">Jármű Típusa</div>
            <div class="info-value">${vehicle.model}</div>
        </div>
        <div class="info-item">
            <div class="info-label">Tulajdonos</div>
            <div class="info-value">${vehicle.owner_name || 'Ismeretlen'}</div>
        </div>
        <div class="info-item">
            <div class="info-label">Tulajdonos ID</div>
            <div class="info-value">${vehicle.owner_id || 'N/A'}</div>
        </div>
    `;
}

// ========================================
// PLAYER DISPLAY
// ========================================

function displayPlayerResults(results) {
    const list = document.getElementById('player-results');
    
    if (!results || results.length === 0) {
        list.innerHTML = '<p class="placeholder">Nincs találat...</p>';
        return;
    }

    list.innerHTML = results.map(player => `
        <div class="result-item" onclick="selectPlayer('${player.identifier}')">
            <div style="font-weight: 600; color: #00ff9f;">${player.firstname} ${player.lastname}</div>
            <div style="font-size: 12px; color: rgba(224, 224, 224, 0.7);">ID: ${player.identifier}</div>
        </div>
    `).join('');
}

function displayPlayerInfo(player) {
    const box = document.getElementById('player-info');
    
    if (!player) {
        document.getElementById('player-tab').innerHTML = '<p class="placeholder">Játékos nem található...</p>';
        return;
    }

    currentPlayer = player;

    // Update player tab with info
    document.getElementById('player-tab').innerHTML = `
        <div style="height: 100%; overflow-y: auto;">
            <div class="info-item">
                <div class="info-label">Név</div>
                <div class="info-value">${player.firstname} ${player.lastname}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Identifier</div>
                <div class="info-value">${player.identifier}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Körözési Szint</div>
                <div class="info-value">${player.wanted_level || 0} csillag</div>
            </div>
            ${player.wanted_reason ? `
            <div class="info-item">
                <div class="info-label">Körözés Oka</div>
                <div class="info-value">${player.wanted_reason}</div>
            </div>
            ` : ''}
            ${player.jail_time ? `
            <div class="info-item">
                <div class="info-label">Börtön Ideje</div>
                <div class="info-value">${player.jail_time} másodperc</div>
            </div>
            <div class="info-item">
                <div class="info-label">Börtön Oka</div>
                <div class="info-value">${player.jail_reason}</div>
            </div>
            ` : ''}
        </div>
    `;

    // Load player notes
    postNUI('getNotes', { citizenId: player.identifier });
}

// ========================================
// WANTED DISPLAY
// ========================================

function displayWantedList(results) {
    const list = document.getElementById('wanted-list');
    
    if (!results || results.length === 0) {
        list.innerHTML = '<p class="placeholder">Nincsenek körözöttek...</p>';
        return;
    }

    list.innerHTML = results.map(wanted => `
        <div class="wanted-item">
            <div style="font-weight: 600; color: #00ff9f;">${wanted.firstname} ${wanted.lastname}</div>
            <div style="font-size: 12px; color: #ff6b6b;">🚨 ${wanted.wanted_level} csillag</div>
            <div style="font-size: 11px; color: rgba(224, 224, 224, 0.7);">Oka: ${wanted.wanted_reason}</div>
        </div>
    `).join('');
}

function searchWanted() {
    // Load all wanted players from server
    postNUI('getWanted', {});
}

// ========================================
// NUI CALLBACKS
// ========================================

function setupNUICallbacks() {
    window.addEventListener('message', function(event) {
        const data = event.data;

        if (data.action === 'vehicleInfoResponse') {
            displayVehicleInfo(data.data);
        }

        if (data.action === 'playerInfoResponse') {
            displayPlayerInfo(data.data);
        }

        if (data.action === 'dispatchCallsResponse') {
            displayDispatchCalls(data.data);
        }

        if (data.action === 'searchResultsResponse') {
            displayPlayerResults(data.data);
        }

        if (data.action === 'notesResponse') {
            displayNotes(data.data);
        }

        if (data.action === 'openMDT') {
            openMDT();
        }

        if (data.action === 'closeMDT') {
            closeMDT();
        }
    });
}

// ========================================
// MDT OPEN/CLOSE
// ========================================

function openMDT() {
    document.getElementById('mdt-container').style.display = 'flex';
    mdtOpen = true;
}

function closeMDT() {
    document.getElementById('mdt-container').style.display = 'none';
    mdtOpen = false;
    postNUI('closeMDT', {});
}

// ========================================
// DISPLAY NOTES
// ========================================

function displayNotes(notes) {
    const list = document.getElementById('notes-list');
    
    if (!notes || notes.length === 0) {
        list.innerHTML = '<p class="placeholder">Nincsenek megjegyzések...</p>';
        return;
    }

    list.innerHTML = notes.map(note => `
        <div class="note-item">
            <div style="font-size: 11px; color: rgba(224, 224, 224, 0.5);">📅 ${note.created_by}</div>
            <div style="margin-top: 5px;">${note.note}</div>
        </div>
    `).join('');
}

// ========================================
// POST NUI
// ========================================

function postNUI(action, data) {
    fetch(`https://${GetParentResourceName()}/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            action: action,
            ...data
        })
    }).then(resp => resp.json()).then(resp => {});
}

// ========================================
// NOTIFICATIONS
// ========================================

function showNotification(message, type = 'info') {
    console.log(`[${type.toUpperCase()}] ${message}`);
}

// Get parent resource name
function GetParentResourceName() {
    return 'fivem-dispatch-mdt-police';
}
