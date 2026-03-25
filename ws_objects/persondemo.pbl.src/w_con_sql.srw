$PBExportHeader$w_con_sql.srw
forward
global type w_con_sql from window
end type
type wb_new from webbrowser within w_con_sql
end type
type dw_new from vs_dw_api within w_con_sql
end type
type st_4 from statictext within w_con_sql
end type
type st_3 from statictext within w_con_sql
end type
type dw_columns from vs_dw_api within w_con_sql
end type
type dw_tables from vs_dw_api within w_con_sql
end type
type cb_create from commandbutton within w_con_sql
end type
type st_2 from statictext within w_con_sql
end type
type st_1 from statictext within w_con_sql
end type
type mle_1 from multilineedit within w_con_sql
end type
type st_registros from statictext within w_con_sql
end type
type cbx_1 from checkbox within w_con_sql
end type
type st_tablerows from statictext within w_con_sql
end type
type pb_disquete from picturebutton within w_con_sql
end type
end forward

global type w_con_sql from window
integer width = 4832
integer height = 2472
boolean titlebar = true
string title = "Consulta SQL Asistida"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
string icon = "AppIcon!"
wb_new wb_new
dw_new dw_new
st_4 st_4
st_3 st_3
dw_columns dw_columns
dw_tables dw_tables
cb_create cb_create
st_2 st_2
st_1 st_1
mle_1 mle_1
st_registros st_registros
cbx_1 cbx_1
st_tablerows st_tablerows
pb_disquete pb_disquete
end type
global w_con_sql w_con_sql

type prototypes

end prototypes

type variables
string is_report_type, is_table
string old_string=""
integer old_fila=0
boolean ib_grid_ready = false
end variables

forward prototypes
private function string wf_build_sql_syntax ()
private subroutine wf_start ()
public subroutine wf_reset ()
private function string wf_grid_columnas_dinamicas ()
private subroutine wf_grid_cargar_datos ()
public subroutine wf_cambiar_tema (string as_tema_pb)
end prototypes

private function string wf_build_sql_syntax ();string	ls_columns, ls_column, ls_sql_syntax
long	ll_Rows, ll_index

ll_Rows = dw_columns.RowCount ( )

For ll_index = 1 to ll_Rows
	If dw_columns.IsSelected(ll_index) Then 
		If ls_columns <> "" Then ls_columns = ls_columns + ", "
		ls_column = dw_columns.GetItemString(ll_index, 1)
		ls_columns = ls_columns + ls_column
	End If
Next

If ls_columns <> "" Then		
	ls_sql_syntax = "Select " + ls_columns + " from " + is_table
	Return ls_sql_syntax
Else
	Return ""
End If
end function

private subroutine wf_start ();long	ll_RowCount
String ls_Sql
Any la_values[]

ls_sql = "SELECT sysobjects.Name FROM sysobjects  INNER JOIN sysindexes  ON sysobjects.id = sysindexes.id WHERE  type = 'U'  AND sysindexes.IndId < 2 AND sysindexes.Rows > 0 ORDER BY sysobjects.Name"

dw_tables.SetSQLSelect(ls_sql)

ll_RowCount = dw_tables.of_retrieve(la_values[])

if ll_RowCount < 1 then
	MessageBox ("Retrieve return code is:", ll_RowCount)
end if

st_tablerows.text="("+string(ll_RowCount)+")"

end subroutine

public subroutine wf_reset ();If dw_new.DataObject<> "dw_new" Then
	dw_new.DataObject="dw_new"
	dw_new.TriggerEvent(Constructor!)
	st_registros.text=string(0, "#,###,###,##0")+" Registros"
End If
end subroutine

private function string wf_grid_columnas_dinamicas ();// Genera la definición JSON de columnas para el grid React
String ls_cols, ls_name, ls_tipo, ls_tipo_corto, ls_extra, ls_header
Integer li_col_count, li_i
Boolean lb_first

li_col_count = Integer(dw_new.Describe("datawindow.column.count"))
If li_col_count < 1 Then Return ""

