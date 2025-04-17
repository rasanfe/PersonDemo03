$PBExportHeader$w_con_sql.srw
forward
global type w_con_sql from window
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
end variables

forward prototypes
private function string wf_build_sql_syntax ()
private subroutine wf_start ()
public subroutine wf_reset ()
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

on w_con_sql.create
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
this.Control[]={this.dw_new,&
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

event open;wf_start()
wf_reset()








end event

event resize;dw_new.Width = newwidth - 50
dw_new.Height = newheight - 960
st_registros.Width = newwidth - 50
st_registros.y = dw_new.Height + dw_new.y + 10



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

event clicked;Integer	li_rtn

If dw_new.RowCount() > 0 Then
	li_rtn = dw_new.SaveAs("", XLSX!, True)
	If li_rtn = 1 Then Messagebox("Exito","¡ La información se ha grabado correctamente !")
End If
end event

