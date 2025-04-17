$PBExportHeader$n_cst_sqlexecutor.sru
forward
global type n_cst_sqlexecutor from nonvisualobject
end type
end forward

global type n_cst_sqlexecutor from nonvisualobject
end type
global n_cst_sqlexecutor n_cst_sqlexecutor

type variables
Constant string is_controller = "SqlExecutor"
end variables

forward prototypes
private function string of_encode (string as_source)
private function datetime of_string_to_datetime (string as_datetime)
public function boolean of_delete (string as_sql, any aa_values[])
public function boolean of_update (string as_sql, any aa_values[])
private function any of_execute (string as_method, string as_sql, ref any aa_values[])
public function long of_insert (string as_sql, any aa_values[])
private function string of_getsql (string as_sql)
private function any of_json_to_array (string as_json)
public function any of_selectinto (string as_sql, any aa_values[])
end prototypes

private function string of_encode (string as_source);String ls_encoded
n_CoderObject ln_coder 

ln_coder =  Create n_CoderObject

ls_encoded = ln_coder.of_encode(as_source)

Destroy ln_coder

Return ls_encoded
end function

private function datetime of_string_to_datetime (string as_datetime); Datetime ldt_datetime
 String ls_date, ls_time, ls_day, ls_month, ls_year, ls_full_datetime

//Formato esperado: "yyyy-mm-ddThh:mm:ss"
as_datetime =  Trim(as_datetime)
ls_date =Mid(as_datetime, 2, 10)   // "yyyy-mm-dd"
ls_time = Mid(as_datetime, 13, 8) // "hh:mm:ss"	

// Extraer los componentes de la fecha (año, mes, día)
ls_year = Left(ls_date, 4)
ls_month = Mid(ls_date, 6, 2)
ls_day = Right(ls_date, 2)

// Reordenar la fecha a "dd-mm-yyyy"
ls_date = ls_day + "-" + ls_month + "-" + ls_year

// Concatenar la fecha y la hora en un formato reconocido por PowerBuilder
ls_full_datetime = ls_date + " " + ls_time

// Intentar convertir la cadena a datetime
ldt_datetime = DateTime(ls_full_datetime)

Return ldt_datetime
end function

public function boolean of_delete (string as_sql, any aa_values[]);String  ls_method
Boolean lb_result

ls_method = "Delete"

lb_result = of_Execute(ls_method, as_sql, aa_values[])

Return lb_result
end function

public function boolean of_update (string as_sql, any aa_values[]);String  ls_method
Boolean lb_result

ls_method = "Update"

lb_result = of_Execute(ls_method, as_sql, aa_values[])

Return lb_result
end function

private function any of_execute (string as_method, string as_sql, ref any aa_values[]);String ls_SQL,  ls_encodedSQL, ls_url, ls_json, ls_response, ls_ApiVerb
Integer li_rtn, li_args, li_new, li_arg
n_JsonGenerator lnv_JsonGenerator
String ls_argnames[], ls_argdatatypes[]
Any la_values[], la_Null[]
Any la_result

li_args=UpperBound(aa_values[])

//1- Retocamos SQL recibido y lo Codificamos
ls_SQL = this.of_GetSql(as_sql)
ls_encodedSQL = this.of_encode(ls_SQL)

//2- Preparamos JSOn con el SQL y los Argumentos.
li_new = 1
ls_argnames[li_new]="sqlEncoded"
ls_argdatatypes[li_new]="string"
la_values[li_new]=ls_encodedSQL

For li_arg = 1 To li_Args
	li_new ++
	ls_argnames[li_new]="param"+string(li_arg)
	ls_argdatatypes[li_new]=ClassName(aa_values[li_arg])
	la_values[li_new]=aa_values[li_arg]
Next
	
lnv_JsonGenerator = Create n_JsonGenerator
ls_json = lnv_JsonGenerator.of_set_arguments(ls_argnames[], ls_argdatatypes[], la_values[])
Destroy lnv_JsonGenerator

//3- En función del Método recibido haremos la llamada a la API
Choose Case as_method
	Case  "Insert"
		ls_ApiVerb="POST"
		ls_url =  gn_api.of_get_url(is_Controller, as_method)
		li_rtn = gn_api.of_Post(ls_url, ls_Json, ref ls_response)
		//Retorna el id, si la tabla tiene autonumeric, si no tiene 0, -1 si hay error
		la_result = long(ls_response)
	Case  "Update"
		ls_ApiVerb="PATCH"
		ls_url =  gn_api.of_get_url(is_Controller, as_method)
		li_rtn = gn_api.of_Patch(ls_url, ls_Json, ref ls_response)
		If ls_response = "true" Then
			la_result = True
		Else	
			la_result = False
		End If	
	Case "Delete"
		ls_ApiVerb= "DELETE"
		ls_url =  gn_api.of_get_url(is_Controller, as_method)
		li_rtn = gn_api.of_Delete(ls_url, ls_Json, ref ls_response)
		If ls_response = "true" Then
			la_result = True
		Else	
			la_result = False
		End If	
	Case  "SelectInto"
		ls_ApiVerb="POST"
		ls_url =  gn_api.of_get_url(is_Controller, as_method)
		li_rtn = gn_api.of_Post(ls_url, ls_Json, ref ls_response)
		//Retorna Json Con Variables del Select Into
		If li_rtn =1 Then la_result[] = of_json_to_array(ls_response)
