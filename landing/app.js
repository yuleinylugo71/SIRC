/**
 * SIRC - Interactive Simulator & Page Logic
 */

document.addEventListener('DOMContentLoaded', () => {
  // State management for simulator
  const state = {
    isOnline: true,
    localRecords: [
      {
        id: '1029384756',
        nombres: 'María Elena',
        apellidos: 'Gómez Restrepo',
        telefono: '+57 312 987 6543',
        correo: 'maria.gomez@ejemplo.com',
        estadoSincronizacion: 'SINCRONIZADO',
        registradoEn: 'DISP-8921',
        createdAt: new Date(Date.now() - 3600000).toLocaleTimeString()
      },
      {
        id: '1098765432',
        nombres: 'Juan Pablo',
        apellidos: 'Rodríguez Silva',
        telefono: '+57 301 555 0192',
        correo: 'juan.rodriguez@ejemplo.com',
        estadoSincronizacion: 'PENDIENTE',
        registradoEn: 'DISP-8921',
        createdAt: new Date().toLocaleTimeString()
      }
    ],
    cloudRecords: [
      {
        id: '1029384756',
        nombres: 'María Elena',
        apellidos: 'Gómez Restrepo',
        registradoEn: 'DISP-8921',
        serverDate: new Date(Date.now() - 3600000).toLocaleTimeString()
      }
    ],
    logs: [
      {
        time: new Date().toLocaleTimeString(),
        type: 'info',
        msg: 'Demón de sincronización iniciado. Estado red: ONLINE.'
      }
    ]
  };

  // DOM Elements
  const networkToggle = document.getElementById('network-toggle');
  const networkIndicator = document.getElementById('network-indicator');
  const simForm = document.getElementById('sim-form');
  
  const localCountEl = document.getElementById('local-count');
  const cloudCountEl = document.getElementById('cloud-count');
  const logCountEl = document.getElementById('log-count');

  const localRecordsBody = document.getElementById('local-records-body');
  const cloudRecordsBody = document.getElementById('cloud-records-body');
  const logStreamBody = document.getElementById('log-stream-body');

  const localEmptyState = document.getElementById('local-empty');
  const cloudEmptyState = document.getElementById('cloud-empty');

  const dbTabs = document.querySelectorAll('.db-tab');
  const tabContents = document.querySelectorAll('.tab-content');

  // Network Toggle Listener
  networkToggle.addEventListener('change', (e) => {
    state.isOnline = e.target.checked;
    
    if (state.isOnline) {
      networkIndicator.className = 'badge-status online';
      networkIndicator.innerHTML = '<i class="fa-solid fa-wifi"></i> ONLINE';
      addLog('success', 'Conexión a internet restablecida. Iniciando verificación de pendientes...');
      triggerBackgroundSync();
    } else {
      networkIndicator.className = 'badge-status offline';
      networkIndicator.innerHTML = '<i class="fa-solid fa-wifi-slash"></i> OFFLINE';
      addLog('warning', 'Modo OFFLINE activado. Todos los registros se almacenarán localmente en SQLite.');
    }
  });

  // Tab Switching
  dbTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      dbTabs.forEach(t => t.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));

      tab.classList.add('active');
      const targetId = tab.getAttribute('data-tab');
      document.getElementById(targetId).classList.add('active');
    });
  });

  // Form Submission
  simForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const docId = document.getElementById('docId').value.trim();
    const nombres = document.getElementById('nombres').value.trim();
    const apellidos = document.getElementById('apellidos').value.trim();
    const telefono = document.getElementById('telefono').value.trim();
    const correo = document.getElementById('correo').value.trim();

    // Check duplicate in local DB
    if (state.localRecords.some(r => r.id === docId)) {
      alert(`El ciudadano con documento ${docId} ya se encuentra registrado localmente.`);
      return;
    }

    const newRecord = {
      id: docId,
      nombres,
      apellidos,
      telefono,
      correo,
      estadoSincronizacion: state.isOnline ? 'SINCRONIZADO' : 'PENDIENTE',
      registradoEn: 'DISP-8921',
      createdAt: new Date().toLocaleTimeString()
    };

    state.localRecords.unshift(newRecord);
    addLog('info', `Nuevo registro guardado en SQLite local [ID: ${docId}] (${state.isOnline ? 'Sincronización Inmediata' : 'Pendiente Sincronización'})`);

    if (state.isOnline) {
      // Sync immediately to cloud
      state.cloudRecords.unshift({
        id: docId,
        nombres: `${nombres} ${apellidos}`,
        registradoEn: 'DISP-8921',
        serverDate: new Date().toLocaleTimeString()
      });
      addLog('success', `HTTP 201 Created: Registro ${docId} enviado exitosamente al backend PostgreSQL.`);
    }

    // Reset Form
    simForm.reset();
    renderUI();
  });

  // Manual Trigger Sync per record
  window.syncSingleRecord = (docId) => {
    if (!state.isOnline) {
      alert('Imposible sincronizar: El dispositivo se encuentra OFFLINE.');
      return;
    }

    const record = state.localRecords.find(r => r.id === docId);
    if (record && record.estadoSincronizacion === 'PENDIENTE') {
      record.estadoSincronizacion = 'SINCRONIZADO';
      state.cloudRecords.unshift({
        id: record.id,
        nombres: `${record.nombres} ${record.apellidos}`,
        registradoEn: record.registradoEn,
        serverDate: new Date().toLocaleTimeString()
      });
      addLog('success', `Registro ${docId} sincronizado manualmente a PostgreSQL.`);
      renderUI();
    }
  };

  // Background Sync Engine Simulation
  function triggerBackgroundSync() {
    if (!state.isOnline) return;

    const pending = state.localRecords.filter(r => r.estadoSincronizacion === 'PENDIENTE');
    if (pending.length === 0) return;

    addLog('info', `Procesando lote de ${pending.length} registro(s) pendiente(s)...`);

    setTimeout(() => {
      pending.forEach(record => {
        record.estadoSincronizacion = 'SINCRONIZADO';
        state.cloudRecords.unshift({
          id: record.id,
          nombres: `${record.nombres} ${record.apellidos}`,
          registradoEn: record.registradoEn,
          serverDate: new Date().toLocaleTimeString()
        });
      });

      addLog('success', `Sincronización completada. ${pending.length} registro(s) actualizados a SINCRONIZADO en Prisma backend.`);
      renderUI();
    }, 1200);
  }

  // Logger helper
  function addLog(type, msg) {
    state.logs.unshift({
      time: new Date().toLocaleTimeString(),
      type,
      msg
    });
    renderLogs();
  }

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (char) => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    })[char]);
  }

  // UI Renderer
  function renderUI() {
    // Counts
    localCountEl.textContent = state.localRecords.length;
    cloudCountEl.textContent = state.cloudRecords.length;
    logCountEl.textContent = state.logs.length;

    // Render Local Records
    if (state.localRecords.length === 0) {
      localEmptyState.style.display = 'block';
      localRecordsBody.innerHTML = '';
    } else {
      localEmptyState.style.display = 'none';
      localRecordsBody.innerHTML = state.localRecords.map(r => {
        const isSynced = r.estadoSincronizacion === 'SINCRONIZADO';
        return `
        <tr>
          <td><strong>${escapeHtml(r.id)}</strong></td>
          <td>${escapeHtml(r.nombres)} ${escapeHtml(r.apellidos)}</td>
          <td>
            <span class="status-badge ${isSynced ? 'sync' : 'pending'}">
              ${isSynced ? '<i class="fa-solid fa-check"></i> Sincronizado' : '<i class="fa-solid fa-clock"></i> Pendiente'}
            </span>
          </td>
          <td>
            ${!isSynced
              ? `<button onclick="syncSingleRecord('${escapeHtml(r.id)}')" class="btn btn-secondary btn-table"><i class="fa-solid fa-sync"></i> Subir</button>` 
              : '<span class="status-badge sync"><i class="fa-solid fa-check"></i> OK</span>'}
          </td>
        </tr>
      `;
      }).join('');
    }

    // Render Cloud Records
    if (state.cloudRecords.length === 0) {
      cloudEmptyState.style.display = 'block';
      cloudRecordsBody.innerHTML = '';
    } else {
      cloudEmptyState.style.display = 'none';
      cloudRecordsBody.innerHTML = state.cloudRecords.map(c => `
        <tr>
          <td><strong>${escapeHtml(c.id)}</strong></td>
          <td>${escapeHtml(c.nombres)}</td>
          <td><span class="status-badge sync">${escapeHtml(c.registradoEn)}</span></td>
          <td>${escapeHtml(c.serverDate)}</td>
        </tr>
      `).join('');
    }

    renderLogs();
  }

  function renderLogs() {
    logStreamBody.innerHTML = state.logs.map(l => `
      <div class="log-entry ${escapeHtml(l.type)}">
        <span class="log-time">[${escapeHtml(l.time)}]</span>
        <span class="log-msg">${escapeHtml(l.msg)}</span>
      </div>
    `).join('');
  }

  // Initial Render
  renderUI();
});
