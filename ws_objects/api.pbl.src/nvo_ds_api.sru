$PBExportHeader$nvo_ds_api.sru
forward
global type nvo_ds_api from u_ds
end type
end forward

global type nvo_ds_api from u_ds
end type
global nvo_ds_api nvo_ds_api

type variables
Private string is_controller = "Datawindow"
Private any ia_values[]
Private String is_dsargnames[], is_dsargdatatypes[]

end variables

forward prototypes
public function integer of_getarguments (ref string as_argnames[], ref string as_argdatatypes[])
public subroutine of_setarguments (string as_argnames[], string as_argdatatypes[], any aa_argvalues[])
private function string of_encode (string as_source)
public function long of_retrieve (any a_values[])
public function string of_get_syntax ()
public function long of_cargar (string as_sql)
private function string of_create_syntax (string as_column[], string as_types[], string as_longitud[])
private function long of_get_json_schema (string as_json, ref string as_columns[], ref string as_types[], ref string as_lens[])
end prototypes

public function integer of_getarguments (ref string as_argnames[], ref string as_argdatatypes[]);string       ls_dsargs, ls_dsargswithtype[], ls_args[], ls_types[]
long         ll_a, ll_args, ll_pos, ll_index

// Comprobamos Si hay Asignado un Datawindow
//if IsNull(this.dataobject) or this.dataobject="" then
//   return -1
//end if

// Obtenemos el string con los argumentos del dw o ds.
ls_dsargs = this.DYNAMIC Describe ( "DataWindow.Table.Arguments" ) 

// Separamos los argumentos utilizando la un array y obtenemos el número total.
ll_args = gf_ParseToArray ( ls_dsargs, "~n", ls_dsargswithtype ) 

// Ahora separamos el nombre del argumento de su tipo.
For ll_a = 1 to ll_args
   ll_pos = Pos ( ls_dsargswithtype[ll_a], "~t", 1 )

   If ll_pos > 0 Then
      ll_index = UpperBound(as_argnames) + 1
      as_argNames[ll_index]      = Left ( ls_dsargswithtype[ll_a], ll_pos - 1 ) 
      as_argDataTypes[ll_index] = Mid ( ls_dsargswithtype[ll_a], ll_pos + 1 ) 
      // Cargamos el valor correspondiente. Si es de tipo array ponemos cadena vacía.
			//If right(as_argDataTypes[ll_index], 4) = 'list' Then
			//	as_argValues[ll_index] = ''
			//Else
				//as_argValues[ll_index] =this.DYNAMIC Describe("evaluate('" + as_argNames[UpperBound(as_argnames)] + "',1)") 
			//End If
	End If
Next

Return UpperBound(as_argNames)

end function

public subroutine of_setarguments (string as_argnames[], string as_argdatatypes[], any aa_argvalues[]);string      ls_object, ls_objects, ls_type, ls_expression
string      ls_value, ls_aux
integer     li_len, li_to, li_from, li_x, li_pos

// Obtenemos la colección de objetos de ds.
ls_objects = this.describe('datawindow.objects')

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
         ls_type = this.describe(ls_object + '.type')
         
         // Solo si es computado comprobamos si su expresión contiene "retrieval arguments".
         If ls_type = "compute" Then
            ls_expression = this.describe(ls_object + '.expression')
            
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
            If ls_expression <> this.describe(ls_object + '.expression') Then

               // Antes de hacer el modify, hay que añadir delante de las comillas dobles la virgulilla.
               li_pos = pos(ls_expression, '"')
               do while li_pos > 0
                  ls_expression = replace(ls_expression, li_pos, 0, "~~")
                  li_pos = pos(ls_expression, '"', li_pos + 2)
               Loop
               
               ls_aux = this.Modify(ls_object + ".expression=~"" + ls_expression + "~"")
               
            End If
         End If
      End If
      
      li_from = li_to + 1
   Loop While (li_to > 0)
