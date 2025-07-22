$PBExportHeader$w_con_facturas.srw
forward
global type w_con_facturas from window
end type
type pb_print_composite from picturebutton within w_con_facturas
end type
type dw_composite from vs_dw_api within w_con_facturas
end type
type pb_print_report from picturebutton within w_con_facturas
end type
type rb_3 from radiobutton within w_con_facturas
end type
type rb_2 from radiobutton within w_con_facturas
end type
type rb_1 from radiobutton within w_con_facturas
end type
type st_3 from statictext within w_con_facturas
end type
type st_2 from statictext within w_con_facturas
end type
type st_1 from statictext within w_con_facturas
end type
type cb_consultar from commandbutton within w_con_facturas
end type
type sle_department from singlelineedit within w_con_facturas
end type
type sle_customer from singlelineedit within w_con_facturas
end type
type sle_serie from singlelineedit within w_con_facturas
end type
type dp_2 from datepicker within w_con_facturas
end type
type dp_1 from datepicker within w_con_facturas
end type
type gb_1 from groupbox within w_con_facturas
end type
type gb_2 from groupbox within w_con_facturas
end type
type gb_3 from groupbox within w_con_facturas
end type
type dw_report from vs_dw_api within w_con_facturas
end type
type dw_1 from vs_dw_api within w_con_facturas
end type
end forward

global type w_con_facturas from window
integer width = 5221
integer height = 2972
boolean titlebar = true
string title = "Listado Facturas"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
pb_print_composite pb_print_composite
dw_composite dw_composite
pb_print_report pb_print_report
rb_3 rb_3
rb_2 rb_2
rb_1 rb_1
st_3 st_3
st_2 st_2
st_1 st_1
cb_consultar cb_consultar
sle_department sle_department
sle_customer sle_customer
sle_serie sle_serie
dp_2 dp_2
dp_1 dp_1
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
dw_report dw_report
dw_1 dw_1
end type
global w_con_facturas w_con_facturas

type prototypes
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

forward prototypes
public function long wf_retrieve_nested (u_dw adw, any aa_values[])
private subroutine wf_set_args (datawindowchild adw, string as_argnames[], string as_argdatatypes[], any aa_argvalues[])
public function long wf_retrieve (vs_dw_api adw)
public function long wf_retrieve_composite (u_dw adw, any aa_values[])
end prototypes

public function long wf_retrieve_nested (u_dw adw, any aa_values[]);Long ll_RowCount
String ls_Json
Integer li_result
DataWindowChild dwc_Nested
String ls_DwProcessing
String ls_Argnames[], ls_Argdatatypes[], la_values[]
nvo_ds_api ds_aux, ds_report
string ls_header, ls_objname, ls_ObjectTemp, ls_Nested, ls_library, ls_libraryTemp
String ls_syntax_original, ls_syntax_new, ErrorBuffer, ls_data_new, ls_data_original
integer li_rtncode

yield()
SetPointer (Hourglass!)

ls_objname ="report_cabecera"
ls_library = gf_getlibraryfromdatawindow(ls_objname) 
ls_Nested ="dw_cabecera"

 If Not gb_isPBIDE Then
	adw.Modify(ls_Nested + ".DataObject='"+ls_objname+"'")
 End If

//Retrieve Argument for Nested report
ls_Argnames[1]="arg_empresa"
ls_Argdatatypes[1]="string"
la_values[1] = "1" 

