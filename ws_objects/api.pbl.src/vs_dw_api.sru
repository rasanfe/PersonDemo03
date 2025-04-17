$PBExportHeader$vs_dw_api.sru
forward
global type vs_dw_api from u_dw
end type
end forward

global type vs_dw_api from u_dw
end type
global vs_dw_api vs_dw_api

type variables
Constant Private string is_controller = "Datawindow"
Private Any ia_values[]
Private String is_dwargnames[], is_dwargdatatypes[]



end variables

forward prototypes
public function integer of_getarguments (ref string as_argnames[], ref string as_argdatatypes[])
public subroutine of_setarguments (string as_argnames[], string as_argdatatypes[], any aa_argvalues[])
public function long of_retrieve (any aa_values[])
public function string of_encode (string as_source)
public function integer of_deleterow (long al_row)
public function long of_update ()
private function string of_get_syntax ()
public function long of_cargar (string as_sql)
end prototypes

public function integer of_getarguments (ref string as_argnames[], ref string as_argdatatypes[]);String       ls_dwargs, ls_dwargswithtype[], ls_args[], ls_types[]
Long         ll_a, ll_args, ll_pos, ll_index

// Obtenemos el string con los argumentos del dw o ds.
ls_dwargs = This.Dynamic Describe ( "DataWindow.Table.Arguments" ) 

// Separamos los argumentos utilizando la un array y obtenemos el número total.
ll_args = gf_ParseToArray ( ls_dwargs, "~n", ls_dwargswithtype ) 

// Ahora separamos el nombre del argumento de su tipo.
For ll_a = 1 to ll_args
   ll_pos = Pos ( ls_dwargswithtype[ll_a], "~t", 1 )

   If ll_pos > 0 Then
      ll_index = UpperBound(as_argnames) + 1
      as_argNames[ll_index]      = Left ( ls_dwargswithtype[ll_a], ll_pos - 1 ) 
      as_argDataTypes[ll_index] = Mid ( ls_dwargswithtype[ll_a], ll_pos + 1 ) 
	End If
Next

Return UpperBound(as_argNames)
end function

public subroutine of_setarguments (string as_argnames[], string as_argdatatypes[], any aa_argvalues[]);String      ls_object, ls_objects, ls_type, ls_expression
String      ls_value, ls_aux
Integer     li_len, li_to, li_from, li_x, li_pos

// Obtenemos la colección de objetos de ds.
ls_objects = This.Describe('datawindow.objects')

// Recorremos los todos objetos.
li_len = Len(ls_objects)

If li_len > 0 Then
   // Inicializamos la variable necesaria desde la que buscamos el siguiente objeto.
   li_from = 1
   
   // Recorremos todos los objetos.
   Do
      li_to = Pos(ls_objects, "~t", li_from)
      
      // Obtenemos el nombre del objeto.
      If li_to = 0 Then
         ls_object = Mid(ls_objects, li_from)
      Else
         ls_object = Mid(ls_objects, li_from, li_to - li_from)
      End If
      
      If Len(ls_object) > 0 Then
         // Obtenemos el tipo del objeto.
         ls_type = This.Describe(ls_object + '.type')
         
         // Solo si es computado comprobamos si su expresión contiene "retrieval arguments".
         If ls_type = "compute" Then
            ls_expression = This.Describe(ls_object + '.expression')
            
            // Para cada objeto miramos todos los "retrieval arguments".
            For li_x = 1 To UpperBound(as_argNames)      
               // Solo tratamos argumentos que no sean array.
               If Right(as_argDataTypes[li_x], 4) = 'list' Then
                  Continue
               Else
                  li_pos = Pos(ls_expression, as_argNames[li_x])
   
                  Do While li_pos > 0 
                     // Comprobamos que no sea otro identificador distinto, para lo que
                     // el carácter que lo precede y el que le sigue debe ser distinto
                     // de letra o número. (si buscamos 'numeropi' que no tome 'numeropista')                  
                     If ((li_pos = 1) Or Match(Mid(ls_expression, li_pos -1, 1), '[^A-Z^a-z^0-9]')) And &
                        ((li_pos + Len(as_argNames[li_x]) - 1 = Len(ls_expression)) Or Match(Mid(ls_expression, li_pos + Len(as_argNames[li_x]), 1), '[^A-Z^a-z^0-9]')) Then
   
                     
					// Hay que tratar los argumentos Nulos.
					If IsNull(aa_argValues[li_x]) Then
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
					Else
						   ls_value = string(aa_argValues[li_x])
					End If			
					                        
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
                        
                        ls_expression = Replace(ls_expression, li_pos, Len(as_argNames[li_x]), ls_aux)
                     End If
                        
                     // Buscamos si la misma ocurrencia aparece otra vez.
                     li_pos = Pos(ls_expression, as_argNames[li_x])
                  Loop
               End If
            Next
            
            // Si se modifico la expresión para el compute la sustituimos con la nueva.
            If ls_expression <> This.Describe(ls_object + '.expression') Then

               // Antes de hacer el modify, hay que añadir delante de las comillas dobles la virgulilla.
               li_pos = Pos(ls_expression, '"')
               Do While li_pos > 0
                  ls_expression = Replace(ls_expression, li_pos, 0, "~~")
                  li_pos = Pos(ls_expression, '"', li_pos + 2)
               Loop
               
               ls_aux = This.Modify(ls_object + ".expression=~"" + ls_expression + "~"")
               
            End If
         End If
      End If
      
      li_from = li_to + 1
   Loop While (li_to > 0)