End Choose
	
If li_rtn < 0 Then
	SetNull(la_result)
	gf_mensaje(ls_ApiVerb + " Request Error "+string(li_rtn), gn_api.of_get_error_text())
End If	

aa_values[] = la_Null[]
Return la_result
end function

public function long of_insert (string as_sql, any aa_values[]);String  ls_method
Long ll_result

ls_method = "Insert"

ll_result = of_Execute(ls_method, as_sql, aa_values[])

Return ll_result
end function

private function string of_getsql (string as_sql);String ls_sql

// Get SELECT statement
ls_sql = Trim(as_sql)

ls_sql =  gf_replaceall(ls_sql, ":", "@")

//Cambio los Tabuladores por un espacio
ls_sql =  gf_replaceall(ls_sql, "~t", " ")

//Quitamos los saltos de linea y pongo un espacio
ls_sql =  gf_replaceall(ls_sql, "~r~n", " ")

//Remplazamos los Espacios en Blanco Inecesarios
Do While Pos(ls_sql, "  ") > 0
	ls_sql =  gf_replaceall(ls_sql, "  ", " ")
Loop	

//Si quedal algun espacio al final lo quito.
If Right(ls_sql, 1) = " "  Then ls_sql = Mid(ls_sql, 1, Len(ls_sql) - 1)

//Api Log
SetProfileString (gs_fichero_ini, "ApiLog", "LastSQL", ls_sql)

Return ls_sql
end function

private function any of_json_to_array (string as_json);String ls_error
jsonparser lnv_jsonparser
Long ll_root, ll_Index, ll_item, ll_object
String ls_key, ls_type
Any la_values[]
String ls_value
Double ld_value
Boolean lb_value
any la_null

SetNull(la_null)

// Crear instancia de JSONParser
lnv_jsonparser = create jsonparser

// Cargar los datos JSON
ls_error = lnv_jsonparser.loadstring(as_json)

If len(trim(ls_error)) > 0 then
    gf_mensaje("Error", "Fallo al cargar JSON: " + ls_error)
    Return ""
End If

// Obtener el handle del item raíz
ll_root = lnv_jsonparser.GetRootItem()

ll_object = lnv_jsonparser.GetChildItem(ll_root, 1)

// Parsear cada item en la fila
For ll_Index = 1 To lnv_jsonparser.GetChildCount(ll_object)
	// Obtener el handle y la clave de cada item
	ll_item = lnv_jsonparser.GetChildItem(ll_object, ll_Index)
	ls_key = lnv_jsonparser.GetChildKey(ll_object, ll_Index)
	
	Choose Case lnv_jsonparser.GetItemType(ll_item)
		Case JsonNullItem! 
			la_values[ll_Index]=la_null
		Case JsonBooleanItem! 
			lb_value = lnv_jsonparser.GetItemBoolean(ll_item)
			la_values[ll_Index]= lb_value
		Case JsonNumberItem!
			ld_value = lnv_jsonparser.GetItemNumber(ll_item)
			la_values[ll_Index]= ld_value
		Case JsonStringItem!
			ls_value = lnv_jsonparser.GetItemString(ll_item)
			If isnumber(ls_value) Then
				If Pos(ls_value, ".") > 0 Then
					la_values[ll_Index] = Dec(gf_replaceall(ls_value, ".", ","))
				Else
					la_values[ll_Index]= long(ls_value)
				End If	
			Else
				la_values[ll_Index]= of_string_to_datetime(char(34)+ls_value+char(34))
				If IsNull(la_values[ll_Index])  Then	la_values[ll_Index] = ls_value
			End if	
		Case Else
			la_values[ll_Index]=la_null
	End Choose
Next		  
  
Return  la_values[]
end function

public function any of_selectinto (string as_sql, any aa_values[]);String  ls_method
any la_result[]

ls_method = "SelectInto"

la_result[] = of_Execute(ls_method, as_sql, aa_values[])

Return la_result[] 
end function

on n_cst_sqlexecutor.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_sqlexecutor.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