If gb_isPBIDE Then
	ls_library = gf_replaceall(ls_library, gs_dir+"\", "")
End If

//Create Helper Datastore to Import Nested Report Data
ds_aux = Create nvo_ds_api
ds_aux.DataObject =ls_objname

//Get Original Data
ls_data_original =ds_aux.Describe("DataWindow.Syntax.Data")

If ls_data_original = "data() " Then
	ls_data_original = ""
 Else
	ls_data_original ="~r~n"+ls_data_original
 End If
 
//Retrieve Nested
ds_aux.of_retrieve(la_values[])

//Get String With Data
ls_data_new = ds_aux.Describe("DataWindow.Syntax.Data") 

If ls_data_new = "data() " Then
	ls_data_new = ""
 Else
 	ls_data_new ="~r~n"+ls_data_new
End If

//Export Syntax of NestedReport
IF gb_isPBIDE Then
	ls_libraryTemp = ls_library
	ls_ObjectTemp = ls_objname
	ls_syntax_original = LibraryExport (ls_library , ls_objname, ExportDataWindow! )
Else
	ls_libraryTemp = gn_api.is_TempLibrary
	ls_ObjectTemp = ls_objname+"_dwtemp"
	ls_header = "$PBExportHeader$" + ls_objname + ".srd"
	ls_syntax_original = ls_header +"~r~n"+ ds_aux.Describe("DataWindow.Syntax") 
End IF

//Replacing Data in the Datastore Syntax
ls_syntax_new=ls_syntax_original+ls_data_new

//Import New Datawindow with Data
li_rtncode = LibraryImport(ls_librarytemp, ls_ObjectTemp, ImportDataWindow!, ls_syntax_new, ErrorBuffer, "")
destroy ds_aux

//Retrieve Princial Report
ds_report = Create nvo_ds_api
ds_report.DataObject = adw.DataObject

ds_report.of_retrieve(aa_values[])
ls_json = ds_report.ExportJson()
Destroy ds_report

//Import Json to Base Datawindow
adw.Reset()

 If Not gb_isPBIDE Then
	  adw.Modify(ls_Nested + ".DataObject='"+ls_ObjectTemp+"'")
 End IF
 
ll_RowCount = adw.ImportJson(ls_json)

//Remplace Arguments In Nested Repor for Them Values.
If ll_RowCount > 0 Then

	ls_DwProcessing = adw.Describe("Datawindow.Processing")
	If ls_DwProcessing <> "5" Then adw.Modify ("Datawindow.Processing=5")
	
	li_result =adw.GetChild(ls_Nested, dwc_Nested)
	
	If li_Result <> 1 Then
		gf_mensaje("Error", "¡ Error Tomando Refrencia a Nested Report !")
		Return -1
	End IF
		
	wf_set_args(dwc_Nested, ls_Argnames[], ls_Argdatatypes[], la_values[])
	adw.groupcalc()

	If ls_DwProcessing <> "5" Then adw.Modify ("Datawindow.Processing="+ls_DwProcessing)
End If	

//Restore Original Report
ls_syntax_original=ls_syntax_original+ls_data_original

 If gb_isPBIDE Then
	li_rtncode = LibraryImport(ls_libraryTemp, ls_ObjectTemp, ImportDataWindow!, ls_syntax_original, ErrorBuffer, "")
 Else
	li_rtncode = LibraryDelete(ls_libraryTemp, ls_ObjectTemp, ImportDataWindow!)
End If
		
SetPointer (Arrow!)
adw.Event Retrieveend(ll_RowCount)

Return ll_RowCount
end function

private subroutine wf_set_args (datawindowchild adw, string as_argnames[], string as_argdatatypes[], any aa_argvalues[]);string      ls_object, ls_objects, ls_type, ls_expression
string      ls_value, ls_aux
integer     li_len, li_to, li_from, li_x, li_pos

// Obtenemos la colección de objetos de ds.
ls_objects = adw.describe('datawindow.objects')

// Recorremos los todos objetos.
li_len = len(ls_objects)

If li_len > 0 Then
   // Inicializamos la variable necesaria desde la que buscamos el siguiente objeto.
   li_from = 1
   
   // Recorremos todos los objetos.
   Do
      li_to = pos(ls_objects, "~t", li_from)
      
      // Obtenemos el nombre del objeto.
      If li_to = 0 Then
         ls_object = mid(ls_objects, li_from)
      Else
         ls_object = mid(ls_objects, li_from, li_to - li_from)
      End If
      
      If len(ls_object) > 0 Then
         // Obtenemos el tipo del objeto.
         ls_type = adw.describe(ls_object + '.type')
         
         // Solo si es computado comprobamos si su expresión contiene "retrieval arguments".
         If ls_type = "compute" Then
            ls_expression = adw.describe(ls_object + '.expression')
            
            // Para cada objeto miramos todos los "retrieval arguments".
            For li_x = 1 To upperBound(as_argNames)      
               // Solo tratamos argumentos que no sean array.
               If right(as_argDataTypes[li_x], 4) = 'list' Then
                  Continue
               Else
                  li_pos = pos(ls_expression, as_argNames[li_x])
   
                  Do While li_pos > 0 
                     // Comprobamos que no sea otro identificador distinto, para lo que
                     // el carácter que lo precede y el que le sigue debe ser distinto
                     // de letra o número. (si buscamos 'numeropi' que no tome 'numeropista')                  
                     If ((li_pos = 1) Or match(mid(ls_expression, li_pos -1, 1), '[^A-Z^a-z^0-9]')) And &
                        ((li_pos + len(as_argNames[li_x]) - 1 = len(ls_expression)) Or match(mid(ls_expression, li_pos + len(as_argNames[li_x]), 1), '[^A-Z^a-z^0-9]')) Then
   
                     
					// Hay que tratar los argumentos Nulos.
					IF isnull(aa_argValues[li_x]) THEN
						Choose Case as_argDataTypes[li_x]
							Case 'number'
								 ls_value ="0"
							Case 'string'
								ls_value = ""                        
							Case 'date'
								ls_value = "1900-01-01"
							Case 'time'
								ls_value="00:00:00"
							Case 'datetime'
								ls_value = "1900-01-01 00:00:00"
							Case Else
									// En un computado no podría aparecer otro tipo.
							End Choose	
					ELSE	
						   ls_value = string(aa_argValues[li_x])
					END IF			
					                        
                        // Obtenemos la nueva expresión para el computado en base al tipo de dato.
                        Choose Case as_argDataTypes[li_x]
                           Case 'number'
                              ls_aux = ls_value
                           Case 'string'
                              ls_aux = "'" + ls_value + "'"                           
                           Case 'date'
                              ls_aux = "date('" + ls_value + "')"
                           Case 'time'
                              ls_aux = "time('" + ls_value + "')"
                           Case 'datetime'
                              ls_aux = "datetime(date(left('" + ls_value + "', 10)), time(mid('" + ls_value + "', 12, 8)))"
                           Case Else
                              // En un computado no podría aparecer otro tipo.
                        End Choose
                        
                        ls_expression = replace(ls_expression, li_pos, len(as_argNames[li_x]), ls_aux)
                     End If
                        
                     // Buscamos si la misma ocurrencia aparece otra vez.
                     li_pos = pos(ls_expression, as_argNames[li_x])
                  Loop
               End If
            Next
            
            // Si se modifico la expresión para el compute la sustituimos con la nueva.
            If ls_expression <> adw.describe(ls_object + '.expression') Then

               // Antes de hacer el modify, hay que añadir delante de las comillas dobles la virgulilla.
               li_pos = pos(ls_expression, '"')
               do while li_pos > 0
                  ls_expression = replace(ls_expression, li_pos, 0, "~~")
                  li_pos = pos(ls_expression, '"', li_pos + 2)
               Loop
               
               ls_aux = adw.Modify(ls_object + ".expression=~"" + ls_expression + "~"")
               
            End If
         End If
      End If
      
      li_from = li_to + 1
   Loop While (li_to > 0)
End If
end subroutine

public function long wf_retrieve (vs_dw_api adw);string ls_empresa, ls_serie,  ls_cli1, ls_cli2, ls_situacion, ls_anyo, ls_obra
Datetime ldt_fecha1, ldt_fecha2
any aa_values[]
Long ll_RowCount

ls_empresa="1"
ls_anyo=string(year(date(dp_1.value)))
ldt_fecha1 = dp_1.value
ldt_fecha2 = dp_2.value

if year(date(dp_1.value)) <> year(date(dp_2.value)) Then
	gf_mensaje("Atención!", "¡Elija un Rango de Fechas del mismo Ejercicio!")
	Return -1
End If

if trim(sle_serie.text)<>""  then
	ls_serie= trim(sle_serie.text)
else
	setnull(ls_serie)
end if	

choose case true
	case 	rb_1.checked
		ls_situacion="N"
	case	rb_2.checked
		ls_situacion="S"
	case	rb_3.checked
		 setnull(ls_situacion)
end choose

	
iF Trim(sle_customer.text) = "" Then
   ls_cli1 = "1"
   ls_cli2 = "99999"
ELSE
	ls_cli1 = sle_customer.text
	ls_cli2 = sle_customer.text
END IF

If  trim(sle_department.text) = "" THEN
	setnull(ls_obra)
ELSE
	ls_obra = sle_department.text
END IF

adw.setredraw(false)		

aa_values[1]  = ls_empresa
aa_values[2]  = ls_anyo
aa_values[3]  = ls_serie
aa_values[4]  = ldt_fecha1
aa_values[5]  = ldt_fecha2
aa_values[6]  = ls_cli1
aa_values[7]  = ls_cli2
aa_values[8]  = ls_obra
aa_values[9]  = ls_situacion

Choose Case adw.Dataobject
	Case "report_composite"
		ll_RowCount = wf_retrieve_composite(adw, aa_values[])
	Case "report_con_listado_con_cabecera"
		ll_RowCount = wf_retrieve_nested(adw, aa_values[])
	Case Else
		ll_RowCount = adw.of_Retrieve(aa_values[])
End Choose


adw.setredraw(true)		

Return ll_RowCount
end function

public function long wf_retrieve_composite (u_dw adw, any aa_values[]);Long ll_RowCount
String ls_Json1, ls_Json2
DataWindowChild dwc_1, dwc_2
String ls_Argnames[], ls_Argdatatypes[], la_values[]
nvo_ds_api ds_1, ds_2
string ls_objname1, ls_objname2
Integer li_result

yield()
SetPointer (Hourglass!)

//Create Helper Datastore to Import Nested Report Data
ls_objname1 ="report_cabecera"
ds_1= Create nvo_ds_api
ds_1.DataObject =ls_objname1

//Retrieve Argument for Nested report 1
ls_Argnames[1]="arg_empresa"
ls_Argdatatypes[1]="string"
la_values[1] = "1" 

//Retrieve Nested
ds_1.of_retrieve(la_values[])
ls_json1 = ds_1.ExportJson()
Destroy ds_1

//Retrieve Princial Report
ls_objname2 ="report_con_listado_sin_cabecera"

ds_2= Create nvo_ds_api
ds_2.DataObject = ls_objname2

ds_2.of_retrieve(aa_values[])
ls_json2 = ds_2.ExportJson()
Destroy ds_2

//Import Json to Base Datawindow
adw.Reset()

li_result =adw.GetChild("dw_cabecera", dwc_1)

If li_Result <> 1 Then
	gf_mensaje("Error", "¡ Error Tomando Refrencia a Nested Report 1 !")
	Return -1
End IF

dwc_1.Reset()
ll_RowCount = dwc_1.ImportJson(ls_json1)
wf_set_args(dwc_1, ls_Argnames[], ls_Argdatatypes[], la_values[])

li_result =adw.GetChild("dw_report", dwc_2)

If li_Result <> 1 Then
	gf_mensaje("Error", "¡ Error Tomando Refrencia a Nested Report 2 !")
	Return -1
End IF

dwc_2.Reset()
ll_RowCount = dwc_2.ImportJson(ls_json2)
wf_set_args(dwc_1, ls_Argnames[], ls_Argdatatypes[], la_values[])


adw.groupcalc()
SetPointer (Arrow!)
adw.Event Retrieveend(ll_RowCount)

Return ll_RowCount
end function

on w_con_facturas.create
this.pb_print_composite=create pb_print_composite
this.dw_composite=create dw_composite
this.pb_print_report=create pb_print_report
this.rb_3=create rb_3
this.rb_2=create rb_2
this.rb_1=create rb_1
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.cb_consultar=create cb_consultar
this.sle_department=create sle_department
this.sle_customer=create sle_customer
this.sle_serie=create sle_serie
this.dp_2=create dp_2
this.dp_1=create dp_1
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.dw_report=create dw_report
this.dw_1=create dw_1
this.Control[]={this.pb_print_composite,&
this.dw_composite,&
this.pb_print_report,&
this.rb_3,&
this.rb_2,&
this.rb_1,&
this.st_3,&
this.st_2,&
this.st_1,&
this.cb_consultar,&
this.sle_department,&
this.sle_customer,&
this.sle_serie,&
this.dp_2,&
this.dp_1,&
this.gb_1,&
this.gb_2,&
this.gb_3,&
this.dw_report,&
this.dw_1}
end on

on w_con_facturas.destroy
destroy(this.pb_print_composite)
destroy(this.dw_composite)
destroy(this.pb_print_report)
destroy(this.rb_3)
destroy(this.rb_2)
destroy(this.rb_1)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_consultar)
destroy(this.sle_department)
destroy(this.sle_customer)
destroy(this.sle_serie)
destroy(this.dp_2)
destroy(this.dp_1)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.dw_report)
destroy(this.dw_1)
end on