ls_cols = "["
lb_first = True

For li_i = 1 To li_col_count
	ls_name = dw_new.Describe("#" + String(li_i) + ".name")
	If ls_name = "!" Or ls_name = "?" Or Len(Trim(ls_name)) = 0 Then GOTO next_col

	ls_header = dw_new.Describe("#" + String(li_i) + ".name")

	ls_tipo = Lower(Trim(dw_new.Describe("#" + String(li_i) + ".coltype")))
	ls_tipo_corto = Left(ls_tipo, 4)

	ls_extra = ""
	Choose Case ls_tipo_corto
		Case "date", "time"
			ls_extra = ',"formatter":"date"'
		Case "deci", "numb", "long", "inte", "real"
			ls_extra = ',"filter":"agNumberColumnFilter"'
	End Choose

	If Not lb_first Then ls_cols = ls_cols + ","
	lb_first = False

	ls_cols = ls_cols + '{"field":"' + Trim(ls_name) + '","headerName":"' + Trim(ls_header) + '"' &
		+ ',"defaultWidth":150' + ls_extra + '}'

	next_col:
Next

ls_cols = ls_cols + "]"
Return ls_cols
end function

private subroutine wf_grid_cargar_datos ();// Carga los datos del dw_new dinámico en el grid React
String ls_cols, ls_json

If dw_new.RowCount() < 1 Then
	wb_new.EvaluateJavascriptAsync("if(window.clearData) window.clearData()")
	Return
End If

// Generar columnas dinámicamente desde el DW
ls_cols = wf_grid_columnas_dinamicas()
If Len(ls_cols) < 5 Then Return

// Enviar columnas al grid
wb_new.EvaluateJavascriptSync("window.setColumns(" + ls_cols + ")")

// Exportar datos del DW a JSON y cargarlos en el grid
ls_json = dw_new.ExportJson(False)
wb_new.EvaluateJavascriptSync("window.loadData(" + ls_json + ")")

// Título para exportaciones
wb_new.EvaluateJavascriptAsync("if(window.setTitle) window.setTitle('Consulta SQL - " + is_table + "')")

// Autoajustar columnas al ancho disponible
wb_new.EvaluateJavascriptAsync("if(window.autoFitColumns) window.autoFitColumns()")

ib_grid_ready = True
end subroutine

public subroutine wf_cambiar_tema (string as_tema_pb);// Cambia el tema del grid React según el tema de PowerBuilder
// Recibe el nombre del tema PB (ej: "Flat Design Blue")
String ls_grid_theme

Choose Case as_tema_pb
	Case "Flat Design Dark"
		ls_grid_theme = "dark"
	Case "Flat Design Blue"
		ls_grid_theme = "rsr"
	Case "Flat Design Grey", "Flat Design Silver"
		ls_grid_theme = "silver"
	Case "Flat Design Lime"
		ls_grid_theme = "lime"
	Case "Flat Design Orange"
		ls_grid_theme = "orange"
	Case Else
		ls_grid_theme = "rsr"
End Choose

wb_new.EvaluateJavascriptSync("if(window.setTheme) window.setTheme('" + ls_grid_theme + "')")
end subroutine

on w_con_sql.create
this.wb_new=create wb_new
this.dw_new=create dw_new
this.st_4=create st_4
this.st_3=create st_3
this.dw_columns=create dw_columns
this.dw_tables=create dw_tables
this.cb_create=create cb_create
this.st_2=create st_2
this.st_1=create st_1
this.mle_1=create mle_1
this.st_registros=create st_registros
this.cbx_1=create cbx_1
this.st_tablerows=create st_tablerows
this.pb_disquete=create pb_disquete
this.Control[]={this.wb_new,&
this.dw_new,&
this.st_4,&
this.st_3,&
this.dw_columns,&
this.dw_tables,&
this.cb_create,&
this.st_2,&
this.st_1,&
this.mle_1,&
this.st_registros,&
this.cbx_1,&
this.st_tablerows,&
this.pb_disquete}
end on