End If
end subroutine

public function long of_retrieve (any aa_values[]);Long ll_RowCount
String ls_url, ls_ApiVerb, ls_DwProcessing, ls_Json, ls_jsonReceived, ls_DataObject, ls_Syntax, ls_encodedSyntax
Any la_Array[]
n_JsonGenerator lnv_JsonGenerator
String ls_argnames[], ls_argdatatypes[]
Any la_values[], la_Null[]
Integer li_value, li_TotalValues, li_result, li_new

This.SetRedraw(False)
This.Reset()

ls_DataObject = This.DataObject

If ls_DataObject = "" Then
	gf_mensaje("Datawindow Api Error", "¡ No hay DataObject asignado al Datawindow !")
	Return -1
End If	

li_TotalValues=UpperBound(aa_values[])

//1- Obtener la Sintaxi <<This.Describe("Datawindow.Syntax")>>
ls_Syntax = of_Get_Syntax()

If ls_Syntax = "" then Return -1

//2- Codificar en Base64
ls_encodedSyntax = of_encode(ls_Syntax)
	
//3- Preparamos Primer Elemento del Json con la Syntaxi		
li_new = 1
ls_argnames[li_new]="sqlEncoded"
ls_argdatatypes[li_new]="string"
la_values[li_new]=ls_encodedSyntax
	
//4- Obetnermos los Argumentos del Datawindow	
li_result= of_getarguments (ref is_dwargnames[], ref is_dwargdatatypes[])
	
If li_result > li_TotalValues Then
	gf_mensaje("Json Error", "Expecting "+string(li_result)+" retrieval arguments but got "+string(li_TotalValues)+".")
	Return -1
End If
	
//5 - Si recibo mas argumentos de los admitidos ignoro los que sobran.
If li_result < li_TotalValues Then
	li_TotalValues = li_result	
End If
	
//6- Detectamos si el Datawindow es Composite para no Hacer el Retieve directamente.	
ls_DwProcessing = This.Describe("Datawindow.Processing")

If ls_DwProcessing <> "5" Then
	 // 7- Preparamos con los Argumentos los siguientes elementos del Json  
	For li_value = 1 To li_TotalValues
		li_new ++
		ls_argnames[li_new]=is_dwargnames[li_value]
		ls_argdatatypes[li_new]=is_dwargdatatypes[li_value]
		la_values[li_new]=aa_values[li_value]
	Next
	
	// 8- Creamos el Json
	lnv_JsonGenerator = Create n_JsonGenerator
	ls_json = lnv_JsonGenerator.of_set_arguments(ls_argnames[], ls_argdatatypes[], la_values[])
	Destroy lnv_JsonGenerator
	
	//9- Preparamos la URL 
	ls_ApiVerb = "POST"
	ls_url =  gn_api.of_get_url(is_Controller, "Retrieve")
	
	//10- Hacemos llamada POST
	gn_api.of_Post(ls_url, ls_Json, ref ls_jsonReceived)
	
	//11- Importamos Json Recibido
	ll_RowCount = ImportJson(ls_jsonReceived)
Else
	//Para Los dw Composite Inserto una Fila
	ll_RowCount = InsertRow(0) 
End If

If ll_RowCount < 0 Then
	gf_mensaje(ls_ApiVerb + " Request Error "+string(ll_RowCount), gn_api.of_get_error_text())
End If
//12- Recargo los Retrieval Argument por si se usan en funciones o otras cosas.
of_setarguments(is_dwargnames[], is_dwargdatatypes[], aa_values[])
	
//13- Actualizamos Banderas y reseteamos variables	
ResetUpdate()
ia_values[] = aa_values[] //Guardo los valores
aa_values[] = la_Null[]
is_dwargnames[] = la_Null[]
is_dwargdatatypes[] = la_Null[]

This.Event Retrieveend(ll_RowCount)
This.SetRedraw(True)
Return ll_RowCount
end function