event open;If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

dp_1.value=datetime("01-04-2025")
dp_2.value=datetime("22-04-2025")



end event

event resize;dw_1.Width = Width - 200
dw_1.Height = Height -  560

dw_report.Width = Width - 200
dw_report.Height = Height - 560

dw_composite.Width = Width - 200
dw_composite.Height = Height - 560

pb_print_composite.x =newwidth - pb_print_composite.width - 75
pb_print_report.x = pb_print_composite.x - pb_print_report.width - 25
cb_consultar.x = pb_print_report.x - cb_consultar.width - 25



end event

event close;Long ll_OpenWindows

If IsValid(w_frame) Then
	ll_OpenWindows = gf_ventanas_abiertas(w_frame)
	
	If ll_OpenWindows = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If
end event

type pb_print_composite from picturebutton within w_con_facturas
integer x = 5010
integer y = 164
integer width = 137
integer height = 112
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "PrintDataWindow!"
alignment htextalign = left!
string powertiptext = "Print Composite"
end type

event clicked;wf_retrieve(dw_composite)
//dw_report.visible=false
//dw_1.visible=false
//dw_composite.visible=true

dw_composite.of_print()


end event

type dw_composite from vs_dw_api within w_con_facturas
boolean visible = false
integer x = 50
integer y = 340
integer width = 5115
integer height = 2072
integer taborder = 80
string dataobject = "report_composite"
boolean vscrollbar = true
boolean ib_logo = false
end type