on w_con_sql.destroy
destroy(this.wb_new)
destroy(this.dw_new)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.dw_columns)
destroy(this.dw_tables)
destroy(this.cb_create)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.mle_1)
destroy(this.st_registros)
destroy(this.cbx_1)
destroy(this.st_tablerows)
destroy(this.pb_disquete)
end on

event open;If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If
wf_start()
wf_reset()

// Navegar al grid React en el WebBrowser
String ls_path
ls_path =  gs_dir+"/dist/index.html"
wb_new.Navigate(ls_path)

end event

event resize;dw_new.Width = newwidth - 50
dw_new.Height = newheight - 960
st_registros.Width = newwidth - 50
st_registros.y = dw_new.Height + dw_new.y + 10

// Redimensionar wb_new igual que dw_new
wb_new.x = dw_new.x
wb_new.y = dw_new.y
wb_new.Width = dw_new.Width
wb_new.Height = dw_new.Height

// Autoajustar columnas del grid React
If ib_grid_ready Then
	wb_new.EvaluateJavascriptAsync("if(window.autoFitColumns) window.autoFitColumns()")
End If

end event

event close;Long ll_OpenWindows

If IsValid(w_frame) Then
	ll_OpenWindows = gf_ventanas_abiertas(w_frame)
	
	If ll_OpenWindows = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If
end event

type wb_new from webbrowser within w_con_sql
boolean visible = false
integer x = 23
integer y = 836
integer width = 4754
integer height = 1432
boolean bringtotop = true
end type

event navigationcompleted;// Aplicar tema del grid según tema de PowerBuilder y desactivar mantenimiento
String ls_theme
ls_theme = ProfileString(gs_fichero_ini, "Setup", "Theme ", "Do Not Use Themes")
wf_cambiar_tema(ls_theme)
this.EvaluateJavascriptAsync("if(window.setMaintenanceEnabled) window.setMaintenanceEnabled(false)")
end event

type dw_new from vs_dw_api within w_con_sql
integer x = 23
integer y = 836
integer width = 4754
integer height = 1432
integer taborder = 80
boolean hscrollbar = true
boolean vscrollbar = true
end type

type st_4 from statictext within w_con_sql
integer x = 27
integer y = 748
integer width = 357
integer height = 64
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "DataWindow:"
end type

type st_3 from statictext within w_con_sql
integer x = 1399
integer y = 16
integer width = 247
integer height = 68
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Syntax:"
end type

type dw_columns from vs_dw_api within w_con_sql
integer x = 718
integer y = 84
integer width = 658
integer height = 640
integer taborder = 30
string dataobject = "dw_column_list"
boolean vscrollbar = true
end type

event clicked;//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Clicked script for dw_columns
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// If user clicks on no row do not continue processing
If row = 0 Then Return	
wf_reset()

// As a column is selected, add it to the list in the select
//If already selected, turn off selection
If dw_columns.IsSelected(row) then
	dw_columns.SelectRow(row, False)
Else
	dw_columns.SelectRow(row, True)
End If

//update the multilineedit to display the updated syntax
//If rb_sql.checked Then
	mle_1.text = wf_build_sql_syntax()
//else
//	mle_1.text = wf_build_dw_syntax()
//End If
end event

event constructor;//Anulo
end event

type dw_tables from vs_dw_api within w_con_sql
event key pbm_dwnkey
integer x = 18
integer y = 84
integer width = 658
integer height = 640
integer taborder = 20
string dataobject = "dw_table_list"
boolean vscrollbar = true
boolean border = false
end type

event clicked;
String ls_sql
Long ll_Row, ll_RowCount
Any la_values[]

If row = 0 Then Return
wf_reset()


dw_tables.SelectRow(0, False)
dw_tables.SelectRow(row, True)

is_Table = dw_tables.GetItemString(row, 1)

ls_sql = "SELECT Column_Name FROM INFORMATION_SCHEMA. COLUMNS WHERE Table_Name ='"+is_table+"' and Data_Type<>'varbinary'"

dw_columns.SetSQLSelect(ls_sql)

