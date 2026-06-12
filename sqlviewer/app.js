/* ============================================================
   Visor SQL (web plana, estilo SSMS) - lógica + puente PowerBuilder
   - Editor: CodeMirror 5 (lib/), dialecto MSSQL, con zoom de letra.
   - Resultados: Tabulator (ordenar, mover/redimensionar columnas, filtros
     tipo Ag-Grid, menús contextuales, exportar a Excel vía PB).
   - MODO ASISTIDO (w_con_sqlasistido): paneles de Tablas y Campos que
     autogeneran el SELECT; edición (insert/update/delete) si el select es
     completo de una sola tabla.
   ============================================================ */
(function () {
  'use strict';

  var cm = null;
  var table = null;
  var state = { columns: [], rows: [] };
  var pageReady = false;
  var paneState = 'split';
  var activeFilters = {};
  var typeByField = {};
  var filterPop = null;

  // Modo asistido
  var asistido = false;
  var tablas = [];
  var campos = [];
  var tablaActual = '';
  var editableInfo = { editable: false };

  function el(id) { return document.getElementById(id); }

  function esc(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function cellText(v) { return (v === null || v === undefined) ? 'NULL' : String(v); }

  // ---------- Puente JS -> PowerBuilder ----------
  function bridge(nombre, payload) {
    try {
      var b = window.webBrowser;
      if (b && b.asyncfun && b.asyncfun.prototype && b.asyncfun.prototype[nombre]) {
        b.asyncfun.prototype[nombre](payload == null ? '' : payload);
        return true;
      }
    } catch (e) { console.error(e); }
    return false;
  }

  function normalize(input) {
    if (Array.isArray(input)) return input;
    if (typeof input === 'string') { try { return JSON.parse(input); } catch (e) { return []; } }
    return [];
  }

  // ---------- UI ----------
  function setStatus(text, isError) {
    var s = el('status');
    s.textContent = text || '';
    s.className = 'status' + (isError ? ' error' : '');
  }

  function setBusy(b) {
    var btn = el('btnRun');
    btn.disabled = !!b;
    btn.innerHTML = b ? '⌛ Ejecutando…' : '▶ Ejecutar';
  }

  function setMsg(text, isError) {
    var m = el('resultsMsg');
    m.textContent = text || '';
    m.className = 'results-msg' + (isError ? ' error' : '');
  }

  function destroyTable() {
    if (table) { try { table.destroy(); } catch (e) {} table = null; }
    el('results').classList.remove('has-data');
  }

  function cellFormatter(cell) {
    var v = cell.getValue();
    if (v === null || v === undefined) return '<span class="tnull">NULL</span>';
    return esc(String(v));
  }

  // ---------- Iconos (SVG monocromo) ----------
  var ICON = {
    copy: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/></svg>',
    rows: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="3" y="5" width="18" height="5" rx="1"/><rect x="3" y="14" width="18" height="5" rx="1"/></svg>',
    all:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="3" y="4" width="18" height="16" rx="1"/><path d="M3 9.5h18M3 15h18M9 4v16"/></svg>',
    asc:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 19V5M7 10l5-5 5 5"/></svg>',
    desc: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 5v14M7 14l5 5 5-5"/></svg>',
    hide: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 3l18 18M10.6 10.6a2 2 0 0 0 2.8 2.8M9.9 5.2A8.8 8.8 0 0 1 21 12a9 9 0 0 1-2 2.7M6 6.2A8.9 8.9 0 0 0 3 12a8.9 8.9 0 0 0 9 6"/></svg>',
    show: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="2.6"/></svg>',
    filter: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 5h18l-7 8v5l-4 2v-7z"/></svg>',
    excel:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/><path d="M9.5 13l5 5M14.5 13l-5 5"/></svg>',
    edit: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>'
  };
  function mi(svg, text, cls) { return '<span class="mi' + (cls ? ' ' + cls : '') + '">' + svg + '</span>' + text; }

  // ---------- Menús contextuales ----------
  // Demo: sin "Editar registro…" (la ficha de mantenimiento no entra en esta versión)
  var menuCelda = [
    { label: mi(ICON.copy, 'Copiar celda'), action: function (e, cell) { copyText(cellText(cell.getValue())); setStatus('Celda copiada.'); } },
    { label: mi(ICON.rows, 'Copiar fila(s)'), action: function (e, cell) { copiarFilas(cell.getRow()); } },
    { label: mi(ICON.all, 'Copiar todo (con cabeceras)'), action: function () { copiarTodo(); } },
    { separator: true },
    { label: mi(ICON.excel, 'Exportar a Excel…', 'excel'), action: function () { exportarExcel(); } }
  ];
  var menuCabecera = [
    { label: mi(ICON.asc, 'Ordenar ascendente'), action: function (e, col) { col.getTable().setSort(col.getField(), 'asc'); } },
    { label: mi(ICON.desc, 'Ordenar descendente'), action: function (e, col) { col.getTable().setSort(col.getField(), 'desc'); } },
    { separator: true },
    { label: mi(ICON.hide, 'Ocultar columna'), action: function (e, col) { col.hide(); } },
    { label: mi(ICON.show, 'Mostrar todas las columnas'), action: function (e, col) { col.getTable().getColumns().forEach(function (c) { c.show(); }); } },
    { separator: true },
    { label: mi(ICON.filter, 'Limpiar filtros'), action: function () { activeFilters = {}; applyFilters(); } },
    { separator: true },
    { label: mi(ICON.excel, 'Exportar a Excel…', 'excel'), action: function () { exportarExcel(); } }
  ];

  // ---------- Filtros por columna (estilo Ag-Grid: embudo + popup) ----------
  var OPS_STR = [
    { v: 'like', t: 'Contiene' }, { v: 'nlike', t: 'No contiene' },
    { v: '=', t: 'Igual a' }, { v: '!=', t: 'Distinto de' },
    { v: 'starts', t: 'Empieza por' }, { v: 'ends', t: 'Termina por' }
  ];
  var OPS_NUM = [
    { v: '=', t: '=' }, { v: '!=', t: '≠' }, { v: '>', t: '>' },
    { v: '>=', t: '≥' }, { v: '<', t: '<' }, { v: '<=', t: '≤' }
  ];

  function matchOp(value, op, target, type) {
    if (type === 'number') {
      var t = parseFloat(target);
      if (isNaN(t)) return true;
      var n = parseFloat(value);
      if (value === null || value === undefined || isNaN(n)) return false;
      switch (op) {
        case '=': return n === t; case '!=': return n !== t;
        case '>': return n > t; case '>=': return n >= t;
        case '<': return n < t; case '<=': return n <= t;
        default: return true;
      }
    }
    var q = String(target).toLowerCase();
    if (q === '') return true;
    var s = (value === null || value === undefined) ? '' : String(value).toLowerCase();
    switch (op) {
      case 'like': return s.indexOf(q) >= 0;
      case 'nlike': return s.indexOf(q) < 0;
      case '=': return s === q;
      case '!=': return s !== q;
      case 'starts': return s.indexOf(q) === 0;
      case 'ends': return s.length >= q.length && s.lastIndexOf(q) === s.length - q.length;
      default: return true;
    }
  }

  function actualizarRowinfo() {
    if (!table) return;
    var total = state.rows.length, vis = total;
    try { vis = table.getDataCount('active'); } catch (e) {}
    el('rowinfo').textContent = (vis === total)
      ? total.toLocaleString('es-ES') + ' fila' + (total === 1 ? '' : 's')
      : vis.toLocaleString('es-ES') + ' de ' + total.toLocaleString('es-ES') + ' filas';
  }

  function applyFilters() {
    if (!table) return;
    var keys = Object.keys(activeFilters);
    if (!keys.length) { table.clearFilter(); }
    else {
      table.setFilter(function (data) {
        for (var i = 0; i < keys.length; i++) {
          var f = activeFilters[keys[i]];
          if (!matchOp(data[keys[i]], f.op, f.value, f.type)) return false;
        }
        return true;
      });
    }
    updateFunnels();
    actualizarRowinfo();
  }

  function updateFunnels() {
    var els = document.querySelectorAll('#grid .th-filter');
    for (var i = 0; i < els.length; i++) {
      var f = els[i].getAttribute('data-field');
      els[i].classList.toggle('active', !!activeFilters[f]);
    }
  }

  function hidePopup() { if (filterPop) filterPop.style.display = 'none'; }

  function ensurePopup() {
    if (filterPop) return filterPop;
    var p = document.createElement('div');
    p.className = 'filter-pop';
    p.style.display = 'none';
    p.innerHTML =
      '<div class="fpop-title"></div>' +
      '<select class="fpop-op"></select>' +
      '<input class="fpop-val" type="text" placeholder="valor…" />' +
      '<div class="fpop-btns"><button class="fpop-clear">Limpiar</button><button class="fpop-apply">Aplicar</button></div>';
    document.body.appendChild(p);
    filterPop = p;
    p.addEventListener('mousedown', function (e) { e.stopPropagation(); });
    p.querySelector('.fpop-apply').addEventListener('click', function () {
      var field = p.getAttribute('data-field'), type = p.getAttribute('data-type');
      var op = p.querySelector('.fpop-op').value, val = p.querySelector('.fpop-val').value;
      if (String(val).trim() === '') delete activeFilters[field];
      else activeFilters[field] = { op: op, value: val, type: type };
      applyFilters();
      hidePopup();
    });
    p.querySelector('.fpop-clear').addEventListener('click', function () {
      delete activeFilters[p.getAttribute('data-field')];
      applyFilters();
      hidePopup();
    });
    p.querySelector('.fpop-val').addEventListener('keydown', function (e) {
      if (e.key === 'Enter') p.querySelector('.fpop-apply').click();
      else if (e.key === 'Escape') hidePopup();
    });
    document.addEventListener('mousedown', function () { hidePopup(); });
    return p;
  }

  function openFilterPopup(field, type, title, anchorEl) {
    var p = ensurePopup();
    p.setAttribute('data-field', field);
    p.setAttribute('data-type', type);
    p.querySelector('.fpop-title').textContent = 'Filtrar: ' + title;
    var ops = (type === 'number') ? OPS_NUM : OPS_STR;
    var sel = p.querySelector('.fpop-op');
    sel.innerHTML = ops.map(function (o) { return '<option value="' + o.v + '">' + o.t + '</option>'; }).join('');
    var cur = activeFilters[field], inp = p.querySelector('.fpop-val');
    sel.value = cur ? cur.op : ops[0].v;
    inp.type = (type === 'number') ? 'number' : 'text';
    inp.value = cur ? cur.value : '';
    p.style.display = 'flex';
    var r = anchorEl.getBoundingClientRect();
    var w = p.offsetWidth || 210;
    p.style.left = Math.max(8, Math.min(r.left, window.innerWidth - w - 8)) + 'px';
    p.style.top = (r.bottom + 3) + 'px';
    setTimeout(function () { inp.focus(); inp.select(); }, 0);
  }

  function headerTitleFormatter(cell) {
    var field = cell.getColumn().getField();
    var wrap = document.createElement('span');
    wrap.className = 'th-wrap';
    var ttl = document.createElement('span');
    ttl.className = 'th-title';
    ttl.textContent = cell.getValue();
    var fil = document.createElement('span');
    fil.className = 'th-filter' + (activeFilters[field] ? ' active' : '');
    fil.setAttribute('data-field', field);
    fil.title = 'Filtrar columna';
    fil.innerHTML = ICON.filter;
    fil.addEventListener('mousedown', function (e) { e.stopPropagation(); });
    fil.addEventListener('click', function (e) {
      e.stopPropagation();
      openFilterPopup(field, typeByField[field] || 'string', ttl.textContent, fil);
    });
    wrap.appendChild(ttl);
    wrap.appendChild(fil);
    return wrap;
  }

  // ---------- Construir la rejilla ----------
  function buildGrid() {
    destroyTable();
    activeFilters = {};
    typeByField = {};
    state.columns.forEach(function (c) { typeByField[c.field] = c.type; });
    var editable = asistido && editableInfo.editable;
    var cols = state.columns.map(function (c) {
      return {
        title: c.title,
        field: c.field,
        headerSort: true,
        resizable: true,
        formatter: cellFormatter,
        sorter: c.type === 'number' ? 'number' : 'string',
        hozAlign: c.type === 'number' ? 'right' : 'left',
        titleFormatter: headerTitleFormatter,
        editor: editable ? 'input' : false
      };
    });
    el('results').classList.add('has-data');
    table = new Tabulator('#grid', {
      data: state.rows,
      columns: cols,
      layout: 'fitDataFill',
      movableColumns: true,
      selectableRows: true,
      selectableRowsRangeMode: 'click',
      editTriggerEvent: 'dblclick',
      height: '100%',
      placeholder: 'Sin filas',
      reactiveData: false,
      columnDefaults: {
        headerHozAlign: 'left',
        headerTooltip: true,
        contextMenu: menuCelda,
        headerContextMenu: menuCabecera
      }
    });
    if (editable) {
      table.on('cellEdited', function (cell) {
        var rd = cell.getRow().getData();
        bridge('ue_set_celda', JSON.stringify({ row: rd._dw_row, field: cell.getField(), value: cell.getValue() }));
      });
    }
    // Mover la fila seleccionada con ↑/↓ (sin interferir con la edición de celdas).
    table.element.addEventListener('keydown', function (e) {
      if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
      var tag = (e.target && e.target.tagName || '').toLowerCase();
      if (tag === 'input' || tag === 'textarea' || (e.target && e.target.isContentEditable)) return;
      e.preventDefault();
      moverSeleccion(e.key === 'ArrowDown' ? 1 : -1);
    });
  }

  // Desplaza la selección de la grid una fila arriba/abajo (respeta filtro/orden).
  function moverSeleccion(dir) {
    if (!table) return;
    var rows = table.getRows('active');
    if (!rows.length) return;
    var sel = table.getSelectedRows();
    var pos = sel.length ? rows.indexOf(sel[sel.length - 1]) : -1;
    var next = (pos < 0) ? (dir > 0 ? 0 : rows.length - 1) : pos + dir;
    next = Math.max(0, Math.min(rows.length - 1, next));
    var target = rows[next];
    table.deselectRow();
    target.select();
    try { table.scrollToRow(target, 'nearest', false); } catch (e) {}
  }

  function showError(msg) {
    setBusy(false);
    destroyTable();
    setMsg(msg || 'Error', true);
    el('rowinfo').textContent = '';
    setStatus('Error', true);
    el('btnClear').disabled = true;
  }

  // ---------- Ejecutar ----------
  function ejecutar() {
    var sql = (cm ? cm.getValue() : '').trim();
    if (!sql) { setStatus('Escribe una consulta SQL.', true); return; }
    setStatus('');
    setBusy(true);
    el('rowinfo').textContent = 'Ejecutando…';
    if (!bridge('ue_ejecutar', sql)) {
      setBusy(false);
      el('rowinfo').textContent = '';
      setStatus('Sin conexión con PowerBuilder (vista previa).', true);
    }
  }

  // ---------- Copiar / Exportar ----------
  function copiarTodo() {
    if (!state.columns.length) return;
    var cols = state.columns, rows = state.rows;
    var lines = [cols.map(function (c) { return c.title; }).join('\t')];
    for (var r = 0; r < rows.length; r++) {
      lines.push(cols.map(function (c) { return cellText(rows[r][c.field]); }).join('\t'));
    }
    copyText(lines.join('\r\n'));
    setStatus(rows.length + ' fila(s) copiada(s) con cabeceras.');
  }

  function copiarFilas(row) {
    var data = table ? table.getSelectedData() : [];
    if ((!data || !data.length) && row) data = [row.getData()];
    if (!data || !data.length) return;
    var cols = state.columns;
    var lines = data.map(function (rd) {
      return cols.map(function (c) { return cellText(rd[c.field]); }).join('\t');
    });
    copyText(lines.join('\r\n'));
    setStatus(data.length + ' fila(s) copiada(s).');
  }

  function exportarExcel() {
    if (!state.columns.length) { setStatus('No hay datos que exportar.', true); return; }
    if (!bridge('ue_exportar_excel', 'XLS')) setStatus('Exportar a Excel requiere PowerBuilder.', true);
  }

  // Ficha de mantenimiento del registro (w_mant_sql en PB) sobre la fila pulsada.
  function editarRegistro(row) {
    var rd = row ? row.getData() : null;
    if (!rd || !rd._dw_row) { setStatus('No hay fila que editar.', true); return; }
    if (!bridge('ue_editar', String(rd._dw_row))) setStatus('Editar requiere PowerBuilder.', true);
  }

  function copyText(txt) {
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(txt); return; }
    } catch (e) { /* file:// */ }
    var ta = document.createElement('textarea');
    ta.value = txt; ta.style.position = 'fixed'; ta.style.left = '-9999px';
    document.body.appendChild(ta); ta.select();
    try { document.execCommand('copy'); } catch (e) {}
    document.body.removeChild(ta);
  }

  // ---------- API window.* para PowerBuilder ----------
  window.setColumns = function (input) {
    state.columns = normalize(input).map(function (c) {
      var t = 'string';
      if (c.filter === 'agNumberColumnFilter') t = 'number';
      else if (c.formatter === 'date') t = 'date';
      return { field: c.field, title: c.headerName || c.field, type: t };
    });
  };
  window.loadData = function (input) {
    state.rows = normalize(input);
    state.rows.forEach(function (r, i) { r._dw_row = i + 1; });
    buildGrid();
    setBusy(false);
    setStatus('');
    var n = state.rows.length;
    el('rowinfo').textContent = n.toLocaleString('es-ES') + ' Registro' + (n === 1 ? '' : 's');
    el('btnClear').disabled = false;
  };
  // Refresco ligero tras la ficha de mantenimiento: mismas columnas, solo datos.
  // replaceData no reconstruye la grid (mantiene orden, filtros, scroll y layout).
  window.refreshData = function (input) {
    var rows = normalize(input);
    rows.forEach(function (r, i) { r._dw_row = i + 1; });
    state.rows = rows;
    if (!table) { window.loadData(rows); return; }
    table.replaceData(state.rows);
    var n = state.rows.length;
    el('rowinfo').textContent = n.toLocaleString('es-ES') + ' Registro' + (n === 1 ? '' : 's');
  };
  window.clearData = function () {
    state.columns = []; state.rows = [];
    destroyTable();
    setMsg('Escribe una consulta SELECT y pulsa F5.', false);
    el('rowinfo').textContent = '';
    el('btnClear').disabled = true;
  };
  window.setSql = function (sql) { if (cm) cm.setValue(sql || ''); };
  window.getSql = function () { return cm ? cm.getValue() : ''; };
  window.setStatus = function (t) { el('rowinfo').textContent = t || ''; };
  window.setError = function (m) { showError(m); };
  window.setBusy = function (b) { setBusy(b); };
  // Tema de empresa: PB inyecta el color de fondo de la empresa activa
  // (botones, slider de zoom y checkboxes via la variable CSS --tema).
  window.setTheme = function (color) {
    if (color && /^#?[0-9a-f]{6}$/i.test(String(color).trim())) {
      color = String(color).trim();
      if (color.charAt(0) !== '#') color = '#' + color;
      document.documentElement.style.setProperty('--tema', color);
    }
  };
  // Modo oscuro (tema PB "Flat Design Dark"): PB lo activa con setDark(true).
  window.setDark = function (on) {
    document.body.classList.toggle('dark', !!on);
  };
  // Toast: confirmación flotante no modal (la usa PB en vez de MessageBox).
  var toastTimer = null;
  window.toast = function (msg) {
    var t = document.getElementById('toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'toast';
      document.body.appendChild(t);
    }
    t.textContent = msg || '';
    t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { t.classList.remove('show'); }, 2600);
  };
  window.setHeaderColor = function () {};
  window.setTitle = function () {};
  window.getConfig = function () { return ''; };
  window.loadConfig = function () {};
  window.autoFitColumns = function () {};
  window.isReady = function () { return pageReady; };

  // ---- Modo asistido ----
  window.setAsistido = function (on) {
    asistido = !!on;
    el('app').classList.toggle('asistido', asistido);
    setTimeout(function () { if (cm) cm.refresh(); if (table) table.redraw(true); }, 0);
  };
  window.setTablas = function (input) {
    tablas = normalize(input).map(function (t) { return (typeof t === 'string') ? t : (t.name || t.TABLE_NAME || ''); });
    var nt = el('numTablas'); if (nt) nt.textContent = '(' + tablas.length + ')';
    renderTablas('');
  };
  window.setCampos = function (input) {
    var d = (typeof input === 'string') ? JSON.parse(input) : input;
    campos = (d && d.campos) || [];
    renderCampos();
    el('chkTodos').checked = true;
    construirSelect();   // solo prepara el SELECT en el editor; NO ejecuta (puede ser pesado)
  };
  window.setEditable = function (input) {
    var d = (typeof input === 'string') ? JSON.parse(input) : input;
    editableInfo = d || { editable: false };
    el('app').classList.toggle('editable', !!(asistido && editableInfo.editable));
  };

  function renderTablas(filtro) {
    var ul = el('listaTablas'); ul.innerHTML = '';
    var f = (filtro || '').toLowerCase();
    tablas.forEach(function (t) {
      if (f && t.toLowerCase().indexOf(f) < 0) return;
      var li = document.createElement('li');
      li.textContent = t;
      li.setAttribute('data-nombre', t);
      if (t === tablaActual) li.className = 'sel';
      li.addEventListener('click', function () { seleccionarTabla(t); });
      ul.appendChild(li);
    });
    aplicarKbdCur(ul);   // restaurar el cursor de teclado tras el re-render
  }

  function seleccionarTabla(t) {
    tablaActual = t;
    kbdCur['listaTablas'] = t;   // el cursor de teclado sigue a la tabla elegida
    renderTablas(el('buscaTabla').value);
    el('campTabla').textContent = t;
    el('listaCampos').innerHTML = '<li class="campo-msg">cargando…</li>';
    bridge('ue_campos', t);
  }

  function renderCampos() {
    var ul = el('listaCampos'); ul.innerHTML = '';
    campos.forEach(function (c) {
      var li = document.createElement('li'); li.className = 'campo-item';
      li.setAttribute('data-nombre', c.name);
      var cb = document.createElement('input'); cb.type = 'checkbox'; cb.checked = true;
      cb.setAttribute('data-campo', c.name);
      cb.addEventListener('change', function () { el('chkTodos').checked = todosMarcados(); construirSelect(); });
      var tx = document.createElement('span'); tx.textContent = c.name;
      li.appendChild(cb); li.appendChild(tx);
      if (c.pk) { var pk = document.createElement('span'); pk.className = 'pk'; pk.textContent = 'PK'; li.appendChild(pk); }
      ul.appendChild(li);
    });
    aplicarKbdCur(ul);   // restaurar el cursor de teclado tras el re-render
  }

  // Navegación por teclado en los paneles de Tablas/Campos:
  //  · letra/dígito = type-ahead por inicial; repetir la misma letra salta al
  //    siguiente elemento que empieza por ella (da la vuelta al final).
  //  · ↑/↓ mueven el cursor fila a fila; Enter activa la fila (seleccionar
  //    tabla / marcar-desmarcar campo).
  // Un ÚNICO listener en document: las teclas van a la última lista "activa"
  // (último clic o ratón encima). NO se depende del foco del WebView2, que se
  // pierde cada vez que la lista se re-renderiza (innerHTML = '').
  var listaActiva = null;   // <ul> que recibe el teclado
  var kbdCur = {};          // ul.id -> data-nombre de la fila con el cursor
  var kbdEnter = {};        // ul.id -> acción de Enter sobre la fila

  function kbdItems(ul) {
    return Array.prototype.slice.call(ul.children).filter(function (li) {
      return li.hasAttribute('data-nombre');
    });
  }
  // Re-aplica la clase del cursor tras cada render (el innerHTML la borra).
  function aplicarKbdCur(ul) {
    var nombre = kbdCur[ul.id] || '';
    kbdItems(ul).forEach(function (li) {
      li.classList.toggle('kbd-cur', nombre !== '' && li.getAttribute('data-nombre') === nombre);
    });
  }
  function kbdMover(ul, lis, idx) {
    idx = Math.max(0, Math.min(lis.length - 1, idx));
    kbdCur[ul.id] = lis[idx].getAttribute('data-nombre');
    aplicarKbdCur(ul);
    try { lis[idx].scrollIntoView({ block: 'nearest' }); } catch (e) {}
  }
  function initListaTeclado(ul, onEnter) {
    if (!ul) return;
    kbdEnter[ul.id] = onEnter;
    ul.addEventListener('mouseenter', function () { listaActiva = ul; });
    ul.addEventListener('mousedown', function () { listaActiva = ul; });
    if (!listaActiva) listaActiva = ul;   // por defecto, la primera (Tablas)
  }
  document.addEventListener('keydown', function (e) {
    var ul = listaActiva;
    if (!ul) return;
    // No interferir si se está escribiendo o navegando en otro control.
    var t = e.target, tag = (t && t.tagName || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea' || tag === 'select' || tag === 'button') return;
    if (t && t.isContentEditable) return;
    if (t && t.closest && (t.closest('.CodeMirror') || t.closest('.tabulator'))) return;

    var lis = kbdItems(ul);
    if (!lis.length) return;
    var actual = -1, nombre = kbdCur[ul.id] || '';
    if (nombre !== '') {
      for (var i = 0; i < lis.length; i++) {
        if (lis[i].getAttribute('data-nombre') === nombre) { actual = i; break; }
      }
    }

    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      var paso = (e.key === 'ArrowDown') ? 1 : -1;
      kbdMover(ul, lis, (actual < 0) ? (paso > 0 ? 0 : lis.length - 1) : actual + paso);
      return;
    }
    if (e.key === 'Enter') {
      if (actual >= 0 && kbdEnter[ul.id]) {
        e.preventDefault();
        kbdEnter[ul.id](lis[actual]);
      }
      return;
    }
    // Type-ahead: una sola letra/dígito sin modificadores.
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    if (!e.key || e.key.length !== 1 || !/[a-z0-9_]/i.test(e.key)) return;
    e.preventDefault();
    var letra = e.key.toLowerCase();
    var curEmpieza = (actual >= 0 &&
      (lis[actual].getAttribute('data-nombre') || '').toLowerCase().charAt(0) === letra);
    var inicio = curEmpieza ? actual + 1 : 0;   // misma letra repetida → siguiente
    for (var j = 0; j < lis.length; j++) {
      var p = (inicio + j) % lis.length;
      if ((lis[p].getAttribute('data-nombre') || '').toLowerCase().charAt(0) === letra) {
        kbdMover(ul, lis, p);
        return;
      }
    }
  });

  function camposMarcados() {
    return Array.prototype.slice.call(el('listaCampos').querySelectorAll('input:checked'))
      .map(function (cb) { return cb.getAttribute('data-campo'); });
  }
  function todosMarcados() {
    var all = el('listaCampos').querySelectorAll('input');
    var ch = el('listaCampos').querySelectorAll('input:checked');
    return all.length > 0 && all.length === ch.length;
  }
  function construirSelect() {
    if (!tablaActual) return;
    // Campos por nombre (nunca SELECT *), aprovechando el ancho disponible:
    // varios campos por línea hasta llenar el editor, y FROM en su propia línea.
    var marc = camposMarcados();
    if (!cm) return;
    if (marc.length === 0) { cm.setValue(''); return; }

    var indent = '       '; // 7 espacios = alineado bajo "SELECT "
    var charW = cm.defaultCharWidth() || 8;
    var avail = cm.getScrollerElement().clientWidth || 600;
    var maxChars = Math.max(40, Math.floor(avail / charW) - 4);

    var out = '';
    var line = 'SELECT ';
    var lineHasField = false;
    for (var i = 0; i < marc.length; i++) {
      var piece = marc[i] + (i < marc.length - 1 ? ',' : '');
      if (lineHasField && (line.length + 1 + piece.length) > maxChars) {
        out += line + '\n';
        line = indent;
        lineHasField = false;
      }
      line += (lineHasField ? ' ' : '') + piece;
      lineHasField = true;
    }
    out += line + '\nFROM ' + tablaActual;
    cm.setValue(out);
  }

  // ---------- Edición (insert/delete/save) ----------
  function insertarFila() {
    if (!(asistido && editableInfo.editable) || !table) {
      setStatus('Esta consulta no es editable.', true);
      return;
    }
    // Índice que tendrá la fila en el DataStore (InsertRow añade al final).
    var idx = state.rows.length + 1;
    var fila = { _dw_row: idx };
    state.rows.push(fila);
    // PB inserta la fila en su DataStore para mantener el buffer en sync.
    // OJO: arg NO vacío (un evento PB con string as_arg no se dispara con '').
    bridge('ue_insertar', 'INS');
    // La añadimos al vuelo, hacemos scroll y empezamos a editar la 1ª celda.
    table.addRow(fila, false).then(function (row) {
      try { table.scrollToRow(row, 'bottom', false); } catch (e) {}
      try { row.getElement().scrollIntoView({ block: 'nearest' }); } catch (e) {}
      var first = state.columns[0];
      if (first) { try { row.getCell(first.field).edit(true); } catch (e) {} }
    }).catch(function (e) { console.error('[insertar]', e); });
    el('rowinfo').textContent = state.rows.length.toLocaleString('es-ES') + ' filas';
  }
  function eliminarFilas() {
    var data = table ? table.getSelectedData() : [];
    var idx = data.map(function (r) { return r._dw_row; }).filter(function (x) { return x; });
    if (!idx.length) { setStatus('Selecciona la(s) fila(s) a eliminar.', true); return; }
    bridge('ue_eliminar', JSON.stringify({ rows: idx.map(function (x) { return { r: x }; }) }));
  }
  function guardarCambios() { bridge('ue_guardar', 'SAVE'); }

  // ---------- Zoom del editor ----------
  function setEditorFont(px) {
    px = Math.max(10, Math.min(28, parseInt(px, 10) || 13));
    if (cm) { cm.getWrapperElement().style.fontSize = px + 'px'; cm.refresh(); }
    el('zoomRange').value = px;
    localStorage.setItem('sqlv-editor-fontsize', String(px));
  }
  function curFont() { return parseInt(localStorage.getItem('sqlv-editor-fontsize') || '13', 10) || 13; }

  // ---------- Sidebar (contraer/expandir tablas y campos) ----------
  function setSidebar(visible) {
    el('app').classList.toggle('sidebar-off', !visible);
    var t = el('btnSidebar');
    if (t) {
      t.innerHTML = visible ? '&#9664;' : '&#9654;';
      t.title = visible ? 'Ocultar panel de tablas' : 'Mostrar panel de tablas';
    }
    localStorage.setItem('sqlv-sidebar', visible ? '1' : '0');
    setTimeout(function () { if (cm) cm.refresh(); if (table) table.redraw(true); }, 0);
  }

  // ---------- Paneles (maximizar/colapsar) ----------
  function setPane(s) {
    paneState = (paneState === s) ? 'split' : s;
    var app = el('app');
    app.classList.toggle('max-editor', paneState === 'editor');
    app.classList.toggle('max-results', paneState === 'results');
    if (cm) cm.refresh();
    if (table) setTimeout(function () { if (table) table.redraw(true); }, 0);
  }

  // ---------- Divisores (alto del editor / ancho del sidebar) ----------
  // Durante el arrastre solo se mueve una rayita guía (.drag-ghost) que marca
  // dónde quedará el corte; el tamaño real se aplica al soltar. Redimensionar
  // CodeMirror/Tabulator en cada mousemove provoca reflows muy pesados.
  var dragGhost = null;
  function ghostEl() {
    if (!dragGhost) {
      dragGhost = document.createElement('div');
      dragGhost.className = 'drag-ghost';
      document.body.appendChild(dragGhost);
    }
    return dragGhost;
  }

  function initDivider() {
    var divider = el('divider'), pane = el('editorPane');
    var guardado = parseInt(localStorage.getItem('sqlv-editor-alto') || '', 10);
    if (!isNaN(guardado) && guardado >= 80 && guardado <= 700) pane.style.height = guardado + 'px';
    divider.addEventListener('mousedown', function (e) {
      e.preventDefault();
      var y0 = e.clientY, h0 = pane.offsetHeight, hFin = h0;
      var rect = pane.getBoundingClientRect();
      var g = ghostEl();
      g.style.cssText = 'display:block;left:' + rect.left + 'px;width:' + rect.width +
        'px;height:3px;top:' + (rect.top + h0) + 'px;';
      document.body.style.cursor = 'row-resize';
      function mv(ev) {
        hFin = Math.max(80, Math.min(700, h0 + (ev.clientY - y0)));
        g.style.top = (rect.top + hFin) + 'px';
      }
      function up() {
        g.style.display = 'none';
        document.body.style.cursor = '';
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        pane.style.height = hFin + 'px';
        localStorage.setItem('sqlv-editor-alto', String(hFin));
        if (cm) cm.refresh();
        if (table) table.redraw(true);
      }
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });
  }

  // ---------- Divisor vertical (ancho del sidebar) ----------
  function initVDivider() {
    var divider = el('vdivider'), pane = el('sidebar');
    if (!divider || !pane) return;
    var guardado = parseInt(localStorage.getItem('sqlv-sidebar-ancho') || '', 10);
    if (!isNaN(guardado) && guardado >= 120 && guardado <= 600) pane.style.flexBasis = guardado + 'px';
    divider.addEventListener('mousedown', function (e) {
      e.preventDefault();
      var x0 = e.clientX, w0 = pane.offsetWidth, wFin = w0;
      var rect = pane.getBoundingClientRect();
      var g = ghostEl();
      g.style.cssText = 'display:block;top:' + rect.top + 'px;height:' + rect.height +
        'px;width:3px;left:' + (rect.left + w0) + 'px;';
      document.body.style.cursor = 'col-resize';
      function mv(ev) {
        wFin = Math.max(120, Math.min(600, w0 + (ev.clientX - x0)));
        g.style.left = (rect.left + wFin) + 'px';
      }
      function up() {
        g.style.display = 'none';
        document.body.style.cursor = '';
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        pane.style.flexBasis = wFin + 'px';
        localStorage.setItem('sqlv-sidebar-ancho', String(wFin));
        if (cm) cm.refresh();
        if (table) table.redraw(true);
      }
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });
  }

  // ---------- Aviso a PB de página lista ----------
  function avisarPbReady() {
    pageReady = true;
    if (bridge('ue_ready', 'READY')) return;
    var intentos = 0;
    var h = setInterval(function () {
      intentos++;
      if (bridge('ue_ready', 'READY') || intentos > 30) clearInterval(h);
    }, 100);
  }

  // ---------- Init ----------
  function init() {
    cm = CodeMirror.fromTextArea(el('sql'), {
      mode: 'text/x-mssql',
      lineNumbers: true,
      indentUnit: 4,
      smartIndent: true,
      lineWrapping: false,
      extraKeys: {
        'F5': function () { ejecutar(); },
        'Ctrl-Enter': function () { ejecutar(); },
        'Cmd-Enter': function () { ejecutar(); }
      }
    });

    // Listeners (null-safe: si falta algún elemento no se rompe el arranque)
    function on(id, ev, fn) { var e = el(id); if (e) e.addEventListener(ev, fn); }
    on('btnRun', 'click', ejecutar);
    on('btnClear', 'click', function () { window.clearData(); });
    on('btnMaxEditor', 'click', function () { setPane('editor'); });
    on('btnMaxResults', 'click', function () { setPane('results'); });
    on('btnInsertar', 'click', insertarFila);
    on('btnEliminar', 'click', eliminarFilas);
    on('btnGuardar', 'click', guardarCambios);
    on('buscaTabla', 'input', function () { renderTablas(this.value); });
    on('btnSidebar', 'click', function () {
      setSidebar(el('app').classList.contains('sidebar-off'));
    });
    if (localStorage.getItem('sqlv-sidebar') === '0') setSidebar(false);
    initListaTeclado(el('listaTablas'), function (li) {
      seleccionarTabla(li.getAttribute('data-nombre'));
    });
    initListaTeclado(el('listaCampos'), function (li) {
      var cb = li.querySelector('input[type=checkbox]');
      if (cb) { cb.checked = !cb.checked; cb.dispatchEvent(new Event('change')); }
    });
    on('chkTodos', 'change', function () {
      var marc = this.checked;
      Array.prototype.slice.call(el('listaCampos').querySelectorAll('input')).forEach(function (cb) { cb.checked = marc; });
      construirSelect();
    });

    setEditorFont(curFont());
    el('zoomRange').addEventListener('input', function () { setEditorFont(this.value); });
    el('zoomMinus').addEventListener('click', function () { setEditorFont(curFont() - 1); });
    el('zoomPlus').addEventListener('click', function () { setEditorFont(curFont() + 1); });
    cm.getWrapperElement().addEventListener('wheel', function (ev) {
      if (!ev.ctrlKey) return;
      ev.preventDefault();
      setEditorFont(curFont() + (ev.deltaY < 0 ? 1 : -1));
    }, { passive: false });

    initDivider();
    initVDivider();
    setTimeout(function () { if (cm) cm.refresh(); }, 50);

    // Modo asistido por URL (?modo=asistido): la web se auto-activa sin depender
    // de que PowerBuilder llame a setAsistido en el momento justo.
    if (location.search.indexOf('modo=asistido') >= 0) {
      window.setAsistido(true);
    }

    avisarPbReady();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