type pb_print_report from picturebutton within w_con_facturas
integer x = 4869
integer y = 164
integer width = 137
integer height = 112
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "PrintDataWindow!"
alignment htextalign = left!
string powertiptext = "Print Report"
end type

event clicked;wf_retrieve(dw_report)
//dw_report.visible=true
//dw_1.visible=false
//dw_composite.visible=false

dw_report.of_print()

end event

type rb_3 from radiobutton within w_con_facturas
integer x = 2377
integer y = 252
integer width = 402
integer height = 56
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Todas"
boolean checked = true
end type

type rb_2 from radiobutton within w_con_facturas
integer x = 2377
integer y = 180
integer width = 480
integer height = 56
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Contabilizadas"
end type

type rb_1 from radiobutton within w_con_facturas
integer x = 2377
integer y = 104
integer width = 462
integer height = 56
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "No Contabilizadas"
end type

type st_3 from statictext within w_con_facturas
integer x = 1838
integer y = 136
integer width = 128
integer height = 64
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Obra"
boolean focusrectangle = false
end type

type st_2 from statictext within w_con_facturas
integer x = 1298
integer y = 140
integer width = 201
integer height = 64
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Cod. Cliente"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_1 from statictext within w_con_facturas
integer x = 946
integer y = 140
integer width = 128
integer height = 64
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Serie"
boolean focusrectangle = false
end type

