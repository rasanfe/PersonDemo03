$PBExportHeader$w_mant_facturas.srw
forward
global type w_mant_facturas from window
end type
type st_registros from statictext within w_mant_facturas
end type
type st_criterio from statictext within w_mant_facturas
end type
type sle_busqueda from singlelineedit within w_mant_facturas
end type
type dw_lista from vs_dw_api within w_mant_facturas
end type
type cb_sqlinsert from commandbutton within w_mant_facturas
end type
type cb_sqlupdate from commandbutton within w_mant_facturas
end type
type cb_sqldelete from commandbutton within w_mant_facturas
end type
type st_2 from statictext within w_mant_facturas
end type
type st_1 from statictext within w_mant_facturas
end type
type cb_delete from commandbutton within w_mant_facturas
end type
type cb_update from commandbutton within w_mant_facturas
end type
type cb_insert from commandbutton within w_mant_facturas
end type
type dw_1 from vs_dw_api within w_mant_facturas
end type
type gb_busqueda from groupbox within w_mant_facturas
end type
type gb_registros from groupbox within w_mant_facturas
end type
end forward

global type w_mant_facturas from window
integer width = 7045
integer height = 2652
boolean titlebar = true
string title = "Mantenimiento Facturas"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
st_registros st_registros
st_criterio st_criterio
sle_busqueda sle_busqueda
dw_lista dw_lista
cb_sqlinsert cb_sqlinsert
cb_sqlupdate cb_sqlupdate
cb_sqldelete cb_sqldelete
st_2 st_2
st_1 st_1
cb_delete cb_delete
cb_update cb_update
cb_insert cb_insert
dw_1 dw_1
gb_busqueda gb_busqueda
gb_registros gb_registros
end type
global w_mant_facturas w_mant_facturas

type prototypes
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

type variables
String is_empresa, is_anyo, is_serie, is_factura
String is_columna_buscar="razon"
Constant String ALL = ""
end variables

forward prototypes
public function long wf_retrieve_lista ()
public subroutine wf_retrieve_dddw (string as_dddw)
end prototypes

public function long wf_retrieve_lista ();string ls_empresa, ls_anyo
any a_values[]
Long ll_RowCount

ls_empresa="1"

If dw_1.RowCount() = 1 Then
	ls_anyo= dw_1.object.venfac_anyo[1]
Else
	ls_anyo=string(year(today()))
End if


dw_lista.setredraw(false)		

a_values[1]  = ls_empresa
a_values[2]  = ls_anyo

ll_RowCount = dw_lista.of_Retrieve(a_values[])

dw_lista.setredraw(true)		

st_registros.text="Total registros: "+string(ll_RowCount, "#,###,###,##0")

Return ll_RowCount
end function

public subroutine wf_retrieve_dddw (string as_dddw);Long ll_RowCount
String ls_Json1, ls_Json2, ls_Json3
DataWindowChild dwc_1, dwc_2, dwc_3
String l_values1[], l_values2[], l_values3[]
nvo_ds_api ds_1, ds_2,ds_3
string ls_objname1, ls_objname2, ls_objname3
Integer li_result

yield()
SetPointer (Hourglass!)

If dw_1.RowCount() <> 1 Then return

//1- DropDownDatawindow Cliente
If as_dddw = "" or as_dddw = "cliente" Then
	ls_objname1 ="dddw_genter_razon"
	ds_1= Create nvo_ds_api
	ds_1.DataObject =ls_objname1
	
	//Argumentos dddw Cliente
	l_values1[1] =  dw_1.object.empresa[1]
	
	//Datastore Auxiliar Cliente
	ds_1.of_retrieve(l_values1[])
	ls_json1 = ds_1.ExportJson()
	Destroy ds_1
	
	li_result =dw_1.GetChild("cliente", dwc_1)
	
	If li_Result <> 1 Then
		gf_mensaje("Error", "¡ Error Tomando Refrencia a DDDW1 !")
		Return 
	End IF
	
	dwc_1.Reset()
	ll_RowCount = dwc_1.ImportJson(ls_json1)
End If