public function string of_encode (string as_source);String ls_encoded
n_CoderObject ln_coder 

ln_coder =  Create n_CoderObject

ls_encoded = ln_coder.of_encode(as_source)

Destroy ln_coder

Return ls_encoded
end function

public function integer of_deleterow (long al_row);Integer li_Rtn

li_Rtn = This.RowsMove(al_row, al_row, Primary!,  This, al_row, Delete!)

Return li_Rtn
end function

public function long of_update ();String ls_encodedSQL, ls_url, ls_ApiVerb
String ls_SqlWithParams, ls_JsonReceived
String ls_jsonsend, ls_jsonExport, ls_jsonExportEncoded
n_JsonGenerator lnv_JsonGenerator
Long ll_rtn
String ls_key[], ls_type[]
any la_value[]

//Sincroniza Cambios (Insert/Delete/Update) con API
This.AcceptText()

//1-Exportamos Datos en Json (changedonly, format)
ls_jsonExport  = This.ExportJson(True, True)
	
//2-Obtenemos la Sintaxi (SDR) del Datawindow	
ls_SqlWithParams =This.describe("Datawindow.syntax")

//3- Codificamos en Base 64
ls_encodedSQL = of_encode(ls_SqlWithParams)
ls_jsonExportEncoded  = of_encode(ls_jsonExport)

//4-Preparamos URL
ls_ApiVerb = "POST"
ls_url =  gn_api.of_get_url(is_Controller, "Update")

//5- Cremos Json Combiando con Sintaxi y Datos Exportados.
lnv_JsonGenerator =  Create n_JsonGenerator

ls_type[1] = "string"
ls_key[1] = "sqlEncoded"
la_value[1] = ls_encodedSQL

ls_type[2] = "string"
ls_key[2] = "jsonExport"
la_value[2] = ls_jsonExportEncoded

ls_jsonsend = lnv_JsonGenerator.of_set_arguments(ls_key[], ls_type[], la_value[])

//6- Hacemos llamada POST
ll_rtn = gn_api.of_Post(ls_url, ls_jsonSend,ref ls_JsonReceived)

If ll_rtn < 1 Then
	gf_mensaje(ls_ApiVerb+" Request Error", gn_api.of_get_error_text())
Else
	ll_rtn = long(ls_JsonReceived)
	If ll_rtn < 0 Then
		gf_mensaje("Datawindow Update", "Error al Actualizar Datawindow")
	End if
End If

//7- Reseteamos Estado Interno del Datawindow
This.ResetUpdate()
	
Return ll_rtn



end function

private function string of_get_syntax ();String ls_dwsyntax, ls_select

If This.DataObject = "" Then Return ""

ls_dwsyntax = This.Describe("DataWindow.Syntax")

//Api Log----------------------------------------------------------------------------------------
ls_select = This.Describe("DataWindow.Table.Select")

ls_Select =  gf_replaceall(ls_Select, ":", "@")
	
//Cambio los Tabuladores por un espacio
ls_Select =  gf_replaceall(ls_Select, "~t", " ")

//Quitamos los saltos de linea y pongo un espacio
ls_Select =  gf_replaceall(ls_Select, "~r~n", " ")
	
//Remplazamos los Espacios en Blanco Inecesarios
Do While Pos(ls_Select, "  ") > 0
	ls_Select =  gf_replaceall(ls_Select, "  ", " ")
Loop
	
//Si quedal algun espacio al final lo quito.
If right(ls_Select, 1) = " "  Then ls_select = Mid(ls_Select, 1, len(ls_select) - 1)
	
SetProfileString (gs_fichero_ini, "ApiLog", "LastSQL", ls_select)
//-----------------------------------------------------------------------------------------------

Return ls_dwsyntax
end function

public function long of_cargar (string as_sql);nvo_ds_api ds_data
Blob lblb_data
Long ll_rv, ll_RowCount

This.Reset()
This.Dataobject=""

ds_data = Create nvo_ds_api

ll_RowCount = ds_data.of_cargar(as_sql)

If ll_RowCount < 0 Then Return -1

ll_rv = ds_data.GetFullState(lblb_data)
			
If ll_rv = -1 Then
	gf_mensaje("Error", "¡ GetFullState failed !")
	Return -1
End If
			
ll_rv = This.SetFullState(lblb_data)
			
If ll_rv = -1 Then
	gf_mensaje("Error", "¡ SetFullState failed !")
	Return -1
End If

Destroy ds_data

//Formateamos el Datawindow
This.PostEvent(constructor!)

Return ll_RowCount
end function

on vs_dw_api.create
call super::create
end on

on vs_dw_api.destroy
call super::destroy
end on