type cb_consultar from commandbutton within w_con_facturas
integer x = 4457
integer y = 164
integer width = 402
integer height = 108
integer taborder = 40
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Consultar"
end type

event clicked;wf_retrieve(dw_1)
dw_1.visible=true
dw_report.visible=false
dw_composite.visible=false
end event

type sle_department from singlelineedit within w_con_facturas
integer x = 1993
integer y = 120
integer width = 261
integer height = 100
integer taborder = 30
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_customer from singlelineedit within w_con_facturas
integer x = 1541
integer y = 120
integer width = 261
integer height = 100
integer taborder = 20
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_serie from singlelineedit within w_con_facturas
integer x = 1088
integer y = 120
integer width = 137
integer height = 100
integer taborder = 20
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = "1"
borderstyle borderstyle = stylelowered!
end type

type dp_2 from datepicker within w_con_facturas
integer x = 485
integer y = 120
integer width = 402
integer height = 100
integer taborder = 10
boolean border = true
borderstyle borderstyle = stylelowered!
datetimeformat format = dtfcustom!
string customformat = "dd-MM-yyyy"
date maxdate = Date("2025-12-31")
date mindate = Date("2024-01-01")
datetime value = DateTime(Date("2025-07-22"), Time("10:55:58.000000"))
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
integer calendarfontweight = 400
boolean todaysection = true
boolean todaycircle = true
end type

