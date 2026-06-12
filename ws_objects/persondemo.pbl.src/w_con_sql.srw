$PBExportHeader$w_con_sql.srw
forward
global type w_con_sql from window
end type
type wb_1 from webbrowser within w_con_sql
end type
end forward

global type w_con_sql from window
integer width = 4101
integer height = 2572
boolean titlebar = true
string title = "Consulta SQL Asistida"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
string icon = "AppIcon!"
wb_1 wb_1
end type
global w_con_sql w_con_sql

type variables
Public:
Boolean ib_RegisterEvent = FALSE
Boolean ib_PaginaCargada = FALSE

// Datastore del framework API donde se ejecuta la consulta (nvo_ds_api:
// el SQL viaja al controlador Datawindow/Cargar y vuelve como JSON)
nvo_ds_api ids_data
// Persistencia: layout de columnas del grid y ultima consulta
String is_grid_config_path
String is_sql_path
// Edicion controlada: ultimo SQL bueno, tabla unica detectada y sus PKs.
// Los insert/update/delete van por n_cst_sqlexecutor (framework de la demo).
String is_sql_ultima
String is_tabla_edit
Boolean ib_editable = FALSE
String is_pk[]
end variables

forward prototypes
public function string wf_js_str (string as_text)
public subroutine wf_cargar ()
public subroutine wf_tema ()
public function string wf_tablas_json ()
public function string wf_pks_csv (string as_tabla)
public function string wf_campos_json (string as_tabla)
public subroutine wf_enviar_tablas ()
public subroutine wf_enviar_campos (string as_tabla)
public function string wf_columnas_json ()
public subroutine wf_enviar_datos ()
public subroutine wf_detectar_editable ()
public subroutine wf_ejecutar (string as_sql)
public function any wf_valor (long al_row, string as_col)
public function boolean wf_es_pk (string as_col)
public subroutine wf_set_celda (long al_row, string as_field, string as_value)
public subroutine wf_insertar ()
public subroutine wf_eliminar (string as_json)
public subroutine wf_guardar ()
public subroutine wf_exportar_excel ()
public function string wf_grid_config_leer ()
public subroutine wf_grid_config_guardar ()
public function string wf_sql_leer ()
public subroutine wf_sql_guardar ()
end prototypes

public function string wf_js_str (string as_text);// Devuelve as_text como literal string JSON (entrecomillado y escapado) para
// inyectarlo con seguridad dentro de una llamada EvaluateJavascript.
String ls