End If
end subroutine

private function string of_encode (string as_source);String ls_Select
String ls_encoded
n_cst_coderobject ln_coder 

ln_coder =  CREATE n_cst_coderobject

ls_encoded = ln_coder.of_encode(as_source)

Destroy ln_coder

RETURN ls_encoded
end function

public function long of_retrieve (any a_values[]);Long ll_RowCount
String ls_url, ls_ApiVerb
Any la_Array[]
String ls_Json, ls_jsonReceived
n_JsonGenerator lnv_JsonGenerator
String ls_Syntax, ls_encodedSyntax
String ls_argnames[], ls_argdatatypes[]
Any l_values[], l_null[]
Integer li_value, li_TotalValues, li_result, li_new

Reset()

IF DataObject = "" THEN
	gf_mensaje("Datastore Api Error", "¡ No hay DataObject asignado al Datastore !")
	RETURN -1
END IF	

li_TotalValues=UpperBound(a_values[])

ls_Syntax = this.of_Get_Syntax()

If ls_Syntax = "" then return -1


ls_encodedSyntax = of_encode(ls_Syntax)
		
li_new = 1
ls_argnames[li_new]="sqlEncoded"
ls_argdatatypes[li_new]="string"
l_values[li_new]=ls_encodedSyntax
	
li_result= of_getarguments (ref is_dsargnames[], ref is_dsargdatatypes[])
	
IF li_result > li_TotalValues THEN
	gf_mensaje("Json Error", "Expecting "+string(li_result)+" retrieval arguments but got "+string(li_TotalValues)+".")
	RETURN -1
END IF	
	
//Imitando el fucnionamiento de los DataStore
//Si le paso mas argumentos de los admitidos ignoro los que sobran.
//Esto es util por si a los reports les añades argumentos
IF li_result < li_TotalValues THEN
	li_TotalValues = li_result	
END IF	
	
FOR li_value = 1 to li_TotalValues
	li_new ++
	ls_argnames[li_new]=is_dsargnames[li_value]
	ls_argdatatypes[li_new]=is_dsargdatatypes[li_value]
	l_values[li_new]=a_values[li_value]
NEXT	
	
lnv_JsonGenerator = Create n_JsonGenerator
ls_json = lnv_JsonGenerator.of_set_arguments(ls_argnames[], ls_argdatatypes[], l_values[])
Destroy lnv_JsonGenerator

ls_ApiVerb = "POST"
ls_url =  gn_api.of_get_url(is_Controller, "Retrieve")
	
gn_api.of_Post(ls_url, ls_Json, ref ls_jsonReceived)
ll_RowCount = ImportJson(ls_jsonReceived)

IF ll_RowCount < 0 THEN
	gf_mensaje(ls_ApiVerb + " Request Error "+string(ll_RowCount), gn_api.of_get_error_text())
END IF


//Recargo los Retrieval Argument por si se usan en funciones o otras cosas.
of_setarguments(is_dsargnames[], is_dsargdatatypes[], a_values[])

ResetUpdate()
ia_values[] = a_values[] //Guardo los valores	
a_values[] = l_null[]
is_dsargnames[] = l_null[]
is_dsargdatatypes[] = l_null[]

This.Event Retrieveend(ll_RowCount)
RETURN ll_RowCount
end function

public function string of_get_syntax ();String ls_dwsyntax, ls_select

If This.Dataobject="" Then Return ""

ls_dwsyntax = This.Object.DataWindow.Syntax

//Api Log----------------------------------------------------------------------------------------
ls_select = This.Describe("DataWindow.Table.Select")

ls_Select =  gf_replaceall(ls_Select, ":", "@")
	
//Cambio los Tabuladores por un espacio
ls_Select =  gf_replaceall(ls_Select, "~t", " ")

//Quitamos los saltos de linea y pongo un espacio
ls_Select =  gf_replaceall(ls_Select, "~r~n", " ")
	