type dp_1 from datepicker within w_con_facturas
integer x = 69
integer y = 120
integer width = 402
integer height = 100
integer taborder = 10
boolean border = true
borderstyle borderstyle = stylelowered!
datetimeformat format = dtfcustom!
string customformat = "dd-MM-yyyy"
date maxdate = Date("2025-12-31")
date mindate = Date("2024-01-01")
datetime value = DateTime(Date("2025-07-22"), Time("10:55:58.000000"))
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
integer calendarfontweight = 400
boolean todaysection = true
boolean todaycircle = true
end type

type gb_1 from groupbox within w_con_facturas
integer x = 32
integer y = 12
integer width = 873
integer height = 308
integer taborder = 40
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Fechas"
end type

type gb_2 from groupbox within w_con_facturas
integer x = 2313
integer y = 16
integer width = 558
integer height = 308
integer taborder = 40
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Situación"
end type

type gb_3 from groupbox within w_con_facturas
integer x = 914
integer y = 16
integer width = 1385
integer height = 308
integer taborder = 50
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Critérios"
end type

type dw_report from vs_dw_api within w_con_facturas
boolean visible = false
integer x = 50
integer y = 340
integer width = 5115
integer height = 2072
integer taborder = 70
string dataobject = "report_con_listado_con_cabecera"
boolean vscrollbar = true
boolean ib_logo = false
end type

type dw_1 from vs_dw_api within w_con_facturas
integer x = 50
integer y = 340
integer width = 5115
integer height = 2512
integer taborder = 60
boolean bringtotop = true
string dataobject = "dw_con_listado"
boolean vscrollbar = true
end type

event doubleclicked;call super::doubleclicked;Integer li_rtn
str_venfac lstr_venfac

If row < 1 then return

lstr_venfac.as_empresa=dw_1.object.empresa[row]
lstr_venfac.as_anyo=dw_1.object.venfac_anyo[row]
lstr_venfac.as_serie=dw_1.object.serie[row]
lstr_venfac.as_factura=dw_1.object.factura[row]

OpenSheetWithParm(w_mant_facturas, lstr_venfac, w_frame, 0, layered!)

li_rtn =  Message.DoubleParm

If li_rtn = 1 Then
	wf_retrieve(dw_1)
End if	
end event