//2- DropDownDatawindow Obra
If as_dddw = "" or as_dddw = "obra" Then
	ls_objname2 ="dddw_venenvio_descripcion"
	ds_2= Create nvo_ds_api
	ds_2.DataObject =ls_objname2
	
	//Argumentos dddw Obra
	dw_1.AcceptText()
	l_values2[1] = dw_1.object.empresa[1]
	l_values2[2] = dw_1.object.cliente[1]
	
	//Datastore Auxiliar Obra
	ds_2.of_retrieve(l_values2[])
	ls_json2 = ds_2.ExportJson()
	Destroy ds_2
	
	li_result =dw_1.GetChild("obra", dwc_2)
	
	If li_Result <> 1 Then
		gf_mensaje("Error", "¡ Error Tomando Refrencia a DDDW2 !")
		Return 
	End IF
	
	dwc_2.Reset()
	ll_RowCount = dwc_2.ImportJson(ls_json2)
End If

//3- DropDownDatawindow Formas de Pago
If as_dddw = "" or as_dddw = "cod_fp" Then
	ls_objname3 ="dddw_carforpag_texto1"
	ds_3= Create nvo_ds_api
	ds_3.DataObject =ls_objname3
	
	//Argumentos dddw Formass de Pago
	l_values3[1] =  dw_1.object.empresa[1]
	
	//Datastore Auxiliar Formas de Pago
	ds_3.of_retrieve(l_values3[])
	ls_json3 = ds_3.ExportJson()
	Destroy ds_3
	
	li_result =dw_1.GetChild("cod_fp", dwc_3)
	
	If li_Result <> 1 Then
		gf_mensaje("Error", "¡ Error Tomando Refrencia a DDDW3 !")
		Return 
	End IF
	
	dwc_3.Reset()
	ll_RowCount = dwc_3.ImportJson(ls_json3)
End If

dw_1.groupcalc()
SetPointer (Arrow!)


end subroutine

on w_mant_facturas.create
this.st_registros=create st_registros
this.st_criterio=create st_criterio
this.sle_busqueda=create sle_busqueda
this.dw_lista=create dw_lista
this.cb_sqlinsert=create cb_sqlinsert
this.cb_sqlupdate=create cb_sqlupdate
this.cb_sqldelete=create cb_sqldelete
this.st_2=create st_2
this.st_1=create st_1
this.cb_delete=create cb_delete
this.cb_update=create cb_update
this.cb_insert=create cb_insert
this.dw_1=create dw_1
this.gb_busqueda=create gb_busqueda
this.gb_registros=create gb_registros
this.Control[]={this.st_registros,&
this.st_criterio,&
this.sle_busqueda,&
this.dw_lista,&
this.cb_sqlinsert,&
this.cb_sqlupdate,&
this.cb_sqldelete,&
this.st_2,&
this.st_1,&
this.cb_delete,&
this.cb_update,&
this.cb_insert,&
this.dw_1,&
this.gb_busqueda,&
this.gb_registros}
end on

on w_mant_facturas.destroy
destroy(this.st_registros)
destroy(this.st_criterio)
destroy(this.sle_busqueda)
destroy(this.dw_lista)
destroy(this.cb_sqlinsert)
destroy(this.cb_sqlupdate)
destroy(this.cb_sqldelete)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_delete)
destroy(this.cb_update)
destroy(this.cb_insert)
destroy(this.dw_1)
destroy(this.gb_busqueda)
destroy(this.gb_registros)
end on

event open;Any l_values[]
str_venfac lstr_venfac

lstr_venfac =  Message.PowerObjectParm

If isValid(lstr_venfac)  then
	is_empresa=lstr_venfac.as_empresa
	is_anyo=lstr_venfac.as_anyo
	is_serie=lstr_venfac.as_serie
	is_factura=lstr_venfac.as_factura
	
	l_values[1]=is_empresa
	l_values[2]=is_anyo
	l_values[3]=is_serie
	l_values[4]=is_factura
	
	dw_1.of_retrieve(l_values[])
End IF

wf_retrieve_lista()



end event

event resize;gb_busqueda.x=46
st_criterio.x=59
sle_busqueda.x=635