//Remplazamos los Espacios en Blanco Inecesarios
DO WHILE POS(ls_Select, "  ") > 0
	ls_Select =  gf_replaceall(ls_Select, "  ", " ")
LOOP	
	
//Si quedal algun espacio al final lo quito.
IF right(ls_Select, 1) = " "  THEN ls_select = Mid(ls_Select, 1, len(ls_select) - 1)
	
SetProfileString (gs_fichero_ini, "ApiLog", "LastSQL", ls_select)
//-----------------------------------------------------------------------------------------------

RETURN ls_dwsyntax
end function

public function long of_cargar (string as_sql);String ls_url, ls_ApiVerb
 n_JsonGenerator lnv_JsonGenerator
String  ls_json, ls_jsonreceived
String ls_encodedSQL
String ls_argnames[], ls_argdatatypes[]
Any l_values[]
Integer li_value, li_TotalValues, li_result, li_new
String ls_columns[], ls_types[], ls_lens[]
Long ll_columnas, ll_RowCount
String ls_DwSyntax
Integer li_rtn

//1- Codificamos SQL recibido en Base64
SetPointer(HourGlass!)
ls_encodedSQL = of_encode(as_sql)
	
//2- Preparamos Json con SQL y Argumentos del Datastore	
li_new = 1
ls_argnames[li_new]="sqlEncoded"
ls_argdatatypes[li_new]="string"
l_values[li_new]=ls_encodedSQL

lnv_JsonGenerator = Create n_JsonGenerator
ls_json = lnv_JsonGenerator.of_set_arguments(ls_argnames[], ls_argdatatypes[], l_values[])
Destroy lnv_JsonGenerator
	
//3- Preparamos URL y hacemos llamada a la Api	
ls_ApiVerb = "POST"
ls_url =  gn_api.of_get_url(is_Controller, "Cargar")
gn_api.of_Post(ls_url, ls_Json, ref ls_jsonReceived)

//4- Obtenemos la definición de las columnas del Json recibido
ll_columnas = of_get_json_schema(ls_jsonReceived, ref ls_columns[], ref ls_types[], ref ls_lens[])

If ll_Columnas = 0 Then
	gf_mensaje("Error", "¡ No se ha Detectado Ninguna columna del Json !")
	Return -1
End IF

//5- Generamos la Sintaxis del Datastore
ls_DwSyntax = of_create_syntax(ls_columns[], ls_types[], ls_lens[])

If ls_DwSyntax = "" Then
	gf_mensaje("Error", "¡ Error Generando Syntaxy del Datastore !")
	Return -1
End IF

//6- Creamos el Objeto a partir de la Sintaxis
li_rtn =This.Create(ls_dwSyntax)

If li_rtn <> 1 Then
	gf_mensaje("Error", "¡ Error Asignando Syntaxy del Datastore !")
	Return -1
End IF

//7- Importamos el Json recibido
ll_RowCount = THIS.ImportJson(ls_jsonReceived)
		
IF ll_RowCount < 0 THEN
	gf_mensaje(ls_ApiVerb + " Request Error "+string(ll_RowCount), gn_api.of_get_error_text())
END IF
	
Return ll_RowCount
end function

private function string of_create_syntax (string as_column[], string as_types[], string as_longitud[]);// Crea un objeto de tipo DataWindow externo
DataWindowChild ldwc
string ls_dwSyntax
Long ll_TotalColumnas
Integer li_col, li_rc
String ls_columnName, ls_columnType, ls_columnLength

ll_TotalColumnas = UpperBound(as_column)