If IsNull(as_text) Then Return '""'
ls = as_text
ls = gf_replaceall(ls, "\", "\\")
ls = gf_replaceall(ls, '"', '\"')
ls = gf_replaceall(ls, "~r", "\r")
ls = gf_replaceall(ls, "~n", "\n")
ls = gf_replaceall(ls, "~t", "\t")
Return '"' + ls + '"'
end function

public subroutine wf_cargar ();// Navega a la pagina del visor SQL (editor CodeMirror + grid). URL con query
// anti-cache (?t=CPU) para que WebView2 no sirva versiones cacheadas.
String ls_url

ls_url = gf_replaceall(gs_dir + "\sqlviewer\index.html", "\", "/")
ls_url = gf_replaceall(ls_url, " ", "%20")
ls_url = "file:///" + ls_url + "?t=" + String(Long(CPU())) + "&modo=asistido"
wb_1.Navigate(ls_url)
end subroutine

public subroutine wf_tema ();// Manda el tema al visor: color de acento (variable CSS --tema) y modo oscuro
// (setDark) si el tema es Dark. Mapeo del tema de PowerBuilder
// (CloudSetting.ini, igual que el _bak) a un color hex.
String ls_theme, ls_color, ls_dark

ls_theme = ProfileString(gs_fichero_ini, "Setup", "Theme ", "Do Not Use Themes")
ls_dark = "false"

Choose Case ls_theme
	Case "Flat Design Dark"
		// En oscuro el acento debe verse sobre #1e1e1e (gris no vale)
		ls_color = "#569cd6"
		ls_dark = "true"
	Case "Flat Design Blue"
		ls_color = "#2d6ca2"
	Case "Flat Design Grey", "Flat Design Silver"
		ls_color = "#6e6e6e"
	Case "Flat Design Lime"
		ls_color = "#7cb342"
	Case "Flat Design Orange"
		ls_color = "#e07b39"
	Case Else
		ls_color = "#2d6ca2"
End Choose

wb_1.EvaluateJavascriptAsync("if(window.setDark) window.setDark(" + ls_dark + ");" + &
	"if(window.setTheme) window.setTheme('" + ls_color + "')")
end subroutine

public function string wf_tablas_json ();// Lista de tablas de usuario (mismo origen que el _bak) como array JSON.
String ls_sql, ls_json
nvo_ds_api lds
Long ll_n, ll_i

ls_sql = "SELECT sysobjects.Name FROM sysobjects " + &
	"INNER JOIN sysindexes ON sysobjects.id = sysindexes.id " + &
	"WHERE type = 'U' AND sysindexes.IndId < 2 AND sysindexes.Rows > 0 " + &
	"ORDER BY sysobjects.Name"

lds = Create nvo_ds_api
ll_n = lds.of_cargar(ls_sql)
ls_json = "["
For ll_i = 1 To ll_n
	If ll_i > 1 Then ls_json += ","
	ls_json += wf_js_str(Trim(lds.GetItemString(ll_i, 1)))
Next
Destroy lds
ls_json += "]"
Return ls_json
end function

public function string wf_pks_csv (string as_tabla);// Claves primarias de la tabla como csv en minusculas (via SqlExecutor;
// FOR XML PATH para no depender de STRING_AGG).
n_cst_sqlexecutor ln_exec
Any la_vals[], la_res[]
String ls_csv, ls_sql

ls_sql = "SELECT ISNULL(STUFF((SELECT ',' + ku.COLUMN_NAME " + &
	"FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc " + &
	"JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME " + &
	"WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND tc.TABLE_NAME = @tabla " + &
	"FOR XML PATH('')), 1, 1, ''), '')"

ln_exec = Create n_cst_sqlexecutor
la_vals[1] = as_tabla
la_res[] = ln_exec.of_SelectInto(ls_sql, la_vals[])
Destroy ln_exec

ls_csv = ""
If UpperBound(la_res[]) >= 1 Then
	If Not IsNull(la_res[1]) Then ls_csv = la_res[1]
End If
Return Lower(Trim(ls_csv))
end function

public function string wf_campos_json (string as_tabla);// Columnas de la tabla (nombre, tipo, pk) como JSON {tabla, campos:[...]}.
// Se excluyen varbinary igual que el _bak.
String ls_sql, ls_json, ls_name, ls_pks
nvo_ds_api lds
Long ll_n, ll_i

ls_pks = "," + wf_pks_csv(as_tabla) + ","

ls_sql = "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS " + &
	"WHERE TABLE_NAME = '" + as_tabla + "' AND DATA_TYPE <> 'varbinary' " + &
	"ORDER BY ORDINAL_POSITION"

lds = Create nvo_ds_api
ll_n = lds.of_cargar(ls_sql)
ls_json = '{"tabla":' + wf_js_str(as_tabla) + ',"campos":['
For ll_i = 1 To ll_n
	ls_name = Trim(lds.GetItemString(ll_i, 1))
	If ll_i > 1 Then ls_json += ","
	ls_json += '{"name":' + wf_js_str(ls_name) + ',"type":' + wf_js_str(Trim(lds.GetItemString(ll_i, 2)))
	If Pos(ls_pks, "," + Lower(ls_name) + ",") > 0 Then ls_json += ',"pk":true'
	ls_json += '}'
Next
Destroy lds
ls_json += ']}'
Return ls_json
end function

public subroutine wf_enviar_tablas ();// Inyecta la lista de tablas en el panel del visor.
String ls_tablas
ls_tablas = wf_tablas_json()
wb_1.EvaluateJavascriptAsync("if(window.setTablas) window.setTablas(" + ls_tablas + ")")
end subroutine

public subroutine wf_enviar_campos (string as_tabla);// Inyecta los campos de la tabla seleccionada en el panel del visor.
String ls_json
ls_json = wf_campos_json(as_tabla)
wb_1.EvaluateJavascriptAsync("if(window.setCampos) window.setCampos(" + ls_json + ")")
end subroutine

public function string wf_columnas_json ();// Genera la definicion JSON de columnas (BaseColumnDef) para el grid a
// partir del datastore dinamico ids_data.
String ls_cols, ls_name, ls_tipo, ls_corto, ls_extra
Integer li_count, li_i
Boolean lb_first

li_count = Integer(ids_data.Describe("datawindow.column.count"))
If li_count < 1 Then Return ""

ls_cols = "["
lb_first = TRUE
For li_i = 1 To li_count
	ls_name = ids_data.Describe("#" + String(li_i) + ".name")
	If ls_name = "!" Or ls_name = "?" Or Len(Trim(ls_name)) = 0 Then Continue

	ls_tipo  = Lower(Trim(ids_data.Describe("#" + String(li_i) + ".coltype")))
	ls_corto = Left(ls_tipo, 4)
	ls_extra = ""
	Choose Case ls_corto
		Case "date", "time"
			ls_extra = ',"formatter":"date"'
		Case "deci", "numb", "long", "inte", "real"
			ls_extra = ',"filter":"agNumberColumnFilter"'
	End Choose

	If Not lb_first Then ls_cols += ","
	lb_first = FALSE
	ls_cols += '{"field":"' + Trim(ls_name) + '","headerName":"' + Trim(ls_name) + '"' &
		+ ',"defaultWidth":150' + ls_extra + '}'
Next
ls_cols += "]"
Return ls_cols
end function

public subroutine wf_enviar_datos ();// Envia al visor: columnas, estado editable y datos del datastore actual.
String ls_cols, ls_json, ls_ed

ls_cols = wf_columnas_json()
If Len(ls_cols) >= 5 Then
	wb_1.EvaluateJavascriptAsync("window.setColumns(" + ls_cols + ")")
End If

If ib_editable Then
	ls_ed = '{"editable":true,"tabla":' + wf_js_str(is_tabla_edit) + '}'
Else
	ls_ed = '{"editable":false}'
End If
wb_1.EvaluateJavascriptAsync("window.setEditable(" + ls_ed + ")")

If ids_data.RowCount() > 0 Then
	ls_json = ids_data.ExportJson(False)
	wb_1.EvaluateJavascriptAsync("window.loadData(" + ls_json + ")")
Else
	wb_1.EvaluateJavascriptAsync("window.loadData([])")
End If
end subroutine

public subroutine wf_detectar_editable ();// Editable solo si el SQL es un SELECT simple de UNA tabla ("select ... from
// tabla", sin joins/where/alias), trae TODAS sus columnas (sin varbinary,
// como el panel) y la tabla tiene clave primaria. Aqui no hay updatetable de
// SyntaxFromSQL (el DW es externo), se decide a mano.
String ls, ls_tabla, ls_csv, ls_vacio[]
Long ll_pos, ll_cols_res, ll_cols_tabla
Double ld_cols
n_cst_sqlexecutor ln_exec
Any la_vals[], la_res[]

is_tabla_edit = ""
ib_editable = FALSE
is_pk[] = ls_vacio[]

ls = Lower(Trim(is_sql_ultima))
ls = gf_replaceall(ls, "~r~n", " ")
ls = gf_replaceall(ls, "~n", " ")
ls = gf_replaceall(ls, "~t", " ")
Do While Pos(ls, "  ") > 0
	ls = gf_replaceall(ls, "  ", " ")
Loop

ll_pos = Pos(ls, " from ")
If ll_pos = 0 Then Return
ls_tabla = Trim(Mid(ls, ll_pos + 6))
// Si tras la tabla hay cualquier cosa (where, join, alias, coma) no es editable
If ls_tabla = "" Then Return
If Pos(ls_tabla, " ") > 0 Or Pos(ls_tabla, ",") > 0 Then Return

// Todas las columnas de la tabla en el resultado
ll_cols_res = Long(ids_data.Describe("datawindow.column.count"))
ln_exec = Create n_cst_sqlexecutor
la_vals[1] = ls_tabla
la_res[] = ln_exec.of_SelectInto("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " + &
	"WHERE TABLE_NAME = @tabla AND DATA_TYPE <> 'varbinary'", la_vals[])
Destroy ln_exec
If UpperBound(la_res[]) < 1 Then Return
If IsNull(la_res[1]) Then Return
ld_cols = la_res[1]
ll_cols_tabla = Long(ld_cols)
If ll_cols_tabla < 1 Or ll_cols_res <> ll_cols_tabla Then Return

// Clave primaria (imprescindible para update/delete controlados)
ls_csv = wf_pks_csv(ls_tabla)
If ls_csv = "" Then Return
gf_ParseToArray(ls_csv, ",", is_pk[])

ib_editable = TRUE
is_tabla_edit = ls_tabla
end subroutine

public subroutine wf_ejecutar (string as_sql);// Ejecuta la consulta via API (Datawindow/Cargar) y vuelca el resultado en el
// grid. nvo_ds_api construye el datastore externo a partir del JSON recibido.
String ls_sql
Long ll_filas

ls_sql = Trim(as_sql)
If ls_sql = "" Then Return

SetPointer(HourGlass!)
If IsValid(ids_data) Then Destroy ids_data
ids_data = Create nvo_ds_api
ll_filas = ids_data.of_cargar(ls_sql)
SetPointer(Arrow!)

If ll_filas < 0 Then
	// nvo_ds_api ya ha mostrado el detalle con gf_mensaje; liberar el visor.
	wb_1.EvaluateJavascriptAsync("if(window.setError) window.setError(" + wf_js_str("Error al ejecutar la consulta.") + ");")
	Return
End If

// CRITICO: of_cargar importa con ImportJson y deja TODAS las filas como
// NewModified!; sin este ResetUpdate, Guardar las tomaria por filas nuevas
// e intentaria un INSERT de cada una (PK duplicada, rafaga de errores 500).
ids_data.ResetUpdate()

// SQL bueno: se guarda para la deteccion de editable
is_sql_ultima = ls_sql
wf_detectar_editable()
wf_enviar_datos()
end subroutine

public function any wf_valor (long al_row, string as_col);// Valor de una celda como Any segun el tipo de la columna (para pasarlo como
// parametro al SqlExecutor). OJO fechas/horas: van como STRING en el formato
// EXACTO que parsea el servidor (JsonProcessorHelper: dd-MM-yyyy HH:mm:ss);
// si van como datetime, el JsonGenerator las emite en ISO con microsegundos
// y SQL Server da "Error al convertir una cadena de caracteres en fecha".
String ls_t
Any la_v
DateTime ldt
Date ld
Time lt

ls_t = Lower(Trim(ids_data.Describe(as_col + ".coltype")))

Choose Case True
	Case Pos(ls_t, "char") > 0 Or Pos(ls_t, "string") > 0
		la_v = ids_data.GetItemString(al_row, as_col)
	Case Pos(ls_t, "datetime") > 0 Or Pos(ls_t, "timestamp") > 0
		ldt = ids_data.GetItemDateTime(al_row, as_col)
		If IsNull(ldt) Then
			SetNull(la_v)
		Else
			la_v = String(ldt, "dd-mm-yyyy hh:mm:ss")
		End If
	Case Pos(ls_t, "date") > 0
		ld = ids_data.GetItemDate(al_row, as_col)
		If IsNull(ld) Then
			SetNull(la_v)
		Else
			la_v = String(ld, "dd-mm-yyyy")
		End If
	Case Pos(ls_t, "time") > 0
		lt = ids_data.GetItemTime(al_row, as_col)
		If IsNull(lt) Then
			SetNull(la_v)
		Else
			la_v = String(lt, "hh:mm:ss")
		End If
	Case Pos(ls_t, "deci") > 0
		la_v = ids_data.GetItemDecimal(al_row, as_col)
	Case Else
		la_v = ids_data.GetItemNumber(al_row, as_col)
End Choose
Return la_v
end function

public function boolean wf_es_pk (string as_col);Integer li
For li = 1 To UpperBound(is_pk[])
	If is_pk[li] = Lower(Trim(as_col)) Then Return TRUE
Next
Return FALSE
end function

public subroutine wf_set_celda (long al_row, string as_field, string as_value);// Asigna un valor a una celda del datastore segun el tipo de la columna.
String   ls_t, ls_val
DateTime ldt_null
Date     ld_null
Time     lt_null
Long     ll_null
Decimal  ldec_null

If Not IsValid(ids_data) Then Return
If al_row < 1 Or al_row > ids_data.RowCount() Then Return

ls_val = as_value
If IsNull(ls_val) Then ls_val = ""

SetNull(ldt_null)
SetNull(ld_null)
SetNull(lt_null)
SetNull(ll_null)
SetNull(ldec_null)

ls_t = Lower(Trim(ids_data.Describe(as_field + ".coltype")))

Choose Case True
	Case Pos(ls_t, "char") > 0 Or Pos(ls_t, "string") > 0 Or Pos(ls_t, "text") > 0
		ids_data.SetItem(al_row, as_field, ls_val)
	Case Pos(ls_t, "datetime") > 0 Or Pos(ls_t, "timestamp") > 0
		If Trim(ls_val) = "" Then
			ids_data.SetItem(al_row, as_field, ldt_null)
		Else
			ids_data.SetItem(al_row, as_field, DateTime(ls_val))
		End If
	Case Pos(ls_t, "date") > 0
		If Trim(ls_val) = "" Then
			ids_data.SetItem(al_row, as_field, ld_null)
		Else
			ids_data.SetItem(al_row, as_field, Date(ls_val))
		End If
	Case Pos(ls_t, "time") > 0
		If Trim(ls_val) = "" Then
			ids_data.SetItem(al_row, as_field, lt_null)
		Else
			ids_data.SetItem(al_row, as_field, Time(ls_val))
		End If
	Case Pos(ls_t, "long") > 0 Or Pos(ls_t, "int") > 0 Or Pos(ls_t, "numb") > 0
		If Trim(ls_val) = "" Then
			ids_data.SetItem(al_row, as_field, ll_null)
		Else
			ids_data.SetItem(al_row, as_field, Long(ls_val))
		End If
	Case Else
		If Trim(ls_val) = "" Then
			ids_data.SetItem(al_row, as_field, ldec_null)
		Else
			ids_data.SetItem(al_row, as_field, Dec(ls_val))
		End If
End Choose
end subroutine

public subroutine wf_insertar ();// Inserta una fila nueva (al final) en el datastore editable. La rejilla web
// la añade y enfoca por su cuenta; aqui solo mantenemos el buffer en sync.
If Not ib_editable Or Not IsValid(ids_data) Then Return
ids_data.InsertRow(0)
end subroutine

public subroutine wf_eliminar (string as_json);// Pregunta y borra las filas indicadas: DELETE por PK via SqlExecutor (el
// framework de la demo). Las filas nuevas sin grabar solo salen del buffer.
JSONParser ljp
Long ll_root, ll_arr, ll_n, ll_i, ll_child
Long ll_rows[], ll_tmp, ll_k, ll_j, ll_p
String ls_sql, ls_where
Any la_params[], la_vacio[]
n_cst_sqlexecutor ln_exec
dwItemStatus l_status
Boolean lb_ok, lb_fallo

If Not ib_editable Or Not IsValid(ids_data) Then Return

ljp = Create JSONParser
ljp.LoadString(as_json)
ll_root = ljp.GetRootItem()
ll_arr = ljp.GetItemArray(ll_root, "rows")
If IsNull(ll_arr) Or ll_arr <= 0 Then
	Destroy ljp
	Return
End If
ll_n = ljp.GetChildCount(ll_arr)
For ll_i = 1 To ll_n
	ll_child = ljp.GetChildItem(ll_arr, ll_i)
	ll_rows[ll_i] = Long(ljp.GetItemNumber(ll_child, "r"))
Next
Destroy ljp

If MessageBox("Atención", "¿Desea eliminar " + String(ll_n) + " fila(s) de la tabla " + is_tabla_edit + "?", Question!, YesNo!, 2) = 2 Then Return

// Ordenar descendente para que DeleteRow no descuadre los indices
For ll_k = 1 To ll_n - 1
	For ll_j = ll_k + 1 To ll_n
		If ll_rows[ll_j] > ll_rows[ll_k] Then
			ll_tmp = ll_rows[ll_k]
			ll_rows[ll_k] = ll_rows[ll_j]
			ll_rows[ll_j] = ll_tmp
		End If
	Next
Next

ln_exec = Create n_cst_sqlexecutor
For ll_i = 1 To ll_n
	If ll_rows[ll_i] < 1 Or ll_rows[ll_i] > ids_data.RowCount() Then Continue

	l_status = ids_data.GetItemStatus(ll_rows[ll_i], 0, Primary!)
	If l_status = New! Or l_status = NewModified! Then
		// Fila nueva sin grabar: solo quitarla del buffer
		ids_data.DeleteRow(ll_rows[ll_i])
		Continue
	End If

	ls_where = ""
	ll_p = 0
	la_params[] = la_vacio[]
	For ll_k = 1 To UpperBound(is_pk[])
		ll_p ++
		la_params[ll_p] = wf_valor(ll_rows[ll_i], is_pk[ll_k])
		If ls_where <> "" Then ls_where += " AND "
		ls_where += is_pk[ll_k] + " = @p" + String(ll_p)
	Next
	ls_sql = "DELETE FROM " + is_tabla_edit + " WHERE " + ls_where

	lb_ok = ln_exec.of_Delete(ls_sql, la_params[])
	If IsNull(lb_ok) Then lb_ok = FALSE
	If lb_ok Then
		ids_data.DeleteRow(ll_rows[ll_i])
	Else
		lb_fallo = TRUE
		gf_mensaje("Eliminar", "No se ha podido eliminar la fila " + String(ll_rows[ll_i]) + ". Proceso detenido.")
		Exit
	End If
Next
Destroy ln_exec

wf_enviar_datos()
If Not lb_fallo Then
	wb_1.EvaluateJavascriptAsync("if(window.toast) window.toast(" + wf_js_str("Fila(s) eliminada(s) correctamente") + ")")
End If
end subroutine

public subroutine wf_guardar ();// Aplica en BD las inserciones (INSERT) y modificaciones (UPDATE por PK) via
// n_cst_sqlexecutor. Los valores van como parametros @pN (posicionales) y los
// null como literal NULL en el SQL.
Long ll_fila, ll_filas, ll_col, ll_cols, ll_p, ll_ops, ll_k, ll_id
String ls_sql, ls_cols, ls_vals, ls_set, ls_where, ls_name
Any la_params[], la_vacio[], la_v
dwItemStatus l_status
n_cst_sqlexecutor ln_exec
Boolean lb_ok

If Not ib_editable Or Not IsValid(ids_data) Then Return

If MessageBox("Atención", "¿Desea actualizar la base de datos (tabla " + is_tabla_edit + ")?", Question!, YesNo!) = 2 Then Return

ll_filas = ids_data.RowCount()
ll_cols = Long(ids_data.Describe("datawindow.column.count"))
ln_exec = Create n_cst_sqlexecutor
ll_ops = 0

For ll_fila = 1 To ll_filas
	l_status = ids_data.GetItemStatus(ll_fila, 0, Primary!)

	Choose Case l_status
		Case NewModified!
			// INSERT con todas las columnas
			ls_cols = ""
			ls_vals = ""
			ll_p = 0
			la_params[] = la_vacio[]
			For ll_col = 1 To ll_cols
				ls_name = ids_data.Describe("#" + String(ll_col) + ".name")
				la_v = wf_valor(ll_fila, ls_name)
				If ls_cols <> "" Then
					ls_cols += ", "
					ls_vals += ", "
				End If
				ls_cols += ls_name
				If IsNull(la_v) Then
					ls_vals += "null"
				Else
					ll_p ++
					la_params[ll_p] = la_v
					ls_vals += "@p" + String(ll_p)
				End If
			Next
			ls_sql = "INSERT INTO " + is_tabla_edit + " (" + ls_cols + ") VALUES (" + ls_vals + ")"

			ll_id = ln_exec.of_Insert(ls_sql, la_params[])
			// OJO: si la API falla, of_insert devuelve NULL (y NULL < 0 NO es
			// TRUE en PB): comprobar IsNull o el bucle seguiria insertando.
			If IsNull(ll_id) Or ll_id < 0 Then
				gf_mensaje("Guardar", "Error insertando la fila " + String(ll_fila) + ". Proceso detenido.")
				Destroy ln_exec
				wf_enviar_datos()
				Return
			End If
			ll_ops ++

		Case DataModified!
			// UPDATE de las columnas no clave, WHERE por PK
			ls_set = ""
			ls_where = ""
			ll_p = 0
			la_params[] = la_vacio[]
			For ll_col = 1 To ll_cols
				ls_name = ids_data.Describe("#" + String(ll_col) + ".name")
				If wf_es_pk(ls_name) Then Continue
				la_v = wf_valor(ll_fila, ls_name)
				If ls_set <> "" Then ls_set += ", "
				If IsNull(la_v) Then
					ls_set += ls_name + " = null"
				Else
					ll_p ++
					la_params[ll_p] = la_v
					ls_set += ls_name + " = @p" + String(ll_p)
				End If
			Next
			For ll_k = 1 To UpperBound(is_pk[])
				la_v = wf_valor(ll_fila, is_pk[ll_k])
				If ls_where <> "" Then ls_where += " AND "
				ll_p ++
				la_params[ll_p] = la_v
				ls_where += is_pk[ll_k] + " = @p" + String(ll_p)
			Next
			ls_sql = "UPDATE " + is_tabla_edit + " SET " + ls_set + " WHERE " + ls_where

			lb_ok = ln_exec.of_Update(ls_sql, la_params[])
			If IsNull(lb_ok) Or Not lb_ok Then
				gf_mensaje("Guardar", "Error actualizando la fila " + String(ll_fila) + ". Proceso detenido.")
				Destroy ln_exec
				wf_enviar_datos()
				Return
			End If
			ll_ops ++
	End Choose
Next
Destroy ln_exec

If ll_ops = 0 Then
	wb_1.EvaluateJavascriptAsync("if(window.toast) window.toast(" + wf_js_str("No hay cambios que guardar") + ")")
	Return
End If

ids_data.ResetUpdate()
wf_enviar_datos()
// Confirmacion no modal: toast verde en la propia web (aqui no hay gf_msgbox)
wb_1.EvaluateJavascriptAsync("if(window.toast) window.toast(" + wf_js_str("Datos guardados correctamente") + ")")
end subroutine

public subroutine wf_exportar_excel ();// Exporta el resultado a Excel: GetFileSaveName + SaveAs(ruta, XLSX!), con
// mensaje tambien en error (el SaveAs("") implicito falla en silencio).
String  ls_path, ls_file, ls_current
Integer li_res

If Not IsValid(ids_data) Then
	gf_mensaje("Exportar a Excel", "No hay ninguna consulta ejecutada.")
	Return
End If
If ids_data.RowCount() < 1 Then
	gf_mensaje("Exportar a Excel", "La consulta no tiene filas que exportar.")
	Return
End If

If Trim(is_tabla_edit) <> "" Then
	ls_file = Trim(is_tabla_edit) + ".xlsx"
Else
	ls_file = "consulta.xlsx"
End If

// GetFileSaveName cambia el directorio actual y gs_dir depende de el: restaurar
ls_current = GetCurrentDirectory()
li_res = GetFileSaveName("Exportar a Excel", ls_path, ls_file, "XLSX", &
	"Archivos XLSX (*.xlsx), *.xlsx", gs_dir, 18)
ChangeDirectory(ls_current)
If li_res <> 1 Then Return

If FileExists(ls_path) Then
	If MessageBox("Remplazar", "¿Desea sobreescribir el archivo " + ls_file + "?", Question!, YesNo!) = 2 Then Return
	If Not FileDelete(ls_path) Then
		gf_mensaje("Exportar a Excel", "No se ha podido reemplazar el archivo:~r~n" + ls_path)
		Return
	End If
End If

li_res = ids_data.SaveAs(ls_path, XLSX!, TRUE)
If li_res = 1 Then
	gf_mensaje("Exportar a Excel", "El archivo se ha guardado correctamente:~r~n" + ls_path)
Else
	gf_mensaje("Exportar a Excel", "No se ha podido guardar el archivo:~r~n" + ls_path)
End If
end subroutine

public function string wf_grid_config_leer ();// Lee el JSON con el layout de columnas del grid (si existe).
String ls_contenido, ls_linea
Integer li_file

If Not FileExists(is_grid_config_path) Then Return ""

li_file = FileOpen(is_grid_config_path, StreamMode!, Read!)
If li_file < 1 Then Return ""

ls_contenido = ""
Do While FileRead(li_file, ls_linea) > 0
	ls_contenido += ls_linea
Loop
FileClose(li_file)

Return ls_contenido
end function

public subroutine wf_grid_config_guardar ();// Pide al grid su layout de columnas y lo guarda en archivo (o lo borra si el
// usuario pulso "Restablecer", que devuelve RESET).
String ls_resultado, ls_error, ls_config
Integer li_file, li_rc
Long ll_pos_ini, ll_pos_fin

li_rc = wb_1.EvaluateJavascriptSync("window.getConfig()", REF ls_resultado, REF ls_error)
If li_rc < 0 Or IsNull(ls_resultado) Or Len(Trim(ls_resultado)) < 5 Then Return

// Extraer el value del wrapper {"type":"string","value":"..."}
ll_pos_ini = Pos(ls_resultado, '"value":"')
If ll_pos_ini > 0 Then
	ll_pos_ini += Len('"value":"')
	ll_pos_fin = Len(ls_resultado) - 1
	ls_config = Mid(ls_resultado, ll_pos_ini, ll_pos_fin - ll_pos_ini)
	ls_config = gf_replaceall(ls_config, '\"', '"')
Else
	ls_config = ls_resultado
End If

If Pos(ls_config, "RESET") > 0 Then
	If FileExists(is_grid_config_path) Then FileDelete(is_grid_config_path)
	Return
End If

If Len(Trim(ls_config)) < 5 Then Return

li_file = FileOpen(is_grid_config_path, StreamMode!, Write!, Shared!, Replace!)
If li_file < 1 Then Return
FileWrite(li_file, ls_config)
FileClose(li_file)
end subroutine

public function string wf_sql_leer ();// Lee la ultima consulta guardada (si existe).
String ls_contenido, ls_linea
Integer li_file

If Not FileExists(is_sql_path) Then Return ""

li_file = FileOpen(is_sql_path, StreamMode!, Read!)
If li_file < 1 Then Return ""

ls_contenido = ""
Do While FileRead(li_file, ls_linea) > 0
	ls_contenido += ls_linea
Loop
FileClose(li_file)

Return ls_contenido
end function

public subroutine wf_sql_guardar ();// Guarda en archivo la consulta actual del editor (para restaurarla al reabrir).
String ls_sql, ls_error
Integer li_file, li_rc
Long ll_pos_ini, ll_pos_fin

li_rc = wb_1.EvaluateJavascriptSync("window.getSql()", REF ls_sql, REF ls_error)
If li_rc < 0 Or IsNull(ls_sql) Then Return

// Desenvolver {"type":"string","value":"..."}
ll_pos_ini = Pos(ls_sql, '"value":"')
If ll_pos_ini > 0 Then
	ll_pos_ini += Len('"value":"')
	ll_pos_fin = Len(ls_sql) - 1
	ls_sql = Mid(ls_sql, ll_pos_ini, ll_pos_fin - ll_pos_ini)
	ls_sql = gf_replaceall(ls_sql, '\"', '"')
	ls_sql = gf_replaceall(ls_sql, "\r", "~r")
	ls_sql = gf_replaceall(ls_sql, "\n", "~n")
	ls_sql = gf_replaceall(ls_sql, "\t", "~t")
	ls_sql = gf_replaceall(ls_sql, "\\", "\")
End If

If Trim(ls_sql) = "" Then
	If FileExists(is_sql_path) Then FileDelete(is_sql_path)
	Return
End If

li_file = FileOpen(is_sql_path, StreamMode!, Write!, Shared!, Replace!)
If li_file < 1 Then Return
FileWrite(li_file, ls_sql)
FileClose(li_file)
end subroutine

on w_con_sql.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_con_sql.destroy
destroy(this.wb_1)
end on

event open;// Igual que el resto de ventanas de la demo: ocultar la web del frame.
If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

// Persistencia: layout de columnas del grid y ultima consulta
is_grid_config_path = gs_dir + "\sqlviewer\config_sqlviewer.json"
is_sql_path         = gs_dir + "\sqlviewer\sql_ultima.txt"

wf_cargar()
end event

event close;Long ll_OpenWindows

If IsValid(w_frame) Then
	ll_OpenWindows = gf_ventanas_abiertas(w_frame)

	If ll_OpenWindows = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If
If IsValid(ids_data) Then Destroy ids_data
end event

event closequery;// Persistir el layout de columnas y la ultima consulta antes de cerrar.
If ib_PaginaCargada Then
	wf_grid_config_guardar()
	wf_sql_guardar()
End If
end event

event resize;wb_1.Width = NewWidth - 100
wb_1.Height = NewHeight - 20
end event

type wb_1 from webbrowser within w_con_sql
event ue_close_window ( string as_arg )
event ue_ready ( string as_arg )
event ue_ejecutar ( string as_sql )
event ue_exportar_excel ( string as_arg )
event ue_campos ( string as_tabla )
event ue_set_celda ( string as_json )
event ue_insertar ( string as_arg )
event ue_eliminar ( string as_json )
event ue_guardar ( string as_arg )
integer x = 23
integer y = 20
integer width = 4050
integer height = 2392
boolean bringtotop = true
end type

event ue_close_window(string as_arg);// JS: window.webBrowser.ue_close_window('CLOSE')
If as_arg = "CLOSE" Then
	Close(Parent)
End If
end event

event ue_ready(string as_arg);// JS avisa que la pagina esta lista: modo asistido, tema, ultima consulta y
// lista de tablas. Inyeccion ASINCRONA para no reentrar en el WebView.
Parent.ib_PaginaCargada = TRUE

this.EvaluateJavascriptAsync("if(window.setAsistido) window.setAsistido(true)")
Parent.wf_tema()

String ls_sql
ls_sql = Parent.wf_sql_leer()
If Len(Trim(ls_sql)) > 0 Then
	this.EvaluateJavascriptAsync("if(window.setSql) window.setSql(" + Parent.wf_js_str(ls_sql) + ")")
End If

// La lista de tablas (llamada a la API) se hace Posted para no demorar el evento.
Parent.Post wf_enviar_tablas()
end event

event ue_ejecutar(string as_sql);// JS: ue_ejecutar(sql) al pulsar Ejecutar (F5 / Ctrl+Enter). Post para SALIR
// del contexto del evento JS->PB antes de volver a llamar al WebView (si no,
// PB y el WebBrowser se esperan mutuamente y la ventana se congela).
Parent.Post wf_ejecutar(as_sql)
end event

event ue_exportar_excel(string as_arg);// JS: menu contextual Exportar a Excel. Post para salir del contexto del
// evento JS antes de abrir el dialogo nativo "Guardar como".
Parent.Post wf_exportar_excel()
end event

event ue_campos(string as_tabla);// JS: ue_campos(tabla) al elegir una tabla -> devolvemos sus campos.
Parent.Post wf_enviar_campos(as_tabla)
end event

event ue_set_celda(string as_json);// JS: ue_set_celda({row, field, value}) al editar una celda.
JSONParser ljp
Long ll_root, ll_row
String ls_field, ls_value

ljp = Create JSONParser
ljp.LoadString(as_json)
ll_root = ljp.GetRootItem()
ll_row = Long(ljp.GetItemNumber(ll_root, "row"))
ls_field = ljp.GetItemString(ll_root, "field")
ls_value = ljp.GetItemString(ll_root, "value")
Destroy ljp

Parent.wf_set_celda(ll_row, ls_field, ls_value)
end event

event ue_insertar(string as_arg);// JS: ue_insertar() -> nueva fila editable. Llamada DIRECTA (no Post) para que
// el InsertRow ocurra antes de que lleguen las ediciones de las celdas.
Parent.wf_insertar()
end event

event ue_eliminar(string as_json);// JS: ue_eliminar({rows:[{r},...]}) -> elimina filas (DELETE por PK via API).
Parent.Post wf_eliminar(as_json)
end event

event ue_guardar(string as_arg);// JS: ue_guardar() -> aplica los cambios en BD (INSERT/UPDATE via API).
Parent.Post wf_guardar()
end event

event navigationstart;Int li_rc1, li_rc2, li_rc3, li_rc4, li_rc5, li_rc6, li_rc7, li_rc8, li_rc9

If ib_RegisterEvent = FALSE Then
	li_rc1 = wb_1.RegisterEvent("ue_close_window")
	li_rc2 = wb_1.RegisterEvent("ue_ready")
	li_rc3 = wb_1.RegisterEvent("ue_ejecutar")
	li_rc4 = wb_1.RegisterEvent("ue_exportar_excel")
	li_rc5 = wb_1.RegisterEvent("ue_campos")
	li_rc6 = wb_1.RegisterEvent("ue_set_celda")
	li_rc7 = wb_1.RegisterEvent("ue_insertar")
	li_rc8 = wb_1.RegisterEvent("ue_eliminar")
	li_rc9 = wb_1.RegisterEvent("ue_guardar")
	If li_rc1 = 1 And li_rc2 = 1 And li_rc3 = 1 And li_rc4 = 1 And li_rc5 = 1 &
		And li_rc6 = 1 And li_rc7 = 1 And li_rc8 = 1 And li_rc9 = 1 Then
		ib_RegisterEvent = TRUE
	End If
End If
end event

event navigationcompleted;// Empujar tema y lista de tablas en cuanto la pagina ha cargado (ademas de ue_ready).
wf_tema()
wf_enviar_tablas()
end event