gb_busqueda.y=44
st_criterio.y=108
sle_busqueda.y=100

gb_registros.x=46
st_registros.x=56

gb_busqueda.width=newwidth / 2 -20
sle_busqueda.width=newwidth / 2 - sle_busqueda.x -20

dw_lista.x=46
dw_lista.y=gb_busqueda.y + gb_busqueda.height + 36
dw_lista.width= newwidth / 2
dw_lista.height= newheight - dw_lista.y - gb_registros.height  - 60

gb_registros.y=dw_lista.y + dw_lista.height + 10
st_registros.y=gb_registros.y + 70

gb_registros.width=newwidth / 2 -20
st_registros.width=newwidth / 2 - 40


dw_1.x=dw_lista.x+dw_lista.width + 20
dw_1.y=256
dw_1.width= newwidth / 2 - 100
dw_1.height= newheight -300

st_2.x = dw_1.x + 100
cb_sqlinsert.x = st_2.x +st_2.width+10
cb_sqldelete.x=cb_sqlinsert.x+cb_sqlinsert.width+10
cb_sqlupdate.x = cb_sqldelete.x+cb_sqldelete.width+10

st_2.y = 24
cb_sqlinsert.y = 0
cb_sqldelete.y=0
cb_sqlupdate.y = 0

st_1.x = dw_1.x + 100
cb_insert.x = st_1.x +st_1.width+10
cb_delete.x=cb_insert.x+cb_insert.width+10
cb_update.x = cb_delete.x+cb_delete.width+10

st_1.y = 148
cb_insert.y = 124
cb_delete.y=124
cb_update.y = 124
end event

type st_registros from statictext within w_mant_facturas
integer x = 78
integer y = 2444
integer width = 4037
integer height = 68
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
long backcolor = 67108864
string text = "Total registros: 0"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_criterio from statictext within w_mant_facturas
integer x = 59
integer y = 108
integer width = 553
integer height = 72
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Razón:"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_busqueda from singlelineedit within w_mant_facturas
event ue_keypress pbm_keyup
integer x = 635
integer y = 100
integer width = 3378
integer height = 80
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event ue_keypress;long ll_Row, ll_RowCount
string ls_buscar, ls_tipo
int li_len

ll_RowCount = dw_lista.RowCount()
ls_tipo = dw_lista.Describe(is_columna_buscar+".coltype")
ls_buscar = Upper(Text)
li_len = len(ls_buscar)

Choose Case  mid(ls_tipo,1,4) 
	Case 'char' 
		ll_Row = dw_lista.Find("Upper(mid("+is_columna_buscar+",1,"+string(li_len)+")) = '"+ls_buscar+"'", 1, ll_RowCount)
	Case 'deci'	
		ll_Row = dw_lista.Find("Upper(mid(string("+is_columna_buscar+"),1,"+string(li_len)+")) = '"+ls_buscar+"'", 1, ll_RowCount)
	Case 'long'	
		ll_Row = dw_lista.Find("Upper(mid(string("+is_columna_buscar+"),1,"+string(li_len)+")) = '"+ls_buscar+"'", 1, ll_RowCount)
End Choose			

If ll_Row > 0 Then
	dw_lista.SelectRow(0, False)
	dw_lista.SetRow(ll_Row)
	dw_lista.ScrollToRow(ll_Row)
	dw_lista.SelectRow(ll_Row, True)
End If	
			
If ls_buscar <> "" Then
	dw_lista.SetFilter("UPPER(string("+is_columna_buscar+")) like '%"+ls_buscar+"%'")
Else
	dw_lista.SetFilter("") 
End iF

dw_lista.filter()
ll_RowCount = dw_lista.RowCount()

st_registros.text="Total registros: "+string(ll_RowCount, "#,###,###,##0")

If ll_RowCount=0 Then
	sle_busqueda.TextColor = RGB(255,0,0)
	st_criterio.TextColor = RGB(255,0,0)
	sle_busqueda.limit=len(sle_busqueda.text)
Else
	sle_busqueda.TextColor = RGB(0,0,0)
	st_criterio.TextColor = RGB(0,0,255)
	sle_busqueda.limit=255
