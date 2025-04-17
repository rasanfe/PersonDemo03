$PBExportHeader$n_jsongenerator.sru
forward
global type n_jsongenerator from jsongenerator
end type
end forward

global type n_jsongenerator from jsongenerator
end type
global n_jsongenerator n_jsongenerator

forward prototypes
public function string of_set_arguments (string as_argnames[], string as_argdatatypes[], any aa_values[])
end prototypes

public function string of_set_arguments (string as_argnames[], string as_argdatatypes[], any aa_values[]);String ls_json
String ls_argname, ls_argdatatype
Integer li_TotalArguments, li_argument
Long ll_RootObject, ll_Child
String ls_valuedatatype
Any la_value
Long ll_types, lla_values
//Array List
Long ll_ChildArray
String ls_item
String ls_List[]
Integer li_TotalArrayList, li_List
  
li_TotalArguments = UpperBound(as_argnames[])
ll_types = UpperBound(as_argdatatypes[])
lla_values = UpperBound(aa_values[])

If lla_values <> li_TotalArguments Or lla_values <> ll_types Or  li_TotalArguments <> ll_types Then
	gf_mensaje("Error JsonGenerator", "¡El Numero de Párametros no coincide!")
	Return ""
End if	

ll_RootObject = CreateJsonObject()
	
If ll_RootObject = -1 Then 
	gf_mensaje("Error JsonGenerator", "¡Error de Inicio Json!")
	Return ""
End If

For li_argument = 1 To li_TotalArguments 
	
	ls_argname = as_argnames[li_argument]

	ls_argdatatype= as_argdatatypes[li_argument]
	
	If IsNull(ls_argdatatype) Then ls_argdatatype = ""
	
	la_value = aa_values[li_argument]
	
	//Limpio el Nombre de Los Agrumentos Para que sea mas elegante el Json
	If gf_iin(left(ls_argname, 4), {"arg_", "adt_", "ada_"}) Then
		ls_argname = Mid(ls_argname, 5, Len(ls_argname) - 4)
	Else	
		If gf_iin(Left(ls_argname, 3), {"as_", "ai_", "ad_", "al_"}) Then
			ls_argname = Mid(ls_argname, 4, Len(ls_argname) - 3)
		End If
	End If
	
	Choose Case Lower(ls_argdatatype)
		Case ""
			ll_Child = AddItemNull (ll_RootObject, ls_argname )	
		Case "string",  "char"
				If Not IsNull(la_value) Then
					ll_Child = AddItemString(ll_RootObject, ls_argname, la_value)
				Else
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				End If
		Case "number", "integer","int", "double", "decimal" ,"dec", "longlong", "long", "real"
				If Not IsNull(la_value) Then
					ll_Child = AddItemNumber(ll_RootObject, ls_argname, la_value)
				Else
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				End If
		Case "datetime"
				If Not IsNull(la_value) Then
					ll_Child = AddItemDatetime(ll_RootObject, ls_argname, la_value)
				Else
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				End If
		Case "date"
				If Not IsNull(la_value) Then
					ll_Child = AddItemDate(ll_RootObject, ls_argname, la_value)
				Else
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				End If	
		Case "time"
				If Not IsNull(la_value) Then 
					ll_Child = AddItemTime(ll_RootObject, ls_argname, la_value)	
				Else
					ll_Child = AddItemNull (ll_RootObject, ls_argname )
				End If
		Case "stringlist",  "decimallist", "numberlist", "datetimelist", "datelist", "timelist"   
							
			li_TotalArrayList = gf_parsetoarray(string(la_value), ",", ref ls_List[]) 
			
			ll_ChildArray =AddItemArray(ll_RootObject, ls_argname)
						
			For li_List = 1 to li_TotalArrayList
				ls_item = ls_List[li_List]
				ll_child = AddItemString(ll_ChildArray, ls_item)
			Next
			
		Case Else
			gf_mensaje("Error JsonGenerator", "Tipo de dato desconocido: " + ls_argdatatype)
			Return ""
	End Choose
Next

// Generar el JSON como string
 ls_Json =This.GetJsonString()
 
 If isnull(ls_Json) Or trim(ls_Json) = "" Then
	gf_mensaje("Error JsonGenerator", "¡ Error Generando Json String !")
 End IF

 // Retornar el JSON generado
 Return ls_Json
end function

on n_jsongenerator.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_jsongenerator.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