ll_RowCount = dw_columns.of_Retrieve( la_values[])

If cbx_1.checked = True Then
	cbx_1.triggerevent(clicked!)
	For ll_Row = 1 To ll_RowCount
		dw_columns.SelectRow (ll_Row, True )
	Next	
End If



end event

event constructor;//Anulo
end event

type cb_create from commandbutton within w_con_sql
integer x = 4201
integer y = 724
integer width = 416
integer height = 96
integer taborder = 70
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Create DW"
end type

event clicked;String ls_sql_syntax
Long ll_RowCount

wf_reset()

if mle_1.text = "" Then
	MessageBox("Atención!", "Introduzca un código SQL válido o seleccione una Tabla, maque las columnas y haga clic en Crear.")
	Return
end if

ls_sql_syntax = mle_1.text

ll_RowCount = dw_new.of_cargar(ls_sql_syntax)

st_registros.text=string(ll_RowCount, "#,###,###,##0")+" Registros"

// Mostrar grid React, ocultar DataWindow
If ll_RowCount > 0 Then
	dw_new.visible = false
	wb_new.visible = true
	ib_grid_ready = false
	wf_grid_cargar_datos()
Else
	dw_new.visible = true
	wb_new.visible = false
End If

end event

type st_2 from statictext within w_con_sql
integer x = 718
integer y = 16
integer width = 658
integer height = 68
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Columns:"
end type

type st_1 from statictext within w_con_sql
integer x = 18
integer y = 16
integer width = 658
integer height = 68
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Tables:"
end type

type mle_1 from multilineedit within w_con_sql
integer x = 1399
integer y = 84
integer width = 2725
integer height = 640
integer taborder = 20
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string pointer = "arrow!"
long textcolor = 41943040
long backcolor = 74481808
boolean vscrollbar = true
boolean autovscroll = true
end type

event modified;wf_reset()
end event

type st_registros from statictext within w_con_sql
integer x = 23
integer y = 2288
integer width = 4942
integer height = 84
integer textsize = -9
integer weight = 700
long textcolor = 8388608
long backcolor = 74481808
string text = "Registros"
alignment alignment = center!
boolean border = true
long bordercolor = 16777215
end type

type cbx_1 from checkbox within w_con_sql
integer x = 759
integer y = 728
integer width = 402
integer height = 84
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "Select *"
boolean checked = true
end type

event clicked;integer i, contarfilas
boolean seleccionar

contarfilas= dw_columns.RowCount()

if this.checked = true then
	seleccionar=true
else
	seleccionar=false
end if	

if seleccionar = true then
for i = 1 to contarfilas
	dw_columns.SelectRow (i, TRUE )
next	
else
	for i = 1 to contarfilas
	dw_columns.SelectRow (i, false)
next
end if

//update the multilineedit to display the updated syntax
//If rb_sql.checked Then
	mle_1.text = wf_build_sql_syntax()
//else
//	mle_1.text = wf_build_dw_syntax()
//End If
end event

type st_tablerows from statictext within w_con_sql
integer x = 503
integer y = 916
integer width = 169
long textcolor = 12632256
boolean enabled = false
alignment alignment = right!
end type

type pb_disquete from picturebutton within w_con_sql
integer x = 4626
integer y = 716
integer width = 133
integer height = 108
integer taborder = 10
boolean bringtotop = true
fontcharset fontcharset = ansi!
string pointer = "HyperLink!"
string picturename = "Custom064_2!"
alignment htextalign = left!
end type

event clicked;// Exportar a Excel: usar el grid React si tiene datos, sino el dw_new
If ib_grid_ready And dw_new.RowCount() > 0 Then
	wb_new.EvaluateJavascriptAsync("if(window.exportToExcel) window.exportToExcel()")
Else
	Integer	li_rtn
	If dw_new.RowCount() > 0 Then
		li_rtn = dw_new.SaveAs("", XLSX!, True)
		If li_rtn = 1 Then Messagebox("Exito","¡ La información se ha grabado correctamente !")
	End If
End If
end event