End If	

end event

event getfocus;this.SelectText(1,Len(this.text))
end event

type dw_lista from vs_dw_api within w_mant_facturas
integer x = 46
integer y = 248
integer width = 4073
integer height = 2148
integer taborder = 20
string dataobject = "dw_mant_lista"
boolean vscrollbar = true
boolean ib_logo = false
end type

event doubleclicked;call super::doubleclicked;Any l_values[]

If row < 1 then return

is_empresa=this.object.empresa[row]
is_anyo=this.object.venfac_anyo[row]
is_serie=this.object.serie[row]
is_factura=this.object.factura[row]

l_values[1]=is_empresa
l_values[2]=is_anyo
l_values[3]=is_serie
l_values[4]=is_factura

dw_1.of_retrieve(l_values[])


end event

event clicked;call super::clicked;IF Right(dwo.Name,2) = '_t' THEN 
	st_criterio.text= dw_lista.Describe( String(dwo.name) +".text")
	is_columna_buscar=left(trim(dw_lista.Describe( String(dwo.name) +".name")) , len(trim(dw_lista.Describe( String(dwo.name) +".name"))) - 2)
END IF

end event

type cb_sqlinsert from commandbutton within w_mant_facturas
integer x = 4544
integer width = 407
integer height = 112
integer taborder = 50
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Insert"
end type

event clicked;n_cst_sqlexecutor ln_exec
String ls_sql
any la_values[], la_null[]
Long ll_result
String ls_cliente, ls_codpago

//Insertamos Clave Primaria
is_empresa="1"
is_anyo="2025"
is_serie="1"
is_factura=gf_nueva_factura(is_empresa, is_anyo, is_serie) 

If dw_1.RowCount() =1 Then
	ls_cliente=dw_1.object.cliente[1] //Copio el Cliente Que estamos Visualizando
	ls_codpago=dw_1.object.cod_fp[1]
Else
	ls_cliente="1849"  //Pongo un Valor fijo
	ls_codpago="71"
End If	
	
la_values[1] = is_empresa
la_values[2] = is_anyo
la_values[3] = is_serie
la_values[4] = is_factura
la_values[5] = ls_cliente
la_values[6] = gf_fecha_factura(is_empresa, is_anyo, is_serie) 
la_values[7] = ls_codpago
la_values[8] = 1000
la_values[9] = 210
la_values[10] = 1210
la_values[11] = "1"
la_values[12] = "N"

ls_sql = "INSERT INTO venfac (empresa, anyo, serie, factura, cliente, fecha_factura, forma_pago, subtotal, total_iva, total_factura, obra, situacion) "+&
			"VALUES (@empresa, @anyo, @serie, @factura, @cliente, @fecha_factura, @forma_pago, @subtotal, @total_iva, @total_factura, @obra, @situacion)"

ln_exec = CREATE n_cst_sqlexecutor
ll_result = ln_exec.of_insert ( ls_sql, la_values[])

IF ll_result > -1 THEN
	MessageBox("Insert", "Resultado Correcto")
	
	la_values[] = la_null[]
	la_values[1]=is_empresa
	la_values[2]=is_anyo
	la_values[3]=is_serie
	la_values[4]=is_factura
	
	dw_1.of_retrieve(la_values[])
END IF

DESTROY ln_exec

wf_retrieve_lista()
end event

type cb_sqlupdate from commandbutton within w_mant_facturas
integer x = 5367
integer width = 402
integer height = 112
integer taborder = 70
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Update"
end type

event clicked;n_cst_sqlexecutor ln_exec
String ls_sql
any la_values[]
Boolean lb_result
Long ll_Row

ll_Row=  dw_1.GetRow()

If ll_Row < 1 Then Return

If Messagebox("Atencion!","¿Desea Actualizar la Base de Datos?", Exclamation!, OkCancel!)=2 Then Return

is_empresa=dw_1.object.empresa[ll_Row]
is_anyo=dw_1.object.venfac_anyo[ll_Row]
is_serie=dw_1.object.serie[ll_Row]
is_factura=dw_1.object.factura[ll_Row]