// Inicializa el DataWindow dinámico como un DataWindow externo
ls_dwSyntax = "release 22;"+char(13)+&
"datawindow(units=0 data.export.format=1 timer_interval=0 color=1073741824 brushmode=0 transparency=0 gradient.angle=0 gradient.color=8421504 gradient.focus=0 gradient.repetition.count=0 gradient.repetition.length=100"+&
" gradient.repetition.mode=0 gradient.scale=100 gradient.spread=100 gradient.transparency=0 picture.blur=0 picture.clip.bottom=0 picture.clip.left=0 picture.clip.right=0 picture.clip.top=0 picture.mode=0 picture.scale.x=100"+&
" picture.scale.y=100 picture.transparency=0 processing=1 HTMLDW=no print.printername='' print.documentname='' print.orientation = 0 print.margin.left = 110 print.margin.right = 110 print.margin.top = 96 print.margin.bottom = 96"+&
" print.paper.source = 0 print.paper.size = 0 print.canusedefaultprinter=yes print.prompt=no print.buttons=no print.preview.buttons=no print.cliptext=no print.overrideprintjob=no print.collate=yes print.background=no"+&
" print.preview.background=no print.preview.outline=yes hidegrayline=no showbackcoloronxp=no picture.file='' grid.lines=0 selected.mouse=no)"+char(13)+&
"header(height=80 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"summary(height=0 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"footer(height=0 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"detail(height=80 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"table("

// Ajuste de posición inicial
Long ll_x_position
integer li_column_width = 485
integer li_column_height = 72
string ls_format, ls_alignment


// Recorre el array deserializado y construye las columnas del DataWindow
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
    ls_columnType = Lower(as_types[li_col]) // Asegurar que el tipo esté en minúsculas
    ls_columnLength = as_longitud[li_col]

    // Validar longitud, si es vacío o nulo, asignar un valor por defecto (p.ej., 50)
    IF IsNull(ls_columnLength) OR ls_columnLength = "" THEN
        ls_columnLength = "50"
    END IF

    // Determina el tipo de dato de PowerBuilder
    CHOOSE CASE ls_columnType
        CASE "integer", "byte", "number"
         	   ls_dwSyntax += "column=(type=number updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "long"
			 ls_dwSyntax += "column=(type=long updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 	
        CASE "char", "string"
			 ls_dwSyntax += "column=(type=char("+ls_columnLength+") updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "date"
			ls_dwSyntax += "column=(type=date updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "datetime"
             ls_dwSyntax += "column=(type=datetime updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "time" 
			  ls_dwSyntax += "column=(type=time updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
        CASE "decimal"
			 if ls_columnLength = "Null" then ls_columnLength = "2"
           	 ls_dwSyntax += "column=(type=Decimal("+ls_columnLength+") updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
          CASE ELSE
            gf_mensaje("Error", "Tipo de dato desconocido: " + ls_columnType)
            RETURN ""
    END CHOOSE

NEXT

ls_dwSyntax += ")"+char(13) 

//COLUMNAS
ll_x_position = 0  // Coordenada inicial de la primera fila
// Recorre el array deserializado y construye las columnas del DataWindow
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
	ls_columnLength = as_longitud[li_col]
	ls_columnType = Lower(as_types[li_col]) // Asegurar que el tipo esté en minúsculas

    // Validar longitud, si es vacío o nulo, asignar un valor por defecto (p.ej., 50)
    IF IsNull(ls_columnLength) OR ls_columnLength = "" THEN
        ls_columnLength = "50"
    END IF
	 
	 CHOOSE CASE ls_columnType
		CASE  "decimal"
			 li_column_width = 485
			 ls_format="###,###,###,##0.00"
			 ls_alignment="1"
		CASE "integer", "byte", "long"
			 li_column_width = 485
			ls_format="[general]"
      		 ls_alignment="1"
		CASE "char", "string"
			 li_column_width = 485
			//li_column_width= integer(ls_columnLength) * 30
			//if 	li_column_width > 1600 then li_column_width =1600
			ls_format="[general]"
			ls_alignment="0"
		CASE  "date",  "datetime"
			 li_column_width = 485
			 ls_format="dd-mm-yy"
			 ls_alignment="2"
		CASE  "time"
			 li_column_width = 485
			 ls_format="hh:mm:ss"
			 ls_alignment="2"	 
	END CHOOSE

     ls_dwSyntax += "column(band=detail id="+ String(li_col) +" alignment='"+ls_alignment+"' tabsequence="+ String(32766) +" border='0' color='0'  x='" + String(ll_x_position) + "' y='4' height='" + String(li_column_height) + "' width='" + String(li_column_width) + "' format='"+ls_format+"' html.valueishtml='0'  name="+ls_columnName+" visible='1' edit.limit=0 edit.case=any edit.focusrectangle=no edit.autoselect=yes edit.autohscroll=yes  font.face='Tahoma' font.height='-10' font.weight='400'  font.family='2' font.pitch='2' font.charset='0' background.mode='1' background.color='536870912' background.transparency='0' background.gradient.color='8421504' background.gradient.transparency='0' background.gradient.angle='0' background.brushmode='0' background.gradient.repetition.mode='0' background.gradient.repetition.count='0' background.gradient.repetition.length='100' background.gradient.focus='0' background.gradient.scale='100' background.gradient.spread='100' tooltip.backcolor='134217752' tooltip.delay.initial='0' tooltip.delay.visible='32000' tooltip.enabled='0' tooltip.hasclosebutton='0' tooltip.icon='0' tooltip.isbubble='0' tooltip.maxwidth='0' tooltip.textcolor='134217751' tooltip.transparency='0' transparency='0' )"+char(13)

    // Incrementa la posición X para la siguiente columna
    ll_x_position += li_column_width 
NEXT

//ETIQUETAS TEXTO:
ll_x_position = 0  
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
	 
   	 ls_dwSyntax += "text(band=header alignment='2' text='"+ls_columnName+"' border='0' color='0' x='" + String(ll_x_position) + "' y='4' height='" + String(li_column_height) + "' width='" + String(li_column_width) +"' html.valueishtml='0'  name="+ls_columnName+"_t visible='1'  font.face='Tahoma' font.height='-10' font.weight='400'  font.family='2' font.pitch='2' font.charset='0' background.mode='1' background.color='536870912' background.transparency='0' background.gradient.color='8421504' background.gradient.transparency='0' background.gradient.angle='0' background.brushmode='0' background.gradient.repetition.mode='0' background.gradient.repetition.count='0' background.gradient.repetition.length='100' background.gradient.focus='0' background.gradient.scale='100' background.gradient.spread='100' tooltip.backcolor='134217752' tooltip.delay.initial='0' tooltip.delay.visible='32000' tooltip.enabled='0' tooltip.hasclosebutton='0' tooltip.icon='0' tooltip.isbubble='0' tooltip.maxwidth='0' tooltip.textcolor='134217751' tooltip.transparency='0' transparency='0' )"+CHAR(13)

    // Incrementa la posición X para la siguiente columna
    ll_x_position += li_column_width  
NEXT

ls_dwSyntax +="htmltable(border='1' )"+char(13)+&
"htmlgen(clientevents='1' clientvalidation='1' clientcomputedfields='1' clientformatting='0' clientscriptable='0' generatejavascript='1' encodeselflinkargs='1' netscapelayers='0' pagingmethod=0 generatedddwframes='1' )"+char(13)+&
"xhtmlgen() cssgen(sessionspecific='0' )"+char(13)+&
"xmlgen(inline='0' )"+char(13)+&
"xsltgen()"+char(13)+&
"jsgen()"+char(13)+&
"export.xml(headgroups='1' includewhitespace='0' metadatatype=0 savemetadata=0 )"+char(13)+&
"import.xml()"+char(13)+&
"export.pdf(method=2 distill.custompostscript='0' nativepdf.customsize=0 nativepdf.customorientation=0 nativepdf.pdfstandard=0 nativepdf.useprintspec=no )"+char(13)+&
"export.xhtml()"

// Muestra la sintaxis generada para depurar
ls_dwSyntax  =gf_replaceall(ls_dwSyntax, "'", '"')


RETURN ls_dwSyntax
end function

private function long of_get_json_schema (string as_json, ref string as_columns[], ref string as_types[], ref string as_lens[]);String ls_Json, ls_Type, ls_value, ls_key, ls_len
Long ll_ChildCount, ll_ArrayItem, ll_ObjectItem
JsonParser lnv_JsonParser
Long ll_columna
DateTime ldt_parse
Date lda_parse
Time lt_parse
Dec ld_parse
Long ll_parse
Long ll_Row, ll_RowCount

//El Formato Esperado sera una Array de Josn, donde caja json sera cada fila

lnv_JsonParser = Create JsonParser

ls_json = as_json

// Loads a JSON string
lnv_JsonParser.LoadString(ls_Json)
ll_ArrayItem = lnv_JsonParser.GetRootItem() // Root item is JsonArrayItem!
ll_ChildCount = lnv_JsonParser.GetChildCount(ll_ArrayItem)
		
 // Gets the array item
 ll_ObjectItem = lnv_JsonParser.GetChildItem(ll_ArrayItem, 1)
 
  If lnv_JsonParser.GetItemType(ll_ObjectItem) <>  JsonObjectItem! Then
	gf_mensaje("Json Schema", "¡ Formato Esperado es una Array de Json !")
	Return -1
  End If	
  

 // Obtiene la cantidad de hijos (pares clave-valor) del objeto JSON
  ll_RowCount = lnv_JsonParser.GetChildCount(ll_ObjectItem)
  
  For ll_Row = 1 To ll_RowCount
	ls_value=""
	ls_Type=""
	ls_len=""
	
	ls_key = lnv_JsonParser.GetChildKey(ll_ObjectItem, ll_Row)
 
	   ll_columna ++
	 as_columns[ll_columna] = ls_key
	 
		 
	  Choose Case lnv_JsonParser.GetItemType(ll_ObjectItem, ls_key)
		  Case JsonStringItem!, JsonNullItem!
				ls_Type = "string"
				ls_len="1033"
	
		  Case JsonNumberItem!
				
			ld_parse = 	lnv_JsonParser.GetItemDecimal(ll_ObjectItem, ls_key)
			 
			If Not Isnull(ld_parse) Then
				ls_value = string(ld_parse)
				ls_Type = "decimal"
				ls_len="4"	
			 End if	
			
			If ls_Type = "" Then
				  ll_parse = lnv_JsonParser.GetItemNumber(ll_ObjectItem, ls_key)
				  ls_value = string(ll_parse)
				  ls_Type = "number"
				  ls_len=""	
			End if
		  Case JsonBooleanItem!
				  ls_value = string(lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key))
			  ls_Type ="number"
				ls_len=""
			  If lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key) = True Then
				ls_value = "1"
			  Else
				ls_value = "0"
			  End if	
		Case JsonObjectItem!
			// Type of the JSON node whose key value pair is an object, such as "date_object":{"datetime":7234930293, "date": "2017-09-21", "time": "12:00:00"}.
			ls_value = lnv_JsonParser.GetItemObjectJSONString (ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"	
		Case JsonArrayItem! 
			//Type of the JSON node whose key value pair is an array, such as "department_array":[999999, {"name":"Website"}, {"name":"PowerBuilder"}, {"name":"IT"}].
			ls_value = lnv_JsonParser.GetItemArrayJSONString(ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"
	End Choose
	
		 as_types[ll_columna]=ls_Type
		 as_lens[ll_columna] = ls_len
	Next	 


Return UpperBound(as_columns[])
end function

on nvo_ds_api.create
call super::create
end on

on nvo_ds_api.destroy
call super::destroy
end on