la_values[1] = dw_1.object.fecha[ll_Row]
la_values[2] = dw_1.object.cliente[ll_Row]
la_values[3] = dw_1.object.obra[ll_Row]
la_values[4] = dw_1.object.cod_fp[ll_Row]
la_values[5] = dw_1.object.subtotal[ll_Row]
la_values[6] = dw_1.object.total_iva[ll_Row]
la_values[7] = dw_1.object.importe[ll_Row]
la_values[8] = is_empresa
la_values[9] = is_anyo
la_values[10] = is_serie
la_values[11] = is_factura

ls_sql = "UPDATE venfac "+&
			"SET fecha_factura = @fecha, "+&
			"cliente=@cliente, "+&
			"obra=@obra, "+&
			"forma_pago=@forma, "+&
			"subtotal=@subtotal, "+&
			"total_iva=@total_iva, "+&
			"total_factura=@importe "+&
			"WHERE empresa= @empresa "+&
			"AND anyo=@anyo "+&
			"AND serie=@serie "+&
			"AND factura = @factura"

ln_exec = CREATE n_cst_sqlexecutor
lb_result = ln_exec.of_Update( ls_sql, la_values[])
DESTROY ln_exec

IF lb_result  THEN
	wf_retrieve_lista()
END IF
end event

type cb_sqldelete from commandbutton within w_mant_facturas
integer x = 4955
integer width = 402
integer height = 112
integer taborder = 60
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Delete"
end type

event clicked;n_cst_sqlexecutor ln_exec
String ls_sql
any la_values[]
Boolean lb_result

Long ll_Row

ll_Row=  dw_1.GetRow()

If ll_Row < 1 Then Return

If Messagebox("Atencion!","¿Desea Eliminar el Registro?", Exclamation!, OkCancel!)=2 Then Return

is_empresa=dw_1.object.empresa[ll_Row]
is_anyo=dw_1.object.venfac_anyo[ll_Row]
is_serie=dw_1.object.serie[ll_Row]
is_factura=dw_1.object.factura[ll_Row]

la_values[1] = is_empresa
la_values[2] = is_anyo
la_values[3] = is_serie
la_values[4] = is_factura

ls_sql = "DELETE venfac "+&
			"WHERE empresa= @empresa "+&
			"AND anyo=@anyo "+&
			"AND serie=@serie "+&
			"AND factura = @factura"

ln_exec = CREATE n_cst_sqlexecutor
lb_result = ln_exec.of_delete( ls_sql, la_values[])
DESTROY ln_exec

IF lb_result  THEN
	wf_retrieve_lista()
	dw_1.Reset()
END IF



end event

type st_2 from statictext within w_mant_facturas
integer x = 4192
integer y = 24
integer width = 334
integer height = 68
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "SqlExecutor"
boolean focusrectangle = false
end type

type st_1 from statictext within w_mant_facturas
integer x = 4192
integer y = 148
integer width = 334
integer height = 68
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Datawindow"
boolean focusrectangle = false
end type

type cb_delete from commandbutton within w_mant_facturas
integer x = 4955
integer y = 124
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Delete"
end type

event clicked;Integer  li_rtn
Long ll_Row

ll_Row=  dw_1.GetRow()

If ll_Row < 1 Then Return

If Messagebox("Atencion!","¿Desea Eliminar el Registro?", Exclamation!, OkCancel!)=2 Then Return

If dw_1.of_DeleteRow(ll_Row) = 1 Then
	If dw_1.of_Update() = 1 Then
		wf_retrieve_lista()
	End if	
End If	

end event

type cb_update from commandbutton within w_mant_facturas
integer x = 5367
integer y = 124
integer width = 402
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Update"
end type

event clicked;If Messagebox("Atencion!","¿Desea Actualizar la Base de Datos?", Exclamation!, OkCancel!)=2 Then Return

If dw_1.of_Update() = 1 Then 
	wf_retrieve_lista()
End If
end event

type cb_insert from commandbutton within w_mant_facturas
integer x = 4544
integer y = 124
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Insert"
end type

event clicked;Long ll_Row

dw_1.Reset()

ll_Row = dw_1.InsertRow(0)

//Insertamos Clave Primaria
is_empresa="1"
is_anyo="2025"
is_serie="1"
is_factura=gf_nueva_factura(is_empresa, is_anyo, is_serie) 

dw_1.object.empresa[ll_Row]=is_empresa
dw_1.object.venfac_anyo[ll_Row]=is_anyo
dw_1.object.serie[ll_Row]=is_serie
dw_1.object.factura[ll_Row]=is_factura

//Añado la ultima fecha factura
dw_1.object.fecha[ll_Row]=gf_fecha_factura(is_empresa, is_anyo, is_serie) 

wf_retrieve_dddw(ALL) 
end event

type dw_1 from vs_dw_api within w_mant_facturas
integer x = 4151
integer y = 256
integer width = 2848
integer height = 2300
integer taborder = 10
string dataobject = "dw_mant_detalle"
boolean livescroll = false
borderstyle borderstyle = stylebox!
boolean ib_logo = false
end type

event itemchanged;call super::itemchanged;Dec{2} ld_importe, ld_totaliva
Constant Dec{2} ld_iva = 0.21

Choose Case dwo.name
	Case "cliente"
		wf_retrieve_dddw("obra")
		this.Object.Obra[1]=""
     Case "subtotal" 
		ld_totaliva = round(dec(data) * ld_iva, 2)
		ld_importe = round(dec(data) + ld_totaliva, 2)
		this.object.total_iva[row]=ld_totaliva
		this.object.importe[row]=ld_importe
End Choose
end event

event retrieveend;call super::retrieveend;wf_retrieve_dddw(ALL)
end event

event clicked;call super::clicked;n_cst_sqlexecutor ln_exec
String ls_sql, ls_Simbolo, ls_func
Any la_values[], la_result[], la_null[]
Long ll_numFac, ll_numAnt

If dw_1.RowCount() <> 1 then Return

Choose Case  dwo.name
	Case "b_ant"
		ls_func = "max"
		ls_Simbolo = "<"
	Case "b_sig"
		   ls_func = "min"
			ls_Simbolo = ">"
		Case Else
		Return
End Choose

ll_numFac = long(is_factura)

ln_exec = Create n_cst_sqlexecutor
	
ls_sql = "SELECT isnull("+ls_func+"(convert(int, factura)), 0)  "+&
			 "FROM venfac "+&
			 "WHERE empresa = @empresa  "+&		
			 "AND anyo = @anyo  "+&	
			  "AND serie = @serie "+&
			  "AND convert(int, factura) "+ls_simbolo+" @numFac"
			 
la_values[1]=is_empresa
la_values[2]=is_anyo
la_values[3]=is_serie
la_values[4] = ll_numFac

la_result[] = ln_exec.of_SelectInto(ls_sql, la_values[])

IF  IsNull( la_result[1]) or  la_result[1] = 0 THEN 
	ls_sql = "SELECT isnull("+ls_func+"(convert(int, factura)), 0)  "+&
				 "FROM venfac "+&
				 "WHERE empresa = @empresa  "+&		
				 "AND anyo = @anyo  "+&	
				  "AND serie = @serie "
	la_values[]=la_null[]			 
	la_values[1]=is_empresa
	la_values[2]=is_anyo
	la_values[3]=is_serie

	la_result[] = ln_exec.of_SelectInto(ls_sql, la_values[])
	If  IsNull( la_result[1]) or  la_result[1] = 0 Then Return 
End If

Destroy ln_exec

ll_numAnt = la_result[1]
is_factura = string(ll_numAnt)

la_values[]=la_null[]			 
la_values[1]=is_empresa
la_values[2]=is_anyo
la_values[3]=is_serie
la_values[4]=is_factura
dw_1.of_retrieve(la_values[])
end event

type gb_busqueda from groupbox within w_mant_facturas
integer x = 46
integer y = 44
integer width = 4005
integer height = 164
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Criterio de Búsqueda"
end type

type gb_registros from groupbox within w_mant_facturas
integer x = 50
integer y = 2388
integer width = 4078
integer height = 164
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string pointer = "11"
long textcolor = 33554432
long backcolor = 67108864
end type

